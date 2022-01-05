/**
 *@group Ticket
 *@description This class is used for test coverage for IssueTickets class
 */
@isTest
public class IssueTicketTest {

  /**
   * @description This is the method to check the positive scenario for resolution code
   */
  @isTest
  private static void invokingPopulateResolutionCodesShouldReturnResolutionCodeTest() {

    StaticResource staticResourceValue = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'IssueTicketIPResponse'
        LIMIT 1];
    String inputStr = staticResourceValue.Body.toString();
    Map<String,Object> mockOperationTicket = new Map<String,Object>();
    mockOperationTicket = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
    IssueTicket.mockedTicketResponse = mockOperationTicket;
    Ticket__c ticketRecord = TestDataFactory.getTicketData();
    ticketRecord.Name = '124567890';
    ticketRecord.Type__c = 'TestType';
    ticketRecord.Sub_Type__c = 'axz';
    ticketRecord.Symptom__c = 'TestCode';
    insert ticketRecord;
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    String METHOD_NAME = 'populateResolutionCodes';
    inputMap.put('bugafiberTicketId', ticketRecord.Name);
    inputMap.put('Id',ticketRecord.Id);
    system.debug('inputMap------->'+inputMap);
    Map<String, String> allOPtionsMap = new Map<String, String>();
    Test.StartTest();
    IssueTicket issue = new IssueTicket();
      issue.invokeMethod('populateResolutionCodes',inputMap,outMap,optionsMap);
      List<Map<String, Object>> resolutioncodeList =
          (List<Map<String, Object>>)outMap.get('options');
    Test.StopTest();
    System.assertEquals(false,
        allOPtionsMap.containsKey(ticketRecord.Resolution__c),
        METHOD_NAME+' should return resolution codes by criteria');
  }
  /**
   * @description This is the method to check the negative scenario for resolution code
   */
  @isTest
  private static void invokingPopulateResolutionCodesShouldNotReturnResolutionCodeTest() {

    StaticResource staticResourceValue = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'IssueTicketIPNegativeResponse'
        LIMIT 1];
    String inputStr = staticResourceValue.Body.toString();
    Map<String,Object> mockOperationTicket = new Map<String,Object>();
    mockOperationTicket = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
    IssueTicket.mockedTicketResponse = mockOperationTicket;
    Ticket__c ticketRecord = TestDataFactory.getTicketData();
    ticketRecord.Name = '124567890';
    ticketRecord.Type__c = 'TestType';
    ticketRecord.Sub_Type__c = 'axz';
    ticketRecord.Symptom__c = 'TestCode';
    insert ticketRecord;
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    String METHOD_NAME = 'populateResolutionCodes';
    inputMap.put('bugafiberTicketId', ticketRecord.Name);
    inputMap.put('Id',ticketRecord.Id);
    system.debug('inputMap------->'+inputMap);
    Map<String, String> allOPtionsMap = new Map<String, String>();
    Test.StartTest();
    IssueTicket issue = new IssueTicket();
      issue.invokeMethod('populateResolutionCodes',inputMap,outMap,optionsMap);
      List<Map<String, Object>> resolutioncodeList =
          (List<Map<String, Object>>)outMap.get('options');
    Test.StopTest();
    System.assertEquals(false,
        allOPtionsMap.containsKey(ticketRecord.Resolution__c),
        METHOD_NAME+' should not return resolution codes by criteria');
  }
}