/*
 * @group SevenDayBatchClassScheduler
 * @description This class used for scheduling the SetForceBillingBatch.
 */
global with sharing class SetForceBillingBatchScheduler implements Schedulable {
 /*
  * @description This method used for scheduling the context variable
  * @param SchedulableContext sc
  */
  global void execute(SchedulableContext sc) {
    SetForceBillingBatch executeBatch = new SetForceBillingBatch();
    Database.executeBatch(executeBatch);
  }
}