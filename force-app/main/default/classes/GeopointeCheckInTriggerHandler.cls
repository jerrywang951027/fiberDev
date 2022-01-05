/**
 * @group Geopointe
 * @description Class creates History Event and History Action when Geopointe
 * No-Answer flow is triggered.
 */
public class GeopointeCheckInTriggerHandler {

  public static final String CLASS_NAME = 'GeopointeCheckInTriggerHandler';

  /**
   * @description AfterInsertTriggerHandler that takes care of after insert
   * functionality.
   * @Param newMap New Map values after trigger takes place.
   * @return null
   */
  public static void afterInsertHandler(Map<Id, Geopointe__Check_In__c> newMap) {

    createCustomerInteraction(newMap);
  }

  /**
   * @description Creates History Action and History Event for the Lead Record
   * which is checked-in.
   * @Param newCheckInMap new map from trigger
   * @return null
   */
  public static void createCustomerInteraction( Map<Id, Geopointe__Check_In__c> newCheckInMap) {

    String METHOD_NAME = 'createCustomerInteraction';
    List<History_Event__c> historyEventList = new List<History_Event__c>();
    List<History_Action__c> historyActionList = new List<History_Action__c>();
    Map<Id, String> geopointeNotesMap = new Map<Id, String>();
    List<Id> leadIds = new List<Id>();
    Savepoint statusSavePoint = Database.setSavepoint();
    try {
      for (Geopointe__Check_In__c newCheckIn : newCheckInMap.values()) {
        History_Event__c historyEvent = createHistoryEvent(
            Constants.HISTORY_EVENT.TYPE.DOOR_TO_DOOR,
            Constants.HISTORY_EVENT.DIRECTION.OUTBOUND, 'Lead__c',
            newCheckIn.geopointe__What_ID__c, false);
        geopointeNotesMap.put(newCheckIn.geopointe__What_ID__c, newCheckIn.geopointe__Why_Text__c);
        leadIds.add(newCheckIn.geopointe__What_ID__c);
        historyEventList.add(historyEvent);
      }
      insert historyEventList;
      for (History_Event__c historyEventRecord : historyEventList) {
        History_Action__c historyAction = createHistoryAction(
            Constants.HISTORY_ACTION.TYPE.NO_ANSWER, historyEventRecord.Id,
            geopointeNotesMap.get(historyEventRecord.Lead__c));
        historyActionList.add(historyAction);
      }
      insert historyActionList;
      if(!historyEventList.isEmpty()) {
        stampLatestHistoryEventCreatedDateOnLead(leadIds);
      }
    } catch (Exception exp) {
      Database.rollback(statusSavePoint);
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /**
   * @description To create a History Event record when the Lead is updated
   * through Geopointe.
   * @param eventType Holds Event Type of History Event.
   * @param direction Holds Direction of History Event.
   * @param sObjectField Holds sObject field to assign lookup with History Event.
   * @param sObjectID Holds sObject Id.
   * @param doorOpen Checks the Door open.
   * @return historyEvent Holds History Event record.
   */
  public static History_Event__c createHistoryEvent(String eventType, String direction,
      String sObjectField, String sObjectID, boolean doorOpen) {

    History_Event__c historyEvent = new History_Event__c();
    historyEvent.Type__c = eventType;
    historyEvent.Direction__c = direction;
    historyEvent.Door_Open__c = doorOpen;
    historyEvent.put(sObjectfield, sobjectID);
    return historyEvent;
  }

  /**
   * @description To create a History Action record when the Lead is updated
   * through Geopointe.
   * @param eventType Holds Event Type to stamp on History Action.
   * @param historyEventId Holds History Event Id.
   * @param notes Holds notes to stamp on History Action.
   * @return historyAction Holds the record of History Action.
   */
  public static History_Action__c createHistoryAction(String eventType,
      String historyEventId, String notes) {

    History_Action__c historyAction = new History_Action__c();
    historyAction.Type__c = eventType;
    historyAction.History_Event__c = historyEventId;
    historyAction.Interaction_Notes__c = notes;
    return historyAction;
  }

  /**
   * @description Stamps latest History Event created date on Lead.
   * @param leadIds Holds Lead Ids.
   * @return null
   */
  @AuraEnabled
  public static void stampLatestHistoryEventCreatedDateOnLead(List<Id> leadIds) {

    String METHOD_NAME = 'stampLatestHistoryEventCreatedDateOnLead';
    list<lead> leadRecords = new list<lead>();
    try {
      for (Id leadId : leadIds) {
        leadRecords.add(
            new Lead(
            Id = leadId,
            Last_D2D_Activity_Date__c = System.today(),
            Sub_Status__c = Constants.LEAD.SUB_STATUS.ATTEMPTED_CONTACT));
      }
      update leadRecords;
    } catch(Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }
}