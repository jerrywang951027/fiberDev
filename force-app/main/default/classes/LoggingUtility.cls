/**
 *  @group Exception Handler
 *  @description to Log the exceptions created on objects API's or IP's
 */
public with sharing class LoggingUtility {
  /**
   *  @description Method for creating the records of Logs to see the error for
        particular object kind of Custom Error Logs.
   *  @param className The name of the class calling this method
   *  @param methodName The name of the method calling this method
   *  @param exe exception passed from calling method.
   *  @param recordId record Id passed from calling method.
   */
  public static void insertExceptionLog(String className, String methodName,
    Exception exe, Id recordId) {
    Logging_Level__c level = Logging_Level__c.getValues('Default');
    Log__c log = new Log__c();
    log.Class__c = className;
    log.Method__c = methodName;
    log.Type__c = exe.getTypeName();
    log.Logging_Level__c = level.Level__c;
    log.Line_Number__c = exe.getLineNumber();
    log.Description__c = exe.getMessage();
    if (recordId != null) {
      log.Object__c = recordId.getSObjectType().getDescribe().getName();
      log.Record_Id__c = recordId;
    }
    insert log;
  }

  /**
   *  @description Method overloading
   *  @param className The name of the class calling this method
   *  @param methodName The name of the method calling this method
   *  @param exe exception passed from calling method.
   *  @return Null
   */
  public static void insertExceptionLog(String className, String methodName,
    Exception exe) {
    insertExceptionLog(className, methodName, exe, null);
  }

  /**
   * @description Method overloading for Integration procedure Logging.
   * @param className The name of the class calling this method
   * @param methodName The name of the method calling this method
   * @param message Exception message passed from calling method.
   */
  public static void insertExceptionLog(String className, String methodName,
    String message) {
    Log__c log = new Log__c();
    log.Class__c = className;
    log.Method__c = methodName;
    log.Description__c = message;
    insert log;
  }
}