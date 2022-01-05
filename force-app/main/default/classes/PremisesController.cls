/**
 * @group PremisesController
 * @description This class is used to get the details of Premises record and update
 * the fields when submitted for review.
 */
public with sharing class PremisesController {
  static String CLASS_NAME = 'PremisesController';

  /*
   * @description To fetch the details of Premises tagged on the Lead record.
   * @param leadId Passing the Lead record Id
   * @return Lead record with Premises details
   */
  @AuraEnabled(cacheable = true)
  public static Lead getLeadWithPremises(Id leadId) {

    String METHOD_NAME = 'getLeadWithPremises';
    try {
      return [
          SELECT Id,
            vlocity_cmt__PremisesId__c,
            vlocity_cmt__PremisesId__r.Name
          FROM Lead
          WHERE Id = :leadId];
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /*
   * @description To update the Reason and comments on Premises that are captured while submitting
   * for revision.
   * @param reason Input from submitReview LWC to capture reason in Premises record.
   * @param comments Input from submitReview LWC to capture reason in Premises record.
   * @param leadId Input to fetch Premises WRT Lead record.
   * @return response status for updating the records.
   */
  @AuraEnabled
  public static string submitPremisesForRevision(String reason, String comments, Id leadId) {

    String METHOD_NAME = 'submitPremisesForRevision';
    String response = null;
    List<vlocity_cmt__Premises__c> premisesUpdate = new List<vlocity_cmt__Premises__c>();
    try {
      Lead leadDetails = getLeadWithPremises(leadId);
      if (String.isNotEmpty(reason)) {
        vlocity_cmt__Premises__c premisesRecord = new vlocity_cmt__Premises__c();
        premisesRecord.Id = leadDetails.vlocity_cmt__PremisesId__c;
        premisesRecord.Reason_for_Submission__c = reason;
        premisesRecord.Comments__c = comments;
        premisesRecord.vlocity_cmt__Status__c = Constants.Premises.STATUS.SUBMITTED_FOR_REVIEW;
        premisesUpdate.add(premisesRecord);
      }
      if (!premisesUpdate.isEmpty()) {
          Database.SaveResult[] saveResultList = Database.update(premisesUpdate, false);
          // Iterate through each returned result
          for (Database.SaveResult saveResponse : saveResultList) {
            if (saveResponse.isSuccess()) {
              response = Constants.Address.REVIEW.SUCCESS_RESPONSE;
            }
            else {
              for (Database.Error err : saveResponse.getErrors()) {
                response = Constants.Address.REVIEW.FAILURE_RESPONSE;
              }
            }
          }
        }
    } catch (Exception exp) {
        LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
        throw exp;
    }
    return response;
  }
}