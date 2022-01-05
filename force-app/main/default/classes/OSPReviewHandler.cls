public class OSPReviewHandler implements ITriggerHandler {
  private static ITriggerHandler instance;
  public static ITriggerHandler getInstance() {
    if (instance == null) {
      instance = new OSPReviewHandler();
    }
    return instance;
  }

  public void onBeforeInsert(List<sObject> newObjects, List<sObject> oldObjects,
      Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    OSPReviewHelper.setEmailAlias((List<OSP_Review__c>) newObjects);
  }

  public void onAfterInsert(List<sObject> newObjects, List<sObject> oldObjects,
      Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    OSPReviewHelper.sendOSPReview((List<OSP_Review__c>) newObjects);
    OSPReviewHelper.processServiceabilityAndBuildStatusChange(
      (List<OSP_Review__c>) newObjects, (Map<Id, OSP_Review__c>) oldMap);
  }

  public void onBeforeUpdate(List<sObject> newObjects, List<sObject> oldObjects,
      Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
  }

  public void onAfterUpdate(List<sObject> newObjects, List<sObject> oldObjects,
      Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    OSPReviewHelper.processServiceabilityAndBuildStatusChange(
      (List<OSP_Review__c>) newObjects, (Map<Id, OSP_Review__c>) oldMap);
    OSPReviewHelper.sendNotificationOnPropertyOspReviewComplete(
      (List<OSP_Review__c>) newObjects, (Map<Id, OSP_Review__c>) oldMap);
  }

  public void onBeforeDelete(List<sObject> newObjects, List<sObject> oldObjects,
      Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
 }

  public void onAfterDelete(List<sObject> newObjects, List<sObject> oldObjects,
      Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
  }

  public void onAfterUndelete(List<sObject> newObjects, List<sObject> oldObjects,
      Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
  }
}