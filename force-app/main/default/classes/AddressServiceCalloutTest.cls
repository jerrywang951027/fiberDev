/*
 * @group AddressServiceability
 * @description Test class to check the functionality of the AddressServiceCallout.
 */
@isTest
private without sharing class AddressServiceCalloutTest {

  /*
   * @description Test method to test the response of AddressServiceCallout.
   */
  @isTest
  static void getCalloutSmartyStreetShouldReturnAddressList() {

    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();

    inputMap.put('street', '34');
    inputMap.put('selected', '');
    AddressServiceCallout addressService = new AddressServiceCallout();
    Test.setMock(HttpCalloutMock.class, new MockGenerator('SmartyStreet'));
    StaticResource staticResourceValue;
    String body;
    staticResourceValue = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'getCalloutSmartyProTestResponse'
        LIMIT 1];
    Test.startTest();
      Boolean result = AddressService.invokeMethod('getCalloutSmartyStreet',
          inputMap, outMap, options);
    Test.stopTest();
    System.assertEquals(staticResourceValue.Body.toString(),
        outMap.get('addressList'), 'SmartyStreet result does not match.');
  }

  /*
   *@description Method to test the response of getAddressInfo.
   */
  @isTest
  static void getAddressInfoShouldReturnServiceAddressData() {

    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    AddressServiceCallout addressService = new AddressServiceCallout();

    Test.setMock(HttpCalloutMock.class, new MockGenerator('AddressService'));
    String resultGetAddressInfo;
    String street;
    StaticResource staticResourceValue = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'getAddressServiceTestResponse'
        LIMIT 1];
    StaticResource addressServiceString = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'getAddressServiceString'
        LIMIT 1];
    inputMap.put('smartyStreet', addressServiceString.Body.toString());
    Test.startTest();
      Boolean result = AddressService.invokeMethod('getAddressInfo',inputMap, outMap, options);
    Test.stopTest();
    System.assertEquals(staticResourceValue.Body.toString(), outMap.get('serviceAddressData'),
        'Service address result does not match.');
  }
}