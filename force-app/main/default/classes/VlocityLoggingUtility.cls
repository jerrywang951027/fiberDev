/**
@group VlocityLoggingUtility
@description Logging Utility for Vlocity components.
*/
global class VlocityLoggingUtility implements vlocity_cmt.VlocityOpenInterface2 {
    global class MethodNotFoundException extends Exception {
  }
  /*
  * @description This method is mandatory as we implement Vlocity open interface.
  * This method is by default called from Vlocity components.
  */

  // Method name reference for LogIpResult which will be referenced in Integration Procedure.
  public static final String LOG_IP_RESULT_METHOD = 'LogIPResult';

  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    // Check if method is found and initialze it to false.
    Boolean result = false;
    try {
      // If Method name is not blank and it is equal to LOG_IP_RESULT_METHOD.
      if (String.isNotBlank(methodName) && LOG_IP_RESULT_METHOD.equalsIgnoreCase(methodName)) {
        result = true;
        // Getting the Integration Procedure name from inputMap
        String iPName = (String)inputMap.get('IPName');
        // Getting the Integration Procedure Element Name from inputMap
        String elementName = (String)inputMap.get('ElementName');
        // Getting the Error Message from InputMap
        String errorMessage = (String)inputMap.get('ErrorMessage');
        // Creating Exception and Logging it
        LoggingUtility.insertExceptionLog(
            iPName,
            elementName,
            errorMessage
        );
      } else {
        MethodNotFoundException e = new MethodNotFoundException
            ('No match found for method' + methodName);
        throw e;
      }
    } catch (Exception e) {
      LoggingUtility.insertExceptionLog(
          'VlocityLoggingUtility',
          methodName,
          e
      );
      throw e;
    }
    // returning result
    return result;
  }
}