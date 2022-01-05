public class TriggerDispatcher {

  private final ITriggerHandler triggerHandler;
  private final TriggerContextData triggerContext;
  private static final String className = TriggerDispatcher.class.getName();

  public TriggerDispatcher(
      ITriggerHandler triggerHandler,
      TriggerContextData triggerContext
  ) {
    if (triggerHandler != null) {
      this.triggerHandler = triggerHandler;
    }
    if (triggerContext != null) {
      this.triggerContext = triggerContext;
    }
  }

  public void dispatch() {
    if (!triggerContext.isExecuting) {
      return;
    }
    if (triggerContext.isBefore) {
      if (triggerContext.isInsert) {
        beforeInsert();
      }
      else if (triggerContext.isUpdate) {
        beforeUpdate();
      }
      else if (triggerContext.isDelete) {
        beforeDelete();
      }
    }
    else if (triggerContext.isAfter) {
      if (triggerContext.isInsert) {
        afterInsert();
      }
      else if (triggerContext.isUpdate) {
        afterUpdate();
      }
      else if (triggerContext.isDelete) {
        afterDelete();
      }
      else if (triggerContext.isUndelete) {
        afterUndelete();
      }
    }
  }

  private void beforeInsert() {
    triggerHandler.onBeforeInsert(
      triggerContext.newObjects,
      triggerContext.oldObjects,
      triggerContext.newMap,
      triggerContext.oldMap
    );
  }

  private void afterInsert() {
    triggerHandler.onAfterInsert(
      triggerContext.newObjects,
      triggerContext.oldObjects,
      triggerContext.newMap,
      triggerContext.oldMap
    );
  }

  private void beforeUpdate() {
    triggerHandler.onBeforeUpdate(
      triggerContext.newObjects,
      triggerContext.oldObjects,
      triggerContext.newMap,
      triggerContext.oldMap
    );
  }

  private void afterUpdate() {
    triggerHandler.onAfterUpdate(
      triggerContext.newObjects,
      triggerContext.oldObjects,
      triggerContext.newMap,
      triggerContext.oldMap
    );
  }

  private void beforeDelete() {
    triggerHandler.onBeforeDelete(
      triggerContext.newObjects,
      triggerContext.oldObjects,
      triggerContext.newMap,
      triggerContext.oldMap
    );
  }

  private void afterDelete() {
    triggerHandler.onAfterDelete(
      triggerContext.newObjects,
      triggerContext.oldObjects,
      triggerContext.newMap,
      triggerContext.oldMap
    );
  }

  private void afterUndelete() {
    triggerHandler.onAfterUndelete(
      triggerContext.newObjects,
      triggerContext.oldObjects,
      triggerContext.newMap,
      triggerContext.oldMap
    );
  }
}