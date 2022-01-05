/**
* @group TestClass-EquipmentReturnedBatch
* @description Test class for EquipmentReturnedBatch to improve code coverage
* and test functionality.
*/
@isTest
public with sharing class EquipmentReturnedBatchTest {
 /**
  * @description This method sets the test data.
  * @param null
  */
  @testSetup
  private static void setupData() {
    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;
    Order orderRecord = TestDataFactory.getOrderData(accountRecord.Id);
    insert orderRecord;
    vlocity_cmt__FulfilmentRequest__c fulfilmentRequest =
        TestDataFactory.getFrlData(orderRecord.Id);
    insert fulfilmentRequest;
    Product2 product2 = TestDataFactory.getProductData('TestName','TestFamily',
        Constants.PRODUCT.PRODUCT_CODE.SVE_BILLING);
    insert product2;
    vlocity_cmt__FulfilmentRequestLine__c fulfilmentRequestLine =
        TestDataFactory.getFrlItemData(product2.Id, fulfilmentRequest.Id);
    fulfilmentRequestLine.Pickup_Deliver_Install_Date__c =
        EquipmentReturnedBatch.dateThreshold.addDays(-60);
    fulfilmentRequestLine.vlocity_cmt__FulfilmentStatus__c =
        Constants.FRL.FULFILMENT_STATUS.IN_PROGRESS;
    fulfilmentRequestLine.vlocity_cmt__Action__c =
        Constants.FRL.ACTION.DISCONNECT;
    fulfilmentRequestLine.Return_Days_Reached__c = false;
    fulfilmentRequestLine.Equipment_Returned__c = false;
    insert fulfilmentRequestLine;
  }

  @isTest
  private static void batchShouldUpdateEquipmentReturned() {
    Test.StartTest();
      EquipmentReturnedBatchScheduler scheduler = new EquipmentReturnedBatchScheduler();
      String cronExpression = '0 0 0 * * ?';
      scheduler.execute(null);
    Test.StopTest();

    vlocity_cmt__FulfilmentRequestLine__c fulfillmentRequestLineItem = [
        SELECT Id, Return_Days_Reached__c
        FROM vlocity_cmt__FulfilmentRequestLine__c
        LIMIT 1
    ];
    System.assertEquals (true, fulfillmentRequestLineItem.Return_Days_Reached__c,
        'Fulfilment Request Line Return Days Reached will be true');
  }
}