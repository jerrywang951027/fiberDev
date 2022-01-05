/**
 * @group DoorKnockLeadBatchScheduler
 * @description This class used for scheduling the DoorKnockLeadBatch class.
 */
global with sharing class DoorKnockLeadBatchScheduler implements Schedulable {
  /**
   * @description This method used for scheduling the context variable
   * @param SchedulableContext schedulableContext
   * @return null
   */
  global void execute(SchedulableContext schedulableContext) {
    DoorKnockLeadBatch doorKnockBatch = new DoorKnockLeadBatch();
    Database.executeBatch(doorKnockBatch);
  }
}