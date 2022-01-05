/**
* @group CSR Console
* @description Test class for OrderList to improve code coverage
  and test functionality.
*/
@isTest
public with sharing class OrderListTest {
  @testSetup static void setupTestData() {
    Account testAccount = TestDataFactory.getAccountData();
    insert testAccount;

    Vlocity_cmt__Premises__c testPremise = TestDataFactory.getPremisesData(
        Constants.Premises.STATUS.UNVALIDATED);
    insert testPremise;

    Account testServiceAccount = TestDataFactory.getAccountData();
    testServiceAccount.RecordTypeId = RecordTypeUtils.SERVICE_ACCOUNT_ID;
    testServiceAccount.vlocity_cmt__Status__c = 'Active';
    testServiceAccount.Account_Id__c = '';
    testServiceAccount.vlocity_cmt__PremisesId__c = testPremise.Id;
    testServiceAccount.ParentId = testAccount.Id;
    insert testServiceAccount;

    Id standardPricebookId = Test.getStandardPricebookId();
    Order testOrders = TestDataFactory.getOrderData(testAccount.Id);
    testOrders.Pricebook2Id = standardPricebookId;
    testOrders.vlocity_cmt__DefaultPremisesId__c = testPremise.Id;
    testOrders.vlocity_cmt__OrderStatus__c = Constants.Order.STATUS.IN_PROGRESS;
    testOrders.vlocity_cmt__FulfilmentStatus__c = Constants.Order.STATUS.IN_PROGRESS;
    testOrders.vlocity_cmt__DefaultServiceAccountId__c = testServiceAccount.Id;
    insert testOrders;

    Product2 testProductA = TestDataFactory.getProductData('Prod A', 'Additional Service',
        'OFR_Storage_1TB');
    insert testProductA;
    Product2 testProductB = TestDataFactory.getProductData('Prod B', 'Additional Service',
        'OFR_Storage_1GB');
    insert testProductB;

    PricebookEntry testPricebookEntryA = TestDataFactory.getPricebookEntry(
        standardPricebookId, testProductA.Id);
    insert testPricebookEntryA;

    PricebookEntry testPricebookEntryB = TestDataFactory.getPricebookEntry(
        standardPricebookId, testProductB.Id);
    insert testPricebookEntryB;

    OrderItem testOrderItemParent = TestDataFactory.getOrderItemData(testOrders.id,
        testPricebookEntryA.Id, testProductA.Id);
    insert testOrderItemParent;

    OrderItem testOrderItemChild = TestDataFactory.getOrderItemData(testOrders.id,
        testPricebookEntryB.Id, testProductB.Id);
    testOrderItemChild.vlocity_cmt__RootItemId__c = testOrderItemParent.Id;
    testOrderItemChild.vlocity_cmt__ParentItemId__c = testOrderItemParent.Id;
    insert testOrderItemChild;
  }
  /**
   * @description This is a test method to test invokeMethod() of class OrderList
   * overriden from vlocity_cmt.VlocityOpenInterface2.
   * @return null
   */
  @isTest static void invokeFetchOrderDetailsShouldReturnOrderList() {
    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    Account serviceAccount = [
        SELECT
          ID
        FROM
          Account
        WHERE
          RecordTypeId = :RecordTypeUtils.SERVICE_ACCOUNT_ID
        LIMIT 1
    ];
    String methodName = 'fetchOrderDetails';
    inputMap.put('serviceAccountId', serviceAccount.Id);
    OrderList orderObject = new OrderList();

    Test.startTest();
      Boolean result = orderObject.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();

    System.assert(result);
    System.assert(json.serialize(outMap.get('orderList')).contains('orderId'));
    System.assert(json.serialize(outMap.get('orderList')).contains('Prod A'));
    System.assert(json.serialize(outMap.get('orderList')).contains('Prod B'));
  }
}