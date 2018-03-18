public with sharing class RestSaleTaxDummyController {

    public interface TaxCalculationInterface {
        Map<String,Object> InvokeMethod(Map<String,Object> parameters);
    }

    /**
     * Dummy Tax implementation in Base
     */
    public class TaxCalculationInnerClass implements TaxCalculationInterface {

        public Map<String,Object> InvokeMethod(Map<String,Object> parameters) {

            Map<String,Object> result = new Map<String,Object>();
            result.put('Tax', 0);
            return result;
        }
    }
}