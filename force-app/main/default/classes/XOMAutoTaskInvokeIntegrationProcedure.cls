/**
 * @group XOMAutoTaskInvokeIntegrationProcedure
 * @description Invokes an integration procedure from an Orchestration Item (auto-task).
 */
global class XOMAutoTaskInvokeIntegrationProcedure implements
vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
  public final static String CLASS_NAME = 'XOMAutoTaskInvokeIntegrationProcedure';
  /*
   * @description Executes auto-task business logic.
   * Not invoked directly but rather called by Vlocity XOM Orchestration engine.
   */
  global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
    String EXECUTE_BATCH = 'executeBatch';
    // Retrieve additional information for Orchestration Items: Order Id, Account Id.
    // This query will return only 1 Orchestration Item which is currently executing in OM.
    List <vlocity_cmt__OrchestrationItem__c> orchestrationItems = [
      SELECT
        Id,
        vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c,
        vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
        vlocity_cmt__AutoTaskParameters__c
      FROM
        vlocity_cmt__OrchestrationItem__c
      WHERE Id IN :items
    ];
    if (orchestrationItems.size() > 1) {
      SObjectException moreThanOneItemsFoundException = new SObjectException();
      moreThanOneItemsFoundException.setMessage(
          String.format(
              'More than 1 Orchestration Items Found. No Of Orchestration Found ({0})',
              new List<String> { String.valueOf(orchestrationItems.size()) })
          );
      LoggingUtility.insertExceptionLog(
          CLASS_NAME, EXECUTE_BATCH, moreThanOneItemsFoundException
      );
      return;
    }
    else if (orchestrationItems.size() == 1) {
      vlocity_cmt__OrchestrationItem__c item = orchestrationItems[0];
      // Initialize variables
      String autoTaskParametersString = item.vlocity_cmt__AutoTaskParameters__c;
      Map<String, Object> autoTaskParametersMap =
          (Map<String, Object>) JSON.deserializeUntyped(autoTaskParametersString);
      // Getting Integration Procedure Name from Map
      String procedureName = (String) autoTaskParametersMap.get('procedureName');
      // Passing OrderId in Map
      autoTaskParametersMap.put(
          'OrderId', item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c);
      // Initializing Maps for Integration Procedure.
      Map<String, Object> ipInput = autoTaskParametersMap;
      Map<String, Object> ipOptions = new Map<String, Object>();

      // If Integration Name is Blank Log it.
      if (String.isBlank(procedureName)) {
        SObjectException ipNotFoundException = new SObjectException();
        ipNotFoundException.setMessage('No Procedure Name found for auto-task');
        LoggingUtility.insertExceptionLog(
            CLASS_NAME, EXECUTE_BATCH, ipNotFoundException
        );
        return;
      }
      // Populating input map for an Integration Procedure structure.
      Id accountId = item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId;
      Id orderId = item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c;
      ipInput.put('accountId', accountId);
      ipInput.put('orderId', orderId);
      ipInput.put('orchestrationItemId', item.Id);
      ipInput.put('orchestrationPlanId', item.vlocity_cmt__OrchestrationPlanId__c);
      vlocity_cmt.IntegrationProcedureService.runIntegrationService(
          procedureName, ipInput, ipOptions);
    }
  }
}