/**
* @group TestClass-SetForceBillingBatch
* @description Test class for SetForceBillingBatch to improve code coverage
* and test functionality.
*/
@isTest
public with sharing class SetForceBillingBatchTest {
 /**
  * @description This method sets the test data.
  * @param null
  */
  @testSetup
  private static void setupData() {
    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;
    Order orderRecord = TestDataFactory.getOrderData(accountRecord.Id);
    orderRecord.Is_Activated__c = false;
    orderRecord.Force_Billing__c = false;
    orderRecord.vlocity_cmt__OrderStatus__c = Constants.ORDER.STATUS.IN_PROGRESS;
    insert orderRecord;
    vlocity_cmt__FulfilmentRequest__c fulfilmentRequest =
        TestDataFactory.getFrlData(orderRecord.Id);
    insert fulfilmentRequest;
    Product2 product2 = TestDataFactory.getProductData('TestName','TestFamily',
        Constants.PRODUCT.PRODUCT_CODE.PRD_FBR_INTERNET);
    insert product2;
    vlocity_cmt__FulfilmentRequestLine__c fulfilmentRequestLine =
        TestDataFactory.getFrlItemData(product2.Id, fulfilmentRequest.Id);
    fulfilmentRequestLine.Pickup_Deliver_Install_Date__c = System.Today() - 9;
    insert fulfilmentRequestLine;
  }

  @isTest
  private static void batchShouldUpdateForceBilling() {
    Test.StartTest();
      SetForceBillingBatchScheduler scheduler = new SetForceBillingBatchScheduler();
      String cronExpression = '0 0 0 * * ?';
      scheduler.execute(null);
    Test.StopTest();
    Order orders = [
        SELECT Force_Billing__c
        FROM Order
        LIMIT 1
    ];
    vlocity_cmt__FulfilmentRequestLine__c fulfillmentRequestLineItem = [
        SELECT Id, Force_Billing__c
        FROM vlocity_cmt__FulfilmentRequestLine__c
        LIMIT 1
    ];
    System.assertEquals (true, orders.Force_Billing__c,'Order Force Billing will be true');
    System.assertEquals (true, fulfillmentRequestLineItem.Force_Billing__c,
        'Fulfilment Request Line Force Billing will be true');
  }
}