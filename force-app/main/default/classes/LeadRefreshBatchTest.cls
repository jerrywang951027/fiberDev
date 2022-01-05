/**
 * @group LeadRefreshBatch
 * @description This class is used for test coverage for LeadRefreshBatch class.
 */
@isTest
private class LeadRefreshBatchTest {

  /**
   * @description This method sets the test data.
   * @param null
   * @return null
   */
  @testSetup
  private static void testSetup() {

    TestDataFactory.getLoggingSetting();
    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    Lead testLeadFirst = TestDataFactory.getCustomerLeadData();
    Lead testLeadSecond = TestDataFactory.getCustomerLeadData();
    Lead testLeadThird = TestDataFactory.getCustomerLeadData();
    List<Lead> leadList = new List<Lead>{ testLeadFirst, testLeadSecond, testLeadThird};
    insert leadList;
    History_Event__c testHistoryFirst = testDataFactory.getHistoryEventData();
    History_Event__c testHistorySecond = testDataFactory.getHistoryEventData();
    History_Event__c testHistoryThird = testDataFactory.getHistoryEventData();
    List<History_Event__c> historyList =
        new List<History_Event__c>{ testHistoryFirst, testHistorySecond , testHistoryThird};
    historyList[0].Lead__c = leadList[0].Id;
    historyList[0].Event_Date__c = System.Today().addMonths(-8);
    historyList[1].Lead__c = leadList[1].Id;
    historyList[1].Event_Date__c = System.Today().addMonths(-8);
    historyList[2].Lead__c = leadList[2].Id;
    historyList[2].Event_Date__c = System.Today().addMonths(-8);
    insert historyList;
  }

  /**
   * @description It will run when status is Disqualified and
   * sub status Do not contact, Not interested or Vacant for the lead.
   * @param null
   * @return null
   */
  @isTest
  private static void disqualifiedLeadStatusShouldChangeToNew() {

    Logging_Level__c setting = new Logging_Level__c();
    setting.Name = Constants.LOGGING_LEVEL.LEVEL.LOG_SETTING;
    setting.Level__c = Constants.LOGGING_LEVEL.LEVEL.LOG_SETTING;
    insert setting;
    List<Lead> leadList = [
        SELECT Id, Status, RecordTypeId
        FROM Lead
        LIMIT 3
    ];
    leadList[0].Status = Constants.LEAD.STATUS.DISQUALIFIED;
    leadList[0].Sub_Status__c = Constants.LEAD.SUB_STATUS.DO_NOT_CONTACT;
    leadList[1].Status = Constants.LEAD.STATUS.DISQUALIFIED;
    leadList[1].Sub_Status__c = Constants.LEAD.SUB_STATUS.NOT_INTERESTED;
    leadList[2].Status = Constants.LEAD.STATUS.DISQUALIFIED;
    leadList[2].Sub_Status__c = Constants.LEAD.SUB_STATUS.VACANT;
    update leadList;
    Test.StartTest();
      LeadRefreshBatchScheduler scheduler = new LeadRefreshBatchScheduler();
      String cronExpression = '0 0 0 * * ?';
      scheduler.execute(null);
    Test.StopTest();
    List<Lead> newLead = [Select Id,Status FROM Lead LIMIT 3];
    System.assert(leadList.size() >= 0);
    System.assertEquals(Constants.LEAD.STATUS.STATUS_NEW, newLead[0].Status,
        'Leads which are disqualified for certain period those lead will be recycled to New');
    System.assertEquals(Constants.LEAD.STATUS.STATUS_NEW, newLead[1].Status,
        'Leads which are disqualified for certain period those lead will be recycled to New');
    System.assertEquals(Constants.LEAD.STATUS.STATUS_NEW, newLead[2].Status,
        'Leads which are disqualified for certain period those lead will be recycled to New');
  }
}