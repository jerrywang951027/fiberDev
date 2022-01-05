/**
 * @group CreateNotificationBatchTest
 * @description Used to test coverage for CreateNotificationBatch class.
 */
@isTest
public class CreateNotificationBatchTest {

  /**
   * @description This method creates the test data.
   */
  @testSetup
  private static void testSetup() {
    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    Account account = TestDataFactory.getAccountData();
    insert account;
    History_Event__c testHistoryFirst = testDataFactory.getHistoryEventData();
    History_Event__c testHistorySecond = testDataFactory.getHistoryEventData();
    List<History_Event__c> historyEventList =
        new List<History_Event__c> {testHistoryFirst, testHistorySecond};
    historyEventList[0].Account__c = account.Id;
    historyEventList[0].Status__c = constants.HISTORY_EVENT.STATUS.OPEN;
    historyEventList[0].Type__c = Constants.HISTORY_EVENT.TYPE.SMS;
    historyEventList[1].Account__c = account.Id;
    historyEventList[1].Status__c = constants.HISTORY_EVENT.STATUS.OPEN;
    historyEventList[1].Type__c = Constants.HISTORY_EVENT.TYPE.CHAT_TYPE;
    insert historyEventList;
  }

 /**
   * @description It will run when more than one history event
   * is created in last 3 days for an account
   */
  @isTest
  private static void historyEventShouldCreateNotification() {
    Test.StartTest();
      CreateNotificationBatchScheduler scheduler = new CreateNotificationBatchScheduler();
      String cronExpression = '0 0 0 * * ?';
      scheduler.execute(null);
    Test.StopTest();
    List<Notification__c> notificationList = [
        SELECT
        Id
        FROM
        Notification__c];
    System.assertEquals(1, notificationList.size());
  }
}