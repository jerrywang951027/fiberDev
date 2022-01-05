/**
 * @group: CreateNotificationBatch
 * @description: create notification when more than one history event are created
 * in last 3 days.
 */
public class CreateNotificationBatch implements Database.Batchable<SObject> {
    public static DateTime CREATED_DATE_THRESHOLD = system.TODAY().addDays(-3);
    public static Date EXPIRATION_DATE_THRESHOLD = system.TODAY().addDays(-1);
    public static Date DEFAULT_EXPIRATION_DATE = system.TODAY().addDays(7);
 /**
  * @description : start method for finding all the history event related to account
  * having created date greater than Today()-3
  * @param batchContext It will hold the batch job Id.
  */
  public Database.QueryLocator start(Database.BatchableContext context) {
    Set<String> historyEventTypes = new Set<String> {
        Constants.HISTORY_EVENT.TYPE.CHAT_TYPE, Constants.HISTORY_EVENT.TYPE.EMAIL,
        Constants.HISTORY_EVENT.TYPE.FIBER_SPACE, Constants.HISTORY_EVENT.TYPE.PHONE_TYPE,
        Constants.HISTORY_EVENT.TYPE.SMS, Constants.HISTORY_EVENT.TYPE.SOCIAL};
    return Database.getQueryLocator([
        SELECT
          Id,
          Account__c
        FROM
          History_Event__c
        WHERE
          CreatedDate > :CREATED_DATE_THRESHOLD
        AND
          Type__c IN :historyEventTypes
        AND
          Account__c != NULL
        ]);
  }

 /**
   * @description : execute batch method for creating notification
   * @param batchContext It will hold the batch job Id.
   * @param scope It will hold the list of history event.
   */
  public void execute(Database.BatchableContext context, List<History_Event__c> scope) {
    Map<String, List<History_Event__c>>
        historyEventsByAccountId = new Map<String, List<History_Event__c>>();
    Map<Id, Id> accountNotificationMap = new Map<Id, Id>();
    List<Notification__c> notifications = new List<Notification__c>();
    for (History_Event__c historyEvent : scope) {
      List<History_Event__c> historyEvents =
          historyEventsByAccountId.containsKey(historyEvent.Account__c)
          ? historyEventsByAccountId.get(historyEvent.Account__c) : new List<History_Event__c>();
      historyEvents.add(historyEvent);
      historyEventsByAccountId.put(historyEvent.Account__c, historyEvents);
    }
    List<Notification__c> notificationsList = [
        SELECT
          Id,
          Account__c
        FROM
          Notification__c
        WHERE
          Account__c IN :historyEventsByAccountId.keySet()
        AND
          Class__c = :Constants.NOTIFICATION.NOTIFICATION_CLASS.NOTIFICATION_SYSTEM
        AND
          Expiration_Date__c > :EXPIRATION_DATE_THRESHOLD];
    for (Notification__c notificationRecord : notificationsList) {
      accountNotificationMap.put(notificationRecord.Account__c, notificationRecord.Id);
    }
    for (Id accountId : historyEventsByAccountId.keySet()) {
      if (historyEventsByAccountId.get(accountId).size() > 1
          && !accountNotificationMap.containsKey(accountId)) {
        Notification__c notification = new Notification__c();
        notification.Expiration_Date__c = DEFAULT_EXPIRATION_DATE;
        notification.Class__c = Constants.NOTIFICATION.NOTIFICATION_CLASS.NOTIFICATION_SYSTEM;
        notification.Type__c = Constants.NOTIFICATION.TYPE.ACCOUNT;
        notification.Account__c = accountId;
        notification.Body__c = Constants.NOTIFICATION.BODY.MULTIPLE_CONTACTS;
        notifications.add(notification);
      }
    }
    if (notifications.size() > 0) {
      insert notifications;
    }
  }

 /**
  * @description This method is used for post-activity purpose after the batch process.
  * @param batchContext It will hold the batch job Id.
  */
  public void finish(Database.BatchableContext context) {
  }
}