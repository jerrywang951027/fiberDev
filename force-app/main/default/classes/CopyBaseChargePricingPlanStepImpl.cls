public with sharing class CopyBaseChargePricingPlanStepImpl{

    public static void copyBaseCharges() {
       Map<Id, Map<String, Object>> priceVarMap;
       if (!Test.isRunningTest()) {
          priceVarMap =
               vlocity_cmt.PricingPlanService.getLineItemPricingVariableValues();
       } else {
               priceVarMap = (Map<Id, Map<String,Object>>)
               vlocity_cmt.PricingPlanService.getFromPricingContext('TestLineItemPricingVariableValues');
         }             
       if (priceVarMap == null || priceVarMap.isEmpty()) return;
       for (Id itemId : priceVarMap.keySet()) {           
           Map<String, Object> valuesMap = priceVarMap.get(itemId);
           if (valuesMap != null) {
               Map<String, Object> lineItemVariableMap = (Map<String,
                   Object>)valuesMap.get('PricingVariableValues');
               if (lineItemVariableMap != null) {
                   // copy RecurringCharge value                   
                   lineItemVariableMap.put('CUSTOM_BASE_MNTH_REC_CHRG',
                       lineItemVariableMap.get('REC_MNTH_STD_PRC'));
                   // copy OneTimeCharge value                   
                   lineItemVariableMap.put('CUSTOM_BASE_ONE_TIME_CHRG',
                       lineItemVariableMap.get('OT_STD_PRC'));
               }
           }
       }
    }    
}