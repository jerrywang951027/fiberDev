/*
 * @group EquipmentReturnedBatchScheduler
 * @description This class used for scheduling the EquipmentReturnedBatch.
 */
global with sharing class EquipmentReturnedBatchScheduler implements Schedulable {
 /*
  * @description This method used for scheduling the context variable
  * @param SchedulableContext sc
  */
  global void execute(SchedulableContext sc) {
    EquipmentReturnedBatch executeBatch = new EquipmentReturnedBatch();
    Database.executeBatch(executeBatch);
  }
}