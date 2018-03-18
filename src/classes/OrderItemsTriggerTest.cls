@isTest(seeAllData = false)
private class OrderItemsTriggerTest {

    public static testMethod void test_bulkorders() {

        Account testAcc = new Account(Name = 'test');
        insert testAcc;

        Order__c testOrd = new Order__c();
        testOrd.Account__c = testAcc.Id;
        insert testOrd;

        Product2 product = new Product2(
            Name = 'testProduct',
            ProductCode = 'testProductCode',
            IsActive = true
        );
        insert product;

        Pricebook2 pricebook2 = new Pricebook2(
            Name = 'Standard Price Book',
            IsActive = true
        );
        insert pricebook2;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pricebookEntryItem = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = pricebookId,
            UnitPrice = 5,
            IsActive = true
        );
        insert pricebookEntryItem;

        PricebookEntry pricebookEntryCustomize = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = pricebook2.Id,
            UnitPrice = 10,
            IsActive = true
        );
        insert pricebookEntryCustomize;

        Test.startTest();
            List<OrderItem__c> orderItemsList = new List<OrderItem__c>();
            OrderItem__c orderItem1 = new OrderItem__c(
                Order__c = testOrd.Id,
                Product_Price__c = 100,
                Quantity__c = 1,
                Product__c = product.Id,
                Use_Standard_Price__c = true
            );
            orderItemsList.add(orderItem1);
            OrderItem__c orderItem2 = new OrderItem__c(
                Order__c = testOrd.Id,
                Product_Price__c = 200,
                Quantity__c = 1,
                Product__c = product.Id,
                Use_Standard_Price__c = false
            );
            orderItemsList.add(orderItem2);

            insert orderItemsList;
        Test.stopTest();

        List<OrderItem__c> test_orderItemsList = [
            SELECT Id, Order__c, Total_Price__c
            FROM OrderItem__c
        ];

        System.assertEquals(10, test_orderItemsList[0].Total_Price__c);
        System.assertEquals(200, test_orderItemsList[1].Total_Price__c);
    }

    @isTest
    public static void testRecalculationSubTotalAfterDeleteOI(){
        Account testAcc = new Account(Name = 'test');
        insert testAcc;

        Order__c testOrd = new Order__c();
        testOrd.Account__c = testAcc.Id;
        insert testOrd;

        Product2 product = new Product2(
            Name = 'testProduct',
            ProductCode = 'testProductCode',
            IsActive = true
        );
        insert product;

        List<OrderItem__c> orderItemsList = new List<OrderItem__c>();
        for(Integer i = 0 ; i < 5; i++) {
            orderItemsList.add(new OrderItem__c(
                Order__c = testOrd.Id,
                Product_Price__c = 200,
                Quantity__c = 1,
                Product__c = product.Id,
                Use_Standard_Price__c = false)
            );
        }

        Test.startTest();
            insert orderItemsList;
        Test.stopTest();

        Order__c order = [SELECT Id, Subtotal__c FROM Order__c WHERE Id = :testOrd.Id];
        System.assertEquals(1000, order.Subtotal__c);

        delete orderItemsList[0];

        order = [SELECT Id, Subtotal__c FROM Order__c WHERE Id = :testOrd.Id];
        System.assertEquals(800, order.Subtotal__c);
    }

    @isTest
    public static void testRecalculationSubTotalAfterDeleteAllOI(){
        Account testAcc = new Account(Name = 'test');
        insert testAcc;

        Order__c testOrd = new Order__c();
        testOrd.Account__c = testAcc.Id;
        insert testOrd;

        Product2 product = new Product2(
            Name = 'testProduct',
            ProductCode = 'testProductCode',
            IsActive = true
        );
        insert product;

        List<OrderItem__c> orderItemsList = new List<OrderItem__c>();
        for(Integer i = 0 ; i < 5; i++) {
            orderItemsList.add(new OrderItem__c(
                Order__c = testOrd.Id,
                Product_Price__c = 200,
                Quantity__c = 1,
                Product__c = product.Id,
                Use_Standard_Price__c = false)
            );
        }

        Test.startTest();
            insert orderItemsList;
        Test.stopTest();

        Order__c order = [SELECT Id, Subtotal__c FROM Order__c WHERE Id = :testOrd.Id];
        System.assertEquals(1000, order.Subtotal__c);

        delete orderItemsList;

        order = [SELECT Id, Subtotal__c FROM Order__c WHERE Id = :testOrd.Id];
        System.assertEquals(0, order.Subtotal__c);
    }

    @isTest
    public static void testCalculationNumberOfSameProductPurchasedOnAccount(){
        Product2 product = new Product2(
            Name = 'testProduct',
            ProductCode = 'testProductCode',
            IsActive = true
        );
        insert product;

        Account testAcc = new Account(Name = 'test');
        insert testAcc;

        List<Order__c> testOrders = new List<Order__c>();
        for(Integer i = 0; i < 5; i++){
            Order__c testOrd = new Order__c();
            testOrd.Account__c = testAcc.Id;
            testOrders.add(testOrd);
        }
        insert testOrders;

        List<OrderItem__c> orderItemsList = new List<OrderItem__c>();
        for(Integer i = 0; i < testOrders.size(); i++){
            orderItemsList.add(new OrderItem__c(
                Order__c = testOrders.get(i).Id,
                Product_Price__c = 200,
                Quantity__c = 1,
                Product__c = product.Id,
                Use_Standard_Price__c = false)
            );
        }

        Test.startTest();
            insert orderItemsList;
        Test.stopTest();

        Account testAccount = [SELECT Number_of_Same_Product_Purchased__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(testOrders.size(), testAccount.Number_of_Same_Product_Purchased__c);

        delete orderItemsList.get(0);
        testAccount = [SELECT Number_of_Same_Product_Purchased__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(testOrders.size()-1, testAccount.Number_of_Same_Product_Purchased__c);        

        delete testOrders;
        testAccount = [SELECT Number_of_Same_Product_Purchased__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(0, testAccount.Number_of_Same_Product_Purchased__c); 
    }

    static testMethod void createOrderItemsProductBundleTest() {
        List<RecordType> recordTypeProductBundle = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Bundle' AND SobjectType = 'Product2' AND IsActive = TRUE];
        List<RecordType> recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product' AND SobjectType = 'Product2' AND IsActive = TRUE];
        Category__c category = new Category__c(
            Brand__c = 'Winter',
            Category_Name__c = 'Test Category Name'
        );
        insert category;

        Product2 prod = new Product2(
            Name = 'Apple Pie + 2L Choc Chip', Family = 'Winter', RecordTypeId = recordTypeProductBundle[0].Id,
            Category__c = category.Id, isActive = true
        );
        Product2 prod1 = new Product2(
            Name = 'Apple Pie', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id,
            Category__c = category.Id, isActive = true
        );
        Product2 prod2 = new Product2(
            Name = '2L Chocolate Chip', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id,
            Category__c = category.Id, isActive = true
        );
        insert new List<Product2>{prod, prod1, prod2};

        Product_Bundle_Item__c pb = new Product_Bundle_Item__c(Product__c = prod1.Id, Product_Bundle__c = prod.Id, Default_Quantity__c = 1);
        Product_Bundle_Item__c pb1 = new Product_Bundle_Item__c(Product__c = prod2.Id, Product_Bundle__c = prod.Id, Default_Quantity__c = 1);
        insert new List<Product_Bundle_Item__c>{pb, pb1};

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice;

        Order__c order0 = new Order__c();
        Order__c order1 = new Order__c();
        insert new List<Order__c> {order0, order1};

        Test.startTest();
            List<OrderItem__c> orderItems = new List<OrderItem__c>();
            for (Integer i = 0; i < 200; i++) {
                orderItems.add(new OrderItem__c(
                Quantity__c = 1, Order__c = order0.Id,
                Product__c = prod.Id, Product_Price__c = 1));
            }
            for (Integer i = 0; i < 200; i++) {
                orderItems.add(new OrderItem__c(
                Quantity__c = 1, Order__c = order1.Id,
                Product__c = prod.Id, Product_Price__c = 1));
            }
            insert orderItems;

        Test.stopTest();

        List<OrderItem__c> orderItemsProductBundle0 = new List<OrderItem__c>();
        List<OrderItem__c> orderItemsProductBundle1 = new List<OrderItem__c>();
        List<OrderItem__c> orderItemsProductBundleItem0 = new List<OrderItem__c>();
        List<OrderItem__c> orderItemsProductBundleItem1 = new List<OrderItem__c>();

        List<OrderItem__c> allOrderItems = [SELECT Id, Is_Product_Bundle__c, Order__c FROM OrderItem__c];
        for (OrderItem__c oi : allOrderItems) {
            if (oi.Is_Product_Bundle__c) {
                if (oi.Order__c == order0.Id) {
                    orderItemsProductBundle0.add(oi);
                } else if (oi.Order__c == order1.Id) {
                    orderItemsProductBundle1.add(oi);
                }
            } else {
                if (oi.Order__c == order0.Id) {
                    orderItemsProductBundleItem0.add(oi);
                } else if (oi.Order__c == order1.Id) {
                    orderItemsProductBundleItem1.add(oi);
                }
            }
        }
        System.assertEquals(200, orderItemsProductBundle0.size());
        System.assertEquals(200, orderItemsProductBundle1.size());
        System.assertEquals(400, orderItemsProductBundleItem0.size());
        System.assertEquals(400, orderItemsProductBundleItem1.size());
    }

    static testMethod void deleteOrderItemOneProductBundleTest() {
        List<RecordType> recordTypeProductBundle = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Bundle' AND SobjectType = 'Product2' AND IsActive = TRUE];
        List<RecordType> recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product' AND SobjectType = 'Product2' AND IsActive = TRUE];
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account acc = new Account(RecordTypeId = customerRecordType.Id, LastName = 'David');
        insert acc;

        Category__c category = new Category__c(
            Brand__c = 'Winter',
            Category_Name__c = 'Test Category Name'
        );
        insert category;

        Product2 prod = new Product2(
            Name = 'Apple Pie + 2L Choc Chip', Family = 'Winter', RecordTypeId = recordTypeProductBundle[0].Id, // Product_Bundle__c = true,     //Product_Bundle__c = true changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = true
        );
        Product2 prod1 = new Product2(
            Name = 'Apple Pie', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id, // Product_Bundle__c = false,      //Product_Bundle__c = false changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = true
        );
        Product2 prod2 = new Product2(
            Name = '2L Chocolate Chip', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id, // Product_Bundle__c = false,      //Product_Bundle__c = false changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = true
        );
        Product2 prodCoolCube = new Product2(
            Name = 'CoolCube', Family = 'Winter', isActive = true,
            Category__c = category.Id
        );
        insert new List<Product2>{prod, prod1, prod2, prodCoolCube};

        Product_Bundle_Item__c pb = new Product_Bundle_Item__c(Product__c = prod1.Id, Product_Bundle__c = prod.Id, Default_Quantity__c = 1);
        Product_Bundle_Item__c pb1 = new Product_Bundle_Item__c(Product__c = prod2.Id, Product_Bundle__c = prod.Id, Default_Quantity__c = 1);
        insert new List<Product_Bundle_Item__c>{pb, pb1};

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice;

        Order__c order = new Order__c(
            Account__c = acc.Id
        );
        insert order;

        OrderItem__c newOI0 = new OrderItem__c(
            Order__c = order.Id, Product__c = prod.Id,
            Quantity__c = 1, Product_Price__c = 10
        );
        OrderItem__c newOI1 = new OrderItem__c(
            Order__c = order.Id, Product__c = prod.Id,
            Quantity__c = 1, Product_Price__c = 10
        );
        OrderItem__c newOICoolCube0 = new OrderItem__c(
            Order__c = order.Id, Product__c = prodCoolCube.Id,
            Quantity__c = 1, Product_Price__c = 10
        );
        OrderItem__c newOICoolCube1 = new OrderItem__c(
            Order__c = order.Id, Product__c = prodCoolCube.Id,
            Quantity__c = 1, Product_Price__c = 10
        );
        insert new List<OrderItem__c>{newOI0, newOI1, newOICoolCube0, newOICoolCube1};

        System.assertEquals(8, [SELECT Id FROM OrderItem__c WHERE Order__c =: order.Id].size());

        Test.startTest();
            delete new List<OrderItem__c>{newOI0, newOI1, newOICoolCube0};
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM OrderItem__c WHERE Order__c =: order.Id].size());

    }

    static testMethod void orderItemForInactiveProductBundleTest() {
        List<RecordType> recordTypeProductBundle = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product_Bundle' AND SobjectType = 'Product2' AND IsActive = TRUE];
        List<RecordType> recordTypeProduct = [SELECT Id FROM RecordType WHERE DeveloperName = 'Product' AND SobjectType = 'Product2' AND IsActive = TRUE];
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Customer_Account' AND IsPersonType = true];
        Account acc = new Account(RecordTypeId = customerRecordType.Id, LastName = 'David');
        insert acc;

        Category__c category = new Category__c(
            Brand__c = 'Winter',
            Category_Name__c = 'Test Category Name'
        );
        insert category;

        Product2 prod = new Product2(
            Name = 'Apple Pie + 2L Choc Chip', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id, // Product_Bundle__c = false,       //Product_Bundle__c = false changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = true
        );
        Product2 prod1 = new Product2(
            Name = 'Apple Pie', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id, // Product_Bundle__c = false,   //Product_Bundle__c = false changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = false
        );
        Product2 prod2 = new Product2(
            Name = '2L Chocolate Chip', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id, // Product_Bundle__c = false,   //Product_Bundle__c = false changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = false
        );
        Product2 prodBund = new Product2(
            Name = 'Apple Pie + 2L NUT', Family = 'Winter', RecordTypeId = recordTypeProductBundle[0].Id, // Product_Bundle__c = true,   //Product_Bundle__c = true changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = true
        );
        Product2 prodForBund = new Product2(
            Name = 'Apple Pie', Family = 'Winter', RecordTypeId = recordTypeProduct[0].Id, // Product_Bundle__c = false,   //Product_Bundle__c = false changed on RecordTypeId      //REMOVED
            Category__c = category.Id, isActive = true
        );
        insert new List<Product2>{prod, prod1, prod2, prodBund, prodForBund};

        Product_Bundle_Item__c pb = new Product_Bundle_Item__c(Product__c = prod1.Id, Product_Bundle__c = prod.Id, Default_Quantity__c = 1);
        Product_Bundle_Item__c pb1 = new Product_Bundle_Item__c(Product__c = prod1.Id, Product_Bundle__c = prod.Id, Default_Quantity__c = 1);
        Product_Bundle_Item__c pb2 = new Product_Bundle_Item__c(Product__c = prodForBund.Id, Product_Bundle__c = prodBund.Id, Default_Quantity__c = 1);
        Product_Bundle_Item__c pb3 = new Product_Bundle_Item__c(Product__c = prodForBund.Id, Product_Bundle__c = prodBund.Id, Default_Quantity__c = 1);
        insert new List<Product_Bundle_Item__c>{pb, pb1, pb2, pb3};

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice;

        Order__c order = new Order__c(
            Account__c = acc.Id
        );
        insert order;

        Test.startTest();
            OrderItem__c newOI0 = new OrderItem__c(
                Order__c = order.Id, Product__c = prod.Id,
                Quantity__c = 1, Product_Price__c = 10
            );
            OrderItem__c newOI1 = new OrderItem__c(
                Order__c = order.Id, Product__c = prodBund.Id,
                Quantity__c = 1, Product_Price__c = 10
            );
            insert new List<OrderItem__c>{newOI0, newOI1};

            
        Test.stopTest();
        
        List<OrderItem__c> items = [SELECT Id, Is_Product_Bundle__c FROM OrderItem__c WHERE Order__c =: order.Id];
        System.assertEquals(4, items.size());

        Integer countProductBundleOrderItem = 0;
        for (OrderItem__c orderItem : items) {
            if (orderItem.Is_Product_Bundle__c) {
                countProductBundleOrderItem++;
            }
        }
        System.assertEquals(1, countProductBundleOrderItem);
    }


}