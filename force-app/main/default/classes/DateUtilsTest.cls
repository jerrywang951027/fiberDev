/**
*  @group TestClass-DateUtils
*  @description Test class for DateUtils to improve code coverage and test functionality.
*/
@isTest
public with sharing class DateUtilsTest {
  
  /**
   *  @description test method to cover getDay method
   *  @param Not available
   *  @return null
   */
   @isTest
   static void passingDateShouldReturnDay() {
     String dateStr = System.now().format('YYYY-MM-dd');

     //Initializing the parameters for invokeMethod
     Map<String, Object> inputMap = new Map<String, Object>();
     Map<String, Object> outputMap = new Map<String, Object>();
     Map<String, Object> options = new Map<String, Object>();
     inputMap.put('arguments', new List<Object>{dateStr});
     Test.startTest();
       Boolean result = new DateUtils().invokeMethod('day', inputMap, outputMap, options);
     Test.stopTest();
     //Unit Test assert start
     System.assertEquals(System.now().day(), outputMap.get('result'), 'Days do not match.');
  }
    
  /**
   *  @description test method to cover negative scenario of not accepting 2 aruments.
   *  @param Not available
   *  @return null
   */
   @isTest
   static void passingTwoArgumentsShouldThrowError() {
     String dateStr = System.now().format('YYYY-MM-dd');

     //Initializing the parameters for invokeMethod
     Map<String, Object> inputMap = new Map<String, Object>();
     Map<String, Object> outputMap = new Map<String, Object>();
     Map<String, Object> options = new Map<String, Object>();
     inputMap.put('arguments', new List<Object>{dateStr, dateStr});
     Boolean result;
     try{
       Test.startTest();
         result = new DateUtils().invokeMethod('day', inputMap, outputMap, options);
       Test.stopTest();
     }
     catch(InvalidParameterValueException e) {
       //Unit Test assert start
       System.assertEquals(null, result, '2 parameters are accepted.');
       System.assert(e.getMessage().contains('Script-thrown exception'),
           'Exception message is not matched');
     }
   }
    
  /**
   *  @description test method to cover negative scenario for wrong date format.
   *  @param Not available
   *  @return null
   */
   @isTest
   static void passingIncorrectDateFormatShouldThrowError() {
     String dateStr = System.now().format('dd-MM-YYYY');
     //Initializing the parameters for invokeMethod
     Map<String, Object> inputMap = new Map<String, Object>();
     Map<String, Object> outputMap = new Map<String, Object>();
     Map<String, Object> options = new Map<String, Object>();
     inputMap.put('arguments', new List<Object>{dateStr});
     Boolean result;
     try{
       Test.startTest();
         result = new DateUtils().invokeMethod('day', inputMap, outputMap, options);
       Test.stopTest();
     }
     catch(InvalidParameterValueException e) {
       //Unit Test assert start
       System.assertEquals(null, result, 'Incorrect date format is accepted');
       System.assert(e.getMessage().contains('Script-thrown exception'),
           'Exception message is not matched');
      }
   }

  /**
   * @description This method is to test convertActivationDate.
   */
  @isTest
  private static void convertActivationDateShouldConvertActivationDate() {
    // Initialising date-time field for testing.
    DateTime expectedDate = DateTime.now();
    String activationDateDetails = expectedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
    expectedDate = (DateTime)JSON.deserialize('"' + activationDateDetails + '"', DateTime.class);
    // Initializing Method Name
    String methodName = DateUtils.HILBERT_ACTIVATION_METHOD_NAME;
    // Initializing Maps for Input
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    DateUtils orderManagementObj = new DateUtils();
    // Passing Data to Input Map
    inputMap.put('activationDate',activationDateDetails);
    // Start Test
    Test.startTest();
      orderManagementObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    DateTime activationDate = DateTime.valueOf(outMap.get('activationDate'));
    // Unit test assert Start
    System.assertEquals(expectedDate,activationDate,
        'Expected date should match the Activation date');
    // Unit test assert End
  }
}