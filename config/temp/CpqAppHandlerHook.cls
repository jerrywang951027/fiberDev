public with sharing class CpqAppHandlerHook implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        try
        {
            System.debug('____ CpqAppHandlerHookImplementation ' + methodName);

            if (methodName == 'postCartsItems.PreInvoke' || methodName == 'putCartsItems.PreInvoke' ||
                    methodName == 'deleteCartsItems.PreInvoke' || methodName == 'getCartsItems.PreInvoke')
            {

                System.debug('my hook impl is invoked with method : ' + methodName); 
                // String customFields = 'Billing_Zip_Code__c'; // comma separated list of custom fields
                // // if fields is passed in, append the custom fields to the parameter value
                // if (String.isNotBlank((String)input.get('fields')))
                // {
                //     input.put('fields', input.get('fields') + ',' + customFields);
                // }
                // else
                // {
                //     // if the fields is not passed in, initialize to default price detail fields and include the custom fields
                //     input.put('fields', 'vlocity_cmt__BillingAccountId__c,vlocity_cmt__ServiceAccountId__c,Quantity,vlocity_cmt__RecurringTotal__c,' +
                //         'vlocity_cmt__OneTimeTotal__c,vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__RecurringManualDiscount__c,' +
                //         'vlocity_cmt__ProvisioningStatus__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__OneTimeCharge__c,ListPrice,' +
                //         'vlocity_cmt__ParentItemId__c,vlocity_cmt__BillingAccountId__r.Name,vlocity_cmt__ServiceAccountId__r.Name,' +
                //         'vlocity_cmt__PremisesId__r.Name,vlocity_cmt__InCartQuantityMap__c,vlocity_cmt__EffectiveQuantity__c' + ',' + customFields);
                // }
                // // if priceDetailsFields is passed in, append the custom fields to the parameter value
                // if (String.isNotBlank((String)input.get('priceDetailsFields')))
                // {
                //     input.put('priceDetailsFields', input.get('priceDetailsFields') + ',' + customFields);
                // }
                // else
                // {
                //     // if the priceDetailFields is not passed in, initialize to default price detail fields and include the custom fields
                //     input.put('priceDetailsFields', 'vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c,vlocity_cmt__OneTimeCharge__c,' +
                //         'vlocity_cmt__OneTimeTotal__c' + ',' + customFields);
                // }
            }
            return true;
        }
        catch (Exception ex)
        {
            System.debug('--- Exception: ' + ex.getMessage());
            System.debug('--- Stack Trace: ' + ex.getStackTraceString());
            throw ex;
        }
    }
}
