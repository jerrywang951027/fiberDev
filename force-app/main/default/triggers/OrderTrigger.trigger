/**
 * @group Order
 * @description This trigger will calls OrderTriggerHandler which get executed
       based on trigger events
 */
trigger OrderTrigger on Order (before insert, before update, after insert,
    after update, after delete) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      //Method that handles all the before Insert logic
    }
    if (Trigger.isUpdate) {
      //Method that handles all the before update logic
      OrderTriggerHandler.beforeUpdateHandler(Trigger.New);
    }
    if (Trigger.isDelete) {
    //Method that handles all the before delete logic
    }
  }
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      //Method that handles all the after Insert logic
     // OrderTriggerHandler.afterInsertHandler(Trigger.new);
    }
    if (Trigger.isUpdate) {
      //Method that handles all the after update logic
      OrderTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isDelete) {
      //Method that handles all the after delete logic
    }
  }
}