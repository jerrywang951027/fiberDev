/**
* @group AMS CustomerInfo
* @description Test class for CustomerInfo to improve code coverage
  and test functionality.
*/
@isTest
public with sharing class CustomerInfoTest {

  private final static String SAMPLE_DATA = '{\"id\":\"testId\",' +
      '\"incorrectNode\":\"incorrectValue\"}';
  private final static String INCORRECT_SAMPLE_DATA = '{\"id\":\"testId\",' +
      '\"serviceAccounts\":[{\"items\":[{\"recurringTotalMicros\":true}]}]}';
  private final static String TEST_ID = 'testId';
  private final static String INCORRECT_VALUE = 'incorrectValue';

  @isTest
  static void transformCustomerInfoTest() {
    Map<String, Object> inputMap = new Map <String, Object>();
    Map<String, Object> outMap = new Map <String, Object>();
    Map<String, Object> options = new Map <String, Object>();

    String methodName = 'transformCustomerInfo';
    inputMap.put('customerAccount',JSON.deserializeUntyped(SAMPLE_DATA));
    CustomerInfo customerInfoObj = new CustomerInfo();

    Test.startTest();
      Boolean result = customerInfoObj.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();
    System.assert(JSON.serialize(outMap.get('response')).contains(TEST_ID));
    System.assert(!(JSON.serialize(outMap.get('response')).contains(INCORRECT_VALUE)));
  }

  @isTest
  static void catchStatementCustomerInfoTest() {
    Map<String, Object> inputMap = new Map <String, Object>();
    Map<String, Object> outMap = new Map <String, Object>();
    Map<String, Object> options = new Map <String, Object>();

    String methodName = 'transformCustomerInfo';
    inputMap.put('customerAccount',JSON.deserializeUntyped(INCORRECT_SAMPLE_DATA));
    CustomerInfo customerInfoObj = new CustomerInfo();

    try {
      Test.startTest();
        Boolean result = customerInfoObj.invokeMethod(methodName, inputMap, outMap, options);
      Test.stopTest();
    }
    catch (Exception e) {
      System.assertEquals(e.getMessage(), 'Attempt to de-reference a null object');
    }
  }
}