/**
*@group Ticket
*@description This class is used for test coverage for ContactTicketController class
*/
  @isTest
  public class ContactTicketControllerTest {

  @testSetup
  private static void setupTestData() {
    vlocity_cmt__Premises__c premises = TestDataFactory.getPremisesData('Planned');
    premises.Global_Address_Id__c = 'ed10f285-b3e2-4861-9b51-9e70b95a5e91';
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
  private static void navigateToAccountBasedOnTicketAndAccountId() {
    string methodName = 'getMostRelatedObjLink';

    Account accountData = TestDataFactory.getAccountData();
    insert accountData;

    Ticket__c ticketData = TestDataFactory.getTicketData();
    ticketData.Name = Constants.HISTORY_EVENT.ExternalTicketId;
    ticketData.Account__c = accountData.Id;
    insert ticketData;

    Test.startTest();
    ContactTicketController.extractTicketDetails obj =
      ContactTicketController.getMostRelatedObjLink(
        ticketData.name, AccountData.Account_Id__c, '');
    Test.stopTest();
    System.assertEquals(true, obj.objLink.contains(AccountData.Id),
      methodName + ' should return account detail record by criteria');
  }

  @isTest
  private static void navigateToAccountBasedOnHistoryEventAndAccountId() {
    String methodName = 'getMostRelatedObjLink';
    StaticResource staticResourceValue = [
      SELECT
        Id,
        Body      
      FROM
        StaticResource
      WHERE
        Name =: 'TicketTypeResponse'
      LIMIT 1
    ];

    String inputStr = staticResourceValue.Body.toString();
    Map <String, Object> mockOperationTicket = new Map <String, Object> ();
    mockOperationTicket = (Map <String, Object>) JSON.deserializeUntyped(inputStr);
    ContactTicketController.mockedTicketResponse = mockOperationTicket;

    Account parentAccountData = TestDataFactory.getAccountData();
    insert parentAccountData;

    Account accountData = TestDataFactory.getAccountData();
    accountData.Account_Id__c = parentAccountData.Id;
    insert accountData;

    Test.startTest();
      ContactTicketController.extractTicketDetails obj =
          ContactTicketController.getMostRelatedObjLink(
            '', accountData.Account_Id__c, '');
    Test.stopTest();
    System.assertEquals(true, obj.objLink.contains(accountData.Id),
      methodName + ' should return account detail record by criteria');
   }

  @isTest
  private static void navigateToAccountBasedOnHistoryEventAndAccountIdIssue() {
    String methodName = 'getMostRelatedObjLink';
    StaticResource staticResourceValue = [
      SELECT
        Id,
        Body
      FROM
        StaticResource
      WHERE
        Name =: 'TicketTypeResonseIssue'
      LIMIT 1
    ];

    String inputStr = staticResourceValue.Body.toString();
    Map <String, Object> mockOperationTicket = new Map <String, Object> ();
    mockOperationTicket = (Map <String, Object>) JSON.deserializeUntyped(inputStr);
    ContactTicketController.mockedTicketResponse = mockOperationTicket;

    Account parentAccountData = TestDataFactory.getAccountData();
    insert parentAccountData;

    Account accountData = TestDataFactory.getAccountData();
    accountData.Account_Id__c = parentAccountData.Id;
    insert accountData;

    Test.startTest();
      ContactTicketController.extractTicketDetails obj =
          ContactTicketController.getMostRelatedObjLink(
            '', accountData.Account_Id__c, '');
    Test.stopTest();
    System.assertEquals(false, obj.objLink.contains(accountData.Id),
      methodName + ' should return account detail record by criteria');
  }

  @isTest
  private static void navigateToAccountBasedOnHistoryEventAndNoAccountId() {
    String methodName = 'getMostRelatedObjLink';
    StaticResource staticResourceValue = [
      SELECT
        Id,
        Body
      FROM
        StaticResource
      WHERE
        Name =: 'TicketTypeResponse'
      LIMIT 1
    ];

    String inputStr = staticResourceValue.Body.toString();
    Map <String, Object> mockOperationTicket = new Map <String, Object> ();
    mockOperationTicket = (Map <String, Object>) JSON.deserializeUntyped(inputStr);
    ContactTicketController.mockedTicketResponse = mockOperationTicket;

    vlocity_cmt__Premises__c premises = TestDataFactory.getPremisesData('Connected');
    premises.Global_Address_Id__c = 'ed10f285-b3e2-4861-9b51-9e70b95a5e87';
    insert premises;

    Account parentAccountData = TestDataFactory.getAccountData();
    insert parentAccountData;

    Account accountData = TestDataFactory.getAccountData();
    accountData.Account_Id__c = Null;
    insert accountData;

    Test.startTest();
      ContactTicketController.extractTicketDetails obj =
          ContactTicketController.getMostRelatedObjLink(
            '', accountData.Account_Id__c, '');
    Test.stopTest();
    System.assertEquals(false, obj.objLink.contains(accountData.Id),
      methodName + ' should return account detail record by criteria');
  }

  @isTest
  private static void navigateHistoryEventBasedOnHistoryEventAndAccountId() {
    string methodName = 'getMostRelatedObjLink';
    History_Event__c ticketData = TestDataFactory.getHistoryEventData();
    ticketData.External_Ticket__c = '65403246';
    insert ticketData;

    vlocity_cmt__Premises__c premises = TestDataFactory.getPremisesData('Connected');
    premises.Global_Address_Id__c = 'ed10f285-b3e2-4861-9b51-9e70b95a5e87';
    insert premises;

    Account parentAccountData = TestDataFactory.getAccountData();
    insert parentAccountData;

    Account accountData = TestDataFactory.getAccountData();
    accountData.Account_Id__c = parentAccountData.Id;
    insert accountData;

    Test.startTest();
      ContactTicketController.extractTicketDetails obj =
          ContactTicketController.getMostRelatedObjLink(
            ticketData.External_Ticket__c,
            accountData.Account_Id__c,
            premises.Global_Address_Id__c);
    Test.stopTest();
    System.assertEquals(true, obj.objLink.contains(ticketData.Id),
      methodName + ' should return history event detail record by criteria');
  }

  @isTest
  private static void navigateTicketBasedOnTicketAndAccountId() {
    string methodName = 'getMostRelatedObjLink';

    Ticket__c ticketData = TestDataFactory.getTicketData();
    ticketData.Name = Constants.HISTORY_EVENT.ExternalTicketId;
    insert ticketData;

    Test.startTest();
      ContactTicketController.extractTicketDetails obj =
          ContactTicketController.getMostRelatedObjLink(ticketData.Name, '', '');
            ContactTicketController.invokeIntegrationProcedure(ticketData.Name);
    Test.stopTest();
    System.assertEquals(true, obj.objLink.contains(ticketData.Id),
      methodName + ' should return ticket detail record by criteria');
  }

  @isTest
  private static void navigateCustomerSearchBasedOnNegativeInput() {
    string methodName = 'getMostRelatedObjLink';

    Test.startTest();
      ContactTicketController.extractTicketDetails obj =
          ContactTicketController.getMostRelatedObjLink(
            'ticketData.External_Ticket__c', '', '');
    Test.stopTest();
    System.assertEquals(true, obj.objLink.contains('CustomerSearch'),
      methodName + ' should return ticket detail record by criteria');
  }
}