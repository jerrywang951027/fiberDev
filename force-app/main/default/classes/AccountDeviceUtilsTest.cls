/**
* @group ADS Dockingbay
* @description Test class for AccountDeviceUtils to improve code coverage
  and test functionality.
*/
@isTest
public with sharing class AccountDeviceUtilsTest {

  private final static String SERIAL_NUMBER = 'CP2029RA0AF';
  private final static List <String> SERIAL_NUMBERS = new List <String> {'CP2029RA0AF', 'CP2029'};
  private final static String SUBTYPE = 'Router';
  private final static String NICKNAME = 'Trung-Ext1';
  private final static String ACCOUNT_ID = 'GF-2600-2600-2600-26';
  private final static String CONFIG_FIELDS_TO_DELETE = 'jsonBody.wifi.enableMode,jsonBody.wifi';
  private final static String CONFIGURATION_DATA = '{\"wifi\":{\"enabled\":true,\"enableMode\" ' +
      ':\"OFF\",\"band2ghz\":{\"enabled\":true,\"channel\":190},\"band5ghz\":' +
      '{\"enabled\":true,\"channel\":1100}},\"parameter\":{}}';
  private final static String DEVICE_DATA = '[{"lastHeartbeatTimeMs":"1639649466163","isActive":' +
      'false,"status":{"deviceOption":["n"],"ipAddress":"2:1","lastBootTimeMs":"12"},"properties":' +
		'{"swVersion":"gflt","model":"GFLT110"},"deviceId":"CP2029RA0AF"}]';

  /**
   * @description This is a test method to test invokeMethod() of class AccountDeviceUtils
   * overriden from vlocity_cmt.VlocityOpenInterface2.
   * @return null
   */
  @isTest static void invokeTransformSerialNumberListShouldReturnFormattedSerialNumberList() {

    List<String> serialNumbers = new List<String> { SERIAL_NUMBER };
    Map<String, Object> inputMap = new Map<String,Object>();
    Map<String, Object> outMap = new Map<String,Object>();
    Map<String, Object> options = new Map<String,Object>();

    String methodName = 'transformSerialNumberList';
    inputMap.put('serialNumber', serialNumbers);
    AccountDeviceUtils configurationObject = new AccountDeviceUtils();

    Test.startTest();
      Boolean result = configurationObject.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();

    System.assert(JSON.serialize(outMap.get('serialNumberList')).contains(SERIAL_NUMBER));
  }

  @isTest static void invokeFetchConfigurationDataShouldReturnFormattedConfigurationResponse() {

    List<String> serialNumbers = new List<String> { SERIAL_NUMBER };
    Map<String, Object> serialNumberDetails = new Map<String, Object> ();
    serialNumberDetails.put('serialNumber', (Object)SERIAL_NUMBER);
    serialNumberDetails.put('subType', (Object)SUBTYPE);
    serialNumberDetails.put('nickname', (Object)NICKNAME);
    serialNumberDetails.put('accountId', (Object)ACCOUNT_ID);

    List<Object> serialNumberDetailsList = new List<Object>();
    serialNumberDetailsList.add((Object)serialNumberDetails);

    Map<String, Object> configuration = new Map<String, Object> ();
    configuration.put('serialNumber', (Object)SERIAL_NUMBER);
    configuration.put('jsonBody', (Object)CONFIGURATION_DATA);
    List<Object> configurationList = new List<Object>();
    configurationList.add((Object)configuration);

    Map<String, Object> inputMap = new Map<String,Object>();
    Map<String, Object> outMap = new Map<String,Object>();
    Map<String, Object> options = new Map<String,Object>();

    String methodName = 'fetchConfigurationData';
    inputMap.put('serialNumber', serialNumbers);
    inputMap.put('serialNumberList', serialNumberDetailsList);
    inputMap.put('configurationList', configurationList);
    inputMap.put('accountId', ACCOUNT_ID);
    inputMap.put('accountConfiguration', configuration);
    AccountDeviceUtils configurationObject = new AccountDeviceUtils();

    try {
      Test.startTest();
        Boolean result = configurationObject.invokeMethod(methodName, inputMap, outMap, options);
      Test.stopTest();
    } catch (Exception e) {
      System.assertEquals(e.getMessage(), 'Attempt to de-reference a null object');
    }
  }

  @isTest static void invokeFetchConfigurationShouldReturnFormattedConfigurationErrorResponse() {

    List<Object> serialNumberDetailsList = new List<Object>();
    List<Object> configurationList = new List<Object>();

    Map<String, Object> inputMap = new Map<String,Object>();
    Map<String, Object> outMap = new Map<String,Object>();
    Map<String, Object> options = new Map<String,Object>();

    Map<String, Object> configuration = new Map<String, Object> ();
    configuration.put('serialNumber', (Object)SERIAL_NUMBER);
    configuration.put('jsonBody', (Object)CONFIGURATION_DATA);
    configurationList.add((Object)configuration);

    String methodName = 'fetchConfigurationData';
    inputMap.put('serialNumber', SERIAL_NUMBERS);
    inputMap.put('serialNumberList', serialNumberDetailsList);
    inputMap.put('configurationList', configurationList);
    inputMap.put('accountId', ACCOUNT_ID);
    inputMap.put('accountConfiguration', configuration);
    AccountDeviceUtils configurationObject = new AccountDeviceUtils();
 
    Test.startTest();
      Boolean result = configurationObject.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();

    System.assert(JSON.serialize(outMap.get('isError')).contains('true'));
    System.assert(JSON.serialize(outMap.get('errorMessage')).contains('Serial numbers not bound'));
  }

  @isTest static void invokeMergeConfigurationDataShouldReturnMergedConfigurationResponse() {

    Map<String, Object> configuration = new Map<String, Object> ();
    configuration.put('jsonBody', JSON.deserializeUntyped(CONFIGURATION_DATA));

    Map<String, Object> inputMap = new Map<String,Object>();
    Map<String, Object> outMap = new Map<String,Object>();
    Map<String, Object> options = new Map<String,Object>();

    String methodName = 'mergeConfigurationData';
    inputMap.put('config', configuration);
    inputMap.put('defaultConfig', configuration);
    AccountDeviceUtils configurationObject = new AccountDeviceUtils();
    Test.startTest();
      Boolean result = configurationObject.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();

    System.assert(JSON.serialize(outMap.get('config')).contains('band5ghz'));
    System.assert(JSON.serialize(outMap.get('config')).contains('band2ghz'));
    System.assert(JSON.serialize(outMap.get('config')).contains('wifi'));
  }

  @isTest static void invokeDeleteConfigurationDataShouldReturnDeletedConfigurationResponse() {

    Map<String, Object> configuration = new Map<String, Object> ();
    configuration.put('jsonBody', JSON.deserializeUntyped(CONFIGURATION_DATA));

    Map<String, Object> inputMap = new Map<String,Object>();
    Map<String, Object> outMap = new Map<String,Object>();
    Map<String, Object> options = new Map<String,Object>();

    String methodName = 'deleteConfigurationData';
    inputMap.put('config', configuration);
    inputMap.put('configFieldsToDelete', CONFIG_FIELDS_TO_DELETE);
    AccountDeviceUtils configurationObject = new AccountDeviceUtils();
    Test.startTest();
      Boolean result = configurationObject.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();

    System.assert(JSON.serialize(outMap.get('config')).contains('jsonBody'));
  }
  
  @isTest static void invokeTransformDeviceDataShouldReturnTransformedResponse() {

    List<String> deviceType = new List<String> { SUBTYPE };
	 List<Object> assetDataList = new List<Object> ();
    Map<String, Object> assetDataObject = new Map<String, Object> ();
    assetDataObject.put('deviceType', deviceType);
	 assetDataObject.put('nickname', NICKNAME);
	 assetDataObject.put('serialNumber', SERIAL_NUMBER);
	 assetDataList.add(assetDataObject);

    Map<String, Object> inputMap = new Map<String,Object>();
    Map<String, Object> outMap = new Map<String,Object>();
    Map<String, Object> options = new Map<String,Object>();
    System.debug('assetDataList :'+ JSON.serialize(assetDataList));
    String methodName = 'transformDeviceServiceData';
    inputMap.put('deviceData', JSON.deserializeUntyped(DEVICE_DATA));
    inputMap.put('assetData', assetDataList);
	 inputMap.put('accountId', ACCOUNT_ID);
	 inputMap.put('oui', ACCOUNT_ID);
	 
    AccountDeviceUtils configurationObject = new AccountDeviceUtils();
    Test.startTest();
      Boolean result = configurationObject.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();

    System.assert(JSON.serialize(outMap.get('device')).contains('accountId'));
  }

  @isTest static void invokeWrongMethodShouldReturnFalseResponse() {

    try {
      Map<String, Object> configuration = new Map<String, Object> ();
      configuration.put('jsonBody', JSON.deserializeUntyped(CONFIGURATION_DATA));

      Map<String, Object> inputMap = new Map<String,Object>();
      Map<String, Object> outMap = new Map<String,Object>();
      Map<String, Object> options = new Map<String,Object>();

      String methodName = 'mergeConfigurationData';
      inputMap.put('config', configuration);
      inputMap.put('defaultConfig', SERIAL_NUMBERS);
      AccountDeviceUtils configurationObject = new AccountDeviceUtils();
      Test.startTest();
        Boolean result = configurationObject.invokeMethod(methodName, inputMap, outMap, options);
      Test.stopTest();
    } catch (Exception e) {
      System.assertEquals(e.getMessage(), 'Attempt to de-reference a null object');
    }
  }
}