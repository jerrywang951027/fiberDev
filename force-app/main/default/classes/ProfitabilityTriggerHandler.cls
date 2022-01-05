public class ProfitabilityTriggerHandler {
  public static void handle(List<Profitability__c> newList,
                            Map<Id, Profitability__c> oldMap) {
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        ProfitabilityHelper.updateEstimatedSignups(newList, null);
      } else if (Trigger.isUpdate) {
        ProfitabilityHelper.updateEstimatedSignups(newList, oldMap);
      }
    }
  }
}