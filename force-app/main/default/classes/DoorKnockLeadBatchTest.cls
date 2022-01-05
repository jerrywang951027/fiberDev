/**
 * @group DoorKnockLeadBatchTest
 * @description This class is used for test coverage for DoorKnockLeadBatchTest
 * class.
 */
@isTest
private class DoorKnockLeadBatchTest {

  /**
   * @description This method sets the test data.
   * @param null
   * @return null
   */
  @testSetup
  private static void setUpTestData() {
    //To create lead record
    Lead lead = TestDataFactory.getCustomerLeadData();
    lead.status = Constants.LEAD.STATUS.IN_PROGRESS;
    insert lead;
    History_Event__c historyEvent = TestDataFactory.getHistoryEventData();
    insert historyEvent;
    historyEvent.Lead__c = lead.Id;
    historyEvent.Event_Date__c = system.today();
    update historyEvent;
    History_Event__c pastHistoryEvent = TestDataFactory.getHistoryEventData();
    pastHistoryEvent.Lead__c = lead.Id;
    pastHistoryEvent.Event_Date__c = Date.today().addMonths(-5);
    insert pastHistoryEvent;
  }

  /**
  * @description   Updates the Doorknock count on Lead
  * @Param NA
  * @return null
  */
  @isTest
  private static void updateDoorKnockCountOnLead() {
    Test.startTest();
      DoorKnockLeadBatchScheduler scheduler = new DoorKnockLeadBatchScheduler();
      String cronExpression = '0 0 0 * * ?';
      scheduler.execute(null);
    Test.stopTest();
    Lead lead = [
        SELECT Id,
               Door_Knock_Count__c,
               Last_N_Month_Door_Knock_Count__c
        FROM Lead
    ];
    System.assertEquals(lead.Door_Knock_Count__c, 2);
    System.assertEquals(lead.Last_N_Month_Door_Knock_Count__c, 1);
  }
}