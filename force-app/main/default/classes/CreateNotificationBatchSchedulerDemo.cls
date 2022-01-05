/**
 * @group CreateNotificationBatchScheduler
 * @description used for scheduling the CreateNotificationBatch class.
 */
global with sharing class CreateNotificationBatchSchedulerDemo implements Schedulable {

  /**
   * @description This method used for scheduling the context variable
   * @param SchedulableContext schedulableContext
   */
  global void execute(SchedulableContext schedulableContext) {
    CreateNotificationBatch notificationBatch = new CreateNotificationBatch();
    Database.executeBatch(notificationBatch);
  }
}