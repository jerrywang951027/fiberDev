/**
 * @group DateHelper
 * @description Standard class for Functionality related to updation of date.
 */
global with sharing class OrderManagementUtils implements vlocity_cmt.VlocityOpenInterface {

  // Initialize Class Constants
  public static final String CLASS_NAME = 'OrderManagementUtils';

  // Method names constant
  public static final String ADD_ZUORA_RATE_PLANID_METHOD_NAME = 'addzuorarateplanid';
  public static final String COPY_BASE_CHARGES_METHOD_NAME = 'copyBaseCharges';
  public static final String FORMAT_URL_METHOD_NAME = 'formatUrl';
  public static final String GET_FUTURE_SHIPMENT_DATE_METHOD_NAME = 'getFutureShipmentDate';
  public static final String GENERATE_PDF_METHOD_NAME = 'generatePdf';
  public static final String INVOKE_METHOD_NAME = 'invokeMethod';
  public static final String MERGE_MODEL_NAME_METHOD_NAME = 'mergeModelName';
  public static final String MERGE_SERIAL_NUMBER_METHOD_NAME = 'mergeSerialNumber';
  public static final String SPLIT_ADDRESS_METHOD_NAME = 'splitAddress';
  public static final String UPLOAD_PDF_FILE_METHOD_NAME = 'uploadPdfFile';

  // Error message constant
  public static final String ERROR_MESSAGE_METHOD_NAME_NOT_FOUND = 'No match found for method: ';

  // Input map key constant
  public static final String INPUT_MAP_ADDRESS_KEY = 'address';
  public static final String INPUT_MAP_ARGUMENTS = 'arguments';
  public static final String INPUT_MAP_FORMATTING_URL = 'formattingUrl';

  // Output map key constant
  public static final String OUTPUT_MAP_FORMATTED_URL_KEY = 'formattedUrl';
  public static final String OUTPUT_MAP_HOUSE_NUMBER_KEY = 'houseNumber';
  public static final String OUTPUT_MAP_STREET_NAME_KEY = 'streetName';

  /**
   * @description This method is mandatory for Vlocity Open Interface.
   */
  global Boolean invokeMethod(String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options) {
    // Check if method is found. Return true.
    try {
      if (methodName
          .equalsIgnoreCase(GET_FUTURE_SHIPMENT_DATE_METHOD_NAME)) {
        getFutureShipmentDate(output);
        return true;
      } else if (methodName.equalsIgnoreCase('generateKey')) {
        generateKey(input, output, options);
        return true;
      } else if(methodName
          .equalsIgnoreCase(MERGE_MODEL_NAME_METHOD_NAME)){
        GpnUtility.mergeModelName(input, output,options);
        return true;
      } else if(methodName
          .equalsIgnoreCase(MERGE_SERIAL_NUMBER_METHOD_NAME)){
        GpnUtility.mergeSerialNumber(input, output,options);
        return true;
      } else if(methodName
          .equalsIgnoreCase(ADD_ZUORA_RATE_PLANID_METHOD_NAME)){
        ZuoraUtils.addZuoraRatePlanId(input, output,options);
        return true;
      } else if(methodName
          .equalsIgnoreCase(SPLIT_ADDRESS_METHOD_NAME)) {
        splitAddress(input, output, options);
        return true;
      } else if(methodName
          .equalsIgnoreCase(FORMAT_URL_METHOD_NAME)) {
        formatUrl(input, output, options);
        return true;
      } else if(methodName
          .equalsIgnoreCase(GENERATE_PDF_METHOD_NAME)) {
        LoaPdfUtility.generatePdf(input, output, options);
        return true;
      } else if(methodName
          .equalsIgnoreCase(UPLOAD_PDF_FILE_METHOD_NAME)){
        LoaPdfUtility.uploadPdfFile(input, output, options);
        return true;
          } else if(methodName
            .equalsIgnoreCase(COPY_BASE_CHARGES_METHOD_NAME)) {
            CopyBaseChargePricingPlanStepImpl.copyBaseCharges();
            return true;
            }
        else{
        // Check if method is not found. Return false.
        String errorMessage =
            ERROR_MESSAGE_METHOD_NAME_NOT_FOUND + methodName;
        LoggingUtility.insertExceptionLog(CLASS_NAME,
            INVOKE_METHOD_NAME, errorMessage);
        return false;
      }
    }
    // Exception occured. Throw exception.
    catch (Exception ex) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, methodName, ex);
      throw ex;
    }
  }
  /**
   * @description This method is to add two hours in Shipment Future date.
   */
  private void getFutureShipmentDate(Map<String, Object> output) {
    DateTime updateDateTime = System.now().addHours(2);
    output.put('updateDateTime', updateDateTime);
  }

  /**
  * @description implementation of the method that invokes the generateRandomId
  * at KeyGenerator, which will return unique account id
  * @param inputMap The key value pair that will be passed to the invoked method
  * @param outMap map that will receive the map of the response
  * @param options map optional parameters
  */
  public void generateKey(Map<String,Object> inputMap, Map<String,Object> outputMap,
      Map<String,Object> options){

    String keyPrefix = (String)inputMap.get('prefix');
    Integer keyTotalLength = (Integer)inputMap.get('totalLength');
    Integer keySegmentSize = (Integer)inputMap.get('segmentSize');

    String returnedKey =
        KeyGenerator.generateRandomId(keyPrefix, keyTotalLength , keySegmentSize);
    outputMap.put('returnedKey',returnedKey);
  }

  /**
   * @description This method splits the address and sends house
   * number and street name as the output.
   * @param inputMap The key value pair that will be passed to the invoked method
   * @param outMap map that will receive the map of the response
   * @param options map optional parameters
   */
  public void splitAddress(Map<String, Object> inputMap,
      Map<String, Object> outMap,
      Map<String, Object> options) {
    String houseNumber = null;
    String streetName = null;
    String address = String.valueOf(
        inputMap.get(INPUT_MAP_ADDRESS_KEY));
    Integer spaceIndex = address.indexOf(' ');
    houseNumber = address.substring(0, spaceIndex);
    streetName = address.substring(spaceIndex + 1);
    outMap.put(OUTPUT_MAP_HOUSE_NUMBER_KEY, houseNumber);
    outMap.put(OUTPUT_MAP_STREET_NAME_KEY, streetName);
  }

  /**
   * @description This method format the url
   * and also append the order id in url.
   */
  public void formatUrl(Map<String, Object> inputMap,
      Map<String, Object> outMap,
      Map<String, Object> options) {
    String formattingUrl = String.valueOf(
        inputMap.get(INPUT_MAP_FORMATTING_URL));
    List<Object> listOfArguments = (List<Object>)inputMap.get(INPUT_MAP_ARGUMENTS);
    String formattedUrl = String.format(formattingUrl, listOfArguments);
    outMap.put(OUTPUT_MAP_FORMATTED_URL_KEY, formattedUrl);
  }

}