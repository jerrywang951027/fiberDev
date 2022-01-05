@isTest
public class MxUTestDataFactory {
  public static Lead createMxuLeadData() {
    Lead leadRec = new Lead();
    leadRec.Firstname = 'TEST';
    leadRec.LastName = 'TEST';
    leadRec.Email = 'test@test.com';
    leadRec.Phone = '723239473';
    leadRec.Status = 'Qualified by Sales and Tech Ops';
    leadRec.TechOps_Decision__c = true;
    leadrec.company = 'Test Company';
    leadRec.Record_Type__c = RecordTypeUtils.LEAD_MxU_DEV_NAME;
    leadRec.RecordTypeId = RecordTypeUtils.LEAD_MXU;
    leadRec.Street = '123 Main Street';
    leadRec.City = 'Sunnyvale';
    leadRec.State = 'CA';
    leadRec.PostalCode = '12345';
    leadRec.Country = 'USA';
    leadRec.Property_Name_MxU__c = 'Test Property';
    leadRec.Property_Classification__c = MxUConstants.OspReview
                                             .PROPERTY_CLASS.GREENFIELD;
    leadRec.Account_Relationship__c = 'Property Owner';
    leadRec.Property_Market__c = 'Austin';
    return leadRec;
  }

  public static OSP_Review__c createOspFromLead(Lead leadRec) {
    OSP_Review__c osp = new OSP_Review__c(
        Lead__c = leadRec.Id,
        Address__c = 'test addr',
        Property_Classification__c =
            MxUConstants.OspReview.PROPERTY_CLASS.GREENFIELD,
        Osp_Build_Status__c = MxUConstants.OspReview.BUILD_STATUS.HHA,
        TechOps_Serviceability_Form_Status__c =
            MxUConstants.OspReview.SERVICEABILITY.TO_BE_REVIEWED,
        Hut_Zone__c = 'test',
        Fiber_Assignments__c = 'test',
        OSP_Extension_Footage_Quantity__c = 'test',
        OSP_Leg__c = 'test',
        Reviewer_LDAP__c = 'test',
        Total_Number_Of_Units__c = 10
    );
    return osp;
  }
}