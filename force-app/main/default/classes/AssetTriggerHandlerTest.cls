/**
 * @group Asset
 * @description To cover AssetHandler, improve code coverage and test functionality.
 */
@isTest
public class AssetTriggerHandlerTest {

  /**
   * @description Method sets up the test data used in this class.
   * @param null
   * return null
   */
  @testSetup
  private static void setupTestData() {

    Account accountObject = TestDataFactory.getAccountData();
    insert accountObject;
    Contact contactObject = TestDataFactory.getContactData(accountObject.Id);
    insert contactObject;
    vlocity_cmt__Premises__c premisesObject =
        TestDataFactory.getPremisesData(Constants.PREMISES.STATUS.UNVALIDATED);
    insert premisesObject;
    Asset assetObject = TestDataFactory.getAssetData(accountObject.Id,
        contactObject.Id);
    assetObject.vlocity_cmt__PremisesId__c = premisesObject.Id;
    assetObject.Status = Constants.ASSET.STATUS.CONNECT;
    insert assetObject;
  }

  /**
   * @description Test method for Asset which is checking the status.
   * @param null
   * @return null
   */
  @isTest
  private static void discontinuedAssetShouldCreateNewLead() {

    Asset assetObject = [
        SELECT
          Id,
          Status,
          vlocity_cmt__PremisesId__c
        FROM Asset
        LIMIT 1];
    assetObject.Status = Constants.ASSET.STATUS.INACTIVE;
    Test.startTest();
      update assetObject;
    Test.stopTest();
    List<Lead> leadList = [
        SELECT
          Id,
          vlocity_cmt__PremisesId__c,
          Status
        FROM Lead
        WHERE vlocity_cmt__PremisesId__c = :assetObject.vlocity_cmt__PremisesId__c];
    System.assertEquals(Constants.LEAD.STATUS.STATUS_NEW, leadList[0].Status);
  }
}