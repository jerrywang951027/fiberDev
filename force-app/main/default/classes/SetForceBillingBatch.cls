/**
 * @group SetForceBillingBatch
 * @description This class will update the FRLs fields and Order whenever the pick up install
 * date is greater than 7 days
 * for daily scheduled batch.
 */
global class SetForceBillingBatch implements Database.Batchable<sObject> {
  // this is the initial date where Pickup_Deliver_Install_Date__c will be
  // considered as lesser than 7 days.
  Date dateThreshold = Date.today().addDays(-7);

  global Database.QueryLocator start(Database.BatchableContext bc) {
    // filter criteria to query the vlocity_cmt__FulfilmentRequestLine__c object and the
    // related fields from order object.
    return Database.getQueryLocator([
      SELECT
        Id,
        Force_Billing__c,
        Pickup_Deliver_Install_Date__c,
        Is_Activated__c,
        vlocity_cmt__Product2Id__r.ProductCode,
        vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.vlocity_cmt__OrderStatus__c,
        vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Is_Activated__c,
        vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Force_Billing__c,
        vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Id
      FROM
        vlocity_cmt__FulfilmentRequestLine__c
      WHERE
        vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.vlocity_cmt__OrderStatus__c
            = :Constants.ORDER.STATUS.IN_PROGRESS
      AND
        vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Is_Activated__c = false
      AND
        vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Force_Billing__c = false
      AND
        vlocity_cmt__Product2Id__r.ProductCode =
            :Constants.PRODUCT.PRODUCT_CODE.PRD_FBR_INTERNET
      AND
        Pickup_Deliver_Install_Date__c <= :dateThreshold
    ]);
  }

  /**
   * @description This method will update the order and related FulfilmentRequestLine records.
   * @param scope It is the list of FulfilmentRequestLine records.
   */
  global void execute(Database.BatchableContext bc,
      List<vlocity_cmt__FulfilmentRequestLine__c> records) {
    List<Order> orderToUpdate = new List<Order>();
    List<vlocity_cmt__FulfilmentRequestLine__c> frlToUpdateList = new
        List<vlocity_cmt__FulfilmentRequestLine__c>();
    if (records.size() > 0) {
      for (vlocity_cmt__FulfilmentRequestLine__c frl :records) {
        orderToUpdate.add(new Order(
            Id = frl.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Id,
                Force_Billing__c = true));
        frlToUpdateList.add(new vlocity_cmt__FulfilmentRequestLine__c(
            Id = frl.Id, Force_Billing__c = true));
      }
    }
    Savepoint objectStatusSavePoint = Database.setSavepoint();
    try {
      if (!orderToUpdate.isEmpty()) {
        update orderToUpdate;
      }
      if (!frlToUpdateList.isEmpty()) {
        update frlToUpdateList;
      }
    } catch (Exception ex) {
      Database.rollBack(objectStatusSavePoint);
      }
  }

 /*
  * @description This method is used for post-activity purpose after the batch process.
  * @param batchContext It will hold the batch job Id.
  */
  global void finish(Database.BatchableContext bc) {
  }
}