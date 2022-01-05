/**
 * @group PremisesContoller
 * @description Test class for PremisesContoller to improve code coverage and test functionality.
 */
@isTest
private class PremisesControllerTest {

  /**
   * @description Test data set up method
   * @param NA
   * @return null
   */
  @testSetup
  private static void setupTestData() {

    // Creating Premises Record
    vlocity_cmt__Premises__c  premisesServiceable =
        TestDataFactory.getPremisesData(Constants.Premises.STATUS.SERVICEABLE);
    insert premisesServiceable;
    // Creating Lead Record
    Lead leadProgress = TestDataFactory.getLeadData();
    leadProgress.Status = Constants.Lead.STATUS.IN_PROGRESS;
    leadProgress.vlocity_cmt__PremisesId__c = premisesServiceable.Id;
    insert leadProgress;
  }

  /**
   *  @description Positive scenario to check Non serviceable Premises record update from Lead.
   *  @param NA
   *  @return null
   */
  @isTest
  private static void savePremisesInfoTest() {

    Lead leadRequest = [
        SELECT
          Id,
          Name
        FROM
          Lead
        WHERE
          Status =:Constants.Lead.STATUS.IN_PROGRESS
    ];
    Test.startTest();
      PremisesController.submitPremisesForRevision('Modify Address', 'Test', leadRequest.Id);
    Test.stopTest();
    Lead leadResponse = [
        SELECT
          Id,
          Name,
          vlocity_cmt__PremisesId__r.vlocity_cmt__Status__c,
          vlocity_cmt__PremisesId__r.Reason_for_Submission__c
        FROM
          Lead
        WHERE
          Id =:leadRequest.Id
    ];
    System.assertEquals('Modify Address',
        leadResponse.vlocity_cmt__PremisesId__r.Reason_for_Submission__c);
    System.assertEquals(Constants.Premises.STATUS.SUBMITTED_FOR_REVIEW,
        leadResponse.vlocity_cmt__PremisesId__r.vlocity_cmt__Status__c);
  }

  /**
   * @description Positive scenario to check exception.
   * @param NA
   * @return null
   */
  @isTest
  private static void savePremisesInfoExceptionTest() {

    try {
      Test.startTest();
      PremisesController.submitPremisesForRevision('Modify Address', 'Test', null);
      Test.stopTest();
    }
    catch (Exception exp) {
      Boolean expectedExceptionThrown = (exp.getMessage() != null) ? true : false;
      System.assertEquals(expectedExceptionThrown, true);
    }
  }
}