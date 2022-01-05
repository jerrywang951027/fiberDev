/*
 *@group Ticket
 *@description This class is used for test coverage for OpenIssueTicketsController class.
 */
@isTest
public class OpenIssueTicketsControllerTest {
  /**
   *  @description Set up data for test method
   *  @param NA
   *  @return null
   */
  @testSetUp
  private static void testSetUp() {

    Account testAccount = TestDataFactory.getAccountData();
    insert testAccount;
    Lead testLead = TestDataFactory.getLeadData();
    insert testLead;
    History_Event__c historyEvent = TestDataFactory.getHistoryEventData();
    historyEvent.Account__c = testAccount.Id;
    historyEvent.Lead__c =testLead.Id;
    historyEvent.Contact_Type__c = 'Sales';
    historyEvent.status__c = Constants.HISTORY_EVENT.STATUS.OPEN;
    insert historyEvent;
    Ticket__c Ticket = TestDataFactory.getTicketData();
    insert Ticket;
    History_Action__c  historyAction = TestDataFactory.getHistoryActionData(historyEvent.id, null);
    historyAction.Ticket__c = Ticket.id;
    insert historyAction;
  }

  /**
   *@description It will run on open ticket creation
   *@param NA
   *@return null
   */
  @isTest
  private static void getOpenIssueTicketShouldFetchAllOpenIssueTicketsForAccount() {

    // Initializing Maps for Input
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName  = 'getOpenIssueTickets';
    Id accountId = ([
        SELECT
          Id
        FROM
          Account
        LIMIT 1]).Id;
    inputMap.put('test1', accountId);
    Test.startTest();
      OpenIssueTicketsController openCtrl = new OpenIssueTicketsController();
      openCtrl.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    List<History_Action__c> actionRecord = [
        SELECT
          Id,
          Ticket__r.Id,
          Ticket__r.Status__c,
          Ticket__r.Name
        FROM
          History_Action__c
        WHERE
          History_Event__r.Account__c = :accountId];
    System.assertEquals(actionRecord[0].Ticket__r.Name,String.valueOf(
       ((Map<String,Object>)((List<Object>)outMap.get('options'))[0]
       ).get('label')));
    System.assertEquals(Constants.TICKET.STATUS.OPEN, actionRecord[0].Ticket__r.Status__c,
        'Ticket status updated to Open');
  }
    /**
   *@description It will run on open ticket creation
   *@param NA
   *@return null
   */
  @isTest
  private static void getOpenIssueTicketsForLeadShouldFetchAllOpenIssueTicketsForLead() {

    // Initializing Maps for Input
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName  = 'getOpenIssueTicketsForLead';
    Id leadId = ([
        SELECT
          Id
        FROM
          Lead
        LIMIT 1]).Id;
    inputMap.put('leadId', leadId);
    Test.startTest();
      OpenIssueTicketsController openCtrl = new OpenIssueTicketsController();
      openCtrl.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    List<History_Action__c> actionRecord = [
        SELECT
          Id,
          Ticket__r.Id,
          Ticket__r.Status__c,
          Ticket__r.Name
        FROM
          History_Action__c
        WHERE
          History_Event__r.Lead__c = :leadId];
    System.assertEquals(actionRecord[0].Ticket__r.Name,String.valueOf(
       ((Map<String,Object>)((List<Object>)outMap.get('options'))[0]
       ).get('label')));
    System.assertEquals(Constants.TICKET.STATUS.OPEN, actionRecord[0].Ticket__r.Status__c,
        'Ticket status updated to Open');
  }
  /**
   *@description It will run on open ticket creation
   *@param NA
   *@return null
   */
  @isTest
  private static void getOpenIssueTicketsForHistoryEventShouldFetchAllOpenIssueTicketsForHistoryEvent() {

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName  = 'getOpenIssueTicketsForHistoryEvent';
    Id historyEventId = ([
        SELECT
          Id
        FROM
          History_Event__c
        LIMIT 1]).Id;
    inputMap.put('historyId', historyEventId);
    Test.startTest();
      OpenIssueTicketsController openCtrl = new OpenIssueTicketsController();
      openCtrl.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    List<History_Action__c> actionRecord = [
        SELECT
          Id,
          Ticket__r.Id,
          Ticket__r.Status__c,
          Ticket__r.Name
        FROM
          History_Action__c
        WHERE
          History_Event__r.Id=:historyEventId];
    System.assertEquals(actionRecord[0].Ticket__r.Name,String.valueOf(
       ((Map<String,Object>)((List<Object>)outMap.get('options'))[0]
       ).get('label')));
    System.assertEquals(Constants.TICKET.STATUS.OPEN, actionRecord[0].Ticket__r.Status__c,
        'Ticket status updated to Open');
  }
}