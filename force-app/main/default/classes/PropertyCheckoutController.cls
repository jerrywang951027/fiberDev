public class PropertyCheckoutController {

  public static final String OPPORTUNITY_MISSING =
      'Please enter the Opportunity on Property';
  private static final String SUCCESS_MESSAGE = 'Success';

  @AuraEnabled
  public static Property__c getProperty(
      Id propertyId) {
    Property__c objProperty = [
        SELECT Id,
        Name,
        Property_Type__c,
        Sub_Type__c,
        Pre_Qual_Property_Style__c,
        Service_Competitors__c,
        Marketing_Exclusivity__c,
        Marketing_Exclusivity_Expiration__c,
        Property_Website__c,
        Fiber_Finder_phone__c,
        Fiber_Finder_Email__c,
        Property_Manager__c,
        Onsite_Property_Manager__c,
        D2D_Allowed_Onsite__c,
        Restricted_Access_Options__c,
        Obtaining_Access_Options__c,
        Entry_Code__c,
        First_Tenant_Move_in_Date__c,
        Green_Field__c,
        Opportunity__c,
        Opportunity__r.Marketing_Exclusivity__c
        FROM Property__c WHERE Id = :propertyId];
    return objProperty;
  }

  @AuraEnabled
  public static String updateChecklist(Opportunity opportunityObj) {
    Savepoint sp = Database.setSavepoint();
    try {
      if (opportunityObj != null) {
        if (opportunityObj.Id == null) {
          return OPPORTUNITY_MISSING;
        }
        update opportunityObj;
      }

    } catch (Exception ex) {
      Database.rollback(sp);
      ErrorUtils.createExceptionLog(ex);
      return ex.getMessage();
    }

    return SUCCESS_MESSAGE;
  }
}