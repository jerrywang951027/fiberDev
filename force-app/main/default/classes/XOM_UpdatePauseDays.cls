/**
 * @group PauseDays
 * @description class for updating the prevous pause days records
 * and creating new pause records.
 */
global with sharing class XOM_UpdatePauseDays implements
    vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

  global class AutoTaskUnrecoverableException extends Exception {
  }

  // Initialize class constants.

  public static final String CLASS_NAME = 'XOM_UpdatePauseDays';
  public static final String UPSERT_PAUSE_HISTORY_METHOD_NAME = 'upsertPauseHistory';
  public static final String MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE =
      'Please provide service account on order.';
  public static final String MULTIPLE_ORCH_ITEM_ERROR_MESSAGE =
      'Multipe Orchestration items are present';
  public static final String ORCH_ITEM_MISSING_ERROR_MESSAGE = 'Orchestration item is missing.';
  public static final String ORDER_ID_MISSING_ERROR_MESSAGE = 'Order id is blank';
  public static final String EXECUTE_BATCH_METHOD_NAME = 'executeBatch';

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
      AutoTaskUnrecoverableException autoTaskException = new AutoTaskUnrecoverableException();
      autoTaskException.setMessage(ORCH_ITEM_MISSING_ERROR_MESSAGE);
      throw autoTaskException;
    }
    try{
      vlocity_cmt__OrchestrationItem__c item = items[0];

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

      upsertPauseHistory(
        orchItems[0].vlocity_cmt__OrchestrationPlanId__r
          .vlocity_cmt__OrderId__c
      );
      if(items.size()>1) {
        LoggingUtility.insertExceptionLog(CLASS_NAME,
            EXECUTE_BATCH_METHOD_NAME, MULTIPLE_ORCH_ITEM_ERROR_MESSAGE);
      }
    }
    catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          EXECUTE_BATCH_METHOD_NAME, e.getMessage());
      throw e;
    }
  }

  /**
   * @description This method updates the previous pause records for the passed service account
   * and creates a new pause record if year of resume start date and pause start date are not
   * matching.
   * @param orderId
   * @return null
   */
  public void upsertPauseHistory(String orderId) {

    if(String.isBlank(orderId)) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          UPSERT_PAUSE_HISTORY_METHOD_NAME,
          ORDER_ID_MISSING_ERROR_MESSAGE);

      AutoTaskUnrecoverableException autoTaskException =
          new AutoTaskUnrecoverableException();
      autoTaskException.setMessage(
          ORDER_ID_MISSING_ERROR_MESSAGE);
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
    Datetime resumeStartDate = System.now();
    // Conditonal check for required fields serviceAccountId.
    if(String.isBlank(serviceAccountId)) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          UPSERT_PAUSE_HISTORY_METHOD_NAME,
          MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE);

      AutoTaskUnrecoverableException autoTaskException =
          new AutoTaskUnrecoverableException();
      autoTaskException.setMessage(
          MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE);
      throw autoTaskException;
    }

    // Retireve old pause records of the service account id.
    List<Pause_History__c> pauseDays = [
      SELECT
        Id,
        Start_Date__c,
        End_Date__c,
        Account__c,
        Pause_Order_Id__c,
        Pause_Days__c,
        Account__r.Current_Year_Pause_Days_Consumed__c,
        Account__r.Next_Year_Pause_Days_Consumed__c
      FROM
        Pause_History__c
      WHERE
        Account__c = :serviceAccountId
        and
        Completed__c = false
      ORDER BY
        End_Date__c DESC
    ];

     // Check for the 1 record in the pauseDays list.
    if(pauseDays.size() == 1) {
      // Retireve the first previous record from the list.
      Pause_History__c previousPause = pauseDays.get(0);
      Integer currentYearBalance =
          previousPause.Account__r.Current_Year_Pause_Days_Consumed__c != null
          ? Integer.valueOf(
          previousPause.Account__r.Current_Year_Pause_Days_Consumed__c) : 0;
      Account serviceAccount = previousPause.Account__r;
      // Comparing the year of resume start date and pause start date.
      if(resumeStartDate.year() != pauseDays.get(0).Start_Date__c.year()) {
        Integer previousDays = previousPause.Pause_Days__c != null
            ? Integer.valueOf(previousPause.Pause_Days__c) : 0;
        previousPause.End_Date__c = Datetime.newInstance(
            previousPause.Start_Date__c.year(), 12, 31);
        previousPause.Completed__c = true;
        previousPause.Year__c = String.valueOf(previousPause.Start_Date__c.year());
        previousPause.Resume_Order_Id__c = orderId;
        previousPause.Pause_Days__c = calculatePauseDays(
            previousPause.Start_Date__c, previousPause.End_Date__c);

        Pause_History__c nextPause = new Pause_History__c();
        nextPause.Start_Date__c = Datetime.newInstance(
            Date.valueOf(resumeStartDate).year(), 01, 01);
        nextPause.End_Date__c = resumeStartDate;
        nextPause.Completed__c = true;
        nextPause.Year__c = String.valueOf(resumeStartDate.year());
        nextPause.Account__c = serviceAccountId;
        nextPause.Resume_Order_Id__c = orderId;
        nextPause.Pause_Order_Id__c = previousPause.Pause_Order_Id__c;
        nextPause.Pause_Days__c = calculatePauseDays(
            nextPause.Start_Date__c, nextPause.End_Date__c);
        serviceAccount.Next_Year_Pause_Days_Consumed__c =
            nextPause.Pause_Days__c;
        serviceAccount.Current_Year_Pause_Days_Consumed__c =
            previousPause.Pause_Days__c +
            currentYearBalance - previousDays;
        upsert new List<SObject>{previousPause, nextPause, serviceAccount};
      }
      else {
        previousPause.End_Date__c = resumeStartDate;
        previousPause.Completed__c = true;
        previousPause.Resume_Order_Id__c = orderId;
        previousPause.Pause_Days__c = calculatePauseDays(
            previousPause.Start_Date__c, previousPause.End_Date__c);
        serviceAccount.Current_Year_Pause_Days_Consumed__c =
            currentYearBalance + previousPause.Pause_Days__c;
        update new List<SObject>{previousPause, serviceAccount};
      }
    }
  }

  /**
   * @description This method calculates total number of pause days between
   * pause start date and resume start date.
   * @param startDate
   * @param endDate
   * @return total number of days between start date and end date.
   */
  private Integer calculatePauseDays(
      Datetime startDate, Datetime endDate) {
    return Date.newInstance(startDate.year(), startDate.month(),
        startDate.day()).daysBetween(Date.newInstance(endDate.year(),
        endDate.month(), endDate.day()));
  }
}