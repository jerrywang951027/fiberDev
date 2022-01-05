/**
 * @group Ticket
 * @description This class manipulates Issue Tickets.
 */
global with sharing class IssueTicket implements vlocity_cmt.VlocityOpenInterface2 {

  /**
   * @description This method invokes PopulateResolutionCodes() if the condition is met.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  public Boolean invokeMethod(String methodName, Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    if (methodName.equals('populateResolutionCodes')) {
      populateResolutionCodes(input, outMap, options);
    }
    return true;
  }

  /**
   * @description This method fetches ticket record and populate the resolution code.
   * @param inputMap This will have ticket list ids.
   * @param outMap This will return resolution code of ticket records.
   * @param options Any optional parameters
   * @return null
   */
  @TestVisible
  private static Map<String,Object> mockedTicketResponse = new Map<String,Object>();
  @AuraEnabled(cacheable = true)
  public static void populateResolutionCodes(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    List<Map<String, String>> uiOptionsMap = new List<Map<String, String>> ();
    List<String> idList = new List<String>();
    for(Object record : input.values()) {
      idList.add(record.toString());
    }
    String IP_NAME = 'TCK_ExtractBuganizerDetails';
    Map <String, Object> ipInput = new Map <String, Object> ();
    Map <String, Object> ipOutput = new Map <String, Object> ();
    Map <String, Object> ipOptions = new Map <String, Object> ();
    Map <String, Object> message;
    Ticket__c ticketRecord = [
        SELECT
          Name,
          Id
        FROM
          Ticket__c
        WHERE
          Id IN :idList
    ];
    ipInput.put('bugafiberTicketId', ticketRecord.Name);
      ipOutput =  (Test.isRunningTest()) ? mockedTicketResponse : (Map<String, Object>)
          vlocity_cmt.IntegrationProcedureService.runIntegrationService(IP_NAME,
          ipInput, ipOptions);
      message = ipOutput;
    List<Issue_Ticket__mdt> issueTicketmdtList = [
        SELECT
          Id,
          Issue_Type__c,
          Issue_Sub_Type__c,
          Issue_Symptom__c,
          Resolution_Code__c
        FROM
          Issue_Ticket__mdt
        WHERE
          Issue_Type__c =
             :String.valueOf(((Map<String,Object>)ipOutput.get('ticketDetails')).get('type'))
          AND Issue_Sub_Type__c =
              :String.valueOf(((Map<String,Object>)ipOutput.get('ticketDetails')).get('subType'))
          AND Issue_Symptom__c =
              :String.valueOf(((Map<String,Object>)ipOutput.get('ticketDetails')).get('symptom'))
          AND Resolution_Code__c != NULL];
    if (!issueTicketmdtList.isEmpty()) {
      for (Issue_Ticket__mdt ticketRecords : issueTicketmdtList) {
        Map <String, String> tempMap = new Map <String, String> ();
        tempMap.put('value', ticketRecords.Resolution_Code__c);
        tempMap.put('label', ticketRecords.Resolution_Code__c);
        uiOptionsMap.add(tempMap);
      }
    } else {
      Map <String, String> tempMap = new Map <String, String> ();
      tempMap.put('value', 'Other - Resolution');
      tempMap.put('label', 'Other - Resolution');
      uiOptionsMap.add(tempMap);
    }
    outMap.put('options', uiOptionsMap);
  }
}