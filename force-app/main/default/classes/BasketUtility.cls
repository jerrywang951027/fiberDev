/**
 * @group BasketUtility
 * @description Utility class for functionality related to basket.
 */
public with sharing class BasketUtility {

  // Initialize class constants.
  public static final String CLASS_NAME = 'BasketUtility';

  // Keys for input map.
  public static final String INPUT_METHOD_NAME_KEY = 'methodName';
  public static final String INPUT_API_NAME_KEY = 'apiName';
  public static final String INPUT_CATALOG_CODE_KEY = 'catalogCode';
  public static final String INPUT_REQUEST_URL_KEY = 'requestURL';

  // Keys for output map.
  public static final String OUTPUT_NEXT_TRANSACTION_KEY = 'nexttransaction';
  public static final String OUTPUT_REST_KEY = 'rest';
  public static final String OUTPUT_PARAMS_KEY = 'params';
  public static final String OUTPUT_MULTI_TRANSACTION_KEY = 'multiTransactionKey';

  /**
   * @description This method calls the CpqAppHandler invokeMethod
   * and keeps on calling until the multiTransactionKey is returned
   * as null from the invokeMethod.
   * @param inputMap
   * @param outMap
   * @param options
   */
  public static void createBasket(
      Map<String, Object> inputMap,
      Map<String, Object> outMap,
      Map<String, Object> options
  ) {
    String methodName = String.valueOf(
        inputMap.get(INPUT_METHOD_NAME_KEY));
    String catalogCode = String.valueOf(
        inputMap.get(INPUT_CATALOG_CODE_KEY));
    String apiName = String.valueOf(
        inputMap.get(INPUT_API_NAME_KEY));
    String requestUrl = String.valueOf(
        inputMap.get(INPUT_REQUEST_URL_KEY));
    String multiTransactionKey = null;
    vlocity_cmt.CpqAppHandler cpq = new vlocity_cmt.CpqAppHandler();
    do {
      if(multiTransactionKey != null) {
        inputMap.clear();
        inputMap.put(INPUT_METHOD_NAME_KEY, methodName);
        inputMap.put(INPUT_API_NAME_KEY, apiName);
        inputMap.put(INPUT_CATALOG_CODE_KEY, catalogCode);
        inputMap.put(INPUT_REQUEST_URL_KEY, requestURL);
        inputMap.put(OUTPUT_MULTI_TRANSACTION_KEY, multiTransactionKey);
        outMap.clear();
      }
      cpq.invokeMethod(methodName, inputMap, outMap, options);
      multiTransactionKey = getMultiTransactionKey(
          (Map<String, Object>)outMap.get(OUTPUT_NEXT_TRANSACTION_KEY));
    } while(multiTransactionKey != null);
  }

  /**
   * @description This method returns the value of the multiTrasnaction
   * key if the nexttransaction json node is not empty.
   * @param nextTransaction
   * @return String This method returns multiTransaction key if
   * nexttransaction JSON node is not empty else returns null.
   */
  public static String getMultiTransactionKey(
      Map<String, Object> nextTransaction)
  {
    if(nextTransaction != null) {
      Map<String, Object> paramsMap = (Map<String, Object>)(
        (Map<String, Object>)((Map<String, Object>)nextTransaction)
          .get(OUTPUT_REST_KEY)).get(OUTPUT_PARAMS_KEY);
      return String.valueOf(
        paramsMap.get(OUTPUT_MULTI_TRANSACTION_KEY)
      );
    }
    return null;
  }

}