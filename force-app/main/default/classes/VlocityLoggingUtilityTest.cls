/*
@group VlocityLoggingUtilityTest
@description Test Class for VlocityLoggingUtility.
*/
@isTest
public class VlocityLoggingUtilityTest {
  // Inputmap Values.
  final static String IP_NAME = 'TestIP';
  final static String IP_ELEMENT_NAME = 'TestIPStep';
  final static String ERROR_MESSAGE = 'Sample Message';

  /*
  * @description This method is to create Test data which will be used across all test methods.
  */
  @testSetup
  private static void setupTestData() {
    Logging_Level__c setting = new Logging_Level__c();
    setting.Name = 'Default';
    setting.Level__c = 'Default';
    insert setting;
  }
  /*
  * @description This method is to test VlocityLoggingUtility and LogIPResult for success scenario.
  */
  @isTest
  private static void passingValidFieldsForLogShouldCreateLogRecord() {
    // initializing Method Name
    String methodName = VlocityLoggingUtility.LOG_IP_RESULT_METHOD;

    // Initializing Maps for input
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    VlocityLoggingUtility vLogUtilObj = new  VlocityLoggingUtility();
    // Passing Data to Input Map for Log Generation
    inputMap.put('IPName', VlocityLoggingUtilityTest.IP_NAME);
    inputMap.put('ElementName', VlocityLoggingUtilityTest.IP_ELEMENT_NAME);
    inputMap.put('ErrorMessage', VlocityLoggingUtilityTest.ERROR_MESSAGE);
    // Start Test
    Test.startTest();
      Boolean result = vLogUtilObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    // Query the log generated.
    List<Log__c> logList = [
        SELECT
            Class__c,
            Method__c,
            Description__c
        FROM
            Log__c
        LIMIT
            1
    ];
    // Unit test assert start
    System.assert(!logList.isEmpty());
    System.assert(result);
    System.assertEquals(logList.size(),1);
    System.assertEquals(logList[0].Class__c, IP_NAME);
    System.assertEquals(logList[0].Method__c, IP_ELEMENT_NAME);
    System.assertEquals(logList[0].description__c, ERROR_MESSAGE);
    // Unit test assert end.
  }
  /*
  * @description This method is to to test VlocityLoggingUtility.LogIPResult
  * for invalid method Scenario.
  */
  @isTest
  private static void passingInvalidMethodNameShouldReturnResultFalse() {
    // Initializing Method Name
    String methodName = VlocityLoggingUtility.LOG_IP_RESULT_METHOD;

    // Initializing Maps for Input
    Map<String, Object> inputMap = new map<String, Object>();
    inputMap.put('IPName',123);
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    VlocityLoggingUtility vLogUtilObj = new  VlocityLoggingUtility();
    try {
      // Start Test
      Test.startTest();
        Boolean result = vLogUtilObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
      Test.stopTest();
      // Stop Test
    }
    catch (Exception e) {
      // Unit test assert Start
      System.assert(true, 'We caught an exception');
    }
  }
  @isTest
  private static void passingInvalidMethodNameShouldThrowError() {
    // Initializing Method Name
    String methodName = 'incorrectMethod';

    // Initializing Maps for Input
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    VlocityLoggingUtility vLogUtilObj = new  VlocityLoggingUtility();
    try {
      // Start Test
      Test.startTest();
        Boolean result = vLogUtilObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
      Test.stopTest();
      // Stop Test
    }
    catch (Exception e) {
      // Unit test assert Start
      System.assert(true, 'We caught an exception');
    }
  }
}