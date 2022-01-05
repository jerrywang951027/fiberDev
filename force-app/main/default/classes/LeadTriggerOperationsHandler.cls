/**
 * @group Premises
 * @description handler class for lead creation, progression
 * and life cycle based on events in related premise.
 */
public class LeadTriggerOperationsHandler {

  public static string CLASS_NAME = 'LeadTriggerOperationsHandler';
  /*
   * @params List of newleads and Old lead map
   * @description To update status of lead before update event
   * @returns void
   */
  public static void beforeUpdateEvents (List<Lead> newLeads, Map<Id, Lead> leadOldMap) {
    leadProofOfResidency(newLeads, leadOldMap);
    leadStatusManagement(newLeads, leadOldMap);
  }
  /*
   * @params List of newleads and Old leads
   * @description To update status of lead to inprogress when lead
   * name, phone and campaign fields are updated/changed
   * @returns void
   */
  public static void leadStatusManagement(List<Lead> newLeads, Map<Id, Lead> leadOldMap) {
    final string METHOD_NAME = 'leadStatusManagement';
    try {
      for (Lead newLead: newLeads) {
        if (leadOldMap.get(newLead.Id).Status == Constants.LEAD.STATUS.STATUS_NEW
           && isFieldChanged(newLead, leadOldMap.get(newLead.Id))) {
          newLead.Status = Constants.LEAD.STATUS.IN_PROGRESS;
          newLead.Sub_Status__c = Constants.LEAD.SUB_STATUS.NEEDS_FOLLOW_UP;
        }
      }
    }
    catch (exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /*
   * @params List of newleads and Old leads
   * @description It return boolean value when the following are changed
   * lead name, phone and campaign
   * @returns Boolean value
   */
  private static Boolean isFieldChanged(Lead newLead, Lead oldLead) {
    if (newLead.FirstName != oldLead.FirstName && newLead.LastName != oldLead.LastName
        && newLead.Phone != oldLead.Phone && newLead.How_The_Customer_Will_Sign_Up__c == null
        && newLead.Campaign__c != null && newLead.RecordTypeId == RecordTypeUtils.CUSTOMER_LEAD_ID) {
      return true;
    }
    return false;
  }

  /*
   * @params List of leads with changed status and sub status.
   * @description It changes the status of lead to 'In progress'
   * and sub status to 'Needs follow up' and 'Is Proof of residency completed' should
   * be editable only when lead is in Status = On Hold and Sub Status = Pending Proof of Residency'.
   * @returns Null
   */
  public static void leadProofOfResidency(List<Lead> leadList, Map<Id, Lead> leadOldMap) {
    final string METHOD_NAME = 'leadProofOfResidency';
    try{
      for(lead leadRecord : leadList) {
        if (!(leadRecord.Status == Constants.LEAD.STATUS.ON_HOLD
            && leadRecord.Sub_Status__c == Constants.LEAD.SUB_STATUS.PENDING_PROOF_OF_RESIDENCE)) {
              if(leadOldMap.get(leadRecord.Id).Is_Proof_of_residency_completed__c
                  != leadRecord.Is_Proof_of_residency_completed__c ) {
                leadRecord.addError('\'Is Proof of residency completed\' should be editable only '+
                    +'when lead is in Status = On Hold and '+
                    +'Sub Status = Pending Proof of Residency.');
              }
        }
        if(leadRecord.Status == Constants.LEAD.STATUS.ON_HOLD
            && leadRecord.Sub_Status__c == Constants.LEAD.SUB_STATUS.PENDING_PROOF_OF_RESIDENCE
            && leadRecord.Is_Proof_of_residency_completed__c == True
            && leadRecord.RecordTypeId == RecordTypeUtils.CUSTOMER_LEAD_ID) {
          leadRecord.Status = Constants.LEAD.STATUS.IN_PROGRESS;
          leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.NEEDS_FOLLOW_UP;
        }
      }
    }
    catch (exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }
}