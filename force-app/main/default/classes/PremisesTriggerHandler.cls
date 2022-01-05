/**
 * @group Premises
 * @description Handler Class to related Premises trigger events.
 */
public class PremisesTriggerHandler {

  public static final String CLASS_NAME = 'PremisesTriggerHandler';

  /**
   * @description After insert functionality on Premises
   * @param premises List of new Premises record from trigger
   * @param premisesOldMap Map of Premises records from trigger
   * @return null
   */
  public static void afterInsertHandler(List<vlocity_cmt__Premises__c> premises) {

    createLeadOnServiceablePremises(premises, null);
  }

  /**
   * @description After update functionality on Premises
   * @param newPremisesList List of new Premises record from trigger
   * @param premisesOldMap Map of Premises records from trigger
   * @return null
   */
  public static void afterUpdateHandler(List<vlocity_cmt__Premises__c> newPremisesList,
      Map<Id, vlocity_cmt__Premises__c> premisesOldMap) {

    createLeadOnServiceablePremises(newPremisesList, premisesOldMap);
    // Method to update Lead status to onhold/new based on Premises status.
    updateLeadStatusOnPremisesChange(newPremisesList, premisesOldMap);
  }

  /**
   * @description Method for Lead creation when Premises becomes
   * serviceable and doesn't have a Lead associated with it
   * @param newPremisesList List of new Premises record from trigger
   * @param oldMap Map of Premises records from trigger
   * @return null
   */
  public static void createLeadOnServiceablePremises(List<vlocity_cmt__Premises__c> newPremisesList,
      Map<Id, vlocity_cmt__Premises__c> premisesOldMap) {

    final String METHOD_NAME = 'createLeadOnServiceablePremises';
    try {
      List<vlocity_cmt__Premises__c> premisesList = new List<vlocity_cmt__Premises__c>();
      Map<Id, Id> premisesWithLeadMap = new Map<Id, Id>();
      List<Lead> leadList = new List<Lead>();
      Set<Id> premisesId = new Set<Id>();
      for (vlocity_cmt__Premises__c premisesRecord : newPremisesList) {
        if ((premisesOldMap == null ||
            premisesRecord.vlocity_cmt__Status__c !=
            premisesOldMap.get(premisesRecord.Id).vlocity_cmt__Status__c) &&
            (premisesRecord.vlocity_cmt__Status__c == Constants.PREMISES.STATUS.SERVICEABLE)) {
          premisesList.add(premisesRecord);
          premisesId.add(premisesRecord.Id);
        }
      }
      if (!premisesList.IsEmpty()) {
        for (Lead leadPremises : [
            SELECT
              Id,
              vlocity_cmt__PremisesId__c,
              Is_Converted__c
            FROM
              Lead
            WHERE
              vlocity_cmt__PremisesId__c IN :premisesId
              AND Is_Converted__c = false]) {
          premisesWithLeadMap.put(leadPremises.vlocity_cmt__PremisesId__c, leadPremises.Id);
        }
      }
      for (vlocity_cmt__Premises__c premisesRecord : premisesList) {
        if (!premisesWithLeadMap.containsKey(premisesRecord.Id)) {
          leadList.add(
              LeadUtils.stampLeadDetails(premisesRecord,
                  Constants.LEAD.LEAD_SOURCE.ADDRESS_SERVICEABLE));
        }
      }
      if (!leadList.isEmpty()) {
        insert leadList;
      }
    }
    catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
  }

  /**
   * @description Updates Lead status accordingly when Premises status changes
   * @param premisesList List of new Premises record from trigger
   * @param premisesOldMap Map of Premises records from trigger
   * @return null
   */
  public static void updateLeadStatusOnPremisesChange(List<vlocity_cmt__Premises__c> premisesList,
      Map<Id, vlocity_cmt__Premises__c> premisesOldMap) {
    final String METHOD_NAME = 'updateLeadStatusOnPremisesChange';
    List<Id> premisesIds = new List<Id>();
    List<Lead> updateLeadList = new List<Lead>();
    List<Task> taskList = new List<Task>();
    Map<Id, Lead> leadByPremisesId = new Map<Id, Lead>();
    Savepoint statusSavePoint = Database.setSavepoint();
    try {
      for (vlocity_cmt__Premises__c premises : premisesList) {
        if (premisesOldMap.get(premises.Id).vlocity_cmt__Status__c !=
            premises.vlocity_cmt__Status__c
            && (premises.vlocity_cmt__Status__c == Constants.PREMISES.STATUS.NOT_SERVICEABLE
            || premises.vlocity_cmt__Status__c == Constants.PREMISES.STATUS.SUBMITTED_FOR_REVIEW
            || premises.vlocity_cmt__Status__c == Constants.PREMISES.STATUS.SERVICEABLE)) {
          premisesIds.add(premises.Id);
        }
      }
      for (Lead leadPremises : [
          SELECT
            Id,
            FirstName,
            Status,
            Sub_Status__c,
            vlocity_cmt__PremisesId__r.vlocity_cmt__Status__c
          FROM
            Lead
          WHERE
            vlocity_cmt__PremisesId__c IN :premisesIds]) {
        leadByPremisesId.put(leadPremises.vlocity_cmt__PremisesId__c, leadPremises);
      }
      for (vlocity_cmt__Premises__c premises : premisesList) {
        if (leadByPremisesId.containsKey(premises.Id)) {
          if ((premises.vlocity_cmt__Status__c == Constants.PREMISES.STATUS.NOT_SERVICEABLE
              || premises.vlocity_cmt__Status__c == Constants.PREMISES.STATUS.SUBMITTED_FOR_REVIEW)
              && (leadByPremisesId.get(premises.Id).Status == Constants.LEAD.STATUS.IN_PROGRESS
              || leadByPremisesId.get(premises.Id).Status == Constants.LEAD.STATUS.STATUS_NEW)) {
            updateLeadList.add(LeadUtils.setLeadForAddressReview(
                leadByPremisesId.get(premises.Id)));
          }
          else if (premises.vlocity_cmt__Status__c == Constants.PREMISES.STATUS.SERVICEABLE
              && leadByPremisesId.get(premises.Id).Status == Constants.LEAD.STATUS.ON_HOLD) {
            updateLeadList.add(LeadUtils.setLeadPostAddressReview(
                leadByPremisesId.get(premises.Id)));
            Task newTask =
                new Task(WhoId = leadByPremisesId.get(premises.Id).Id,
                    Subject = Constants.TASK.TYPES.FOLLOW_UP_CALL);
            taskList.add(newTask);
          }
        }
      }
      if (updateLeadList.size() > 0) {
        Database.update(updateLeadList);
        Database.insert(taskList);
      }
   }
   catch (Exception exp) {
     Database.rollback(statusSavePoint);
     LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
     throw exp;
    }
  }
}