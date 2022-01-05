/**
 * @group TestClass-LeadTriggerOperationsHandler
 * @description Test class for LeadTriggerOperationsHandler
 * to improve code coverage and test functionality.
 */
@istest(SeeAllData = False)
private class LeadTriggerOperationsHandlerTest {
  /* this is test setup method*/
  @testsetup
  private static void testSetup() {
    //creating premise record for test data.
    vlocity_cmt__Premises__c premiseRecord = TestDataFactory.getPremisesData('Serviceable');
    List<vlocity_cmt__Premises__c> premisesList = new List<vlocity_cmt__Premises__c>();
    premisesList.add(premiseRecord);
    insert premisesList;
    Campaign camp = new Campaign();
    camp.Name = 'TestCampaign';
    camp.StartDate = Date.newInstance(2021, 12, 8);
    camp.EndDate = Date.newInstance(2021, 12, 9);
    insert camp;
    List<Lead> leadList = new List<lead>();
    //creating lead record for test data.
    Lead leadRecord = TestDataFactory.getCustomerLeadData();
    leadRecord.Status = 'New';
    leadRecord.FirstName = 'Unknown';
    leadRecord.LastName = 'Unknown';
    leadRecord.Company = 'Accenture2';
    leadRecord.Phone = '9177700012';
    leadRecord.Email = 'test@test2.com';
    leadRecord.Campaign__c = camp.Id;
    leadRecord.vlocity_cmt__PremisesId__c = premisesList[0].Id;
    leadList.add(leadRecord);
    insert leadList;
  }
  /**
   * @description This method is for testing lead status change for the lead when first name,
   * last name ,phone and campgain fields change.
   * @param NA
   * @return null
   */
  @isTest
  private static void leadNameAndPhoneChangesStatusGetUpdatedToInprogress() {
    Lead leadRecord = [
        SELECT
          Id,
          Status,
          FirstName,
          LastName,
          Sub_Status__c,
          RecordTypeId
        FROM
          Lead
        WHERE
          Email = 'test@test2.com'
        LIMIT 1
    ];
    Test.startTest();
    leadRecord.FirstName = 'TestLead';
    leadRecord.LastName = 'TestLead';
    leadRecord.Phone = '9177700022';
    leadRecord.How_The_Customer_Will_Sign_Up__c = null;
    update leadRecord;
    Test.stopTest();
   	Lead leadResponse = [
        SELECT
          Id,
          Status,
          FirstName,
          LastName,
          Sub_Status__c,
          RecordTypeId
        FROM
          Lead
        WHERE
          Email = 'test@test2.com'
        LIMIT 1
    ];
    System.assertEquals(Constants.LEAD.STATUS.IN_PROGRESS, leadResponse.Status,
        'Lead Status should update to In Progress');
    System.assertEquals(Constants.LEAD.SUB_STATUS.NEEDS_FOLLOW_UP, leadResponse.Sub_Status__c,
        'Lead Sub Status should update to Needs Follow Up');
  }

  /**
   * @description method for testing lead status change.
   * @param NA
   * @return null
   */
  @isTest
  private static void leadStatusAndSubStatusShouldAutomaticallyChangeOnVerification() {
    List<Lead> newLead = new List<Lead>();
    Lead leadRecord = [
        SELECT
          Id,
          Status,
          Sub_Status__c,
          FirstName,
          LastName
        FROM
          Lead
        LIMIT 1];
    leadRecord.Status = Constants.LEAD.STATUS.ON_HOLD;
    leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.PENDING_PROOF_OF_RESIDENCE;
    leadRecord.Is_Proof_of_residency_completed__c = true;
    test.startTest();
      update leadRecord;
    test.stopTest();
    Lead leadRecordPostUpdate = [
        SELECT
          Id,
          Status,
          Sub_Status__c,
          FirstName,
          LastName
        FROM
          Lead
        WHERE
          Id = :leadRecord.Id
        LIMIT 1
    ];
    System.assertEquals(Constants.LEAD.STATUS.IN_PROGRESS, leadRecordPostUpdate.Status,
        'Lead Status updated to In Progress');
  }
}