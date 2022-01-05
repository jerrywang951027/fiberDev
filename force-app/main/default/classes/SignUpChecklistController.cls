/**
 * @description Captures details for Customer Sign-up.
 * @group SignUpChecklist
 */
public without sharing class SignUpChecklistController {

  public static String CLASS_NAME = 'SignUpChecklistController';

  /**
   * @description Creates History Event record associated to Lead and captures
   * the Interaction log.
   * @param type This will hold type of action.
   * @param leadData This holds the Lead Info.
   * @param signUpState This holds the boolean value of signUpState.
   * @return History_Event__c returns the History Event.
   */
  @AuraEnabled
  public static History_Event__c createHistoryEvent(String type,
      Lead leadData, boolean signUpState) {
    String METHOD_NAME = 'createHistoryEvent';
    History_Event__c historyEventRecord = new History_Event__c();
    try {
      Lead leadRecord = [
          SELECT
            Id,
            Interaction_Notes__c,
            Interaction_Type__c
          FROM
            Lead
          WHERE
            Id =:leadData.Id
      ];
      leadData.OwnerId = userInfo.getUserId();
      historyEventRecord.OwnerId = userInfo.getUserId();
      historyEventRecord.Door_Open__c = false;
      if (leadData.Interaction_Type__c == 'Inbound call') {
        historyEventRecord.Type__c = Constants.HISTORY_EVENT.TYPE.PHONE_TYPE;
        historyEventRecord.Direction__c = Constants.HISTORY_EVENT.DIRECTION.INBOUND;
      } else if (leadData.Interaction_Type__c == 'Outbound call') {
        historyEventRecord.Type__c = Constants.HISTORY_EVENT.TYPE.PHONE_TYPE;
        historyEventRecord.Direction__c = Constants.HISTORY_EVENT.DIRECTION.OUTBOUND;
      } else {
        historyEventRecord.Type__c = leadData.Interaction_Type__c;
        historyEventRecord.Direction__c = Constants.HISTORY_EVENT.DIRECTION.OUTBOUND;
      }
      historyEventRecord.Lead__c = leadData.Id;
      Database.SaveResult savedEventRecord =
          Database.insert(historyEventRecord, false);
      Database.update(leadData, false);
      if (savedEventRecord.isSuccess()) {
        stampLeadDetailsForSignUp(leadData.Id, signUpState);
        createHistoryAction(savedEventRecord.getId(), leadData, type);
        stampLatestHistoryEventCreatedDateOnLead(leadData.Id);
      }
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
    return historyEventRecord;
  }

  /*
   * @description Stamp Lead details
   * @param leadId This holds the Lead Id.
   * @param signUpState This holds boolean value
   * which decides Lead sub status as pending sign-up or needs follow-up.
   * @return null
   */
  @AuraEnabled
  public static void stampLeadDetailsForSignUp(Id leadId, boolean signUpState) {

    String METHOD_NAME = 'stampLeadDetailsForSignUp';
    try {
      Lead leadRecord = [
          SELECT
            Id,
            Status,
            Sub_Status__c
          FROM
            Lead
          WHERE
            Id =:leadId
      ];
      leadRecord.Status = Constants.LEAD.STATUS.IN_PROGRESS;
      if (signUpState) {
        leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.PENDING_SIGNUP;
      } else {
        leadRecord.Sub_Status__c = Constants.LEAD.SUB_STATUS.NEEDS_FOLLOW_UP;
      }
      update leadRecord;
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /*
   * @description Create History Action and stamp captured History Action
   * details
   * @param historyEventId This hold History Event Id.
   * @param leadData This holds the Lead Info.
   * @param type This will hold type of action.
   * @return null
   */
  public static void createHistoryAction(Id historyEventId, Lead leadData, String type) {

    String METHOD_NAME = 'createHistoryAction';
    History_Action__c historyActionRecord = new History_Action__c();
    historyActionRecord.History_Event__c = historyEventId;
    historyActionRecord.Interaction_Notes__c = leadData.Interaction_Notes__c;
    historyActionRecord.Customer_consents_to_3rd_Party_delivery__c =
        String.valueOf(leadData.Customer_Consent_to_3rd_Party_Delivery__c);
    historyActionRecord.Pilot__c = leadData.Pilot__c;
    historyActionRecord.Third_Party_Delivery__c =
        leadData.Third_Party_Delivery__c;
    if (leadData.Status == Constants.LEAD.STATUS.DISQUALIFIED) {
      historyActionRecord.Type__c = Constants.HISTORY_ACTION.TYPE.RE_ENGAGE;
    } else {
      historyActionRecord.Type__c = type;
    }
    historyActionRecord.Interaction_Result__c = leadData.Interaction_Result__c;
    historyActionRecord.Lead_Objection__c = leadData.Objection_Reason__c;
    historyActionRecord.OwnerId = userinfo.getUserId();
    historyActionRecord.Sign_Up_Insights__c = leadData.Sign_up_Insights__c;
    historyActionRecord.Campaign__c = leadData.Campaign__c;
    try {
      insert historyActionRecord;
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /**
   * @description Stamps Latest History Event created date on Lead.
   * @param leadId Holds Lead record Id.
   * @return  ipOutput Holds the map of output of Integration Procedure.
   */
  @AuraEnabled
  public static Map<String, Object> stampLatestHistoryEventCreatedDateOnLead(Id leadId) {

    String METHOD_NAME = 'stampLatestHistoryEventCreatedDateOnLead';
    String IP_NAME = 'LDM_UpdateLeadLastD2DActivityDate';
    Map<String, Object> ipInput = new Map<String, Object>();
    Map<String, Object> ipOutput = new Map<String, Object>();
    Map<String, Object> ipOptions = new Map<String, Object>();
    ipInput.put('leadId', leadId);
    try {
      ipOutput =
          (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(
          IP_NAME, ipInput, ipOptions);
      return ipOutput;
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /**
   * @description check If History Event is open.
   * @param leadId Holds Lead record Id.
   * @return  ipOutput Holds the map of output of Integration Procedure.
   */
  @AuraEnabled
  public static Boolean hasOpenHistoryEvent(Id leadId){

    String METHOD_NAME = 'hasOpenHistoryEvent';
    try{
      List<History_Event__c> historyEventList = [
        SELECT Id, Status__c
        FROM History_Event__c
        WHERE Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
        AND Lead__c = :leadId
      ];
      Boolean checkRecord = false;
      if (historyEventList.size() > 0) {
        checkRecord = true;
      } else {
        checkRecord = false;
      }
      return checkRecord;
    }
    catch(Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /**
   * @description Update bugafiber ticket.
   * @param leadId Holds Lead record Id.
   * @return  ipOutput Holds the map of output of Integration Procedure.
   */
  @AuraEnabled
  public static Map<String, Object> updateBugafiberTicket(String bugafiberTicketId,
      String firstName, String lastName, String email, String phoneNumber) {
    Map<String, Object> response = new Map<String, Object>();
    String METHOD_NAME = 'updateBugafiberTicket';
    String IP_NAME = 'TCK_UpdateBugafiberContactTicket';
    Map<String, Object> ipInput = new Map<String, Object>();
    Map<String, Object> ipOutput = new Map<String, Object>();
    Map<String, Object> ipOptions = new Map<String, Object>();
    ipInput.put('bugafiberTicketId', bugafiberTicketId);
    ipInput.put('firstName', firstName);
    ipInput.put('lastName', lastName);
    ipInput.put('email', email);
    ipInput.put('phoneNumber', phoneNumber);
    try{
      response = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(
          IP_NAME, ipInput, ipOptions);
      return response;
    } catch(Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /**
   * @description extracts Latest Bugafiber Ticket
   * @param input The input map Holds history event Id.
   * @param outMap The output of the Apex Class.
   * @param options The options passed from Apex Class.
   */
  @AuraEnabled
  public static String extractLatestBugafiberTicketId(Id leadId) {
    String METHOD_NAME = 'extractLatestBugafiberTicketId';
    try {
      History_Event__c historyEventRecord = [
          SELECT
            Id,
            External_Ticket__c
          FROM
            History_Event__c
          WHERE
            Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
          AND
            Lead__c = :leadId
          ORDER BY CreatedDate DESC
          LIMIT 1
      ];
      return historyEventRecord.External_Ticket__c;
    }
    catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /**
   * @description extracts Bugafiber Ticket
   * @param input The input map Holds history event Id.
   * @param outMap The output of the Apex Class.
   * @param options The options passed from Apex Class.
   */
  @AuraEnabled
  public static String extractBugafiberTicketId(Id leadId) {

    String METHOD_NAME = 'extractBugafiberTicketId';
    try{
      History_Event__c historyEventRecord = [
          SELECT
            Id,
            External_Ticket__c
          FROM
            History_Event__c
          WHERE
            Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
          AND
            Lead__c = :leadId
          ORDER BY CreatedDate DESC
          LIMIT 1
      ];
      return historyEventRecord.External_Ticket__c;
    }
    catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }

  /**
   * @description Check Open Contact Ticket associate with Lead
   * @param leadId to fetch associate lead
   */
  @AuraEnabled
  public static Boolean isContactTicket(Id leadId) {
    Boolean isContactTicket;
    String METHOD_NAME = 'isContactTicket';
    try{
      List<History_Event__c> historyEventRecord = new List<History_Event__c>();
      historyEventRecord = [
          SELECT
            Id,
            External_Ticket__c
          FROM
            History_Event__c
          WHERE
            Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
          AND
            Lead__c = :leadId
          LIMIT 1
      ];
      if (historyEventRecord.isEmpty()) {
        isContactTicket = true;
      } else {
        isContactTicket = false;
      }
      return isContactTicket;
    }
    catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }
}