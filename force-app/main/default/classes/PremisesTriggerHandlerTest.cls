/**
 * @group Premises
 * @description Test class for PremisesTriggerHandler to improve code coverage and
 * test functionality
 */
@isTest
private class PremisesTriggerHandlerTest {

  /**
   * @description Test data set up method.
   * @param NA
   * @return null
   */
  @testSetup
  private static void setupTestData() {

    // Creating Premises Record
    List<vlocity_cmt__Premises__c> premisesList = new List<vlocity_cmt__Premises__c>();
    vlocity_cmt__Premises__c premisesServiceable = TestDataFactory.getPremisesData(
        Constants.PREMISES.STATUS.SERVICEABLE);
    premisesList.add(premisesServiceable);
    vlocity_cmt__Premises__c  premisesNotServiceable = TestDataFactory.getPremisesData(
        Constants.PREMISES.STATUS.NOT_SERVICEABLE);
    premisesList.add(premisesNotServiceable);
    vlocity_cmt__Premises__c  premisesReview = TestDataFactory.getPremisesData(
        Constants.PREMISES.STATUS.SUBMITTED_FOR_REVIEW);
    premisesList.add(premisesReview);
    insert premisesList;
    // Creating Lead Record
    List<Lead> leadList = new List<Lead>();
    Lead leadOnHoldStatus = TestDataFactory.getLeadData();
    leadOnHoldStatus.Status = Constants.LEAD.STATUS.ON_HOLD;
    leadOnHoldStatus.vlocity_cmt__PremisesId__c = premisesList[0].Id;
    leadList.add(leadOnHoldStatus);
    Lead leadInProgress = TestDataFactory.getLeadData();
    leadInProgress.Status = Constants.LEAD.STATUS.IN_PROGRESS;
    leadInProgress.vlocity_cmt__PremisesId__c = premisesList[1].Id;
    leadList.add(leadInProgress);
    Lead leadOnNewStatus = TestDataFactory.getLeadData();
    leadOnNewStatus.Status = Constants.LEAD.STATUS.STATUS_NEW;
    leadOnNewStatus.vlocity_cmt__PremisesId__c = premisesList[2].Id;
    leadList.add(leadOnNewStatus);
    insert leadList;
  }

  /**
   * @description Method for testing Task creation for the Premises having status Serviceable
   * @param NA
   * @return null
   */
  @isTest
  private static void reviewStatusShouldCreateOnHoldLead() {

    List<vlocity_cmt__Premises__c> premisesList;
    List<Lead> leadList;
    premisesList = [
        SELECT
          Id,
          name,
          vlocity_cmt__Status__c
        FROM
          vlocity_cmt__Premises__c
        WHERE
          vlocity_cmt__Status__c = :Constants.PREMISES.STATUS.SERVICEABLE
    ];
    premisesList[0].vlocity_cmt__Status__c = Constants.PREMISES.STATUS.SUBMITTED_FOR_REVIEW;
    Test.startTest();
      update premisesList[0];
    Test.stopTest();
    leadList = [
        SELECT
          Id,
          Status
        FROM
          Lead
        WHERE
          vlocity_cmt__PremisesId__r.vlocity_cmt__Status__c =
              :Constants.PREMISES.STATUS.SUBMITTED_FOR_REVIEW
          AND Status =: Constants.Lead.STATUS.ON_HOLD
        LIMIT 1
    ];
    System.assertEquals(Constants.Lead.STATUS.ON_HOLD, leadList[0].Status);
  }

  /**
   * @description When Premises updated as serviceable Lead should be created
   * @param NA
   * @return null
   */
  @isTest
  private static void serviceableStatusShouldCreateNewLead() {

    List<vlocity_cmt__Premises__c> premisesList;
    List<Lead> leadList;
    premisesList = [
        SELECT
          Id,
          vlocity_cmt__Status__c
        FROM
          vlocity_cmt__Premises__c
        WHERE
          vlocity_cmt__Status__c = :Constants.PREMISES.STATUS.NOT_SERVICEABLE
    ];
    premisesList[0].vlocity_cmt__Status__c = Constants.PREMISES.STATUS.SERVICEABLE;
    Test.startTest();
      update premisesList[0];
    Test.stopTest();
    leadList = [
        SELECT
          Id,
          Status
        FROM
          Lead
        WHERE
          vlocity_cmt__PremisesId__r.vlocity_cmt__Status__c =
              :Constants.PREMISES.STATUS.SERVICEABLE
        LIMIT 1
    ];
    System.assertEquals(Constants.LEAD.STATUS.STATUS_NEW, leadList[0].Status);
  }
}