/**
 *@group Ticket
 *@description This class is used for test coverage for ContactTicketController class
 */
@isTest
public class X2ControllerTest {

  @testSetup
  private static void setupTestData() {
    vlocity_cmt__Premises__c premises = TestDataFactory.getPremisesData('Serviceable');
    premises.Global_Address_Id__c = 'ed10f285-b3e2-4861-9b51-9e70b95a5e87';
    insert premises;

    Account acc = TestDataFactory.getAccountData();
    acc.Account_Id__c = 'GF-3000-1000-1000-14';
    acc.vlocity_cmt__PremisesId__c = premises.Id;
    insert acc;

    Lead led = TestDataFactory.getLeadData();
    led.Account__c = acc.Id;
    led.vlocity_cmt__PremisesId__c = premises.Id;
    insert led;

    Ticket__c ticketData = TestDataFactory.getTicketData();
    ticketData.Name = '204975966';
    ticketData.Account__c = acc.Id;
    insert ticketData;

    Ticket__c ticketData1 = TestDataFactory.getTicketData();
    ticketData1.Name = '204975969';
    insert ticketData1;

    History_Event__c historyEventRecord = TestDataFactory.getHistoryEventData();
    historyEventRecord.Account__c = acc.Id;
    historyEventRecord.External_Ticket__c = '205524227';
    historyEventRecord.Lead__c = led.Id;
    insert historyEventRecord;


    History_Event__c historyEventRecord1 = TestDataFactory.getHistoryEventData();
    historyEventRecord1.Lead__c = led.Id;
    historyEventRecord1.External_Ticket__c = '205524221';
    insert historyEventRecord1;

    list <History_Event__c> historyEvent = new list <History_Event__c> ();
    historyEvent.add(historyEventRecord);
    historyEvent.add(historyEventRecord1);
    History_Action__c historyAction = new History_Action__c();
    historyAction.Ticket__c = ticketData.Id;
    historyAction.Account__c = acc.Id;
    historyAction.Type__c = Constants.HISTORY_ACTION.TYPE.ISSUE;
    insert historyAction;

  }
  /**
   * @description This is the method to create history
   * event when agent navigates from CSA to SFDC from the given url.
   */
  @isTest
  private static void navigateToAccount() {
    string methodName = 'getTicketObjectLink';
    List<Ticket__c> ticketData = [
        SELECT
          ID,
          Name
        FROM
          Ticket__c
    ];
    Account AccountData =  [
        SELECT
        Id,
        Account_Id__c
        FROM
        Account
    ];
    vlocity_cmt__Premises__c premisesData = [
       SELECT
        Id,
        Global_Address_Id__c
        FROM
        vlocity_cmt__Premises__c
    ];
    Test.startTest();
      X2Controller.extractTicketDetails obj =
          X2Controller.getMostRelatedObjLink(ticketData[0].name, AccountData.Account_Id__c,premisesData.Global_Address_Id__c);
    Test.stopTest();
  }

  @isTest
  private static void navigateToHistoryEventRecordBasedOnHistoryEventId1() {
    string methodName = 'getMostRelatedObjLink';
    History_Event__c historyEventRecord = [
        SELECT
          External_Ticket__c
        FROM
          History_Event__c
        WHERE
          External_Ticket__c = :Constants.HISTORY_EVENT.ExternalTicketId
    ];
    vlocity_cmt__Premises__c premisesData = [
       SELECT
        Id,
        Global_Address_Id__c
        FROM
        vlocity_cmt__Premises__c
    ];
    Test.startTest();
      X2Controller.invokeIntegrationProcedure('207344565');
      X2Controller.extractTicketDetails obj =
          X2Controller.getMostRelatedObjLink('207344565','','');
    Test.stopTest();
    //System.assertEquals(true, obj.objLink.contains(historyEventRecord.Id),
     // methodName + ' should return history event record by criteria');
  }
    
 
    
    
  @isTest
  private static void createInboundContactByPhoneShouldReturnHistoryEvent() {
    Ticket__c ticketData = TestDataFactory.getTicketData();
    ticketData.Name = Constants.HISTORY_EVENT.ExternalTicketId;
    insert ticketData;

    Test.startTest();
      
     X2Controller.extractTicketDetails obj =
          X2Controller.getMostRelatedObjLink(ticketData.Name,'','');
      X2Controller.invokeIntegrationProcedure(ticketData.Name);
    Test.stopTest();
  }
   @isTest
  private static void createInboundContactByPhoneShouldReturnHistoryEvent1() {
    History_Event__c ticketData = TestDataFactory.getHistoryEventData();
    ticketData.External_Ticket__c = Constants.HISTORY_EVENT.ExternalTicketId;
    insert ticketData;

    Test.startTest();
      
     X2Controller.extractTicketDetails obj =
          X2Controller.getMostRelatedObjLink('ticketData.External_Ticket__c','68787889','0990909');
    Test.stopTest();
  }
    
  @isTest
  private static void navigateToAccountBasedOnTicketId() {
    string methodName = 'getMostRelatedObjLink';
    StaticResource staticResourceValue = [
      SELECT
        Id,
        Body
      FROM
        StaticResource
         WHERE Name = 'TicketTypeResponse'
      LIMIT 1
    ];
    String inputStr = staticResourceValue.Body.toString();
    Map <String, Object> mockOperationTicket = new Map <String, Object> ();
    mockOperationTicket = ( Map <String, Object> ) JSON.deserializeUntyped(inputStr);
    X2Controller.mockedTicketResponse = mockOperationTicket;
    
    Account parentAccountData  = TestDataFactory.getAccountData();
    insert parentAccountData;

    Account accountData  = TestDataFactory.getAccountData();
    accountData.Account_Id__c = parentAccountData.Id;
    insert accountData;
      
    Ticket__c ticketData = TestDataFactory.getTicketData();
    ticketData.Name = Constants.HISTORY_EVENT.ExternalTicketId;
    ticketData.Account__c = accountData.Id;
    insert ticketData;
  
    Ticket__c ticketData1 = TestDataFactory.getTicketData();
    ticketData1.Name = ticketData.Id;
    ticketData1.Account__c = accountData.Id;
    insert ticketData1;

    Test.startTest();
     X2Controller.extractTicketDetails obj =
         X2Controller.getMostRelatedObjLink(ticketData.Id, accountData.Id,'');
    Test.stopTest();
  }
}