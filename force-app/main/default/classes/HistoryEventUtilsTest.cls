/**
 * @group History Action
 * @description To cover HistoryEventUtils, improve code coverage and test functionality.
 */
@isTest
private class HistoryEventUtilsTest {

  /**
   * @description Method sets up the test data used in this class
   * @param null
   * return null
   */
  @testSetup
  private static void setupTestData() {

    Ticket__c ticketObject = TestDataFactory.getTicketData();
    insert ticketObject;
    // Create Account Record
    Account objectAccount = TestDataFactory.getAccountData();
    insert objectAccount;
    // Create Order Record
    Order objectOrder = TestDataFactory.getOrderData(objectAccount.Id);
    insert objectOrder;
    // Create History Event Record
    History_Event__c history = TestDataFactory.getHistoryEventData();
    history.Account__c = objectAccount.Id;
    history.Ticket_Updated_Date__c = System.today()+1;
    history.External_Ticket__c = '12323';
    history.Type__c = Constants.HISTORY_EVENT.TYPE.CHAT_TYPE;
    history.Event_Date__c = System.today();
    history.Event_End_Date__c = System.today()+2;
    insert history;
    // Create History Action Record
    History_Action__c historyAction = TestDataFactory.getHistoryActionData(
        history.Id, objectOrder.Id);
    historyAction.Ticket__c = ticketObject.Id;
    insert historyAction;
  }

  /**
   * @description Checks if History Event and History Action with notes is captured.
   */
  @isTest
   static void returnHistoryEventsRecordsOfTickets() {
    Ticket__c ticketRecord = [SELECT Id FROM Ticket__c LIMIT 1] ;
    List<History_Event__c>  historyEvents = new List<History_Event__c>();
    Test.startTest();
      historyEvents = HistoryEventUtils.getHistoryEvents(ticketRecord.Id);
    Test.stopTest();
    System.assertEquals(1, historyEvents.size(),
        'incorrect number of history actions retrieved');
  }
}