public interface ITriggerHandler {
  void onBeforeInsert(
      List<sObject> newObjects,
      List<sObject> oldObjects,
      Map<Id, sObject> newMap,
      Map<Id, sObject> oldMap);

  void onAfterInsert(
      List<sObject> newObjects,
      List<sObject> oldObjects,
      Map<Id, sObject> newMap,
      Map<Id, sObject> oldMap
  );

  void onBeforeUpdate(
      List<sObject> newObjects,
      List<sObject> oldObjects,
      Map<Id, sObject> newMap,
      Map<Id, sObject> oldMap
  );

  void onAfterUpdate(
      List<sObject> newObjects,
      List<sObject> oldObjects,
      Map<Id, sObject> newMap,
      Map<Id, sObject> oldMap
  );

  void onBeforeDelete(
      List<sObject> newObjects,
      List<sObject> oldObjects,
      Map<Id, sObject> newMap,
      Map<Id, sObject> oldMap
  );

  void onAfterDelete(
    List<sObject> newObjects,
    List<sObject> oldObjects,
    Map<Id, sObject> newMap,
    Map<Id, sObject> oldMap
  );

  void onAfterUndelete(
    List<sObject> newObjects,
    List<sObject> oldObjects,
    Map<Id, sObject> newMap,
    Map<Id, sObject> oldMap
  );
}