/**
 * @group BandWidth_Status_Polling__e
 * @description This class is responsible for making a callout to
 * bandwidth status polling api.
 */
public with sharing class BandwidthStatusPollingCallout implements
    Queueable, Database.AllowsCallouts {

  // Initialize Class Constants.
  public static final String CLASS_NAME = 'BandwidthStatusPollingCallout';
  public static final String API_CALLOUT_METHOD_NAME = 'apiCallout';
  public static final String PROCESS_IP_RESPONSE_METHOD_NAME = 'processIpResponse';
  public static final String INVOKE_DR_METHOD_NAME = 'invokeDataRaptor';
  public static final String STATUS_COMPLETE_VALUE = 'COMPLETE';

  // Keys for ipInput.
  public static final String IP_INPUT_FRL_ID_KEY = 'frlId';
  public static final String IP_INPUT_RETIREVED_STATUS_KEY = 'retirevedStatus';
  public static final String IP_INPUT_ORDER_MESSAGE_KEY = 'orderMessage';
  public static final String IP_INPUT_TRANSACTION_STATUS_KEY = 'transactionStatus';
  public static final String IP_INPUT_FOC_DATE_KEY = 'focDate';

  // Keys for ipOutput.
  public static final String IP_OUTPUT_SUCCESS_KEY = 'success';
  public static final String IP_OUTPUT_ERROR_KEY = 'error';

  // Keys for dataraptor output.
  public static final String DR_OUTPUT_PROCESSING_STATUS_KEY = 'processingStatus';
  public static final String DR_OUTPUT_FOC_DATE_KEY = 'focDate';
  public static final String DR_OUTPUT_ERRORS_KEY = 'errors';
  public static final String DR_OUTPUT_ERROR_CODE_KEY = 'errorCode';
  public static final String DR_OUTPUT_ERROR_DESCRIPTION_KEY = 'errorDescription';

  // Callout details keys.
  public static final String CALLOUT_GET_METHOD = 'GET';
  public static final String CALLOUT_ENDPOINT_KEY = 'endpoint';
  public static final String CALLBACK_IP_NAME_KEY = 'callbackIpName';
  public static final String CALLOUT_MAX_RETRY_KEY = 'maxRetry';
  public static final String CALLOUT_TRANSFORM_RESPONSE_KEY = 'calloutTransformResponse';

  // Keys for error message.
  public static final String ERROR_MESSAGE_DR_TRANSFORM_EMPTY_RESPONSE = 'Dataraptor transform response is blank.';
  public static final String ERROR_MESSAGE_CALLOUT_RETRY_COUNT_EXCEED = 'Callout retry count exceeded.';
  
  // Initialize variables for callout. 
  private Bandwidth_Status_Polling__e statusPollingEvent;
  private Map<String, Object> calloutDetails;
  private Integer currentRetryCount;

  // Constructor
  public BandwidthStatusPollingCallout(Bandwidth_Status_Polling__e statusPollingEvent,
      Map<String, Object> calloutDetails, Integer currentRetryCount) {
    this.statusPollingEvent = statusPollingEvent;
    this.calloutDetails = calloutDetails;
    this.currentRetryCount = currentRetryCount;
  }

  /**
   * @decription Executes the queueable api callout.
   * @param context
   */
  public void execute(QueueableContext context) {
    apiCallout();
  }

  /**
   * @description This method makes the bandwidth api callout based on the
   * event type and details of the callout present inside the calloutDetails
   * parameter.
   */
  public void apiCallout() {
    String retirevedStatus = null;
    String orderMessage = null;
    String transactionStatus = null;
    Map<String, Object> ipInput = new Map<String, Object>();
    Map<String, Object> ipOutput = new Map<String, Object>();
    Map<String, Object> ipOptions = new Map<String, Object>();
    String ipName = String.valueOf(
        calloutDetails.get(CALLBACK_IP_NAME_KEY));
    Integer maxRetry = Integer.valueOf(
        calloutDetails.get(CALLOUT_MAX_RETRY_KEY));
    try{
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      request.setEndpoint(String.valueOf(
          calloutDetails.get(CALLOUT_ENDPOINT_KEY)));
      request.setMethod(CALLOUT_GET_METHOD);
      response = http.send(request);
      if(response.getStatusCode() != 200) {
        LoggingUtility.insertExceptionLog(CLASS_NAME, API_CALLOUT_METHOD_NAME,
            response.getBody() + response.getStatus());
        return;
      }
      Map<String, Object> jsonResponse = invokeDataRaptor(
          String.valueOf(calloutDetails.get(CALLOUT_TRANSFORM_RESPONSE_KEY)),
          response.getBody());
      if(jsonResponse == null || jsonResponse.isEmpty()) {
        LoggingUtility.insertExceptionLog(CLASS_NAME, API_CALLOUT_METHOD_NAME,
            ERROR_MESSAGE_DR_TRANSFORM_EMPTY_RESPONSE);
        return;
      }
      retirevedStatus = String.valueOf(jsonResponse.get(
          DR_OUTPUT_PROCESSING_STATUS_KEY));
      // Return if the current status and retireved status are same.
      if(!String.isBlank(retirevedStatus) &&
          statusPollingEvent.Current_Status__c.equalsIgnoreCase(
          retirevedStatus)) {
        return;
      }
      ipInput.put(IP_INPUT_FRL_ID_KEY, statusPollingEvent.FRL_Id__c);
      ipInput.put(IP_INPUT_RETIREVED_STATUS_KEY, retirevedStatus);
      ipInput.put(IP_INPUT_ORDER_MESSAGE_KEY, setOrderMessage(
        jsonResponse.containsKey(DR_OUTPUT_ERRORS_KEY) ?
        (List<Object>)jsonResponse.get(DR_OUTPUT_ERRORS_KEY)
        : null
      ));
      ipInput.put(IP_INPUT_TRANSACTION_STATUS_KEY,
          setTransactionStatus(retirevedStatus,
          statusPollingEvent.Event_Type__c));
      ipInput.put(IP_INPUT_FOC_DATE_KEY, jsonResponse.get(
          DR_OUTPUT_FOC_DATE_KEY));
      invokeIntegrationProcedure(ipName, ipInput, ipOutput, ipOptions);
    }
    catch(CalloutException e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, API_CALLOUT_METHOD_NAME,
          e.getMessage());
      if(maxRetry >= currentRetryCount) {
        System.enqueueJob(new BandwidthStatusPollingCallout(
            statusPollingEvent, calloutDetails, ++currentRetryCount));
      }
      else{
        LoggingUtility.insertExceptionLog(CLASS_NAME, API_CALLOUT_METHOD_NAME,
            ERROR_MESSAGE_CALLOUT_RETRY_COUNT_EXCEED);
      }
    }
    catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
        API_CALLOUT_METHOD_NAME, e.getMessage());
    }
  }

  /**
   * @description Executes an Integration Procedure based on Name and Inputs.
   * @param procedureName Name of the Integration Procedure
   * @param ipInput InputMap for Integration Procedure
   * @param ipOutput OutputMap for Integration Procedure
   * @param ipOptions OptionsMap for Integration Procedure
   * @return null
   */
  public static void invokeIntegrationProcedure(
    String procedureName,
    Map<String, Object> ipInput,
    Map<String, Object> ipOutput,
    Map<String, Object> ipOptions
  )
  {
    // Call the IP via runIntegrationService, and save the output to ipOutput.
    ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(
      procedureName, ipInput, ipOptions);
    // Process the response of the IP.
    processIpResponse(ipOutput);
  }
  /**
   * @description This method processes the output of the Integration
   * Procedure.
   * @param ipOutput the output from the Integration Procedure
   * @return null
   */
  public static void processIpResponse(Map<String, Object> ipOutput) {
    if(ipOutput != null) {
      if(ipOutput.get(IP_OUTPUT_SUCCESS_KEY) == false ||
          ipOutput.containsKey(IP_OUTPUT_ERROR_KEY)) {
        LoggingUtility.insertExceptionLog(CLASS_NAME,
          PROCESS_IP_RESPONSE_METHOD_NAME, String.valueOf(ipOutput));
      }
    }
  }

  /**
   * @description This method executes the dataraptor which takes xml string 
   * as an input and converts it to json.
   * @param dataraptorName Name of the dataraptor.
   * @param xmlInput Xml string.
   * @return transformed json.
   */
  public static Map<String, Object> invokeDataRaptor(String dataraptorName,
      String xmlInput) {
    vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processString(
        xmlInput, dataraptorName);
    if(result.toJson() == null) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, INVOKE_DR_METHOD_NAME,
          ERROR_MESSAGE_DR_TRANSFORM_EMPTY_RESPONSE);
      return null;
    }
    return (Map<String, Object>)result.toJson();
  }

  /**
   * @description This method creates the order message string from errors array.
   * @param errors
   * @return String
   */
  public static String setOrderMessage(List<Object> errors) {
    String orderMessage = '';
    if(errors == null || errors.isEmpty()) {
      return null;
    }
    for(Object errorObject: errors) {
      Map<String, Object> error = (Map<String, Object>)errorObject;
      String errorCode = String.valueOf(error.get(DR_OUTPUT_ERROR_CODE_KEY));
      String errorDescription = String.valueOf(
          error.get(DR_OUTPUT_ERROR_DESCRIPTION_KEY));
      orderMessage = (String.isBlank(orderMessage) ?
          orderMessage : orderMessage + ';') + errorCode + ':'
          + errorDescription;
    }
    return orderMessage;
  }

  /**
   * @description This method set the transaction status.
   * @param retirevedStatus
   * @param eventType
   * @return String
   */
  public static String setTransactionStatus(String retirevedStatus,
      String eventType) {
    String transactionStatus = null;
    switch on eventType {
      when 'E911' {
        transactionStatus = STATUS_COMPLETE_VALUE.containsIgnoreCase(
            retirevedStatus) ?
            Constants.FRL.ASYNC_TRANSACTION_STATUS.E911_COMPLETE
            : Constants.FRL.ASYNC_TRANSACTION_STATUS.E911_IN_PROGRESS;
      }
      when else {
        transactionStatus = STATUS_COMPLETE_VALUE.equalsIgnoreCase(
            retirevedStatus) ?
            Constants.FRL.ASYNC_TRANSACTION_STATUS.PORTIN_COMPLETE
            : Constants.FRL.ASYNC_TRANSACTION_STATUS.PORTIN_IN_PROGRESS;
      }
    }
    return transactionStatus;
  }

}