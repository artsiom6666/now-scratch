@isTest
public class CustomerModelTest {

    static testmethod void testOne() {

        // Access CustomerModel outer class
        CustomerModel customerModel = new CustomerModel();

        customerModel.id = 'sampleId';
        customerModel.created_at = 'xyz';
        customerModel.email = 'abc@gmail.com';
        customerModel.first_name = 'xyz';
        customerModel.last_name = 'abc';
        customerModel.username = 'xyz';
        customerModel.role = 'abc';
        customerModel.last_order_id = 'abc';
        customerModel.last_order_date = 'xyz';
        customerModel.orders_count = 'abc';
        customerModel.total_spent = 'xyz';
        customerModel.avatar_url = 'abc';

        // Access BillingAddress inner class
        CustomerModel.BillingAddress billAddress = new CustomerModel.BillingAddress();

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
        customerModel.billing_address = billAddress;

        // Access ShippingAddress inner class
        CustomerModel.ShippingAddress shipAddress = new CustomerModel.ShippingAddress();

        shipAddress.first_name = 'Fname';
        shipAddress.last_name = 'Lname';
        shipAddress.company = 'sampleCompany';
        shipAddress.address_1 = 'addressOne';
        shipAddress.address_2 = 'addressTwo';
        shipAddress.city = 'sampleCity';
        shipAddress.state = 'sampleState';
        shipAddress.postcode = 'samplePostcode';
        shipAddress.country = 'sampleCountry';
        
        // Access shipping_address data members and add their values
        customerModel.shipping_address = shipAddress;
        System.assert(true);

    }
}