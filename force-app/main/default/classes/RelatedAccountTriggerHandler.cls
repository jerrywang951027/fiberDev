public class RelatedAccountTriggerHandler {
  public static void handle(List<GFB_Related_Account__c> newList,
                            List<GFB_Related_Account__c> oldList,
                            Map<Id, GFB_Related_Account__c> newMap,
                            Map<Id, GFB_Related_Account__c> oldMap) {
    if (Trigger.isInsert) {
      if (Trigger.isAfter) {
        RelatedAccountHelper.primaryFieldUpdateLogic(newList, null);
      }
    } else if (Trigger.isUpdate) {
      if (Trigger.isAfter) {
        RelatedAccountHelper.primaryFieldUpdateLogic(newList, oldMap);
      }
    } else if (Trigger.isDelete) {
      if (Trigger.isBefore) {
        RelatedAccountHelper.restrictDeletePrimaryAccount(oldList);
      }
    }
  }
}