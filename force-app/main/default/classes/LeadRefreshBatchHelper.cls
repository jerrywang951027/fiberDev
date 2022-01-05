/**
 * @group LeadRefreshBatch
 * @description This class used for logic process execute method of LeadRefreshBatch.
 */
public with sharing class LeadRefreshBatchHelper {

  public final static String CLASS_NAME = 'LeadRefreshBatchHelper';
  /**
   * @description This is the method to indentifyLeadForRecycling.
   * @param scope Which hold list of Leads records.
   * @return null
   */
  public static void updateLeadStatus(List<Lead> scope) {

    final String METHOD_NAME = 'updateLeadStatus';
    try {
      Date today = System.today();
      Date maxVacantSubStatusDate = today.addMonths(-6);
      Date maxDoNotContactDate = today.addDays(-60);
      List<Lead> leadsToUpdate = new List<Lead>();
      for (Lead leadUpdate : scope) {
        if (leadUpdate.History_Events__r[0] != null) {
          if (leadUpdate.History_Events__r[0].Event_Date__c != null &&
              ((leadUpdate.History_Events__r[0].Event_Date__c <= maxVacantSubStatusDate &&
              (leadUpdate.Sub_Status__c == Constants.LEAD.SUB_STATUS.VACANT ||
              leadUpdate.Sub_Status__c == Constants.LEAD.SUB_STATUS.NOT_INTERESTED)) ||
              (leadUpdate.History_Events__r[0].Event_Date__c <= maxDoNotContactDate &&
              leadUpdate.Sub_Status__c == Constants.LEAD.SUB_STATUS.DO_NOT_CONTACT))) {
            leadsToUpdate.add(LeadUtils.addLeadtoSalesQueue(leadUpdate));
          }
        }
      }
      if (leadsToUpdate.size() > 0) {
       update leadsToUpdate;
      }
    } catch(Exception e) {
        LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
    }
  }
}