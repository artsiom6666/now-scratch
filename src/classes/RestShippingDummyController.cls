public with sharing class RestShippingDummyController {

    public interface shippingInterface {
        Map<String,Object> InvokeMethod(Map<String,Object> parameters);
    }

    /**
     * Dummy Shipping implementation in Base
     */
    public class shippingInnerClass implements shippingInterface {

        public Map<String,Object> InvokeMethod(Map<String,Object> parameters) {

            Map<String,Object> result = new Map<String,Object>();
            result.put('Shipping', 0);
            return result;
        }
    }
}