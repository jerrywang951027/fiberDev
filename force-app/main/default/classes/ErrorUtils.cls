public class ErrorUtils {
  private static List<Exception_Log__c> exceptionLogs =
      new List<Exception_Log__c>();
  // retrieving user emails
  // note: ApexEmailNotification has an 'Email' field
  // but that's only for external emails
  private static List<ApexEmailNotification> aens = [SELECT User.Email
      FROM ApexEmailNotification
      WHERE User.Email != NULL];
  // allows devs to send apex notification email after catching an exception
  public static void sendExceptionEmail(String mailSubject, String mailBody) {
    if (aens.size() == 0) {
      return;
    }

    List<String> toAddresses = new List<String>();
    for (ApexEmailNotification aen : aens) {
      toAddresses.add(aen.User.Email);
    }

    // prepare the call to send email
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Apex Error Notification');
    mail.setSubject(mailSubject);
    mail.setPlainTextBody(mailBody);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
        mail
    });
  }

  // entry method #1
  public static void sendExceptionEmail(Exception e) {
    String mailSubject = 'Apex Exception Notification: ' + e.getTypeName();
    String mailBody = String.format(
        'type of exception: {0} \n error message: {1} \n stack trace: {2}',
        new List<String> {
          e.getTypeName(),
          e.getMessage(),
          e.getStackTraceString()
        });
    ErrorUtils.SendExceptionEmail(mailSubject,mailBody);
  }

  // entry method #2
  public static void sendExceptionEmail(Database.Error e) {
    String mailSubject = 'Apex Exception Notification: Database.Error Code: '
        + e.getStatusCode().name();
    String mailBody = String.format(
        'Error Code: {0} \n error message: {1} \n',
        new List<String> {
          e.getStatusCode().name(),
          e.getMessage()
        });
    mailBody += String.format(
          'fields in the object affecting the error condition: {0}',
          e.getFields());
    ErrorUtils.SendExceptionEmail(mailSubject,mailBody);
  }

  public static void addExceptionLog(Database.Error e) {
    // capture all the exception details and call methods to create records.
    Exception_Log__c exceptionObj = new Exception_Log__c();
    exceptionObj.Exception_Description__c = e.getMessage();
    exceptionObj.Exception_Type__c = e.getStatusCode().name();
    exceptionLogs.add(exceptionObj);
  }

  public static void addExceptionLog(Exception e) {
    // capture all the exception details and call methods to create records.
    Exception_Log__c exceptionObj = new Exception_Log__c();
    exceptionObj.Exception_Description__c = e.getMessage();
    exceptionObj.Exception_Stack_Trace__c = e.getStackTraceString();
    exceptionObj.Exception_Type__c = e.getTypeName();
    exceptionObj.Exception_Line_Number__c = e.getLineNumber();

    exceptionLogs.add(exceptionObj);
  }

  public static void insertExceptionLogs() {
    if (exceptionLogs.size() == 0) {
      return;
    }

    if (Test.isRunningTest()) {
      // start new context via system.runAs()
      // for the same user for test code only
      System.runAs(new User(Id = Userinfo.getUserId())) {
        insert exceptionLogs;
      }
    } else {
      // in non-test code insert normally
      insert exceptionLogs;
    }

    exceptionLogs = new List<Exception_Log__c>();
  }

  public static void createExceptionLog(Exception e) {
    createExceptionLog(e.getMessage(), e.getTypeName(), e.getStackTraceString(),
        e.getLineNumber());
  }

  public static void createExceptionLog(String message, String type) {
    createExceptionLog(message, type, null, null);
  }

  public static void createExceptionLog(String message, String type,
      String stackTraceString, Integer lineNumber) {
    // capture all the exception details and call methods to create records.
    Exception_Log__c exceptionObj = new Exception_Log__c();
    exceptionObj.Exception_Description__c = message;
    exceptionObj.Exception_Stack_Trace__c = stackTraceString;
    exceptionObj.Exception_Type__c = type;
    exceptionObj.Exception_Line_Number__c = lineNumber;
    if (Test.isRunningTest()) {
      // start new context via system.runAs()
      // for the same user for test code only
      System.runAs(new User(Id = Userinfo.getUserId())) {
          insert exceptionObj;
      }
    } else {
      // in non-test code insert normally
      insert exceptionObj;
    }

    System.assertNotEquals(exceptionObj.Id, null);
  }

  // used to reduce processing time.
  // capture all the exception details
  // and call methods in future to create records.
  public static void createFutureExceptionLog(Exception e) {
    String errMessage = e.getMessage();
    String errTrace = e.getStackTraceString();
    String errType = e.getTypeName();
    Integer errLineNumber = e.getLineNumber();
    createFutureHelperLog(errMessage, errTrace, errType, errLineNumber);
  }

  @future
  public static void createFutureHelperLog(String errMessage, String errTrace,
      String errType,Integer errLineNumber) {
    Exception_Log__c exceptionObj = new Exception_Log__c();
    exceptionObj.Exception_Description__c = errMessage;
    exceptionObj.Exception_Stack_Trace__c = errTrace;
    exceptionObj.Exception_Type__c = errType;
    exceptionObj.Exception_Line_Number__c = errLineNumber;

    insert exceptionObj;
    System.assertNotEquals(exceptionObj.Id, null);
  }

  public static void addExceptionLog(String errMessage, String errTrace,
      String errType, Integer errLineNumber) {
    Exception_Log__c exceptionObj = new Exception_Log__c();
    exceptionObj.Exception_Description__c = errMessage;
    exceptionObj.Exception_Stack_Trace__c = errTrace;
    exceptionObj.Exception_Type__c = errType;
    exceptionObj.Exception_Line_Number__c = errLineNumber;
    exceptionLogs.add(exceptionObj);
  }
}