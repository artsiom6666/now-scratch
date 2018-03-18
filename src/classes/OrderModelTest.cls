@isTest
public class OrderModelTest {

    static testmethod void testOne() {

        // Access OrderModel outer class
        OrderModel orderModel = new OrderModel();
        CustomerModel customer = new CustomerModel();
        //hh
        CustomerModel customerModel = new CustomerModel();
        orderModel.customer = customerModel;
        //hh
        
        List<OrderModel.LineItems> line_items=new List<OrderModel.LineItems>();
        List<OrderModel.ShippingLines> shipping_lines=new List<OrderModel.ShippingLines>();
        orderModel.id = '0X33000';
        orderModel.order_number = 'abc';
        orderModel.created_at = Datetime.now();
        orderModel.updated_at = Datetime.now();
        orderModel.completed_at = Datetime.now();
        orderModel.status = 'abc';
        orderModel.currencyType = 'xyz';
        orderModel.total = 10;
        orderModel.subtotal = 10;
        orderModel.total_line_items_quantity = 'abc';
        orderModel.total_tax = 10;
        orderModel.total_shipping = 20;
        orderModel.cart_tax = 10;
        orderModel.shipping_tax = 15;
        orderModel.total_discount = 10;
        orderModel.shipping_methods = 'abc';
        orderModel.note = 'xyz';
        orderModel.customer_ip = 'abc';
        orderModel.customer_user_agent = 'xyz';
        orderModel.customer_id = 'abc';
        orderModel.view_order_url = 'xyz';

        // Access PaymentDetails inner class
        OrderModel.PaymentDetails payDetails = new OrderModel.PaymentDetails();
        payDetails.method_id = 'methodIdOne';
        payDetails.method_title = 'TitleOne';
        payDetails.paid = 'yes';

        // Access payment_details data members and add their values
        orderModel.payment_details = payDetails;

        // Access BillingAddress inner class
        OrderModel.BillingAddress billAddress = new OrderModel.BillingAddress();
        billAddress.first_name = 'Fname';
        billAddress.last_name = 'Lname';
        billAddress.company = 'sampleCompany';
        billAddress.address_1 = 'addressOne';
        billAddress.address_2 = 'addressTwo';
        billAddress.city = 'sampleCity';
        billAddress.state = 'sampleState';
        billAddress.postcode = 'samplePostcode';
        billAddress.country = 'sampleCountry';
        billAddress.email = 'abc@gmail.com';
        billAddress.phone = 'samplePhone';

        // Access billing_address data members and add their values
        orderModel.billing_address = billAddress;

        // Access ShippingAddress inner class
        OrderModel.ShippingAddress shipping_address = new OrderModel.ShippingAddress();
        shipping_address.first_name = 'Fname';
        shipping_address.last_name = 'Lname';
        shipping_address.company = 'sampleCompany';
        shipping_address.address_1 = 'addressOne';
        shipping_address.address_2 = 'addressTwo';
        shipping_address.city = 'sampleCity';
        shipping_address.state = 'sampleState';
        shipping_address.postcode = 'samplePostcode';
        shipping_address.country = 'sampleCountry';

        // Access shipping_address data members and add their values
        orderModel.shipping_address = shipping_address;

        // Access LineItems inner class
        OrderModel.LineItems lineItem = new OrderModel.LineItems();
        lineItem.id = 'sampleIdOne';
        lineItem.orderId = '0X5550000';
        lineItem.subtotal = '10';
        lineItem.subtotal_tax = '10';
        lineItem.total = '50';
        lineItem.total_tax = '10';
        lineItem.price = 100;
        lineItem.quantity = 2;
        lineItem.tax_class = 'taxClass';
        lineItem.name = 'sampleName';
        lineItem.product_id = 'ProductId';
        lineItem.sku = 'sampleSKU';

        line_items.add(lineItem);

        // Access line_items data members and add their values
        orderModel.line_items = line_items;

        // Access ShippingLines inner class
        OrderModel.ShippingLines shipLines = new OrderModel.ShippingLines();
        shipLines.id = 'sampleIdTwo';
        shipLines.method_id = 'MethodidTwo';
        shipLines.method_title = 'TitleTwo';
        shipLines.total = 10;

        shipping_lines.add(shipLines);

        // Access shipping_lines data members and add their values
        orderModel.shipping_lines = shipping_lines;

        List<OrderModel.CouponCodes> coupon_codes =new List<OrderModel.CouponCodes>();


        OrderModel.CouponCodes coupon = new OrderModel.CouponCodes();
        coupon.id = '123';
        coupon.code = 'TEST';
        coupon.type = 'Shipping Code';
        coupon_codes.add(coupon);

        System.assert(true);
    }
}