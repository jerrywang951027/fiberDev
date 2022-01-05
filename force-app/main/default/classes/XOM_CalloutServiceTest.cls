/*
 * @description:   Test Class for XOM_CalloutService
 */
@isTest
public class XOM_CalloutServiceTest {

  final static XOM_CalloutService CALLOUT_INSTANCE = new XOM_CalloutService();
  final static String VALID_ORCH_ITME = 'TestValidItem';
  final static String INVALID_ORCH_ITME = 'TestInvalidItem';
  final static String IP_ERROR_RESPONSE_MESSAGE = 'IP Error Response';

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

    insert testOrder;

    // Create Orchestration Plan
    vlocity_cmt__OrchestrationPlan__c testOrchPlan = new vlocity_cmt__OrchestrationPlan__c(
        vlocity_cmt__OrderId__c = testOrder.Id
    );

    insert new List<vlocity_cmt__OrchestrationPlan__c>{testOrchPlan};

    // Create Orchestration Item For Valid IP Name
    vlocity_cmt__OrchestrationItem__c testOrchItemValid = new vlocity_cmt__OrchestrationItem__c(
        Name = XOM_CalloutServiceTest.VALID_ORCH_ITME,
        vlocity_cmt__AutoTaskParameters__c = '{"integrationProcedureName":"XOM_CreateZuoraAccount" }',
        vlocity_cmt__OrchestrationPlanId__c = testOrchPlan.Id
    );

    // Create Orchestration Item For invalid/Blank IP Name
    vlocity_cmt__OrchestrationItem__c testOrchItemInvalid = new vlocity_cmt__OrchestrationItem__c(
        Name = XOM_CalloutServiceTest.INVALID_ORCH_ITME,
        vlocity_cmt__AutoTaskParameters__c = '{"integrationProcedureName":""}',
        vlocity_cmt__OrchestrationPlanId__c = testOrchPlan.Id
      );

    insert new List<vlocity_cmt__OrchestrationItem__c>{testOrchItemValid,testOrchItemInvalid};

  }
  /*
  * @description : This method is to to test XOM_CalloutService.processIPResponse for Failure Scenario.
  */
  @isTest
  private static void passingFaileResponseShouldCreateLog() {
    // Initializing Method Name
    String API_RESPONSE_KEY = XOM_CalloutService.IP_OUTPUT_KEY_API_RESPONSE;

    Map<String,Object> apiResponseMap = new Map<String,Object>();

    // Creating Sample Failure Response
    apiResponseMap.put(XOM_CalloutService.IP_OUTPUT_KEY_API_RESPONSE,new Map<String,Object>{
      'success' => false
    });


    try{
      // Start Test
      Test.startTest();
      CALLOUT_INSTANCE.processIPResponse(apiResponseMap);
      Test.stopTest();
    }
    catch(XOM_CalloutService.DefaultInterfaceUnrecoverableException e) {
      System.assert(e.getMessage().contains(IP_ERROR_RESPONSE_MESSAGE));
    }

  }

  /*
  * @description : This method is to to test XOM_CalloutService.
  *                Execute Item for Success Scenario.
  */
  @isTest private static void passingSingleOrchestrationItemWithIPNameExecutesIP() {
    vlocity_cmt__OrchestrationItem__c orchItem = [
      SELECT
        Id,
        Name,
        vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c,
        vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
        vlocity_cmt__AutoTaskParameters__c
      FROM
        vlocity_cmt__OrchestrationItem__c
      WHERE
        Name =: XOM_CalloutServiceTest.VALID_ORCH_ITME
    ];
      // Start Test
      Test.startTest();
        CALLOUT_INSTANCE.executeItem('','',orchItem);
      Test.stopTest();
  }

  /*
  * @description : This method is to to test XOM_CalloutService.executeItem for Blank IP Name Scenario.
  */
  @isTest private static void passingBlankIPNameShouldCreateLogForExecuteItem() {
    vlocity_cmt__OrchestrationItem__c orchItem = [
      SELECT
        Id,
        Name,
        vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c,
        vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
        vlocity_cmt__AutoTaskParameters__c
      FROM
        vlocity_cmt__OrchestrationItem__c
      WHERE
        Name =: XOM_CalloutServiceTest.INVALID_ORCH_ITME
    ];

    try{
      // Start Test
      Test.startTest();
        CALLOUT_INSTANCE.executeItem('','',orchItem);
      Test.stopTest();
    }
    catch(XOM_CalloutService.DefaultInterfaceUnrecoverableException e) {
      System.assert(e.getMessage().contains(IP_ERROR_RESPONSE_MESSAGE));
    }

  }

  /*
  * @description : This method is to to test XOM_CalloutService.
  *                IntegrationProcedure for Failure Scenario.
  */
  @isTest private static void passingBlankIPNameShouldCreateLogForinvokeIntegrationProcedure() {
    Map<String,Object> inputMap = new map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> optionsMap = new map<String,Object>();

    try{
      // Start Test
      Test.startTest();
        CALLOUT_INSTANCE.invokeIntegrationProcedure('',inputMap,outMap,optionsMap);
      Test.stopTest();
    }
    catch(XOM_CalloutService.DefaultInterfaceUnrecoverableException e) {
      System.assert(e.getMessage().contains(IP_ERROR_RESPONSE_MESSAGE));
    }
  }
}