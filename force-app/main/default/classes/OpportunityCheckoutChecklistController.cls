public class OpportunityCheckoutChecklistController {

  public static final String PROFITABILITY_MISSING =
      'Please enter the Profitability on Property';
  public static final String PROPERTY_MISSING =
      'Please enter the Property on Opportunity';
  private static final String SUCCESS_MESSAGE = 'Success';

  @AuraEnabled
  public static Opportunity getOpportunity(
      Id recordId) {
    Opportunity objOppty = [
        SELECT Id, Property__c, Property__r.Construction_POC__c,
            Property__r.Unit_Economics__c,
            Property__r.Service_Competitors__c,
            Property__r.Negotiated_Partnership_Points__c,
            Property__r.Implemented_Partnership_Points__c,
            Property__r.Construction_POC__r.Name,
            Property__r.Year_Constructed__c,
            Property__r.Property_Classification_v2__c,
            Property__r.Pre_Qual_Property_Style__c,
            Property__r.Property_Type__c,
            Property__r.Sub_Type__c,
            Property__r.Cabling_Infrastructure_Coaxial__c,
            Property__r.Cabling_Infrastructure_Fiber__c,
            Property__r.Cabling_Infrastructure_Twisted_Pair__c,
            Property__r.Walls_Close_Date__c,
            Property__r.First_Tenant_Move_in_Date__c,
            Property__r.Number_of_Courtesy_Accounts__c,
            Property__r.Profitability__c,
            Property__r.Profitability__r.Terminal_Take_Rate__c,
            Property__r.Profitability__r.Time_to_Terminal_Take_Rate_in_Months__c,
            Property__r.Profitability__r.Projected_1st_Month_TR__c,
            Property__r.Profitability__r.Finalize__c,
            RecordType.DeveloperName,
            StageName, Name,
            Contract_Type__c, Date_AA_Signed__c,
            Service_Commitment_Language_y_n__c,
            Terms_of_the_Service_Commitment__c,
            Service_Commitment_Date__c,
            Date_term_Initiates_on__c,
            Expiration_Term_Years__c,
            Auto_Renewal_Terms_Years__c,
            Auto_Renewal_Notice_Period_Months__c,
            Property_Sale_Terms__c,
            Simba_Deal_ID__c,
            Webpass_Deal_ID__c,
            Simba_Deal_Sales_Status__c,
            Legal_Entity_Text__c,
            Total_Number_Of_Units__c,
            Marketing_Exclusivity__c,
            Marketing_Exclusivity_Notes__c,
            Inside_Wiring_Exclusivity__c,
            Cure_Period__c,
            Binding_Assignment_Min_Years__c,
            Insurance_Requirements_for_Vendors__c,
            Legal_Notice_Street_Address__c,
            Legal_Notice_City__c,
            Legal_Notice_State__c,
            Legal_Notice_Zip__c,
            Legal_Team_Member__c,
            First_Tenant_Move_In_Date__c,
            Survival_Terms__c,
            DAF_Signed_Y_N__c
        FROM Opportunity WHERE Id = :recordId];
    return objOppty;
  }

  @AuraEnabled
  public static String updateChecklist(Opportunity opportunityObj,
      Property__c propertyObj,Profitability__c profitabilityObj, Id propertyId) {
    Savepoint sp = Database.setSavepoint();
    try {
      if (profitabilityObj != null) {
        if (profitabilityObj.Id == null) {
          if (propertyId == null) {
            return PROPERTY_MISSING;
          }
          return PROFITABILITY_MISSING;
        }

        update profitabilityObj;
      }

      if (propertyObj != null) {
        if (propertyObj.Id == null) {
          return PROPERTY_MISSING;
        }
        propertyObj.Construction_POC__r = null;
        update propertyObj;
      }

      if (opportunityObj != null) {
        update opportunityObj;
      }
    } catch(Exception ex) {
      Database.rollback(sp);
      return ex.getMessage();
    }

    return SUCCESS_MESSAGE;
  }
}