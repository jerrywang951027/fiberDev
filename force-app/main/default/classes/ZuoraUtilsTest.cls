/**
 * @group TestClass-ZuoraUtils
 * @description Test class for ZuoraUtils to improve code coverage
 * and test functionality.
 */
@isTest
public with sharing class ZuoraUtilsTest {

  // Initialize class constants.
  private static final String INPUT_MAP_FIBER_BILLING_LINE_KEY = 'fiberBillingCFSLine';
  private static final String INPUT_MAP_REMOVE_PRODUCT_KEY = 'removeProducts';
  private static final String INPUT_MAP_UPDATE_PRODUCT_KEY = 'updateProducts';
  private static final String INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY = 'removedProductsChangeOfPlan';
  private static final String INPUT_MAP_ZUORA_INSTANCE_ID_KEY = 'zuoraProductInstanceID';
  private static final String INPUT_MAP_RATE_PLAN_ID_KEY = 'ratePlanId';
  private static final String ZUORA_EXTERNAL_ID = '2314563123';
  private static final String RATE_PLAN_INSTANCE_ID = '51384d21-3804-68b2-1c15-e13fc2a9ef84';
  private static final String PRODUCT_TYPE = 'Internet';
  
  @testSetup
  private static void setupData() {
    Zuora__SubscriptionRatePlan__c zuoraIns = new Zuora__SubscriptionRatePlan__c();
    zuoraIns.RatePlanInstanceID__c = RATE_PLAN_INSTANCE_ID;
    zuoraIns.Zuora__External_Id__c = ZUORA_EXTERNAL_ID;
    insert zuoraIns;
  }
    
/**
 * @description This method should return true.
 * @param null
 */
  @isTest
  private static void processRemoveProductsShouldAddRatePlanId() { 
    Map<String, Object> removeProduct = new Map<String, Object>{
      'zuoraProductInstanceID' => RATE_PLAN_INSTANCE_ID,
      'productType' => PRODUCT_TYPE
    };
    Map<String, Object> removeProducts = new Map<String, Object>{
      'removeProducts' => new List<Object>{removeProduct}
    };
    Map<String, Object> fiberBillingCFSLine = new Map<String, Object>{
      'fiberBillingCFSLine' => removeProducts
    };
    Map<String, Object> inputMap = fiberBillingCFSLine;
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
      
    Test.StartTest();
      ZuoraUtils.addZuoraRatePlanId(
          inputMap, outMap, options);
    Test.StopTest();
    
    Map<String, Object> lineKeyMap = 
        (Map<String, Object>) outMap.get(INPUT_MAP_FIBER_BILLING_LINE_KEY);
    List<Object> jsonAttList = 
        (List<Object>)lineKeyMap.get(INPUT_MAP_REMOVE_PRODUCT_KEY);
    Map<String, Object> jsonAttMap = (Map<String, Object>)jsonAttList[0];
    System.assertEquals (ZUORA_EXTERNAL_ID, 
        jsonAttMap.get(INPUT_MAP_RATE_PLAN_ID_KEY ),
        'Should add rate plan id to remove product node.');
  }
    
/**
 * @description This method should return true.
 * @param null
 */
  @isTest
  private static void processUpdateProductsShouldAddRatePlanId() { 
    Map<String, Object> updateProduct = new Map<String, Object>{
      'zuoraProductInstanceID' => RATE_PLAN_INSTANCE_ID,
      'productType' => PRODUCT_TYPE
    };
    Map<String, Object> updateProducts = new Map<String, Object>{
      'updateProducts' => new List<Object>{updateProduct}
    };
    Map<String, Object> fiberBillingCFSLine = new Map<String, Object>{
      'fiberBillingCFSLine' => updateProducts
    };
    Map<String, Object> inputMap = fiberBillingCFSLine;
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
      
    Test.StartTest();
      ZuoraUtils.addZuoraRatePlanId(
          inputMap, outMap, options);
    Test.StopTest();
    
    Map<String, Object> lineKeyMap = 
        (Map<String, Object>) outMap.get(INPUT_MAP_FIBER_BILLING_LINE_KEY);
    List<Object> jsonAttList = 
        (List<Object>)lineKeyMap.get(INPUT_MAP_UPDATE_PRODUCT_KEY);
    Map<String, Object> jsonAttMap = (Map<String, Object>)jsonAttList[0];
    System.assertEquals (ZUORA_EXTERNAL_ID, 
        jsonAttMap.get(INPUT_MAP_RATE_PLAN_ID_KEY),
        'Should add rate plan id to update product node.');
  }
    
/**
 * @description This method should return true.
 * @param null
 */
  @isTest
  private static void processRemoveProductChangePlanShouldAddRatePlanId() { 
    Map<String, Object> removedProductsChangeOfPlanIns = new Map<String, Object>{
      'zuoraProductInstanceID' => RATE_PLAN_INSTANCE_ID,
      'productType' => PRODUCT_TYPE
    };
    Map<String, Object> removedProductsChangeOfPlan = new Map<String, Object>{
      'removedProductsChangeOfPlan' => new List<Object>{removedProductsChangeOfPlanIns}
    };
    Map<String, Object> fiberBillingCFSLine = new Map<String, Object>{
      'fiberBillingCFSLine' => removedProductsChangeOfPlan
    };
    Map<String, Object> inputMap = fiberBillingCFSLine;
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
      
    Test.StartTest();
      ZuoraUtils.addZuoraRatePlanId(inputMap, outMap, options);
    Test.StopTest();
    
    Map<String, Object> lineKeyMap = 
        (Map<String, Object>) outMap.get(INPUT_MAP_FIBER_BILLING_LINE_KEY);
    List<Object> jsonAttList = 
        (List<Object>)lineKeyMap.get(INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY);
    Map<String, Object> jsonAttMap = (Map<String, Object>)jsonAttList[0];
    System.assertEquals (ZUORA_EXTERNAL_ID, 
        jsonAttMap.get(INPUT_MAP_RATE_PLAN_ID_KEY),
        'Should add rate plan id to remove change product node.');
  }
    
}