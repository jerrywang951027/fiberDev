/**
 * @group LeadRefreshBatchScheduler
 * @description This class used for scheduling the LeadBatch class.
 */
global with sharing class LeadRefreshBatchScheduler implements Schedulable {

  /**
   * @description This method used for scheduling the context variable
   * @param SchedulableContext schedulableContext
   * @return null
   */
  global void execute(SchedulableContext schedulableContext) {

    String query = 'SELECT Id, Status, Sub_Status__c, OwnerId, Owner.Name,' +
        ' (SELECT Id, Event_Date__c, CreatedDate FROM History_Events__r' +
        ' ORDER BY CreatedDate desc LIMIT 1)' +
        ' FROM Lead WHERE Status = \''+ Constants.LEAD.STATUS.DISQUALIFIED +'\' '+
        ' AND RecordTypeId = \''+ RecordTypeUtils.CUSTOMER_LEAD_ID +'\' '+
        ' AND Sub_Status__c IN (\''+ Constants.LEAD.SUB_STATUS.VACANT +'\','+
        ' \''+ Constants.LEAD.SUB_STATUS.NOT_INTERESTED +'\','+
        ' \''+ Constants.LEAD.SUB_STATUS.DO_NOT_CONTACT +'\')';
    Database.executeBatch(new LeadRefreshBatch(query));
  }
}