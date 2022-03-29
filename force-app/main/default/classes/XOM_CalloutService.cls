/**
 * @group Order Orchestration
 * @description Invokes an integration procedure from an orchestration item (callout)
 */
global class XOM_CalloutService extends vlocity_cmt.DefaultSystemInterface {

  global class DefaultInterfaceUnrecoverableException extends Exception {
  }

  // Initialize Class Constants.
  public static final String CLASS_NAME = 'XOM_CalloutService';
  public static final String PROCESS_IP_METHOD = 'processIPResponse';
  public static final String API_RESPONSE_ERROR_MESSAGE = 'API Callout Response is unsuccessfull';
  public static final String EXECUTE_ITEM_METHOD = 'executeItem';
  public static final String IP_BLANK_MESSAGE = 'Integration Procedure name is not provided';
  public static final String IP_Inactive_MESSAGE = 'No Active Procedure Found';
  public static final String INTEGRATION_PROCEDURE_METHOD = 'invokeIntegrationProcedure';

  // Keys for vlocity_cmt__OrchestrationItem__c.AutoTaskParameters.
  public static final String AUTOTASK_KEY_CAMPAIGN_ID = 'Campaign_Id';
  public static final String AUTOTASK_KEY_IP_NAME = 'integrationProcedureName';

  // Keys for ipInput
  public static final String IP_INPUT_KEY_ACCOUNT_ID = 'accountId';
  public static final String IP_INPUT_KEY_CAMPAIGN_ID = 'campaignId';
  public static final String IP_INPUT_KEY_FRL_ID = 'frlId';
  public static final String IP_INPUT_KEY_ORDER_ID = 'orderId';
  public static final String IP_INPUT_KEY_ORCH_ITEM_ID = 'orchestrationItemId';
  public static final String IP_INPUT_KEY_ORCH_ITEM_NAME = 'orchestrationItemName';
  public static final String IP_INPUT_KEY_ORCH_PLAN_ID = 'orchestrationPlanId';

  // Keys for ipOutput
  public static final String IP_OUTPUT_K_API_RESPONSE = 'APIResponse';
  public static final String IP_OUTPUT_KEY_ERROR = 'error';
  public static final String IP_OUTPUT_KEY_REASONS = 'reasons';
  public static final String IP_OUTPUT_KEY_SUCCESS = 'success';

  // Initialize global map for IP response.
  public Map<String, Object> ipResponse = new Map<String, Object>();

  /**
   * @description Invoked when the callout is using an Integration Procedure.
   * @param ipOutput the output from the Integration Procedure
   */
  global void processIpResponse(Map<String, Object> ipOutput) {
    // Check for error
    if (ipOutput != null && ipOutput.get(IP_OUTPUT_KEY_API_RESPONSE) != null) {
      Map<String, Object> apiResponse = (Map<String, Object>)ipOutput.get(IP_OUTPUT_KEY_API_RESPONSE);
      if (apiResponse != null) {
        if (apiResponse.get(IP_OUTPUT_KEY_SUCCESS) == false || apiResponse.get(IP_OUTPUT_KEY_ERROR) != null) {
          LoggingUtility.insertExceptionLog(
            CLASS_NAME, PROCESS_IP_METHOD, API_RESPONSE_ERROR_MESSAGE);
          throw new DefaultInterfaceUnrecoverableException ('IP Error Response: ' + apiResponse);
        }
      }
    }
  }

  /**
   * @description Executes a Callout OrchestrationItem.
   * @param url Base URL to send the request to
   * @param path Path to send the request to
   * @param item OrchestrationItem that needs to be executed
   */
  global virtual override void executeItem(
    String url, String path, vlocity_cmt__OrchestrationItem__c item) {
    // Retrieve information for orchestration items: order Id, account Id
    Map<String, Object> autoTaskParametersMap = new Map<String, Object>();
    List<vlocity_cmt__OrchestrationItem__c> orchestrationItems = 
    [SELECT Id,
      vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c,
      vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
      vlocity_cmt__AutoTaskParameters__c,
      vlocity_cmt__FulfilmentRequestLineId__c
    FROM 
      vlocity_cmt__OrchestrationItem__c
    WHERE
      Id =:item.Id];

    vlocity_cmt__OrchestrationItem__c orchestrationItem = orchestrationItems[0];
    // Populating autoTaskParametersMap to get Integration Procedure Details.
    String autoTaskParametersString = orchestrationItem.vlocity_cmt__AutoTaskParameters__c;
    if (autoTaskParametersString != null) {
      autoTaskParametersMap =
        (Map<String, Object>)JSON.deserializeUntyped(autoTaskParametersString);
    }

    // Initialize Maps for Integration Procedure.
    Map<String, Object> ipInput = new Map<String, Object>();
    Map<String, Object> ipOutput = new Map<String, Object>();
    Map<String, Object> ipOptions = new Map<String, Object>();

    // Populating input map for an Integration Procedure. Follow whatever structure your VIP expects
    // If you need more input information for VIP, you can extend the code here.
    // Alternatively, you can use dataraptors within your VIP to collect such information.
    String accountId =
      orchestrationItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId;
    String orderId = item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c;
    String orchestrationItemId = item.Id;
    String orchestrationItemName = item.Name;
    String orchestrationPlanId = item.vlocity_cmt__OrchestrationPlanId__c;
    String fulfilmentRequestLineId = orchestrationItem.vlocity_cmt__FulfilmentRequestLineId__c;
    ipInput.put(IP_INPUT_KEY_ACCOUNT_ID, accountId);
    ipInput.put(IP_INPUT_KEY_ORDER_ID, orderId);
    ipInput.put(IP_INPUT_KEY_ORCH_ITEM_ID, orchestrationItemId);
    ipInput.put(IP_INPUT_KEY_ORCH_ITEM_NAME, orchestrationItemName);
    ipInput.put(IP_INPUT_KEY_ORCH_PLAN_ID, orchestrationPlanId);
    ipInput.put(IP_INPUT_KEY_FRL_ID, fulfilmentRequestLineId);

    // Retrieve Integration Procedure Name from AutoTask Parameters.
    String ipName = autoTaskParametersMap.get(AUTOTASK_KEY_IP_NAME) != null
      ? String.valueOf(autoTaskParametersMap.get(AUTOTASK_KEY_IP_NAME))
      : '';

    // Retireve Campaign Id from AutoTask Parameters if campaign Id exists.
    String campaignId = autoTaskParametersMap.get(AUTOTASK_KEY_CAMPAIGN_ID)!= null
      ? String.valueOf(autoTaskParametersMap.get(AUTOTASK_KEY_CAMPAIGN_ID))
      : null;

    if(String.isNotBlank(campaignId)){
      ipInput.put(IP_INPUT_KEY_CAMPAIGN_ID, campaignId);
    }

    if (String.isNotBlank(ipName)) {
      // Invoke Integration Procedure.
      invokeIntegrationProcedure(ipName, ipInput, ipOutput, ipOptions);
      // Process Response of the Integration Procedure.
      processIpResponse(ipResponse);
    }
    else {
      LoggingUtility.insertExceptionLog(CLASS_NAME, EXECUTE_ITEM_METHOD, IP_BLANK_MESSAGE);
      throw new DefaultInterfaceUnrecoverableException ('IP Error Response: ' + IP_BLANK_MESSAGE);
    }
  }

  /**
   * @description Executes an Integration Procedure based on Name and Inputs.
   * @param procedureName Name of the Integration Procedure
   * @param ipInput InputMap for Integration Procedure
   * @param ipOutput OutputMap for Integration Procedure
   * @param ipOptions OptionsMap for Integration Procedure
   */

  public void invokeIntegrationProcedure(String procedureName,
      Map<String, Object> ipInput,
      Map<String, Object> ipOutput,
      Map<String, Object> ipOptions) {
    if (!Test.isRunningTest()){
      if (String.isBlank(procedureName)) {
        LoggingUtility.insertExceptionLog(CLASS_NAME, INTEGRATION_PROCEDURE_METHOD, IP_BLANK_MESSAGE);
        throw new DefaultInterfaceUnrecoverableException ('IP Error Response: ' + IP_BLANK_MESSAGE);
      }

      // Call the IP via runIntegrationService, and save the output to ipResponse
      ipResponse = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(
        procedureName, ipInput, ipOptions);
      Boolean result = ipResponse.containsKey('error');
      if (result == true)
      {
        throw new DefaultInterfaceUnrecoverableException ('IP Error Response: ' + IP_Inactive_MESSAGE);
      }
    }
  }
}