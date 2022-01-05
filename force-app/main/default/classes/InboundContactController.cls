/**
 * @description Creating inbound buganizer ticket from IVR.
 * @group BuganizerIntegrationProcedureService
 */
public class InboundContactController {
  /**
   * @description Creating inbound buganizer ticket from IVR.
   */
  @AuraEnabled
  public static History_Event__c invokeIntegrationProcedure(
      String callGUID,
      String chatGUID,
      String contactChannel,
      String email,
      String phone
      ){
    History_Event__c historyEvent = new History_Event__c();
    try {
      /* Initialize variables */
      String IP_NAME = 'CON_CreateContactBuganizerTicket';
      Map<String, Object> ipInput = new Map<String, Object>();
      Map<String, Object> ipOutput = new Map<String, Object>();
      Map<String, Object> ipOptions = new Map<String, Object>();
      Map<String, Object> message;

      /**
      * Populating input map for an Integration Procedure.
      * Follow whatever structure our VIP expects.
      */
      if (contactChannel.equalsIgnoreCase(Constants.HISTORY_EVENT.TYPE.PHONE_TYPE)) {
        ipInput.put('contactChannel', contactChannel);
        ipInput.put('phoneNumber', phone);
        ipInput.put('callGUID', callGUID);
        historyEvent.Phone__c = phone;
        historyEvent.Type__c = Constants.HISTORY_EVENT.TYPE.PHONE_TYPE;
        historyEvent.InteractionId__c = callGUID;
        historyEvent.GUID__c = callGUID;
      } else if (contactChannel.equalsIgnoreCase(Constants.HISTORY_EVENT.TYPE.CHAT_TYPE)) {
        historyEvent = new History_Event__c();
        ipInput.put('contactChannel', contactChannel);
        ipInput.put('chatGUID', chatGUID);
        ipInput.put('email', email);
        historyEvent.Email__c = email;
        historyEvent.InteractionId__c = chatGUID;
        historyEvent.GUID__c = chatGUID;
        historyEvent.Type__c = Constants.HISTORY_EVENT.TYPE.CHAT_TYPE;
      }
      ipInput.put('ticketCode', Constants.BUGAFIBER.TICKET_CODE.CONTACT);
      ipInput.put('title', Constants.BUGAFIBER.TITLE.INBOUND_CONTACT);
      ipInput.put('type', Constants.BUGAFIBER.TYPE.CONTACT);
      ipInput.put('status', Constants.HISTORY_EVENT.STATUS.OPEN);
      historyEvent.Direction__c = Constants.HISTORY_EVENT.DIRECTION.INBOUND;
      historyEvent.Event_Date__c = System.Now();
      historyEvent.Status__c = Constants.HISTORY_EVENT.STATUS.OPEN;
      /**
       * Call the IP via runIntegrationService and save the output to ipOutput.
       */
      ipOutput = (Map<String, Object>)
          vlocity_cmt.IntegrationProcedureService.runIntegrationService(IP_NAME,
            ipInput, ipOptions);
      message = ipOutput;
      historyEvent.External_Ticket__c = string.valueOf(message.get('buganizerTicket'));
      insert historyEvent;
    }
    catch (Exception exp) {
      LoggingUtility.insertExceptionLog('InboundContactController',
          'invokeIntegrationProcedure', exp);
      throw exp;
    }
    return historyEvent;
  }

 /**
   * Call the contactTicketVerification class to check existion open contact ticket.
   */
  @AuraEnabled
  public static list<History_Event__c> contactTicketVerification(
      string callInteraction,
      string chatInteraction) {
      list<History_Event__c> historyEventRecord = [
        SELECT
          Id,
          External_Ticket__c,
          InteractionId__c,
          Phone__c,
          Email__c,
          Status__c
        FROM
          History_Event__c
        WHERE
          Status__c != :Constants.HISTORY_EVENT.STATUS.CLOSE
        AND
          InteractionId__c != null
        AND
          (
            InteractionId__c = :callInteraction
          OR
            InteractionId__c = :chatInteraction
          )
      ];
      return historyEventRecord;
  }
}