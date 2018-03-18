public with sharing class SubscriptionOrderBatch implements Database.Batchable<sObject>{

    private Date daySubscription;

    public SubscriptionOrderBatch() {
        this.daySubscription = Date.today();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Active__c, Order_Repeat__c, Frequency__c, Start_Date__c, Stop_Date__c, ' +
            'Count__c, Stop_Count__c, Stop_On__c, Account__c, Charge_Amount__c, Paused__c, Unpause_Date__c, ' +

            '(SELECT Id, Subtotal__c, Subscription_Approved_Charges_Count__c, Total__c, Subscription_Remains_Amount__c, ' +
            'Amount_To_Charge__c, Date__c FROM Subscription__c.Orders__r ' +
            'WHERE Status__c != \'Error\' ORDER BY Date__c DESC LIMIT 1), ' + 

            '(SELECT Id, Order__c, Amount__c, Date__c, Remaining_Retries__c, ' +
            'Status__c FROM Subscription__c.Payment_Attempts__r WHERE Status__c != \'Retry\' ORDER BY Date__c DESC) ' +

            'FROM Subscription__c ' +
            'WHERE Active__c = true AND Start_Date__c >= TODAY';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Subscription__c> subscriptionRecords = (List<sObject>) scope;
        List<Order__c> ordersToInsert = new List<Order__c>();
        List<List<OrderItem__c>> newOrderItemsLists = new List<List<OrderItem__c>>();
        List<Payment_Attempt__c> newOrderPaymentAttempts = new List<Payment_Attempt__c>();

        //Subscription__c.Order_Repeat__c == true - create orders
        for (Subscription__c item : subscriptionRecords) {
            if (item.Orders__r.size() == 0 || !item.Order_Repeat__c) {
                continue;
            }

            Datetime lastOrderDate = item.Orders__r[0].Date__c;
            Boolean needOrder = false;

            if (item.Frequency__c == 'Daily') {
                if (Date.today() >= lastOrderDate.addDays(1).date()) {
                    needOrder = true;
                }
            } else if (item.Frequency__c == 'Weekly') {
                if (Date.today() >= lastOrderDate.addDays(7).date()) {
                    needOrder = true;
                }
            } else if (item.Frequency__c == 'Monthly') {
                if (Date.today() >= lastOrderDate.addMonths(1).date()) {
                    needOrder = true;
                }
            } else if (item.Frequency__c == 'Quarterly') {
                if (Date.today() >= lastOrderDate.addMonths(3).date()) {
                    needOrder = true;
                }
            } else if (item.Frequency__c == 'Annual') {
                if (Date.today() >= lastOrderDate.addYears(1).date()) {
                    needOrder = true;
                }
            }

            if (item.Paused__c) {
                if (item.Unpause_Date__c <= Date.today()) {
                    item.Paused__c = false;
                } else {
                    needOrder = false;
                }
            }

            if (needOrder) {
                item.Count__c = item.Count__c != null ? item.Count__c + 1 : 2;

                if (item.Stop_On__c == 'First') {
                    item.Active__c = false;
                } else if (item.Stop_On__c == 'Count') {
                    item.Active__c = item.Count__c < item.Stop_Count__c;
                } else if (item.Stop_On__c == 'Date') {
                    item.Active__c = item.Stop_Date__c < Date.today();
                }

                Order__c newOrder = cloneOrder(item.Orders__r[0].Id);
                List<OrderItem__c> newOrdeItems = cloneOrderItems(item.Orders__r[0].Id);

                item.Orders__r[0] = newOrder;

                ordersToInsert.add(newOrder);
                newOrderItemsLists.add(newOrdeItems);

                Payment_Attempt__c paymentAttempt = new Payment_Attempt__c(
                    Remaining_Retries__c = 3, 
                    Amount__c = item.Charge_Amount__c,
                    Retries_Interval__c = 3
                );
                paymentAttempt.Date__c = Date.today();
                newOrderPaymentAttempts.add(paymentAttempt);
            }
        }

        update subscriptionRecords;

        if (!ordersToInsert.isEmpty()) {
            List<Database.SaveResult> srListOrders = Database.insert(ordersToInsert);

            List<OrderItem__c> orderItemsToInsert = new List<OrderItem__c>();

            for (Integer i = 0; i < ordersToInsert.size(); i++) {
                for (OrderItem__c item : newOrderItemsLists.get(i)) { 
                    item.Order__c = ordersToInsert.get(i).Id; 
                    orderItemsToInsert.add(item);
                }
                newOrderPaymentAttempts.get(i).Order__c = ordersToInsert.get(i).Id;
            }

            List<Database.SaveResult> srListOrderItems = Database.insert(orderItemsToInsert);
        }

        List<Payment_Attempt__c> todayPaymentAttempts = new List<Payment_Attempt__c>();

        //Subscription__c.Order_Repeat__c == false - create payment attempts
        for (Subscription__c item : subscriptionRecords) {
            if (item.Orders__r.size() == 0 || item.Orders__r[0].Subscription_Remains_Amount__c == 0 || item.Order_Repeat__c) {
                continue;
            }

            Payment_Attempt__c paymentAttempt = new Payment_Attempt__c(
                Order__c = item.Orders__r[0].Id, Remaining_Retries__c = 3,
                Amount__c = item.Orders__r[0].Amount_To_Charge__c, Retries_Interval__c = 3
            );

            //Create Payment Attempt just for today or for the future
            Date startDay = item.Start_Date__c < this.daySubscription ? this.daySubscription : item.Start_Date__c;
            Date nextStartDay;

            //Date existing Payment Attempts
            Set<Date> oldAttemptsDate = new Set<Date>();
            for (Payment_Attempt__c pa : item.Payment_Attempts__r) {
                oldAttemptsDate.add(pa.Date__c);
            }

            if (item.Frequency__c == 'Daily') {
                startDay = startDay >= this.daySubscription ? startDay : this.daySubscription;
                nextStartDay = startDay == this.daySubscription ? startDay.addDays(1) : null;
            }
            if (item.Frequency__c == 'Weekly') {
                startDay = startDay >= this.daySubscription ? startDay : startDay.addDays(7);
                nextStartDay = startDay == this.daySubscription ? startDay.addDays(7) : null;
            }
            if (item.Frequency__c == 'Monthly') {
                startDay = startDay >= this.daySubscription ? startDay : startDay.addMonths(1);
                nextStartDay = startDay == this.daySubscription ? startDay.addMonths(1) : null;
            }
            if (item.Frequency__c == 'Quarterly') {
                startDay = startDay >= this.daySubscription ? startDay : startDay.addMonths(4);
                nextStartDay = startDay == this.daySubscription ? startDay.addMonths(4) : null;
            }
            if (item.Frequency__c == 'Annual') {
                startDay = startDay >= this.daySubscription ? startDay : startDay.addYears(1);
                nextStartDay = startDay == this.daySubscription ? startDay.addYears(1) : null;
            }

            if (!oldAttemptsDate.contains(startDay)) {
                if (item.Stop_On__c == 'Never') {
                    //For Today
                    paymentAttempt.Date__c = startDay;
                }
                if (item.Stop_On__c == 'First' && oldAttemptsDate.isEmpty()) {
                    //For Today
                    paymentAttempt.Date__c = startDay;
                }
                if (item.Stop_On__c == 'Count' && item.Count__c != 0 
                    && item.Orders__r[0].Subscription_Approved_Charges_Count__c < item.Count__c) {
                    //If Count != 0
                    paymentAttempt.Date__c = startDay;
                }
                if (item.Stop_On__c == 'Date' && item.Stop_Date__c >= startDay) {
                    //The last Payment Attempt for Today
                    paymentAttempt.Date__c = startDay;
                }
                if (item.Stop_On__c == 'Full Payment' && item.Orders__r[0].Subscription_Remains_Amount__c != 0) {
                    //If Amount != 0
                    paymentAttempt.Date__c = startDay;
                }
            }

            if (paymentAttempt.Date__c != null) {
                todayPaymentAttempts.add(paymentAttempt);
            }

            if ((paymentAttempt.Date__c == this.daySubscription || oldAttemptsDate.contains(startDay)) && !oldAttemptsDate.contains(nextStartDay)) {
                //how much pay
                Decimal nextAmmount = item.Orders__r[0].Subscription_Remains_Amount__c - item.Orders__r[0].Amount_To_Charge__c;
                Decimal nextAmountToCharge = nextAmmount <= item.Orders__r[0].Amount_To_Charge__c ? nextAmmount : item.Orders__r[0].Amount_To_Charge__c;

                if (nextAmountToCharge != 0) {
                    Payment_Attempt__c nextPaymentAttempt = new Payment_Attempt__c(
                        Date__c = nextStartDay, Order__c = item.Orders__r[0].Id,
                        Remaining_Retries__c = 3, Retries_Interval__c = 3
                    );

                    if (item.Stop_On__c == 'Never') {
                        nextPaymentAttempt.Amount__c = nextAmountToCharge;
                    }
                    if (item.Stop_On__c == 'Count' && (item.Orders__r[0].Subscription_Approved_Charges_Count__c + 1) < item.Count__c) {
                        nextPaymentAttempt.Amount__c = nextAmountToCharge;
                    }
                    if (item.Stop_On__c == 'Date' && item.Stop_Date__c >= nextStartDay) {
                        nextPaymentAttempt.Amount__c = nextAmountToCharge;
                    }
                    if (item.Stop_On__c == 'Full Payment') {
                        nextPaymentAttempt.Amount__c = nextAmountToCharge;
                    }

                    if (nextPaymentAttempt.Amount__c != null) {
                        todayPaymentAttempts.add(nextPaymentAttempt);
                    }
                }
            }
        }

        todayPaymentAttempts.addAll(newOrderPaymentAttempts);
        if (!todayPaymentAttempts.isEmpty()) {
            List<Database.SaveResult> srListPaymentAttempts = Database.insert(todayPaymentAttempts);
        }
    }

    public void finish(Database.BatchableContext BC) {
        SubscriptionPaymentAttemptBatch job = new SubscriptionPaymentAttemptBatch(this.daySubscription);
        Database.executeBatch(job, 1);
    }

    public Order__c cloneOrder(Id orderId) {
        List<Order__c> ordersList = [ 
            SELECT Id, OwnerId, Account__c, Brand__c, Order_Type__c, Parrent_Upsell_Order__c, 
                    Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State__c, Billing_Zip_Postal__c, 
                    Geolocation__Longitude__s, Geolocation__Latitude__s, 
                    Payment_Method__c, Charge_Amount__c, Subtotal__c, Currency__c, 
                    Shipping_First_Name__c, Shipping_Name__c, Shipping_Phone__c, Shipping_City__c, Shipping_State__c, Shipping_Zip_Postal__c, 
                    Named_Agent__c, Billing_Email__c, Billing_First_Name__c, Billing_Phone__c, Billing_Country__c, 
                    Shipping_Address__c, Shipping_Country__c, 
                    Utm_Campaign__c, Utm_Content__c, Utm_Medium__c, Utm_Source__c, Utm_Term__c, //Affiliate_Id__c, 
                    Sub_Id1__c, Sub_Id2__c, Sub_Id3__c, Sub_Id4__c, Sub_Id5__c, 
                    Order_Source__c, Coupon_Discount__c, Subscription_To__c, 
                    (SELECT Product__c, Quantity__c, Product_Price__c FROM Order_Items__r) 
            FROM Order__c 
            WHERE Id = :orderId 
        ];

        if (ordersList.size() == 0) { 
            return null; 
        } 

        Order__c oldOrder = ordersList[0]; 

            /* -------- Save new Order -------- */ 
        Order__c cOrder = new Order__c(); 
        cOrder.OwnerId = oldOrder.OwnerId; 

        cOrder.Account__c = oldOrder.Account__c; 
        cOrder.Brand__c = oldOrder.Brand__c; 
        cOrder.Order_Type__c = oldOrder.Order_Type__c; 
        cOrder.Parrent_Upsell_Order__c = oldOrder.Parrent_Upsell_Order__c; 

            /* -------- Billing Info -------- */ 
        cOrder.Billing_Last_Name__c = oldOrder.Billing_Last_Name__c; 
        cOrder.Date__c = System.now(); 

        cOrder.Billing_Address__c = oldOrder.Billing_Address__c; 
        cOrder.Billing_City__c = oldOrder.Billing_City__c; 
        cOrder.Billing_State__c = oldOrder.Billing_State__c; 
        cOrder.Billing_Zip_Postal__c = oldOrder.Billing_Zip_Postal__c; 

        cOrder.Geolocation__Longitude__s = oldOrder.Geolocation__Longitude__s; 
        cOrder.Geolocation__Latitude__s = oldOrder.Geolocation__Latitude__s; 

            /* -------- CC information -------- */ 
        cOrder.Payment_Method__c = oldOrder.Payment_Method__c; 

        cOrder.Charge_Amount__c = oldOrder.Charge_Amount__c; 
        //cOrder.Tax__c = oldOrder.Tax__c; 

            /* -------- Order Amount Infromation -------- */ 
        cOrder.Subtotal__c = oldOrder.Subtotal__c; 

        cOrder.Currency__c = oldOrder.Currency__c; 
//        cOrder = (Order__c) setCurrencyIsoCode(cOrder, currency_code); 

            /* -------- Shipping Info -------- */ 
        cOrder.Shipping_First_Name__c = oldOrder.Shipping_First_Name__c; 
        cOrder.Shipping_Name__c = oldOrder.Shipping_Name__c; 
        cOrder.Shipping_Phone__c = oldOrder.Shipping_Phone__c; 

        //TODO 
        cOrder.Shipping__c = 0; 

        cOrder.Shipping_City__c = oldOrder.Shipping_City__c; 
        cOrder.Shipping_State__c = oldOrder.Shipping_State__c; 
        cOrder.Shipping_Zip_Postal__c = oldOrder.Shipping_Zip_Postal__c; 

            /* -------- Payment Gateway Info -------- */ 
        cOrder.Named_Agent__c = oldOrder.Named_Agent__c; 

            /* -------- Required fields for MinFraud -------- */ 
        cOrder.Billing_Email__c = oldOrder.Billing_Email__c; 
        cOrder.Billing_First_Name__c = oldOrder.Billing_First_Name__c; 
        cOrder.Billing_Phone__c = oldOrder.Billing_Phone__c; 
        cOrder.Billing_Country__c = oldOrder.Billing_Country__c; 

        cOrder.Shipping_Address__c = oldOrder.Shipping_Address__c; 
        cOrder.Shipping_Country__c = oldOrder.Shipping_Country__c; 

            /* -------- UTM Info -------- */ 
        cOrder.Utm_Campaign__c = oldOrder.Utm_Campaign__c; 
        cOrder.Utm_Content__c = oldOrder.Utm_Content__c; 
        cOrder.Utm_Medium__c = oldOrder.Utm_Medium__c; 
        cOrder.Utm_Source__c = oldOrder.Utm_Source__c; 
        cOrder.Utm_Term__c = oldOrder.Utm_Term__c; 

            /* ----- For Affiliate ------ */ 
        // cOrder.Affiliate_Id__c = oldOrder.Affiliate_Id__c; 
        cOrder.Sub_Id1__c = oldOrder.Sub_Id1__c; 
        cOrder.Sub_Id2__c = oldOrder.Sub_Id2__c; 
        cOrder.Sub_Id3__c = oldOrder.Sub_Id3__c; 
        cOrder.Sub_Id4__c = oldOrder.Sub_Id4__c; 
        cOrder.Sub_Id5__c = oldOrder.Sub_Id5__c; 

        cOrder.Order_Source__c = 'Subscription';  //added Order Tracking 

        cOrder.Coupon_Discount__c = oldOrder.Coupon_Discount__c;

        cOrder.Subscription_To__c = oldOrder.Subscription_To__c;

        return cOrder; 
    }

    public List<OrderItem__c> cloneOrderItems(Id orderId) {
        List<Order__c> ordersList = [ 
            SELECT Id, (SELECT Product__c, Quantity__c, Product_Price__c, Order_Item_Bundle__c FROM Order_Items__r) 
            FROM Order__c 
            WHERE Id = :orderId 
        ];

        if (ordersList.size() == 0) { 
            return null; 
        }

        Order__c oldOrder = ordersList[0]; 

        List<OrderItem__c> cOrderItems = new List<OrderItem__c>(); 
        Decimal subtotal = 0; 

        for (OrderItem__c orderItem : oldOrder.Order_Items__r) {
            if (orderItem.Order_Item_Bundle__c == null) {
                OrderItem__c item = new OrderItem__c(); 
                item.Product__c = orderItem.Product__c; 
                item.Quantity__c = orderItem.Quantity__c; 
                item.Product_Price__c = orderItem.Product_Price__c; 
                item.Is_Bump_Offer__c = true; 
                item.Not_Active_Product__c = true; 
                cOrderItems.add(item); 
                subtotal = subtotal + item.Product_Price__c * item.Quantity__c; 
            }
        } 

        return cOrderItems; 
    }
}