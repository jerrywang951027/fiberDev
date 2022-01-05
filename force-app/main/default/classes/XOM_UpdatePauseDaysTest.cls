/**
*  @group TestClass-UpdatePauseDays
*  @description Test class for XOM_UpdatePauseDays to improve code coverage and test functionality.
*/
@isTest
public with sharing class XOM_UpdatePauseDaysTest {

  public static final String ORCH_ITEM_NAME = 'Test Valid Orch Item';
  public static final String ORCH_ITEM_MISSING_ERROR_MESSAGE = 'Orchestration item is missing.';
  public static final String MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE =
      'Please provide service account on order.';
  public static final String ORDER_WITHOUT_ACCOUNT = 'Order Without Account';

  /*
   * @description : This method is to create Test Data which will be used across all test methods.
   */
  @testSetup
  private static void setupTestData() {
    // Create Account
    Account testAcc = TestDataFactory.getAccountData();
    insert testAcc;

    // Create Order
    Order testOrder = TestDataFactory.getOrderData(testAcc.Id);
    testOrder.vlocity_cmt__DefaultServiceAccountId__c = testAcc.Id;

    // Create order without account.
    Order orderWithoutServiceAccount = TestDataFactory.getOrderData(testAcc.Id);
    orderWithoutServiceAccount.Name = ORDER_WITHOUT_ACCOUNT;

    insert new List<Order>{testOrder, orderWithoutServiceAccount};

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

    // Create Pause record
    Pause_History__c pause = new Pause_History__c(
        Account__c = testAcc.Id,
        Start_Date__c = Datetime.newInstance(2020, 04, 06),
        Pause_Order_Id__c = testOrder.Id
    );
    insert pause;
  }

  /**
   * @description test method to cover update pause days scenario
   * when pause start date and resume start date are in the same year.
   * @return null
   */
  @isTest
  static void passingOrchItemShouldUpdateExistingPauseDays() {
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
          Name =:ORCH_ITEM_NAME
        LIMIT 1
    ];
    Test.startTest();
      XOM_UpdatePauseDays pauseDays = new XOM_UpdatePauseDays();
      pauseDays.executeBatch(new List<vlocity_cmt__OrchestrationItem__c>{orchItem});
    Test.stopTest();
    List<Pause_History__c> pauseHistory = [
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
    System.assert(pauseHistory[0].Completed__c, 'Pause record 1 is completed.');
    System.assert(pauseHistory[1].Completed__c, 'Pause record 2 is completed.');
    System.assertEquals(
        orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
        pauseHistory[0].Account__c, 'Service accounts do not match'
    );
  }

  /**
   * @description test method to cover update pause days scenario
   * when pause start date and resume start date are in the differnt year.
   * @return null
   */
  @isTest
  static void ShouldCreateTwoPauseHistories() {
    Integer expectedNextYearBalance = 0;
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
      XOM_UpdatePauseDays pauseDays = new XOM_UpdatePauseDays();
      pauseDays.upsertPauseHistory(
          orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c
      );
    Test.stopTest();
    List<Pause_History__c> pauseHistory = [
        SELECT
          Id,
          Start_Date__c,
          End_Date__c,
          Account__c,
          Account__r.Next_Year_Pause_Days_Consumed__c,
          Completed__c
          FROM
            Pause_History__c
          WHERE
            Account__c =
              :orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId
    ];
    Datetime startDate = pauseHistory[1].Start_Date__c;
    Datetime endDate = pauseHistory[1].End_Date__c;
    expectedNextYearBalance =
        Date.newInstance(startDate.year(), startDate.month(),
        startDate.day()).daysBetween(Date.newInstance(endDate.year(),
        endDate.month(), endDate.day()));
    // Unit test assert
    System.assert(pauseHistory[0].Completed__c, 'Pause record 1 is completed.');
    System.assert(pauseHistory[1].Completed__c, 'Pause record 2 is completed.');
    System.assertEquals(
        orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
        pauseHistory[0].Account__c, 'Service accounts do not match'
    );
    System.assertEquals(expectedNextYearBalance,
        pauseHistory[1].Account__r.Next_Year_Pause_Days_Consumed__c,'Next year balance did not match');
  }

  /**
   * @description test method to cover missing orch item scenario
   * @return null
   */
  @isTest
  static void passingNullOrchItemShouldThrowError() {
    try{
      Test.startTest();
        XOM_UpdatePauseDays pauseDays = new XOM_UpdatePauseDays();
        pauseDays.executeBatch(new List<vlocity_cmt__OrchestrationItem__c>());
      Test.stopTest();
    }
    catch(XOM_UpdatePauseDays.AutoTaskUnrecoverableException e) {
      System.assert(e.getMessage().contains(ORCH_ITEM_MISSING_ERROR_MESSAGE),
        'Error message is not matching');
    }
  }

  /**
   * @description test method to cover missing order id
   * @return null
   */
  @isTest
  static void passingNullOrderIdShouldThrowError() {
    try{
      Test.startTest();
        XOM_UpdatePauseDays pauseDays = new XOM_UpdatePauseDays();
        pauseDays.upsertPauseHistory(null);
      Test.stopTest();
    }
    catch(XOM_UpdatePauseDays.AutoTaskUnrecoverableException e) {
      System.assert(e.getMessage().contains(
        XOM_UpdatePauseDays.ORDER_ID_MISSING_ERROR_MESSAGE),
          'Error message is not matching');
    }
  }

  /**
   * @description test method to cover missing service account id
   * @return null
   */
  @isTest
  static void passingNullServiceAccountIdShouldThrowError() {
    try{
      Order order = [
        SELECT
          Id
        FROM
          Order
        WHERE
          Name = :ORDER_WITHOUT_ACCOUNT
      ];
      Test.startTest();
        XOM_UpdatePauseDays pauseDays = new XOM_UpdatePauseDays();
        pauseDays.upsertPauseHistory(order.Id);
      Test.stopTest();
    }
    catch(XOM_UpdatePauseDays.AutoTaskUnrecoverableException e) {
      System.assert(e.getMessage().contains(
        MISSING_SERVICE_ACCOUNT_ID_ERROR_MESSAGE),
          'Error message is not matching');
    }
  }

}