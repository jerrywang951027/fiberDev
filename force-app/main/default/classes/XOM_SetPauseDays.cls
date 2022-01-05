/**
 *
 *  @description class for setting the pause days records.
 */
global with sharing class XOM_SetPauseDays implements
    vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

  global class AutoTaskUnrecoverableException extends Exception {
  }

  // Initialize class constants.
  public static final String CREATE_PAUSE_HISTORY_METHOD_NAME = 'createPauseHistoryForPauseOrder';
  public static final String MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE =
      'Please provide service account on order.';
  public static final String MISSING_ORDER_ID_ERROR_MESSAGE = 'Order Id is blank';
  public static final String ORCH_ITEM_MISSING_ERROR_MESSAGE = 'Orchestration item is missing.';
  public static final String EXECUTE_BATCH_METHOD_NAME = 'executeBatch';
  public static final String CLASS_NAME = 'XOM_SetPauseDays';

  /**
   * @description Executes auto-task business logic.
   * Not invoked directly but rather called by Vlocity XOM Orchestration engine.
   * @param items The list of orchestration items.
   * @return null
   */
  global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {

    if(items.isEmpty()) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          EXECUTE_BATCH_METHOD_NAME, ORCH_ITEM_MISSING_ERROR_MESSAGE);
      AutoTaskUnrecoverableException autoTaskException =
          new AutoTaskUnrecoverableException('ERROR: ' + ORCH_ITEM_MISSING_ERROR_MESSAGE);
      autoTaskException.setMessage(ORCH_ITEM_MISSING_ERROR_MESSAGE);
      throw autoTaskException;
    }
    vlocity_cmt__OrchestrationItem__c item= items[0];

    List<vlocity_cmt__OrchestrationItem__c> orchItems =  [
        SELECT
          Id,
          vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c
        FROM
          vlocity_cmt__OrchestrationItem__c
        WHERE
          Id = :item.id
        LIMIT 1
      ];

    String orderId =
        orchItems[0].vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c;

    createPauseHistoryForPauseOrder(orderId);

  }

  /**
   * @description This method creates the pause records.
   * @param serviceAccountId
   * @param pauseStartDate
   * @param orderId
   * @return null
   */
  public void createPauseHistoryForPauseOrder(String orderId){

    if(String.isBlank(orderId)) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          CREATE_PAUSE_HISTORY_METHOD_NAME,
          MISSING_ORDER_ID_ERROR_MESSAGE);

      AutoTaskUnrecoverableException autoTaskException =
          new AutoTaskUnrecoverableException();
      autoTaskException.setMessage(
          MISSING_ORDER_ID_ERROR_MESSAGE);
      throw autoTaskException;
    }
    Order order = [
      SELECT
        Id,
        vlocity_cmt__DefaultServiceAccountId__c
      FROM
        Order
      WHERE
        Id = :orderId
      LIMIT 1
    ];
    String serviceAccountId =
        order.vlocity_cmt__DefaultServiceAccountId__c;
    Datetime pauseStartDate = System.now();
    if(String.isBlank(serviceAccountId)) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          CREATE_PAUSE_HISTORY_METHOD_NAME, MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE);
      AutoTaskUnrecoverableException autoTaskException = new AutoTaskUnrecoverableException();
      autoTaskException.setMessage(MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE);
      throw autoTaskException;
    }
    Pause_History__c pause = new Pause_History__c();
    pause.Start_Date__c = pauseStartDate;
    pause.Pause_Order_Id__c = orderId;
    pause.Account__c = serviceAccountId;

    insert pause;
  }
}