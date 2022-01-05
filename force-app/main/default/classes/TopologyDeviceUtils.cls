/**
 * @group TopologyDeviceUtils
 * @description To transform and fetch configuration data related to Topology and its Devices.
 */
global with sharing class TopologyDeviceUtils implements vlocity_cmt.VlocityOpenInterface2 {

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
          
          TopologyController topologyObject = new TopologyController();
          Boolean result = true;
          try {
              if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('removeDeviceData')) {
                  topologyObject.removeDeviceData(inputMap, outMap, options);
              } 
          } catch (Exception exp) {
              result = false;
              LoggingUtility.insertExceptionLog('TopologyDeviceUtils', 'invokeMethod', exp);
              throw exp;
          }
          return result;
      }
}