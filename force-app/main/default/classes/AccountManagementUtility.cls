/**
 * @group AccountManagementUtility
 * @description Utility class for functionality related to AMS.
 */
global with sharing class AccountManagementUtility
  implements vlocity_cmt.VlocityOpenInterface2 {

  // Initialize class constants.
  public static final String CLASS_NAME = 'AccountManagementUtility';
  public static final String INVOKE_METHOD_NAME = 'invokeMethod';
  public static final String CREATE_BASKET_METHOD_NAME = 'createBasket';

  // Keys for error message.
  public static final String ERROR_MESSAGE_METHOD_NAME_BLANK = 'No match found for method: ';

  // Keys for output map.
  public static final String OUTPUT_MAP_ERROR_KEY = 'error';

  /**
   * @description This method is mandatory as we implements vlocity Open interface.
   * This method is by default called from Vlocity Components.
   * @param methodName
   * @param inputMap
   * @param outMap
   * @param options
   */
  global Boolean invokeMethod(String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options) {
    try{
      if(methodName.equalsIgnoreCase(CREATE_BASKET_METHOD_NAME)) {
        BasketUtility.createBasket(inputMap, outMap, options);
        return true;
      }
      else {
        String errorMessage = ERROR_MESSAGE_METHOD_NAME_BLANK + methodName;
        LoggingUtility.insertExceptionLog(CLASS_NAME, INVOKE_METHOD_NAME,
            errorMessage);
        outMap.put(OUTPUT_MAP_ERROR_KEY, errorMessage);
        return false;
      }
    } catch(Exception e) {
        LoggingUtility.insertExceptionLog(CLASS_NAME, INVOKE_METHOD_NAME,
            e);
        throw e;
    }
  }

}