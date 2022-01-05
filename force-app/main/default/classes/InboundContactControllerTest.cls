/**
 *@group Ticket
 *@description This class is used for test coverage for InboundContactController class
 */
@isTest
public class InboundContactControllerTest {
  /**
   * @description This is the method to create history
   * event phone type from the given url.
   */
  @isTest
  private static void createInboundContactByPhoneShouldReturnHistoryEvent() {
    String PHONE = '200146335';
    Test.startTest();
      History_Event__c historyEventRecord = InboundContactController.invokeIntegrationProcedure(
          '','',Constants.HISTORY_EVENT.TYPE.PHONE_TYPE,'',PHONE
      );
    Test.stopTest();
    System.assertEquals(Constants.HISTORY_EVENT.TYPE.PHONE_TYPE,historyEventRecord.Type__c,
        'invokeIntegrationProcedure' +' should return history event record with channel phone');
  }

  /**
   * @description This is the method to create history
   * event Chat type from the given url.
   */
  @isTest
  private static void createInboundContactByChatShouldReturnHistoryEvent() {
    String EMAIL = 'test@google.com';

    Test.startTest();
    History_Event__c historyEventRecord = InboundContactController.invokeIntegrationProcedure(
          '','', Constants.HISTORY_EVENT.TYPE.CHAT_TYPE,EMAIL,''
      );
    Test.stopTest();
    System.assertEquals(Constants.HISTORY_EVENT.TYPE.CHAT_TYPE, historyEventRecord.Type__c,
        'invokeIntegrationProcedure' +' should return history event record with email');
  }
}