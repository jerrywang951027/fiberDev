/**
 * @group Geopointe
 * @description This class used for test coverage for GeopointeCheckInTriggerHandler class.
 */
@isTest
public class GeopointeCheckInTriggerHandlerTest {

  /**
   * @description It holds all the test data for setup data.
   */
  @testSetup
  public static void testSetUp() {

    Logging_Level__c level = TestDataFactory.getLoggingSetting();
    insert level;
    Lead testLead = TestDataFactory.getLeadData();
    insert testLead;
  }

  /**
   * @description Checks if History Event and History Action with notes is captured.
   */
  @isTest
  public static void checkCustomerInteractionCreation() {

    Lead leadRecord = [
      SELECT Id
      FROM Lead
      LIMIT 1
    ];
    Geopointe__Check_In__c checkInItem = TestDataFactory.getCheckInData(leadRecord.Id, 'testData');
    Test.startTest();
      insert checkInItem;
    Test.stopTest();
    Geopointe__Check_In__c checkInItemWithCapture = [
        SELECT Id, Geopointe__What_ID__c
        FROM Geopointe__Check_In__c
        LIMIT 1
    ];
    Lead checkInLead = [
        SELECT Id,
          (SELECT Id FROM History_Events__r)
        FROM Lead
        WHERE Id= :checkInItemWithCapture.geopointe__What_ID__c
        LIMIT 1
    ];
    History_Action__c historyActionItem = [
        SELECT Id, Interaction_Notes__c
        FROM History_Action__c
        WHERE History_Event__c = :checkInLead.History_Events__r[0].Id
        LIMIT 1
    ];
    System.assertEquals(1, checkInLead.History_Events__r.size(),
        'History Event should be created');
    System.assertEquals('testData', historyActionItem.Interaction_Notes__c,
        'Interaction Notes should be filled');
  }
}