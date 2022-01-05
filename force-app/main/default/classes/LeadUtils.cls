/**
 * @group Lead
 * @description Utility methods for Lead.
 */
public class LeadUtils {
  private static Id salesQueueId;

  /**
   * @description When the Premises is serviceable, at that time
   * a Lead will be created according to its default value.
   * @param premisesRecord Input to create Lead record base on Premises object.
   * @param leadSource Input to set Lead source value
   * @return Lead record
   **/
  public static Lead stampLeadDetails(vlocity_cmt__Premises__c premisesRecord, String leadSource) {
    Lead leadRecord = new Lead();
    leadRecord.FirstName = Constants.LEAD.DEFAULT_VALUES.LEAD_DEFAULT_FIRSTNAME;
    leadRecord.LastName = Constants.LEAD.DEFAULT_VALUES.LEAD_DEFAULT_LASTNAME;
    leadRecord.vlocity_cmt__PremisesId__c = premisesRecord.Id;
    leadRecord.Phone = Constants.LEAD.DEFAULT_VALUES.LEAD_DEFAULT_PHONE;
    leadRecord.Status = Constants.LEAD.STATUS.STATUS_NEW;
    leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.READY_FOR_CONTACT;
    leadRecord.LeadSource = leadSource;
    leadRecord.City = premisesRecord.vlocity_cmt__City__c;
    leadRecord.Country = premisesRecord.vlocity_cmt__Country__c;
    leadRecord.Company = Constants.LEAD.DEFAULT_VALUES.LEAD_DEFAULT_COMPANY;
    leadRecord.Street = premisesRecord.vlocity_cmt__StreetAddress__c;
    leadRecord.PostalCode = premisesRecord.vlocity_cmt__PostalCode__c;
    leadRecord.State = premisesRecord.vlocity_cmt__State__c;
    leadRecord.Geolocation__Latitude__s = premisesRecord.vlocity_cmt__Geolocation__Latitude__s;
    leadRecord.Geolocation__Longitude__s = premisesRecord.vlocity_cmt__Geolocation__Longitude__s;
    leadRecord.OwnerId = getSalesQueue();
    leadRecord.RecordTypeId = RecordTypeUtils.CUSTOMER_LEAD_ID;
    return leadRecord;
  }

  /**
   * @description If there is a queueId, assign that to ownerId.
   * @param null
   * @return queueId
   **/
  public static Id getSalesQueue() {
    if (salesQueueId == null) {
      salesQueueId = [
          SELECT
            Id,
            QueueId
          FROM
            QueueSobject
          WHERE
            Queue.DeveloperName = :Constants.LEAD.DEFAULT_VALUES.SALES_QUEUE
      ].QueueId;
    }
    return salesQueueId;
  }

  /**
   * @description This method assigns a Lead to the Sales Queue.
   * @param leadRecord It contains Lead record to be updated.
   * @return Lead record
   **/
  public static Lead addLeadtoSalesQueue(Lead leadRecord) {
    leadRecord.Status = Constants.LEAD.STATUS.STATUS_NEW;
    leadRecord.OwnerId = getSalesQueue();
    leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.READY_FOR_CONTACT;
    return leadRecord;
  }

  /**
   * @description This method marks a Lead as pending for Address Review.
   * @param leadRecord It contains Lead record to be updated.
   * @return Lead record
   **/
  public static Lead setLeadForAddressReview(Lead leadRecord) {
    leadRecord.Status = Constants.LEAD.STATUS.ON_HOLD;
    leadRecord.LeadSource = Constants.LEAD.LEAD_SOURCE.ADDRESS_REVIEW;
    leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.ADDRESS_ISSUE;
    leadRecord.Objection_Reason__c = Constants.LEAD.OBJECTION_REASON.PENDING_ADDRESS;
    return leadRecord;
  }

  /**
   * @description This method stamps Lead status as new,
   * Lead sub-status as expression of interest and Lead Source as address review.
   * It also clears the objection reason if Premises status is serviceable.
   * @param leadRecord It contains Lead record to be updated.
   * @return Lead record
   **/
  public static Lead setLeadPostAddressReview(Lead leadRecord) {
    leadRecord.Status = Constants.LEAD.STATUS.STATUS_NEW;
    leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.EXPRESSION_INTEREST;
    leadRecord.LeadSource = Constants.LEAD.LEAD_SOURCE.ADDRESS_REVIEW;
    if (leadRecord.vlocity_cmt__PremisesId__r.vlocity_cmt__Status__c
        == Constants.PREMISES.STATUS.SERVICEABLE ) {
      leadRecord.Objection_Reason__c = '';
    }
    return leadRecord;
  }
}