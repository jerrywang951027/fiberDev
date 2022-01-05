/**
 * @group EquipmentReturnedBatch
 * @description This class will update the FRLs fields whenever the
 * pick up deliver install date is greater than 60 days
 * for daily scheduled batch.
 */
public with sharing class EquipmentReturnedBatch implements Database.Batchable<sObject> {
  public final static String CLASS_NAME = 'EquipmentReturnedBatch';
  // this is the initial date where Pickup_Deliver_Install_Date__c will be
  // considered as lesser than 60 days.
  @TestVisible static Date dateThreshold = Date.today().addDays(-60);

  public Database.QueryLocator start(Database.BatchableContext bc) {
    // filter criteria to query the vlocity_cmt__FulfilmentRequestLine__c object
    return Database.getQueryLocator([
      SELECT
        Id,
        vlocity_cmt__FulfilmentStatus__c,
        vlocity_cmt__Action__c,
        Equipment_Returned__c,
        Return_Days_Reached__c,
        vlocity_cmt__Product2Id__c,
        Pickup_Deliver_Install_Date__c
      FROM
        vlocity_cmt__FulfilmentRequestLine__c
      WHERE
        vlocity_cmt__FulfilmentStatus__c =
            :Constants.FRL.FULFILMENT_STATUS.IN_PROGRESS
      AND
        vlocity_cmt__Action__c = :Constants.FRL.ACTION.DISCONNECT
      AND
        Equipment_Returned__c = false
      AND
        Return_Days_Reached__c = false
      AND
        vlocity_cmt__Product2Id__r.ProductCode =
            :Constants.PRODUCT.PRODUCT_CODE.SVE_BILLING
      AND
        Pickup_Deliver_Install_Date__c <= :dateThreshold
    ]);
  }

  /**
   * @description This method will update the FulfilmentRequestLine records.
   * @param scope It is the list of FulfilmentRequestLine records.
   */
  public void execute(Database.BatchableContext bc,
      List<vlocity_cmt__FulfilmentRequestLine__c> records) {

    final String METHOD_NAME = 'execute';
    List<vlocity_cmt__FulfilmentRequestLine__c> frlToUpdateList = new
        List<vlocity_cmt__FulfilmentRequestLine__c>();
    if (records.size() > 0) {
      for (vlocity_cmt__FulfilmentRequestLine__c frl : records) {
        frlToUpdateList.add(new vlocity_cmt__FulfilmentRequestLine__c(Id = frl.Id,
            Return_Days_Reached__c = true));
      }
    }
    try {
      if (!frlToUpdateList.isEmpty()) {
        update frlToUpdateList;
      }
    } catch (Exception ex) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, ex);
    }
  }

 /*
  * @description This method is used for post-activity purpose after the batch process.
  * @param batchContext It will hold the batch job Id.
  */
  public void finish(Database.BatchableContext bc) {
  }
 }