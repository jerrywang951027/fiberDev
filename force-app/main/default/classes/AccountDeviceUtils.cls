/**
 * @group AccountDeviceUtils
 * @description To transform and fetch configuration data related to Account and its Devices.
 */
global with sharing class AccountDeviceUtils implements vlocity_cmt.VlocityOpenInterface2 {

  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * transformConfigurationData, fetchConfigData method.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  global boolean invokeMethod(String methodName, Map <String, Object> inputMap,
      Map <String, Object> outMap, Map <String, Object> options) {

    ConfigurationController configurationObject = new ConfigurationController();
    Boolean result = true;
    try {
      if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('fetchConfigurationData')) {
        configurationObject.fetchConfigurationData(inputMap, outMap, options);
      } else if (String.isNotBlank(methodName) &&
          methodName.equalsIgnoreCase('deleteConfigurationData')) {
        configurationObject.deleteConfigurationData(inputMap, outMap, options);
      } else if (String.isNotBlank(methodName) &&
          methodName.equalsIgnoreCase('mergeConfigurationData')) {
        configurationObject.mergeConfigurationData(inputMap, outMap, options);
      } else if (String.isNotBlank(methodName) &&
          methodName.equalsIgnoreCase('transformSerialNumberList')) {
        configurationObject.transformSerialNumberList(inputMap, outMap, options);
      } else if (String.isNotBlank(methodName) &&
          methodName.equalsIgnoreCase('transformAssetModelResponse')) {
        configurationObject.transformAssetModelResponse(inputMap, outMap, options);
      } else if (String.isNotBlank(methodName) &&
          methodName.equalsIgnoreCase('fetchAssetModelData')) {
        configurationObject.fetchAssetModelData(inputMap, outMap, options);
      } else if (String.isNotBlank(methodName) &&
          methodName.equalsIgnoreCase('transformDeviceServiceData')) {
        configurationObject.transformDeviceServiceData(inputMap, outMap, options);
      }
    } catch (Exception exp) {
      result = false;
      LoggingUtility.insertExceptionLog('AccountDeviceUtils', 'invokeMethod', exp);
      throw exp;
    }
    return result;
  }
}