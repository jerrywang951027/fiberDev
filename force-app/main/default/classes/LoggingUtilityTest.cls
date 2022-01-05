/**
 *  @group TestClass-Exception Handler
 *  @description Test class for LoggingUtility to improve code coverage and test functionality.
 */
@istest
public with sharing class LoggingUtilityTest {
  /**
   *  @description test method to cover logUpsertResult method
   *  @param Not available
   *  @return null
   */
  static testMethod void logExceptionRecord() {
    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    Account testIdAccount = new Account();
    try {
      testIdAccount = TestDataFactory.getAccountData();
      insert testIdAccount;
      testIdAccount.Name = '' ;
      update testIdAccount;
    }
    catch (Exception e) {
      LoggingUtility.insertExceptionLog('LoggingUtilityTest', 'LoggingUtilityTest', e,
          testIdAccount.Id);
      Boolean expectedExceptionThrown =  (e.getMessage() != null) ? true : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }
  }

  /**
   * @description Test method for insertExceptionLog (String, String, String)
   * @param Not available
   * @return null
   */
  static testMethod void passingClassNameMethodNameAndMessageCreateLog() {

    // Initializing Log inputs.
    String ipName = 'iPName';
    String iPElementName = 'iPElementName';
    String iPMessage = 'iPMessage';

    // Start Test
    Test.startTest();
      LoggingUtility.insertExceptionLog(ipName, iPElementName, iPMessage);
    Test.stopTest();

    // Query the log generated
    List<Log__c> logList = [
      SELECT
        Class__c,
        Method__c,
        Description__c
      FROM
        Log__c
      LIMIT 1
    ];
    // Unit test assert Start.
    System.assert(!logList.isEmpty());
    System.assertEquals(logList[0].Class__c, ipName);
    System.assertEquals(logList[0].Method__c, iPElementName);
    System.assertEquals(logList[0].description__c, iPMessage);
  }
}