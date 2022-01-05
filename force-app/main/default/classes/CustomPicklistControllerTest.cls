/*
 *@group CustomPicklist
 *@description This class is used for test coverage for CustomPicklistController Class.
 */
@isTest
private class CustomPicklistControllerTest {

  /**
   * @description Method to create test data
   */
  @testSetup
  private static void testSetup() {

    Lead leadTestRecord = TestDataFactory.getLeadData();
    insert leadTestRecord;
  }

  /**
   * @description Checks if the method in invokable.
   */
  @isTest
  private static void checkInvocationCustomPicklistMethod() {

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    String methodName = 'customPicklist';
    CustomPicklistController customPicklistClass = new CustomPicklistController();
    Lead leadRecord = [
      SELECT Id
      FROM Lead
      LIMIT 1
    ];
    inputMap.put('ContextId', leadRecord.Id);
    inputMap.put('fieldName', 'Pilot__c');
    Test.startTest();
      Boolean result = customPicklistClass.invokeMethod(methodName, inputMap, outMap,  options);
    Test.stopTest();
    System.assertEquals(true, result,
        'To check whether customPicklist method is invoked from Omniscript');
  }

  /**
   * @description Checks the picklist values fetched.
   */
  @isTest
  private static void checkCustomPicklistValues() {

    Test.startTest();
      List<Map<String, String>> options = CustomPicklistController.getPickListValues('Lead',
          'Pilot__c');
    Test.stopTest();
    System.assertEquals('#BASIC', options[0].get('value'), 'To verify the Pilot picklist value');
  }
}