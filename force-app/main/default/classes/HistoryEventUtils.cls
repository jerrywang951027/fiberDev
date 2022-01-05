/**
 * @group History Events records.
 * @description This class is used to display all History
 * Events via History Action of the ticket records.
 */
public with sharing class HistoryEventUtils {
  /**
   * @description This method fetches all History Events via History
   * Action of the ticket records.
   * @param input This will have ticketId.
   * @return list of History Action of the Ticket Id.
   */
  @AuraEnabled(Cacheable = true)
  public static List<History_Event__c> getHistoryEvents(String ticketId) {
    List<History_Action__c> historyAction = new List<History_Action__c>();
    List<History_Event__c> historyEvents = new List<History_Event__c>();
    set<Id> historyEventIds = new set<Id>();
    historyAction = [
        SELECT
          History_Event__c
        FROM
          History_Action__c
        WHERE
          Ticket__c = :ticketId
        AND
          History_Event__c != null];
    for(History_Action__c hAction : historyAction) {
      historyEventIds.add(hAction.History_Event__c);
    }
    historyEvents = [
        SELECT
          Ticket_Updated_Date__c,
          Id,
          Name,
          External_Ticket__c,
          Type__c,
          Event_Date__c,
          Event_End_Date__c
        FROM
          History_Event__c
        WHERE
          Id IN :historyEventIds];
    return historyEvents;
  }
}