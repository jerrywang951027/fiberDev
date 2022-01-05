/*
 * @group SignUpChecklist
 * @description Test class for SignUpChecklistController
 * to improve code coverage and test functionality.
 */
@isTest
private class SignUpChecklistControllerTest {

   static final string TICKET_ID = '1234';

  /*
   * @description Test data set up method.
   */
  @testSetup
  private static void testSetUp() {

    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    Lead testLead = testDataFactory.getLeadData();
    testlead.Interaction_Notes__c = 'testNote';
    testlead.RecordTypeId = RecordTypeUtils.CUSTOMER_LEAD_ID;
    insert testLead;
    History_event__c testHistoryEvent = testDataFactory.getHistoryEventData();
    testHistoryEvent.Lead__c = testLead.Id;
    insert testHistoryEvent;
  }

  /*
   * @description To check the direction of History Event created.
   * @param N/A
   * @return null
   */
  @isTest
  private static void createHistoryEventShouldStampDirectionOutbound() {

    Lead leadRecord = [
      SELECT Id, Status, Interaction_Type__c, Interaction_Notes__c,
      Customer_Consent_to_3rd_Party_Delivery__c, Pilot__c,
      Third_Party_Delivery__c, Interaction_Result__c, Objection_Reason__c,
      Sign_up_Insights__c, Campaign__c
      FROM Lead
      LIMIT 1
    ];
    Test.startTest();
      History_Event__c historyRecord = SignUpChecklistController.createHistoryEvent(
          'Customer Follow up', leadRecord, true);
    Test.stopTest();
    System.assertEquals('Outbound', historyRecord.Direction__c,
        'History record must have direction outbound');
  }

  /*
   * @description checks Lead sub Status on update.
   * @param N/A
   * @return null
   */
  @isTest
  private static void checkLeadSubStatusOnUpdate() {

    Lead leadRecordBeforeUpdate = [
      SELECT Id, Status, sub_status__c
      FROM Lead
      LIMIT 1
    ];
    Test.startTest();
      SignUpChecklistController.stampLeadDetailsForSignUp(
          leadRecordBeforeUpdate.Id, true);
    Test.stopTest();
    Lead leadRecordAfterUpdate = [
      SELECT Id, sub_status__c
      FROM Lead
      LIMIT 1
    ];
    System.assertEquals('Pending Signup', leadRecordAfterUpdate.Sub_Status__c,
        'Lead record should have sub status as pending signup');
  }

  /*
   * @description Checks exception for History Event record creation.
   * @param N/A
   * @return null
   */
  @isTest
  private
  static void createHistoryEventExceptiontest() {

    Lead leadRecord = [
      SELECT Id, sub_status__c
      FROM Lead
      LIMIT 1
    ];
    String interactionType = testDataFactory.generateRandomString(81);
    Boolean expectedExceptionThrown;
    Test.startTest();
      try {
        SignUpChecklistController.createHistoryEvent(interactionType, leadRecord, true);
      } catch (Exception exp) {
        expectedExceptionThrown = (exp.getMessage() != null) ? true : false;
      }
    Test.stopTest();
    System.assertEquals(expectedExceptionThrown, true,
        'Record should have correct details stamped');
  }

  /*
   * @description Checks exception while stamping Lead details.
   * @param N/A
   * @return null
   */
  @isTest
  private static void stampLeadDetailsForSignUpExceptiontest() {

    Boolean expectedExceptionThrown = false;
    Test.startTest();
      try {
        SignUpChecklistController.stampLeadDetailsForSignUp(null, null);
      } catch (Exception exp) {
        expectedExceptionThrown = (exp.getMessage() != null) ? true : false;
      }
    Test.stopTest();
    System.assertEquals(expectedExceptionThrown, true,
        'Record should have correct details stamped');
  }

  /*
   * @description Check exception while creating History Action.
   * @param N/A
   * @return null
   */
  @isTest
  private static void createHistoryActionExceptiontest() {

    Boolean expectedExceptionThrown = false;
    Test.startTest();
      try {
        SignUpChecklistController.createHistoryAction(null, null, null);
      } catch (Exception exp) {
        expectedExceptionThrown = (exp.getMessage() != null) ? true : false;
      }
    Test.stopTest();
    System.assertEquals(expectedExceptionThrown, true,
        'Record should have correct details stamped');
  }
  /*
   * @description Checks Open History Events
   * @param N/A
   * @return null
   */
  @isTest
  private static void resultShouldBeTrueForHistoryEventStatusOpen() {

    History_Event__c historyEvent = [
      SELECT Id, Lead__c, External_Ticket__c, Status__c
      FROM History_Event__c
      LIMIT 1
    ];
    historyEvent.External_Ticket__c = TICKET_ID;
    historyEvent.Status__c = Constants.HISTORY_EVENT.STATUS.CLOSE;
    update historyEvent;
    test.startTest();
      Boolean result = SignUpChecklistController.hasOpenHistoryEvent(historyEvent.Lead__c);
    test.stopTest();
    system.assertEquals(false,result,'open history event should be present');
  }

  /*
   * @description  Checks Update Bugafiber Ticket
   * @param N/A
   * @return null
   */
  @isTest
  private static void checkUpdateBugafiberTicket() {
    String bugafiberTicket = TICKET_ID;
    String firstName = TestDataFactory.generateRandomString(7);
    String lastName = TestDataFactory.generateRandomString(7);
    String email = TestDataFactory.EMAIL_VALUE;
    String phoneNumber = TestDataFactory.PHONE_VALUE;
    test.startTest();
      SignUpChecklistController.updateBugafiberTicket(
          bugafiberTicket, firstName, lastName, email, phoneNumber);
    test.stopTest();
    List<Log__c> logList = [
        SELECT
          Class__c,
          Method__c,
          Description__c
        FROM
          Log__c
        LIMIT 1
    ];
    system.assertEquals(0, loglist.size(), 'No Exception log should be created');
    }

  /*
   * @description Checks Extracted Bugafiber Ticket
   * @param N/A
   * @return null
   */
  @isTest
  private static void bugafiberTicketShouldStampOnOpenHistoryEvent() {

    History_Event__c historyEvent = [
      SELECT Id, Lead__c, External_Ticket__c, Status__c
      FROM History_Event__c
      LIMIT 1
    ];
    historyEvent.External_Ticket__c = TICKET_ID;
    historyEvent.Status__c = Constants.HISTORY_EVENT.STATUS.OPEN;
    update historyEvent;
    test.startTest();
      String bugafiberId =
          SignUpChecklistController.extractBugafiberTicketId(historyEvent.Lead__c);
    test.stopTest();
    system.assertEquals(TICKET_ID, bugafiberId,'Bugafiber Id should be equal');
  }

  /*
   * @description Checks Extracted Bugafiber Ticket
   * @param N/A
   * @return null
   */
  @isTest
  private static void extractLatestBugafiberTicketIdShouldReturnExternalTicketId() {
    History_Event__c historyEvent = [
      SELECT Id, Lead__c, External_Ticket__c, Status__c
      FROM History_Event__c
      LIMIT 1
    ];
    historyEvent.External_Ticket__c = TICKET_ID;
    historyEvent.Status__c = 'Open';
    update historyEvent;
    Test.startTest();
      String externalTicketId =
          SignUpChecklistController.extractLatestBugafiberTicketId(historyEvent.Lead__c);
    Test.stopTest();
    System.AssertEquals(TICKET_ID, externalTicketId,
        'Extracted External Ticket Id should match the history Event Ticket Id');
  }

  /*
   * @description checks Lead sub Status on update.
   * @param N/A
   * @return null
   */
  @isTest
  private static void checkOpenContactTicketAssociate() {

    Boolean isContactTicket;
    Boolean result;
    Lead leadRecord = [
      SELECT Id, Status, sub_status__c
      FROM Lead
      LIMIT 1
    ];
    History_Event__c historyEventRecord = [
      SELECT Id, Status__c
      FROM History_Event__c
      LIMIT 1
    ];
    if (historyEventRecord.Status__c == Constants.HISTORY_EVENT.STATUS.OPEN) {
      isContactTicket = false;
    } else {
      isContactTicket = true; 
    }
    Test.startTest();
      result = SignUpChecklistController.isContactTicket(leadRecord.Id);
    Test.stopTest();
    System.assertEquals(isContactTicket, result,
        'Lead record should have sub status as pending signup');
  }
}