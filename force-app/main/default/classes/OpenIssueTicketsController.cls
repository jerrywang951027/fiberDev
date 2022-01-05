/**
 * @group Ticket
 * @description This class is the controller class for open issue tickets.
 */
global with sharing class OpenIssueTicketsController implements vlocity_cmt.VlocityOpenInterface2 {

  /**
   * @description This is the method to invoke the method getOpenIssueTickets
   * @This is the method to invoke the method getOpenIssueTicketsForLead 
   * @This is the method to invoke the method getOpenIssueTicketsForHistoryEvent.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  public Boolean invokeMethod(String methodName, Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    if (methodName.equals('getOpenIssueTickets')) {
      getOpenIssueTickets(input, outMap, options);
    }
    else if (methodName.equals('getOpenIssueTicketsForLead')) {
      getOpenIssueTicketsForLead(input, outMap, options);
    }
    else if (methodName.equals('getOpenIssueTicketsForHistoryEvent')) {
      getOpenIssueTicketsForHistoryEvent(input, outMap, options);
    }
    return true;
  }

  /**
   * @description This is the method to populate Open Issue Tickets.
   * @param inputMap The input will have list of Account Record IDs.
   * @param outMap This will output list of Open Issue Ticket.
   * @param options Any optional parameters.
   * @return null
   */
  @AuraEnabled(cacheable = true)
  public static void getOpenIssueTickets(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    List<Map<String, String>> uiOptions = new List<Map<String, String>> ();
    List<Id> accountIds = new List<Id>();
    for(Object accountId : input.values()) {
      accountIds.add((Id)accountId);
    }
    List<History_Event__c> historyEventRecord = [
        SELECT
          Id,
          Status__c,
          (SELECT
            Id,
            Ticket__c,
            Ticket__r.Name,
            Ticket__r.Status__c,
            Ticket__r.Escalated__c
          FROM
            History_Actions__r
          WHERE
            Ticket__r.Status__c = :Constants.TICKET.STATUS.OPEN
          AND
            Ticket__r.Escalated__c = false)
        FROM
          History_Event__c
        WHERE
          Account__c IN :accountIds
          AND Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
    ];
    for (History_Event__c eventRecord : historyEventRecord) {
      for (History_Action__c actionRecord : eventRecord.History_Actions__r) {
        Map <String, String> tempMap = new Map <String, String> ();
        tempMap.put('value', actionRecord.Ticket__c);
        tempMap.put('label', actionRecord.Ticket__r.Name);
        uiOptions.add(tempMap);
      }
    }
    outMap.put('options', uiOptions);
  }

  /**
   * @description This is the method to populate Open Issue Tickets for Lead.
   * @param inputMap The input will have list of Lead Record IDs.
   * @param outMap This will output list of Open Issue Ticket.
   * @param options Any optional parameters.
   * @return null
   */
  @AuraEnabled(cacheable = true)
  public static void getOpenIssueTicketsForLead(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    List<Map<String, String>> uiOptions = new List<Map<String, String>> ();
    Id leadId = Id.valueOf((Id)input.get('leadId'));
    List<History_Event__c> historyEventRecord = [
        SELECT
          Id,
          Status__c,
          (SELECT
            Id,
            Ticket__c,
            Ticket__r.Name,
            Ticket__r.Status__c,
            Ticket__r.Escalated__c
          FROM
            History_Actions__r
          WHERE
            Ticket__r.Status__c = :Constants.TICKET.STATUS.OPEN
          AND
            Ticket__r.Escalated__c = false)
        FROM
          History_Event__c
        WHERE
          Lead__c = :leadId
          AND Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
    ];
    for (History_Event__c eventRecord : historyEventRecord) {
      for (History_Action__c actionRecord : eventRecord.History_Actions__r) {
        Map <String, String> tempMap = new Map <String, String> ();
        tempMap.put('value', actionRecord.Ticket__c);
        tempMap.put('label', actionRecord.Ticket__r.Name);
        uiOptions.add(tempMap);
      }
    }
    outMap.put('options', uiOptions);
  }

  /**
   * @description This is the method to populate Open Issue Tickets for History Event.
   * @param inputMap The input will have list of History Event Record IDs.
   * @param outMap This will output list of Open Issue Ticket.
   * @param options Any optional parameters.
   * @return null
   */
  @AuraEnabled(cacheable = true)
  public static void getOpenIssueTicketsForHistoryEvent(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    List<Map<String, String>> uiOptions = new List<Map<String, String>> ();
    Id historyEventId = Id.valueOf((Id)input.get('historyId'));
    List<History_Event__c> historyEventRecord = [
        SELECT
          Id,
          Status__c,
          (SELECT
            Id,
            Ticket__c,
            Ticket__r.Name,
            Ticket__r.Status__c,
            Ticket__r.Escalated__c
          FROM
            History_Actions__r
          WHERE
            Ticket__r.Status__c = :Constants.TICKET.STATUS.OPEN
          AND
            Ticket__r.Escalated__c = false)
        FROM
          History_Event__c
        WHERE
          id = :historyEventId
          AND Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
    ];
    for (History_Event__c eventRecord : historyEventRecord) {
      for (History_Action__c actionRecord : eventRecord.History_Actions__r) {
        Map <String, String> tempMap = new Map <String, String> ();
        tempMap.put('value', actionRecord.Ticket__c);
        tempMap.put('label', actionRecord.Ticket__r.Name);
        uiOptions.add(tempMap);
      }
    }
    outMap.put('options', uiOptions);
  }
}