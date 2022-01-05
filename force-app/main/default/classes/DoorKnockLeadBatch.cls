/**
 * @group DoorKnockLeadBatch
 * @description This class is used for calculating the DoorKnockCount and Last 4
 * month DoorKnockCount.
 */
global class DoorKnockLeadBatch implements Database.Batchable<sObject> {

  // this is the initial date from where history events will be considered for
  // 4 month DoorKnockCount.
  Date fourMonthsAgo = Date.today().addMonths(-4);

  // this is the initial date from where history events will be considered for
  // DoorKnockCount.
  Date oneYearAgo = Date.today().addYears(-1);

  global Database.QueryLocator start(Database.BatchableContext bc) {
      // filter criteria for the queried leads
      return Database.getQueryLocator ([
        SELECT
          Id,Status,
          Door_Knock_Count__c,
          Last_N_Month_Door_Knock_Count__c,
          (SELECT Id,
            Lead__c,
            Type__c,
            Event_Date__c
           FROM History_Events__r
           WHERE
            Type__c = :Constants.HISTORY_EVENT.TYPE.DOOR_TO_DOOR
            AND Event_Date__c > :oneYearAgo
          )
        FROM Lead
        WHERE
          RecordTypeId = :RecordTypeUtils.CUSTOMER_LEAD_ID
       ]);
  }

  /**
   * @description This method will update the status of disqualified Lead and
   * recyle Lead record.
   * @param batchContext It will hold the batch job Id.
   * @param scope It is the list of Lead records.
   * @return null
   */
  global void execute(Database.BatchableContext bc, List<Lead> records) {

    Map<Id,Lead> leadsToUpdateMap = new Map<Id,Lead>();
    for (Lead leadRecord : records) {

      Integer numberOfDoorKnocks = 0;
      Integer numberOfDoorKnocksLast4Months = 0;

      numberOfDoorKnocks = leadRecord.History_Events__r.size();

      for (History_Event__c event : leadRecord.History_Events__r) {
        if (event.Event_Date__c > fourMonthsAgo) {
          numberOfDoorKnocksLast4Months++;
        }
      }

      if (this.shouldUpdateLead(leadRecord,
                                numberOfDoorKnocks,
                                numberOfDoorKnocksLast4Months)) {
        Lead updatedLead = this.setNewLeadValues(leadRecord,
                                                numberOfDoorKnocks,
                                                numberOfDoorKnocksLast4Months);
        leadsToUpdateMap.put(updatedLead.Id, updatedLead);
      }
    }

    // update the Lead
    if (!leadsToUpdateMap.values().isEmpty()) {
        update leadsToUpdateMap.values();
    }
  }

  /**
   * @description This method is used for post-activity purpose after the
   * batch process.
   * @param batchContext It will hold the batch job Id.
   * @return null
   */
  global void finish(Database.BatchableContext bc) {
    // execute any post-processing operations
  }

 /**
  * @description This method return if the lead should be updated or not to
  * avoid unecessary updates
  * @param lead The lead that will be target of the comparison.
  * @param numberOfDoorKnocks The new number of door knocks.
  * @param numberOfDoorKnocksLast4Months The new number of door knocks in the
  * Last 4 Months.
  */
  private Boolean shouldUpdateLead(Lead lead,
                                    Integer numberOfDoorKnocks,
                                    Integer numberOfDoorKnocksLast4Months) {
    return lead.Door_Knock_Count__c != numberOfDoorKnocks ||
      lead.Last_N_Month_Door_Knock_Count__c != numberOfDoorKnocksLast4Months;
  }

 /**
  * @description This method return an updated lead based on new values provided.
  * @param lead The lead that will be target of change.
  * @param numberOfDoorKnocks The new number of door knocks.
  * @param numberOfDoorKnocksLast4Months The new number of door knocks in the
  * Last 4 Months.
  */
  private Lead setNewLeadValues(Lead lead,
                                Integer numberOfDoorKnocks,
                                Integer numberOfDoorKnocksLast4Months) {
    lead.Door_Knock_Count__c = numberOfDoorKnocks;
    lead.Last_N_Month_Door_Knock_Count__c = numberOfDoorKnocksLast4Months;

    return lead;
  }
}