/**
 * @group CustomPicklistController
 * @description Fetches picklist values from Salesforce.
 */
global with sharing class CustomPicklistController implements
    vlocity_cmt.VlocityOpenInterface2 {
  /**
   * @description Invoke method
   * @param methodName The name of the method thats needs to invoke.
   * @param input The input passed to Apex Class.
   * @param outMap The output of the Apex Class.
   * @param options The options passed from Apex Class.
   * @return true The response is true when the invoke happens.
   */
  public Boolean invokeMethod(String methodName, Map<String, Object> input,
      Map<String, Object> outMap,
      Map<String, Object> options) {
    if (methodName.equals('customPicklist')) {
      customPicklist(input, outMap, options);
    }
    return true;
  }

  /**
   * @description Method to tranform input to fetch custom picklist values.
   * @param input The input map passed from Omniscrpit to Apex Class.
   * @param outMap The output of the Apex Class.
   * @param options The options passed from Apex Class to OmniScript.
   */
  @AuraEnabled(cacheable = true)
  public static void customPicklist(
      Map<String, Object> input, Map<String, Object> outMap,
      Map<String, Object> options) {
    List<Map<String, String>> uiOptions = new List<Map<String, String>>();
    String getObjectName;
    Id recordId = Id.valueOf((Id)input.get('ContextId'));
    String fieldName = String.valueOf(input.get('fieldName'));
    String objectName = recordId.getSObjectType().getDescribe().getName();
    uiOptions = getPickListValues(objectName, fieldName);
    options.put('options', uiOptions);
    outMap.put('options', uiOptions);
  }

  /**
   * @description This method fetches pickist from salesforce
   * @param objApiName The API name of object.
   * @param fieldName The API name of field.
   * @return options Holds all the picklist values.
   */
  @AuraEnabled
  public static List<Map<String, String>> getPickListValues(String objApiName,
      String fieldName) {
    List<Map<String, String>> options = new List<Map<String, String>>();
    Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
    if (objType == null) {
      return options;
    }
    Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
    if (fieldMap.get(fieldName) == null) {
      return options;
    }
    List<Schema.PicklistEntry> pickListValues =
        fieldMap.get(fieldName).getDescribe().getPickListValues();
    for (Schema.PicklistEntry picklistValue : pickListValues) {
      Map<String, String> values = new Map<String, String>{
       'label' => picklistValue.getLabel(), 'value' => picklistValue.getValue()};
      options.add(values);
    }
    return options;
  }
}