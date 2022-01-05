/*
 * @group XOMAutoTaskInvokeIPTest
 * @Description Test Class for XOMAutoTaskInvokeIntegrationProcedure
 */
@isTest
public class XOMAutoTaskInvokeIPTest {
  final static String VALID_OM_ITEM_NAME = 'TestValidItem';
  final static String INVALID_OM_ITEM_NAME = 'TestInvalidItem';
  /*
   * @description This method is to create Test Data which will be used across all test methods.
   */
  @testSetup
  private static void setupTestData() {
    // Create Account
    Account testAccount = TestDataFactory.getAccountData();
    insert testAccount;
    // Create Order
    Order testOrder = TestDataFactory.getOrderData(testAccount.Id);
    insert testOrder;
    // Create Orchestration Plan
    vlocity_cmt__OrchestrationPlan__c testOrchPlan = new vlocity_cmt__OrchestrationPlan__c(
      vlocity_cmt__OrderId__c = testOrder.Id
    );
    insert new List<vlocity_cmt__OrchestrationPlan__c>{testOrchPlan};
    // Create Orchestration Item For Valid IP Name
    vlocity_cmt__OrchestrationItem__c testOrchItemValid = new vlocity_cmt__OrchestrationItem__c(
      Name = VALID_OM_ITEM_NAME,
      vlocity_cmt__AutoTaskParameters__c = '{"procedureName":"Ordering_gDriveQuota" }',
      vlocity_cmt__OrchestrationPlanId__c = testOrchPlan.Id
    );
    // Create Orchestration Item For Invalid/Blank IP Name
    vlocity_cmt__OrchestrationItem__c testOrchItemInvalid = new vlocity_cmt__OrchestrationItem__c(
      Name = INVALID_OM_ITEM_NAME,
      vlocity_cmt__AutoTaskParameters__c = '{"procedureName":""}',
      vlocity_cmt__OrchestrationPlanId__c = testOrchPlan.Id
    );
    insert new List<vlocity_cmt__OrchestrationItem__c>{testOrchItemValid,testOrchItemInvalid};
    // Creating Defaul Log Level
    Logging_Level__c setting = new Logging_Level__c();
    setting.Name = 'Default';
    setting.Level__c = 'Default';
    insert setting;
  }
  /*
   * @description This method is to to test XOMAutoTaskInvokeIntegrationProcedure.executeBatch
   * for success scenario.
   */
  @isTest
  private static void passingValidFieldShouldCallIPSuccessfully() {
    XOMAutoTaskInvokeIntegrationProcedure xomAutoTaskInstance =
    new XOMAutoTaskInvokeIntegrationProcedure();
    List<vlocity_cmt__OrchestrationItem__c> items = [
      SELECT
        Id
      FROM
        vlocity_cmt__OrchestrationItem__c
      WHERE
        Name = :VALID_OM_ITEM_NAME
    ];
    Test.startTest();
      xomAutoTaskInstance.executeBatch(items);
    Test.stopTest();
    // Query the log generated
    List<Log__c> log = [
      SELECT
        Id
      FROM
        Log__c
      LIMIT
        1
    ];
    // Unit test assert Start
    System.assert(log.isEmpty());
  }
  /*
  * @description This method is to to test XOMAutoTaskInvokeIntegrationProcedure.executeBatch
  * for exception scenario.
  */
  @isTest
  private static void passingBlankIPNameShouldCreateException() {
    XOMAutoTaskInvokeIntegrationProcedure xomAutoTaskInstance =
    new XOMAutoTaskInvokeIntegrationProcedure();
    List<vlocity_cmt__OrchestrationItem__c> items = [
      SELECT
        Id
      FROM
        vlocity_cmt__OrchestrationItem__c
      WHERE
        Name = :INVALID_OM_ITEM_NAME
    ];
    Test.startTest();
      xomAutoTaskInstance.executeBatch(items);
    Test.stopTest();
    // Query the log generated
    List<Log__c> log = [
      SELECT
        Class__c,
        Method__c,
        Type__c,
        description__c,
        Status_Code__c
      FROM
        Log__c
      LIMIT
        1
    ];
    // Unit test assert Start
    System.assert(!log.isEmpty());
    System.assertEquals(log[0].Class__c, 'XOMAutoTaskInvokeIntegrationProcedure',
        'It will verify the exception log fires from class WRT log stored in Log object');
    System.assertEquals(log[0].Method__c, 'executeBatch',
        'It will check the exception fires from method of class WRT log stored in Log object');
    System.assertEquals(log[0].Type__c, 'System.SObjectException',
        'It will check the type of exception fires from class WRT log stored in Log object');
  }
  /*
  * @description This method is to to test XOMAutoTaskInvokeIntegrationProcedure.executeBatch
  * for exception scenario.
  */
  @isTest
  private static void passingMoreThanOneItemsShouldCreateException() {
    XOMAutoTaskInvokeIntegrationProcedure xomAutoTaskInstance =
    new XOMAutoTaskInvokeIntegrationProcedure();
    List<vlocity_cmt__OrchestrationItem__c> items = [
      SELECT
        Id
      FROM
        vlocity_cmt__OrchestrationItem__c
    ];
    Test.startTest();
      xomAutoTaskInstance.executeBatch(items);
    Test.stopTest();
    System.assert(items.size() > 1);
    // Query the log generated
    List<Log__c> log = [
        SELECT
          Class__c,
          Method__c,
          Type__c,
          description__c,
          Status_Code__c
        FROM
          Log__c
        LIMIT
          1
    ];
    // Unit test assert Start
    System.assert(!log.isEmpty());
    System.assertEquals(log[0].Class__c, 'XOMAutoTaskInvokeIntegrationProcedure',
        'It will verify the exception log fires from class WRT log stored in Log object');
    System.assertEquals(log[0].Method__c, 'executeBatch',
        'It will check the exception fires from method of class WRT log stored in Log object');
    System.assertEquals(log[0].Type__c, 'System.SObjectException',
        'It will check the type of exception fires from class WRT log stored in Log object');
  }
}