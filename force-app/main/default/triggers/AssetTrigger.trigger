/**
 * @group Asset
 * @description AssetTrigger called by AssetHandler class.
 */
trigger AssetTrigger on Asset (before insert, before update, after insert,
    after update, after delete) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      // Method that handles all the before Insert logic
    }
    if (Trigger.isUpdate) {
      // Method that handles all the before update logic
    }
    if (Trigger.isDelete) {
      // Method that handles all the before delete logic
    }
  }
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      // Method that handles all the after Insert logic
    }
    if (Trigger.isUpdate) {
      // Method that handles all the after update logic
      AssetTriggerHandler.afterUpdateExecute(trigger.new, trigger.oldMap);
    }
    if (Trigger.isDelete) {
      // Method that handles all the after delete logic
    }
  }
}