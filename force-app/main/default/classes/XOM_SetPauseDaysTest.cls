/**
*  @group TestClass-XOM_SetPauseDays
*  @description Test class for XOM_SetPauseDays to improve code coverage and test functionality.
*/
@isTest
public with sharing class XOM_SetPauseDaysTest {

  public static final String ORCH_ITEM_NAME = 'Test Valid Orch Item';
  public static final String ORCH_ITEM_MISSING_ERROR_MESSAGE = 'Orchestration item is missing.';
  public static final String MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE =
      'Please provide service account on order.';

  /*
   * @description : This method is to create Test Data
   * which will be used across all test methods.
   */
  @testSetup
  private static void setupTestData() {
    // Create Account
    Account testAcc = TestDataFactory.getAccountData();
    insert testAcc;

    // Create Order
    Order testOrder = TestDataFactory.getOrderData(testAcc.Id);
    testOrder.vlocity_cmt__DefaultServiceAccountId__c = testAcc.Id;
    insert testOrder;

    // Create Orchestration Plan
    vlocity_cmt__OrchestrationPlan__c testOrchPlan = new vlocity_cmt__OrchestrationPlan__c(
        vlocity_cmt__OrderId__c = testOrder.Id
    );
    insert new List<vlocity_cmt__OrchestrationPlan__c>{testOrchPlan};

    // Create Orchestration Item For Valid IP Name
    vlocity_cmt__OrchestrationItem__c testOrchItemValid = new vlocity_cmt__OrchestrationItem__c(
        Name = ORCH_ITEM_NAME,
        vlocity_cmt__OrchestrationPlanId__c = testOrchPlan.Id
    );
    insert new List<vlocity_cmt__OrchestrationItem__c>{testOrchItemValid};
  }

  /**
   * @description test method to set pause days
   * @return null
   */
  @isTest
  static void passingOrchItemShouldCreatePauseDays() {
    vlocity_cmt__OrchestrationItem__c orchItem = [
        SELECT
          Id,
          Name,
          vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c,
          vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
          vlocity_cmt__FulfilmentRequestLineId__c,
          vlocity_cmt__AutoTaskParameters__c
        FROM
          vlocity_cmt__OrchestrationItem__c
        WHERE
          Name =: ORCH_ITEM_NAME
        LIMIT 1
    ];
    Test.startTest();
      XOM_SetPauseDays setPauseDays = new XOM_SetPauseDays();
      setPauseDays.executeBatch(new List<vlocity_cmt__OrchestrationItem__c>{orchItem});
    Test.stopTest();
    List<Pause_History__c> pause = [
        SELECT
          Id,
          Account__c,
          Completed__c
          FROM
            Pause_History__c
          WHERE
            Account__c =
              :orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId
    ];
    // Unit test assert
    System.assert(!pause[0].Completed__c, 'Pause record is completed.');
    System.assertEquals(
        orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
        pause[0].Account__c,'Service accounts do not match');
  }

  /**
   * @description test method to cover missing orch item scenario
   * @return null
   */
  @isTest
  static void passingNullOrchItemShouldThrowError() {
    try{
      Test.startTest();
        XOM_SetPauseDays setPauseDays = new XOM_SetPauseDays();
        setPauseDays.executeBatch(new List<vlocity_cmt__OrchestrationItem__c>());
      Test.stopTest();
    }
    catch (XOM_SetPauseDays.AutoTaskUnrecoverableException e) {
      System.assert(e.getMessage().contains(ORCH_ITEM_MISSING_ERROR_MESSAGE),
          'Error message is not matching');
    }

  }

  /**
   * @description test method to cover missing service account id
   * @return null
   */
  @isTest
  static void passingNullOrderIdShouldThrowError() {
    try{
      Test.startTest();
        XOM_SetPauseDays pauseDays = new XOM_SetPauseDays();
        pauseDays.createPauseHistoryForPauseOrder(null);
      Test.stopTest();
    }
    catch(XOM_SetPauseDays.AutoTaskUnrecoverableException e) {
      System.assert(e.getMessage().contains(
          XOM_SetPauseDays.MISSING_ORDER_ID_ERROR_MESSAGE),
          'Error message is not matching');
    }
  }

}