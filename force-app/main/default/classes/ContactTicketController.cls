/**
 * @group Ticket
 * @description This class Navigate from CSA to Salesforce.
 */
public class ContactTicketController {
  public static final String CLASS_NAME = 'ContactTicketController';

  @TestVisible
  private static Map <String, Object> mockedTicketResponse = new Map <String, Object> ();
  /**
   * @description This method used to navigate  based on ticketId and accountId.
   * @param inputMap This will have ticket Id and account Id.
   * @param outMap This will return navigate to history or ticket or operation ticket record.
   * @param options Any optional parameters
   * @return Customer search
   */
  @AuraEnabled
  public static extractTicketDetails getMostRelatedObjLink(
      String ticketId, String accountId, String globalAddress) {
    String objLink = '';
    List <History_Event__c> historyEvent = new List <History_Event__c> ();
    List <Ticket__c> ticket = new List <Ticket__c> ();
    List <Operation_Ticket__x> operationTicket = new List <Operation_Ticket__x> ();
    historyEvent = [
      SELECT
        Id,
        Account__r.Id,
        Account__r.Account_Id__c,
        External_Ticket__c
      FROM
        History_Event__c
      WHERE
        External_Ticket__c = :ticketId
    ];
    ticket = [
      SELECT
        Id,
        Account__r.Id,
        Account__r.Account_Id__c,
        Name
      FROM
        Ticket__c
      WHERE
        Name = :ticketId
    ];

    operationTicket = [
      SELECT
        Id,
        Account__r.Id,
        Account__r.Account_Id__c,
        ExternalId
      FROM
        Operation_Ticket__x
      WHERE
        ExternalId =: ticketId
    ];

    List <Lead> leadRecord = [
      SELECT
        Id,
        vlocity_cmt__PremisesId__r.Global_Address_Id__c,
        Status
      FROM
        Lead
      WHERE
        vlocity_cmt__PremisesId__r.Global_Address_Id__c =: globalAddress
      AND(
        Status !=: Constants.LEAD.STATUS.CONVERTED OR
          Status !=: Constants.LEAD.STATUS.DISQUALIFIED)
      LIMIT 1
    ];

    extractTicketDetails obj = new extractTicketDetails();
    if (historyEvent.size() > 0 || ticket.size()> 0 || operationTicket.size()> 0) {
      if ((ticket.size()> 0 && String.isNotBlank(ticket.get(0).Account__r.Id)) ||
        (historyEvent.size() > 0 && String.isNotBlank(historyEvent.get(0).Account__r.Id)) ||
        (operationTicket.size() > 0 && String.isNotBlank(operationTicket.get(0).Account__r.Id))) {
        obj.objLink = '/lightning/r/Account/' + ticket.get(0).Account__r.Id + '/view';
      }
      if (String.isNotEmpty(ticketId) && String.isNotEmpty(globalAddress)) {
        if (leadRecord.size() > 0) {
          obj.objLink = '/lightning/r/Lead/' + leadRecord.get(0).Id + '/view';
        }
      }
      if (ticket.size() > 0 && String.isBlank(ticket.get(0).Account__r.Id)) {
        obj.objLink = '/lightning/r/Ticket__c/' + ticket.get(0).Id + '/view';
      } else if (historyEvent.size() > 0 && String.isBlank(historyEvent.get(0).Account__r.Id)) {
        obj.objLink = '/lightning/r/History_Event__c/' + historyEvent.get(0).Id + '/view';
      } else if (operationTicket.size() > 0 && String.isBlank(operationTicket.get(0).Account__r.Id)) {
        obj.objLink = '/lightning/r/Operation_Ticket__x/' + operationTicket.get(0).Id + '/view';
      }
    } else if (historyEvent.size() == 0 && ticket.size() == 0 && operationTicket.size() == 0) {
      Map <String, Object> message = invokeIntegrationProcedure(ticketId);
      map <String, object> ticketObjDetail = (Map<String, Object>) message.get('ticketDetails');
      if (ticketObjDetail != null) {
        if (ticketObjDetail.keySet().size() > 0 &&
          String.isNotBlank(String.valueOf(ticketObjDetail.get('ticketType')))) {
          if (ticketObjDetail.get('ticketType') == Constants.BUGAFIBER.TYPE.CONTACT) {
            History_Event__c historyEventObj = new History_Event__c();
            historyEventObj.External_Ticket__c = ticketId;
            historyEventObj.Status__c = Constants.HISTORY_EVENT.STATUS.OPEN;
            List <Account> accountForContact = [
              SELECT
                Account_Id__c,
                Id
              FROM
                Account
              WHERE
                Account_Id__c = :accountId
            ];
            if (String.isNotBlank(accountForContact.get(0).Account_Id__c)) {
              historyEventObj.Account__c = accountForContact.get(0).Id;
              insert historyEventObj;
              obj.HistoryEventObject = historyEventObj;
              obj.objLink = '/lightning/r/Account/' + accountForContact.get(0).Id + '/view';
            } else {
              insert historyEventObj;
              obj.HistoryEventObject = historyEventObj;
              obj.objLink = '/lightning/r/History_Event__c/' + historyEventObj.Id + '/view';
            }
          } else if (ticketObjDetail.keySet().size()> 0 &&
            ticketObjDetail.get('ticketType') != Constants.BUGAFIBER.TYPE.CONTACT) {
            Ticket__c newTicket = new Ticket__c();
            newTicket.Name = ticketId;
            List <Account> accountForIssue = [
              SELECT
                Id,
                Account_Id__c
               FROM
                 Account
               WHERE
                 Account_Id__c =: accountId
            ];

            if (String.isNotBlank(accountForIssue.get(0).Account_Id__c)) {
              newTicket.Account__c = accountForIssue.get(0).Id;
            }
            insert newTicket;

            history_Action__c historyAction = new history_Action__c();
            historyAction.Ticket__c = newTicket.Id;
            historyAction.Type__c = Constants.HISTORY_ACTION.TYPE.ISSUE;
            List <Account> accountForHistory = [
              SELECT
                Id,
                Account_Id__c
              FROM
                Account
              WHERE
                Account_Id__c = :accountId
            ];

            if (String.isNotBlank(accountForHistory.get(0).Account_Id__c)) {
              historyAction.Account__c = accountForHistory.get(0).Id;
            }
            insert historyAction;

            obj.HistoryActionObject = historyAction;
            obj.objLink = '/lightning/r/Ticket__c/' + newTicket.Id + '/view';
          } else if (ticketObjDetail.get('ticketType') == null || ticketId == '') {
            obj.objLink = Label.Customer_Search;
          }
        }
      } else {
        obj.objLink = Label.Customer_Search;
      }
    }
    return obj;
  }

  public class extractTicketDetails {
    @AuraEnabled
    public String objLink {
      get;
      set;
    }
    @AuraEnabled
    public History_Event__c HistoryEventObject {
      get;
      set;
    }
    @AuraEnabled
    public History_Action__c HistoryActionObject {
      get;
      set;
    }
  }

  /**
   * @description This method used to navigate  based on ticketId.
   * @param inputMap This will have ticket Id.
   * @param outMap This will return the type of ticket.
   * @param options Any optional parameters
   * @return Customer search
   */
  @AuraEnabled
  public static Map <String, Object> invokeIntegrationProcedure(String ticketId) {
    String IP_NAME = 'TCK_ExtractBuganizerDetails';
    Map <String, Object> ipInput = new Map <String, Object> ();
    Map <String, Object> ipOutput = new Map <String, Object> ();
    Map <String, Object> ipOptions = new Map <String, Object> ();
    Map <String, Object> message;
    try {
      /**
       * Populating input map for an Integration Procedure.
       * Follow whatever structure our VIP expects.
       */
      ipInput.put('bugafiberTicketId', ticketId);
      /**
       * Call the IP via runIntegrationService and save the output to ipOutput.
       */
      ipOutput = (Test.isRunningTest()) ? mockedTicketResponse : (Map <String, Object>)
      vlocity_cmt.IntegrationProcedureService.runIntegrationService(IP_NAME, ipInput, ipOptions);
      message = ipOutput;
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog('ContactTicketController',
        'invokeIntegrationProcedure', exp);
      throw exp;
    }
    return ipOutput;
  }
}