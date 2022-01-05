public class TriggerContextData {

  public boolean isExecuting { get; private set; }
  public boolean isInsert { get; private set; }
  public boolean isUpdate { get; private set; }
  public boolean isDelete { get; private set; }
  public boolean isUndelete { get; private set; }
  public boolean isBefore { get; private set; }
  public boolean isAfter { get; private set; }
  public List<sObject> newObjects { get; private set; }
  public List<sObject> oldObjects { get; private set; }
  public Map<ID, sObject> newMap { get; private set; }
  public Map<ID, sObject> oldMap { get; private set; }

  public TriggerContextData(
      boolean isExecuting,
      boolean isInsert, boolean isUpdate, boolean isDelete, boolean isUndelete,
      boolean isBefore, boolean isAfter,
      List<sObject> newObjects, List<sObject> oldObjects,
      Map<ID, sObject> newMap, Map<ID, sObject> oldMap
  ) {
    this.isExecuting = isExecuting;
    this.isInsert = isInsert;
    this.isUpdate = isUpdate;
    this.isDelete = isDelete;
    this.isUndelete = isUndelete;
    this.isBefore = isBefore;
    this.isAfter = isAFter;
    this.newObjects = newObjects;
    this.oldObjects = oldObjects;
    this.newMap = newMap;
    this.oldMap = oldMap;
  }
}