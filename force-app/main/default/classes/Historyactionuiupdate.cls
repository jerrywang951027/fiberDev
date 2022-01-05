/**
 * @group ticket__c
 * @description This class performs actions related to ticket.
 */
global with sharing class Historyactionuiupdate implements vlocity_cmt.VlocityOpenInterface2 {
  public static final String CLASS_NAME = 'TicketingUtils';
  //list of parent filter values_
  public static List<String> parentFilterList = new List<String>();
  //list of child filter values
  public static List<String> childFilterList = new List<String>();
  //issue tickets full service response
  public static Map<String, Object> responseMapIssue;
  //list of history action which are associated to history event
  public static List<String> historyActionIdList = new List<String>();
  //list of history event which are associated to account with ticket value
  public static List<String> historyEventIdList = new List<String>();
  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * cancelAppointmentRequest method.
   * @param methodName The name of the method that will be invoked
   * @param input The inputs of the method
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  public Boolean invokeMethod(String methodName, Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {
    String METHOD_NAME = 'invokeMethod';
    Boolean result = true;
    try{
      if (methodName.equals('cancelAppointmentRequest')) {
        cancelAppointmentRequest(input, outMap, options);
      } else if (methodName.equals('getWorklogTemplate')) {
        getWorklogTemplate(input, outMap, options);
      } else if (methodName.equals('populateTemplates')) {
        populateTemplates(input, outMap, options);
      } else if (methodName.equals('extractHistory')) {
        extractHistory(input, outMap, options);
      } else if (methodName.equals('getFolder')) {
        EmailController.getFolder(input, outMap, options);
      } else if (methodName.equals('getTemplates')) {
        EmailController.getTemplates(input, outMap, options);
      } else if (methodName.equals('getEmailTemplateDetail')) {
        EmailController.getEmailTemplateDetail(input, outMap, options);
      } else if (methodName.equals('getEmail')) {
        EmailController.getEmail(input, outMap, options);
      } else if (methodName.equals('getContactTicket')) {
        EmailController.getContactTicket(input, outMap, options);
      } else if (methodName.equals('sendEmailService')) {
        EmailController.sendEmailService(input, outMap, options);
      } else if (methodName.equals('getAFUType')) {
        getAFUType(input, outMap, options);
      } else {
        result = false;
      }
    } catch(Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      result = false;
    }
    return result;
  }
  /*
   * @group Scheduling
   * @description US to Cancel service appointment in OFSC Part 2.
   * @param getAppointmentDetail Input to fetch the actual appointment details.
   * @param selected Input to create the reques for appointment cancellation.
   * @return appointment cancellation request using json generator in generateRequestJson method.
   */
  public static void cancelAppointmentRequest(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {
    if (String.isNotBlank(String.valueOf(input.get('getAppointmentDetail')))) {
      outMap.put('sequenceResponse',json.deserializeuntyped(generateRequestJson(input,outMap)));
    } else {
      outMap.put('sequenceResponse',null);
    }
  }
  /*
   * @group Scheduling
   * @description US to Cancel service appointment in OFSC Part 2.
   * @param getAppointmentDetail Input to fetch the actual appointment details.
   * @param selected Input to create the reques for appointment cancellation.
   * @return appointment cancellation request using json generator functionality.
   */
  private static String generateRequestJson(Map<String, Object> input,
      Map<String, Object> outMap){
    String reuqestJson;
    // Create a JSONGenerator object.
    JSONGenerator gen = JSON.createGenerator(true);
    // Write data to the JSON string.
    gen.writeStartObject();
    // write condition to replace install with Installation if there is node by name Install.
    if (String.valueOf(
        ((Map<String,Object>)(input.get('getAppointmentDetail'))
        ).get('appointmentType')).contains('install')) {
      gen.writeFieldName('appointmentType');
      gen.writeStartObject();
      // Write data to the JSON Object
      gen.writeObjectField('installation',(
          (Map<String,Object>)(input.get('appointmentType'))).get('install'));
      gen.writeEndObject();
    } else {
      gen.writeObjectField('appointmentType',(
          (Map<String,Object>)(input.get('getAppointmentDetail'))).get('appointmentType'));
    }
    gen.writeEndObject();
    reuqestJson = gen.getAsString();
    return reuqestJson;
  }

  /**
   * @description This method fetches operation ticket meta data.
   * @param inputMap This will have ticket list ids.
   * @param outMap This will return template for operation ticket.
   * @param options Any optional parameters
   * @return null
   */
  @AuraEnabled(cacheable = true)
  public static List<Worklog_Template__mdt> getWorklogTemplate(
      Map<String, Object> input, Map<String, Object> outMap,
      Map<String, Object> options) {
    String labelName;
    List<Worklog_Template__mdt> workLogTemplateList = new List<Worklog_Template__mdt>();
    try{
      String ticketId = String.valueOf(input.get('ticketId'));
      if (String.isNotBlank(ticketId)) {
        Operation_Ticket__x ticketRecord = getOperationTicketById(ticketId);
        labelName = String.valueOf(ticketRecord.Type__c);
      } else {
        labelName = String.valueOf(input.get('labelName'));
      }

      List<Map<String, String>> uiOptionsMap = new List<Map<String, String>>();
      workLogTemplateList = [
        SELECT
          Id,
          MasterLabel,
          DeveloperName,
          Template__c
        FROM
          Worklog_Template__mdt
        WHERE
          MasterLabel = :labelName
      ];
      Map<String, String> operationTemplateMap;
      for (Worklog_Template__mdt workLogTemplate : workLogTemplateList) {
        operationTemplateMap = new Map<String, String>();
        operationTemplateMap.put('masterLabel', workLogTemplate.MasterLabel);
        operationTemplateMap.put('template', workLogTemplate.Template__c);
        uiOptionsMap.add(operationTemplateMap);
      }
      outMap.put('options', uiOptionsMap);
      outMap.put('type', labelName);
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          'getWorklogTemplate', exp);
      throw exp;
    }
    return workLogTemplateList;
  }

  /**
   * @description This method fetches worklog templates name from custom worklog meta data.
   * @param inputMap This will be null.
   * @param outMap This will return template names from worklog meta data.
   * @param options Any optional parameters
   * @return null
   */
  @AuraEnabled(cacheable = true)
  public static Map<String, Object> populateTemplates(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {
    List<Map<String, String>> uiOptionsMap = new List<Map<String, String>> ();
    try{
      List<Worklog_Template__mdt> workLogTemplateList = [
          SELECT
            Id,
            MasterLabel
          FROM
            Worklog_Template__mdt
      ];
      for (Worklog_Template__mdt ticketRecords : workLogTemplateList) {
        Map <String, String> tempMap = new Map <String, String> ();
        tempMap.put('value', ticketRecords.MasterLabel);
        tempMap.put('label', ticketRecords.MasterLabel);
        uiOptionsMap.add(tempMap);
      }
      outMap.put('options', uiOptionsMap);
      } catch (Exception exp) {
        LoggingUtility.insertExceptionLog(CLASS_NAME,
            'populateTemplates', exp);
        throw exp;
      }
    return outMap;
  }

  /**
   * @description Holds the mock response for external object(operation ticket)
   * @return Operation Ticket(mock data)
   */
  @TestVisible
  private static List<Operation_Ticket__x> mockedRequests = new List<Operation_Ticket__x>();
  public static Operation_Ticket__x getOperationTicketById(String requestId) {
    List<Operation_Ticket__x> requests = (Test.isRunningTest()) ? mockedRequests : [
        SELECT
          Id,
          Type__c
        FROM
          Operation_Ticket__x
        WHERE
          Id = :requestId
    ];
    return (requests.size() > 0) ? requests[0] : null;
  }

   /*
   * @group querytickets
   * @description US to extraxt History Event/Action details.
   * @param request Input to fetch the actual Issue ticket details.
   * @return response generated by getCallOutResponse method.
   * {
   *  "totalSize": "15",
   *  "ticketResponse": [
   *  {
   *   "type": "Inbound Email",
   *    ...
   *    "children": [
   *    {
   *      "type": "Issue",
   *      ...
   *    }, ...]
   *  }, ...],
   * "pageToken": "value of pageToken",
   * "pageSize": "10"
   * }
   */
  void extractHistory(Map<String, Object> input, Map<String, Object> outMap,
      Map<String, Object> optionsMap) {
    if (input.get('totalSize') != null) {
      outMap.put('allIssueTicketList',json.serialize(
          mapTicketsWithHistory(input,outMap)));
    } else {
     outMap.put('allIssueTicketList',null);
    }
  }
  /*
   * @group querytickets
   * @description US to extraxt History Event/Action details.
   * @param request Input to fetch the actual Issue ticket details.
   * @return history Event/Action records correctly mapped with salesforce object.
   * {
   *  "totalSize": "15",
   *  "ticketResponse": [
   *  {
   *   "type": "Inbound Email",
   *    ...
   *    "children": [
   *    {
   *      "type": "Issue",
   *      ...
   *    }, ...]
   *  }, ...],
   * "pageToken": "value of pageToken",
   * "pageSize": "10"
   * }
   */
  public cls_historyResponseWrapperParent mapTicketsWithHistory(Map<String, Object> input,
      Map<String, Object> outMap) {
    //list of issue tickets from salesforce query response
    Set<String> issueTicketRecordList = new Set<String>();
    //list of issue tickets from service response
    List<String> issueTicketBuganizerIds = new List<String>();
    //list of contact tickets from service response
    List<String> contactTicketBuganizerIds = new List<String>();
    //list of history action which are associated to account but not with history event
    List<History_Action__c> historyActionNoEventList = new List<History_Action__c>();
    //list of history actionTicket which are associated to account but not with history event
    List<String> historyActionTicketNoEventList = new List<String>();
    //contact tickets full service response
    Map<String, Object> responseMapContact;
    //list of history event which are associated to account with ticket value
    List<String> historyEventIdList = new List<String>();
    //list of parent filter values
    List<String> parentFilterList = new List<String>();
    //list of child filter values
    List<String> childFilterList = new List<String>();
    //issue tickets full service response
    Map<String, Object> responseMapIssue;
    //other tickets NIU,NOC,INSTALLATION_OPERATIONS service response
    Map<String, Object> responseMapOtherTckets;
    //list of history action which are associated to history event
    Set<String> historyActionIdList = new Set<String>();
    List<History_Event__c> historyEventRecordList =
        new List<History_Event__c>();
    List<History_Action__c> historyActionRecordList =
        new List<History_Action__c>();
    List<Billing_Events__c> billingEventRecordList =
        new List<Billing_Events__c>();
    cls_historyResponseWrapperParent parentResponseWrapper =
        new cls_historyResponseWrapperParent();
    List<cls_historyResponseWrapper> responseWrapperList =
        new List<cls_historyResponseWrapper>();
    OrderItem orderItem = new OrderItem();
    String newInstallOrderId;
    Map <String, Object> ipInput = new Map <String, Object> ();
    Map <String, Object> ipOutput = new Map <String, Object> ();
    Map <String, Object> ipOptions = new Map <String, Object> ();
    Map <String, Object> message;
    String IP_NAME = 'ORD_ExtractOrderDetails';
    if (String.isNotBlank(String.valueOf(input.get('type')))) {
      List<cls_type> typeFilterList =  (List<cls_type>)JSON.deserialize(
          JSON.serialize(input.get('type')),List<cls_type>.class);
      for (cls_type typeFilter : typeFilterList) {
        if (typeFilter.level == 'parent') {
          parentFilterList.add(typeFilter.value);
        } else {
          childFilterList.add(typeFilter.value);
        }
      }
    }
    parentResponseWrapper.pageToken = String.valueOf(input.get('nextPageToken'));
    parentResponseWrapper.totalSize = String.valueOf(input.get('totalSize'));
    parentResponseWrapper.pageSize = String.valueOf(input.get('pageSize'));
    if(input.get('totalSize')!=null) {
      responseMapIssue = (Map<String, Object>)(input.get('issueTicketList'));
      responseMapContact = (Map<String, Object>)(input.get('contactTicketList'));
      if(input.get('otherTypeTicketList')!=null){
        responseMapOtherTckets = (Map<String, Object>)(input.get('otherTypeTicketList'));
      }
      if (responseMapIssue != null) {
        for (Object ticketObj : (List<Object>)responseMapIssue.get('tickets')) {
          Map<String,Object> ticket = (Map<String,Object>)ticketObj;
          issueTicketBuganizerIds.add(String.valueOf(
              ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId')));
        }
      }
      if (responseMapContact != null) {
        for (Object ticketObj : (List<Object>)responseMapContact.get('tickets')) {
          Map<String,Object> ticket = (Map<String,Object>)ticketObj;
          contactTicketBuganizerIds.add(String.valueOf(
              ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId')));
        }
      }
      historyEventRecordList = getHistoryEvents(input,contactTicketBuganizerIds,
          historyEventRecordList);
      historyActionRecordList = getHistoryActions(input,issueTicketBuganizerIds,
          historyActionRecordList);
      billingEventRecordList = getBillingEvents(input,billingEventRecordList);
      for (History_Action__c historyAction : historyActionRecordList) {
        issueTicketRecordList.add(historyAction.Ticket__r.Name);
      }
      for (History_Event__c historyEvent : historyEventRecordList) {
        if(historyEvent.Order__r.Type == 'Change Services') {
          ipInput.put('orderId', historyEvent.Order__r.Id);
          ipInput.put('type', 'Plan change');
        } else if(historyEvent.Order__r.Type == 'New Install') {
          newInstallOrderId = historyEvent.Order__r.Id;
        }
      }
      if(String.isNotBlank(newInstallOrderId)) {
        orderItem = getPlanTypeFromOrderItem(newInstallOrderId);
      }
      ipOutput =  (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(IP_NAME,
          ipInput, ipOptions);
      System.debug('ipoutput++++'+JSON.serialize(ipOutput));
      //parent loop for all history event associated with account/lead
      for (History_Event__c eventTicket : historyEventRecordList) {
        if (eventTicket.Type__c != Constants.HISTORY_EVENT.TYPE.SERVICE_VISIT
            && responseMapContact != null) {
          for (Object ticketObj : (List<Object>)responseMapContact.get('tickets')) {
            Map<String,Object> ticket = (Map<String,Object>)ticketObj;
            if (eventTicket.External_Ticket__c != null
                && eventTicket.External_Ticket__c == String.valueOf(
                ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId'))
                && (parentFilterList.contains(eventTicket.Type__c)
                || parentFilterList.isEmpty())) {
              historyEventIdList.add(eventTicket.External_Ticket__c);
              responseWrapperList.add(createParentResponseWrapper(null,eventTicket,ticket,'',
                  childFilterList,responseMapIssue,historyActionIdList,null,null));
            }
          }
        } else if (eventTicket.Type__c == Constants.HISTORY_EVENT.TYPE.SERVICE_VISIT &&
            (parentFilterList.contains(eventTicket.Type__c) || parentFilterList.isEmpty())) {
          historyEventIdList.add(eventTicket.External_Ticket__c);
          responseWrapperList.add(createParentResponseWrapper(null,eventTicket,null,'',
              childFilterList,responseMapIssue,historyActionIdList,null,null));
        }
      }
      //parent loop for all history action not associated to history event
      if (responseMapIssue != null) {
        for (Object ticketObj : (List<Object>)responseMapIssue.get('tickets')) {
          Map<String,Object> ticket = (Map<String,Object>)ticketObj;
          String issueId = String.valueOf(
              ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId'));
          if (!historyActionIdList.contains(issueId)
              && !historyActionTicketNoEventList.contains(issueId)
              && (parentFilterList.contains('Internal Issue') || parentFilterList.isEmpty())) {
            responseWrapperList.add(createParentResponseWrapper(null,null,ticket,'Internal Issue',
                childFilterList,responseMapIssue,historyActionIdList,null,null));
          } else {
            for (History_Action__c historyActionNoEvent : historyActionRecordList) {
              if (historyActionNoEvent.Ticket__r.Name == issueId
                  && (parentFilterList.contains(historyActionNoEvent.Type__c)
                  || parentFilterList.isEmpty())) {
                responseWrapperList.add(createParentResponseWrapper(historyActionNoEvent,null,
                    ticket,'',childFilterList,responseMapIssue,historyActionIdList,null,null));
              }
            }
          }
        }
      }
      //parent loop for all history event not associated with account/lead
      if (responseMapContact != null) {
        for (Object ticketObj : (List<Object>)responseMapContact.get('tickets')) {
          Map<String,Object> ticket = (Map<String,Object>)ticketObj;
          List<cls_children> childrenList = new List<cls_children>();
          cls_historyResponseWrapper responseWrapperOutbbound = new cls_historyResponseWrapper();
          if (!historyEventIdList.contains(String.valueOf(
              ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId')))
              && String.valueOf(
              ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
              ).get('contact channel')).get('enumValue')).equalsIgnoreCase('Outbound')
              && (parentFilterList.contains('Outbound')
              || parentFilterList.isEmpty())) {
            responseWrapperList.add(createParentResponseWrapper(null,null,ticket,'Outbound',
                childFilterList,responseMapIssue,historyActionIdList,null,null));
          }
        }
      }
      //parent loop for history event associated with account/lead not associated service response
      for (History_Event__c eventTicket : historyEventRecordList) {
        if ((!historyEventIdList.contains(eventTicket.External_Ticket__c)
            || String.isBlank(eventTicket.External_Ticket__c))
            && ((String.isNotBlank(eventTicket.Type__c) && parentFilterList.contains(eventTicket.Type__c))
            || (String.isNotBlank(eventTicket.Order__r.Type)
            &&  ((!'Change Services'.equalsIgnoreCase(eventTicket.Order__r.Type)
            && parentFilterList.contains(eventTicket.Order__r.Type)) 
            || ('Change Services'.equalsIgnoreCase(eventTicket.Order__r.Type)
            && parentFilterList.contains('Plan change'))))
            || parentFilterList.isEmpty())) {
          responseWrapperList.add(createParentResponseWrapper(null,eventTicket,null,'',
              childFilterList,responseMapIssue,historyActionIdList,ipOutput,OrderItem));
        }
      }
      //parent loop for billing event associated with account
      if(!billingEventRecordList.isEmpty()) {
        for (Billing_Events__c eventTicket : billingEventRecordList) {
          if ((((!'Delinquent'.equalsIgnoreCase(eventTicket.Billing_Event__c)
              && !'Suspended'.equalsIgnoreCase(eventTicket.Billing_Event__c))
              && ((!eventTicket.Event_Type__c.contains('-') && parentFilterList.contains(eventTicket.Event_Type__c))
              || (eventTicket.Event_Type__c.contains('-') && parentFilterList.contains('Billing'))))
              || (('Delinquent'.equalsIgnoreCase(eventTicket.Billing_Event__c)
              || 'Suspended'.equalsIgnoreCase(eventTicket.Billing_Event__c))
              && parentFilterList.contains('Suspension')))
              || parentFilterList.isEmpty()) {
            responseWrapperList.add(createParentResponseWrapperWithBillingRecord(eventTicket));
          }
        }
      }
      //parent loop for all history event not associated with account/lead
      if(responseMapOtherTckets!=null) {
        responseMapOtherTckets = (Map<String, Object>)(input.get('otherTypeTicketList'));
        for (Object ticketObj : (List<Object>)responseMapOtherTckets.get('tickets')) {
          Map<String,Object> ticket = (Map<String,Object>)ticketObj;
          if(!historyEventIdList.contains(String.valueOf(
              ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId')))) {
             if('NOC'.equalsIgnoreCase(String.valueOf(ticket.get('ticketFlowDefType')))) {  
              if(Boolean.valueOf(((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')    
                  ).get('known issue')).get('booleanValue'))    
                  && (parentFilterList.contains('known Issue')  
                  || parentFilterList.isEmpty())) { 
                responseWrapperList.add(createParentResponseWrapper(null,null,ticket,'known Issue', 
                    childFilterList,responseMapIssue,historyActionIdList,null,null)); 
              } else if(!Boolean.valueOf(((Map<String,Object>)((Map<String,Object>)ticket
                  .get('fieldValues')).get('known issue')).get('booleanValue'))    
                  && (parentFilterList.contains('Outage')   
                  || parentFilterList.isEmpty())) { 
                responseWrapperList.add(createParentResponseWrapper(null,null,ticket,'Outage',  
                    childFilterList,responseMapIssue,historyActionIdList,null,null));     
              }
            } else if('NIU'.equalsIgnoreCase(String.valueOf(ticket.get('ticketFlowDefType')))
                && 'New Install'.equalsIgnoreCase(String.valueOf
                (((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
                ).get('install type')).get('enumValue')))
                && (parentFilterList.contains('NIU Install')
                || parentFilterList.isEmpty())) {
              responseWrapperList.add(createParentResponseWrapper(null,null,ticket,'NIU Install',
                  childFilterList,responseMapIssue,historyActionIdList,null,null));
            } else if('INSTALLATION_OPERATIONS'.equalsIgnoreCase(
                String.valueOf(ticket.get('ticketFlowDefType')))
                && (parentFilterList.contains(Constants.HISTORY_EVENT.TYPE.SERVICE_VISIT)
                || parentFilterList.isEmpty())) {
              responseWrapperList.add(createParentResponseWrapper(null,null,ticket,
                  Constants.HISTORY_EVENT.TYPE.SERVICE_VISIT,childFilterList,
                  responseMapIssue,historyActionIdList,null,null));
            }
          }
        }
      }
    }
    parentResponseWrapper.ticketResponse =  responseWrapperList;
    return parentResponseWrapper;
  }
  /*
   * @group ticket__c
   * @description to fetch operation ticket record related to ticketId.
   * @param String externalId Input to fetch the opration ticket record.
   * @return operationTicketId as string.
   */
  @TestVisible
  private static Operation_Ticket__x mockedTicketResponse = new Operation_Ticket__x();
  private static String getOperationTicketRecord(String externalId) {
    Operation_Ticket__x operationTicket = (Test.isRunningTest()) ? mockedTicketResponse : [
        SELECT
          Id
        FROM Operation_Ticket__x
        WHERE ExternalId = :externalId];
    String operationTicketId = operationTicket.Id;
    return operationTicketId;
  }
  /*
   * @group ticket__c
   * @description getBillingEvents method to fetch billing event
   * @record related to ticketId/accountId.
   * @param input to fetch the billing event record.
   * @return list of billingEvents related BuganizerIds.
   * ["202711052", ...]
   */
  private static List<Billing_Events__c> getBillingEvents(Map<String, Object> input,
      List<Billing_Events__c> billingEventRecordList) {
    if (String.isNotBlank(String.valueOf(input.get('accountId')))) {
        billingEventRecordList = [
            SELECT Id,
              Actionable_Future_Event__c,
              Actionable_Future_Event_Time__c,
              Billing_Event__c,
              createdDate,
              Event_Type__c
            FROM Billing_Events__c
            WHERE Account__r.Parent.Id = :String.valueOf(input.get('accountId'))
            OR Account__r.Parent.Parent.Id = :String.valueOf(input.get('accountId'))] ;
    }
    return billingEventRecordList;
  }
  /*
   * @group ticket__c
   * @description getBillingEvents method to fetch billing event
   * @record related to ticketId/accountId.
   * @param input to fetch the billing event record.
   * @return list of billingEvents related BuganizerIds.
   * ["202711052", ...]
   */
  private static OrderItem getPlanTypeFromOrderItem(String orderId) {
    OrderItem orderItem = [
        SELECT Id,
            createdDate,
            product2.name,
            Product2.vlocity_cmt__Type__c,
            OrderId
        FROM OrderItem
        WHERE OrderId = :orderId
        AND Product2.vlocity_cmt__Type__c = 'Internet'];
    return orderItem;
  }
  /*
   * @group ticket__c
   * @description getHistoryEvents method to fetch history event
   * @record related to ticketId/accountId.
   * @param input to fetch the history event record.
   * @return list of historyEvents related BuganizerIds.
   * ["202711052", ...]
   */
  private static List<History_Event__c> getHistoryEvents(Map<String, Object> input,
      List<String> contactTicketBuganizerIds,List<History_Event__c> historyEventRecordList) {
    if (String.isNotBlank(String.valueOf(input.get('accountId')))) {
        historyEventRecordList = [
            SELECT
              Id,
              External_Ticket__c,
              Type__c,
              CreatedDate,
              Direction__c,
              Request_Id__c,
              Email_Campaign_Id__c,
              Email_Type__c,
              Event_Note__c,
              Order__r.Id,
              Order__r.createdDate,
              Order__r.OrderNumber,
              Order__r.Sub_Type__c,
              Order__r.Type,
              Order__r.vlocity_cmt__Reason__c,
              (SELECT
                Id,
                Type__c,
                CreatedDate,
                History_Event__c,
                Email_Subject__c,
                History_Event__r.Id,
                History_Event__r.Type__c,
                Ticket__c,Ticket__r.Name,
                Order__r.Id,
                Order__r.createdDate,
                Order__r.Sub_Type__c,
                Order__r.Type,
                Order__r.vlocity_cmt__Reason__c,
                Ticket__r.createdDate,
                Order__r.OrderNumber,
               Ticket__r.Symptom__c
              FROM History_Actions__r)
            FROM History_Event__c
            WHERE Account__r.Id = :String.valueOf(input.get('accountId'))] ;
    } else if (String.isNotBlank(String.valueOf(input.get('leadId')))) {
        historyEventRecordList = [
            SELECT
              Id,
              External_Ticket__c,
              Type__c,CreatedDate,
              Direction__c,
              Request_Id__c,
              Email_Campaign_Id__c,
              Email_Type__c,
              Event_Note__c,
              Order__r.Id,
              Order__r.createdDate,
              Order__r.OrderNumber,
              Order__r.Sub_Type__c,
              Order__r.Type,
              Order__r.vlocity_cmt__Reason__c,
              (SELECT
                Id,
                Type__c,
                CreatedDate,
                History_Event__c,
                Email_Subject__c,
                History_Event__r.Id,
                History_Event__r.Type__c,
                Ticket__c,
                Ticket__r.Name,
                Order__r.Id,Order__r.createdDate,
                Order__r.Sub_Type__c,
                Order__r.Type,
                Order__r.vlocity_cmt__Reason__c,
                Ticket__r.createdDate,
                Order__r.OrderNumber,
               Ticket__r.Symptom__c
              FROM History_Actions__r)
            FROM History_Event__c
            WHERE Lead__r.Id = :String.valueOf(input.get('leadId'))];
    } else {
        historyEventRecordList = [
            SELECT
              Id,
              External_Ticket__c,
              Type__c,CreatedDate,
              Direction__c,
              Request_Id__c,
              Email_Campaign_Id__c,
              Email_Type__c,
              Event_Note__c,
              Order__r.Id,
              Order__r.createdDate,
              Order__r.OrderNumber,
              Order__r.Sub_Type__c,
              Order__r.Type,
              Order__r.vlocity_cmt__Reason__c,
              (SELECT
                Id,
                Type__c,
                CreatedDate,
                History_Event__c,
                Email_Subject__c,
                History_Event__r.Id,
                History_Event__r.Type__c,
                Ticket__c,
                Ticket__r.Name,
                Order__r.Id,Order__r.createdDate,
                Order__r.Sub_Type__c,
                Order__r.Type,
                Order__r.vlocity_cmt__Reason__c,
                Ticket__r.createdDate,
                Order__r.OrderNumber,
               Ticket__r.Symptom__c
              FROM History_Actions__r)
            FROM History_Event__c
            WHERE External_Ticket__c IN :(contactTicketBuganizerIds)];
    }
    return historyEventRecordList;
  }
  /*
   * @group ticket__c
   * @description getHistoryActions method to fetch history action
   * @record related to ticketId/accountId.
   * @param input to fetch the history action record.
   * @return list of historyActions realted BuganizerIds.
   * ["202711051", ...]
   */
  private static List<History_Action__c> getHistoryActions(Map<String, Object> input,
      List<String> issueTicketBuganizerIds,List<History_Action__c> historyActionRecordList) {
    if (String.isNotBlank(String.valueOf(input.get('accountId')))) {
        historyActionRecordList = [
            SELECT
              Id,
              Type__c,
              CreatedDate,
              History_Event__c,
              Email_Subject__c,
              History_Event__r.Id,
              History_Event__r.Type__c,
              Ticket__c,
              Ticket__r.Name,
              Order__r.Id,
              Order__r.createdDate,
              Order__r.Sub_Type__c,
              Order__r.Type,
              Order__r.vlocity_cmt__Reason__c,
              Order__r.OrderNumber,
              Ticket__r.Symptom__c
            FROM History_Action__c
            WHERE (Ticket__r.Name IN :(issueTicketBuganizerIds)
            AND (Ticket__r.Account__r.Id = :String.valueOf(input.get('accountId'))
            AND History_Event__c = :null))] ;
    } else if (String.isNotBlank(String.valueOf(input.get('leadId')))) {
        historyActionRecordList = [
            SELECT
              Id,
              Type__c,
              CreatedDate,
              History_Event__c,
              Email_Subject__c,
              History_Event__r.Id,
              History_Event__r.Type__c,
              Ticket__c,Ticket__r.Name,
              Order__r.Id,Order__r.createdDate,
              Order__r.Sub_Type__c,
              Order__r.Type,
              Order__r.vlocity_cmt__Reason__c,
              Order__r.OrderNumber,
              Ticket__r.Symptom__c
            FROM History_Action__c
            WHERE (Ticket__r.Name IN :(issueTicketBuganizerIds)
            AND (Ticket__r.Lead_Id__r.Id = :String.valueOf(input.get('leadId'))
            AND History_Event__c = :null))] ;
    } else {
        historyActionRecordList = [
            SELECT
              Id,
              Type__c,
              CreatedDate,
              History_Event__c,
              Email_Subject__c,
              History_Event__r.Id,
              History_Event__r.Type__c,
              Ticket__c,Ticket__r.Name,
              Order__r.Id,Order__r.createdDate,
              Order__r.Sub_Type__c,
              Order__r.Type,
              Order__r.vlocity_cmt__Reason__c,
              Order__r.OrderNumber,
             Ticket__r.Symptom__c
            FROM History_Action__c
            WHERE Ticket__r.Name IN :(issueTicketBuganizerIds)] ;
    }
    return historyActionRecordList;
  }
  /*
   * @group ticket__c
   * @description createParentResponseWrapper method to generate parent response wrapper
   * @param History_Event__c.
   * @return cls_historyResponseWrapper.
   */
  private static cls_historyResponseWrapper createParentResponseWrapperWithBillingRecord(Billing_Events__c eventTicket) {
    List<cls_children> childrenList = new List<cls_children>();
    cls_historyResponseWrapper responseWrapper = new cls_historyResponseWrapper();
    responseWrapper.isChild = false;
    String billingEventType;
    if (eventTicket != null) {
      responseWrapper.isBuganizerTicket = true;
      responseWrapper.Id = eventTicket.Id;
      //responseWrapper.bugafiberId = eventTicket.Event_Type__c;
      if(eventTicket.Event_Type__c.contains('-')) {
        List<String> eventType = eventTicket.Event_Type__c.split('-');
        billingEventType = eventType[0];
      }
      responseWrapper.type = eventTicket.Event_Type__c != null ? ( eventTicket.Billing_Event__c != null
          && (eventTicket.Billing_Event__c == 'Delinquent' || eventTicket.Billing_Event__c == 'Suspended')
          ? 'Suspension' : (billingEventType != null ? billingEventType : eventTicket.Event_Type__c)) : '';
      responseWrapper.createdDate = String.isNotBlank(string.valueOf(eventTicket.createdDate))
          ? string.valueOf(eventTicket.createdDate.format('MMM-dd-yyyy')) : '';
      responseWrapper.createdDateFilter = String.isNotBlank(string.valueOf(eventTicket.createdDate))
          ? eventTicket.createdDate : null;
      responseWrapper.ticketUrl = '/'+eventTicket.Id;
      responseWrapper.summary = eventTicket.Actionable_Future_Event__c != null
          ? eventTicket.Actionable_Future_Event__c : '';
      responseWrapper.children = childrenList;
    }
    return responseWrapper;
  }
  /*
   * @group ticket__c
   * @description createParentResponseWrapper method to generate parent response wrapper
   * @param History_Event__c.
   * @return cls_historyResponseWrapper.
   */
  private static cls_historyResponseWrapper createParentResponseWrapper(History_Action__c
      historyActionNoEvent,History_Event__c eventTicket,Map<String,Object> ticket,String type,
      List<String> childFilterList,Map<String, Object> responseMapIssue,
      Set<String> historyActionIdList,Map <String, Object> ipOutput,
      OrderItem orderItem) {
    List<cls_children> childrenList = new List<cls_children>();
    cls_historyResponseWrapper responseWrapper = new cls_historyResponseWrapper();
    responseWrapper.isChild = false;
    List<String> orderType = new List<String>{'Move','Pause','Change Services','New Install','Disconnect','Account Transfer'};
    if (eventTicket != null && ticket != null) {
      responseWrapper.isBuganizerTicket = true;
      responseWrapper.Id = eventTicket.Id;
      responseWrapper.bugafiberId = eventTicket.External_Ticket__c;
      responseWrapper.type = eventTicket.Direction__c != null && eventTicket.Type__c != null
          ? eventTicket.Direction__c+' '+eventTicket.Type__c : eventTicket.Type__c;
      responseWrapper.createdDate = String.valueOf(
          ((DateTime)JSON.deserialize('"' + String.valueOf(
          ((Map<String,Object>)ticket.get('buganizerIssue')).get('createdTime'))
          + '"', DateTime.class)).format('MMM-dd-yyyy'));
      responseWrapper.createdDateFilter = (DateTime)JSON.deserialize('"' + String.valueOf(
          ((Map<String,Object>)ticket.get('buganizerIssue')).get('createdTime'))
          + '"', DateTime.class);
      responseWrapper.ticketUrl = '/'+eventTicket.Id;
      responseWrapper.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
            ).get('notes')).get('stringValue'));
      //child loop for all history action associated to history event
      for (History_Action__c actionTicket : eventTicket.History_Actions__r) {
        if (responseMapIssue != null && (childFilterList.contains(actionTicket.Type__c)
            || childFilterList.isEmpty())) {
          for (Object issueTicketObj : (List<Object>)responseMapIssue.get('tickets')) {
            Map<String,Object> issueTicket = (Map<String,Object>)issueTicketObj;
            if (actionTicket.Ticket__r.Name == String.valueOf(
                ((Map<String,Object>)issueTicket.get('buganizerIssue'))
                .get('issueId'))) {
              historyActionIdList.add(actionTicket.Ticket__r.Name);
              childrenList.add(createChildResponseWrapper(actionTicket,issueTicket));
            }
          }
        }
        if ((String.isNotBlank(actionTicket.Ticket__r.Name)
            && !historyActionIdList.contains(actionTicket.Ticket__r.Name))
            || actionTicket.Order__c != null
            || (actionTicket.Ticket__c == null && actionTicket.Order__c == null)) {
          historyActionIdList.add(actionTicket.Ticket__r.Name);
          childrenList.add(createChildResponseWrapper(actionTicket,null));
        }
        responseWrapper.children = childrenList;
      }
    } else if (historyActionNoEvent != null && ticket != null) {
      responseWrapper.isBuganizerTicket = true;
      responseWrapper.Id = historyActionNoEvent.Ticket__c;
      responseWrapper.bugafiberId = historyActionNoEvent.Ticket__r.Name;
      responseWrapper.type = historyActionNoEvent.Type__c;
      responseWrapper.createdDate = String.valueOf(
          ((DateTime)JSON.deserialize('"' + String.valueOf(
          ((Map<String,Object>)ticket.get('buganizerIssue')).
          get('createdTime')) + '"', DateTime.class)).format('MMM-dd-yyyy'));
      responseWrapper.createdDateFilter = (DateTime)JSON.deserialize('"' + String.valueOf(
          ((Map<String,Object>)ticket.get('buganizerIssue')).
          get('createdTime')) + '"', DateTime.class);
      responseWrapper.ticketUrl = '/'+historyActionNoEvent.Ticket__c;
      responseWrapper.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
            ).get('sub type')).get('notes'));
      responseWrapper.children = childrenList;
    } else if (eventTicket != null && eventTicket.Order__r.Type != null 
        && orderType.contains(eventTicket.Order__r.Type)) {
      responseWrapper.bugafiberId = eventTicket.Order__r.OrderNumber;
      responseWrapper.Id = eventTicket.Order__r.Id;
      responseWrapper.isBuganizerTicket = false;
      if(('Move').equalsIgnoreCase(eventTicket.Order__r.Type)) {
        responseWrapper.summary = 'Customer initiated account move';
      } else if(('Change Services').equalsIgnoreCase(eventTicket.Order__r.Type)
          && !ipOutput.isEmpty()) {
        String oldPlan = String.isNotBlank(String.valueOf(ipOutput.get('oldPlan')))
            ? String.valueOf(ipOutput.get('oldPlan')) : '';
        String newPlan = String.isNotBlank(String.valueOf(ipOutput.get('newPlan')))
            ? String.valueOf(ipOutput.get('newPlan')) : '';
        responseWrapper.summary = oldPlan + '>' + newPlan;  
      } else if(('New Install').equalsIgnoreCase(eventTicket.Order__r.Type) 
          && String.valueOf(orderItem.orderId).equalsIgnoreCase(eventTicket.Order__r.Id)) {
        responseWrapper.summary = orderItem.Product2.Name;
      } else {
        responseWrapper.summary = eventTicket.Order__r.vlocity_cmt__Reason__c;
      }
      responseWrapper.type = eventTicket.Order__r.Type != null
          && ('Change Services').equalsIgnoreCase(eventTicket.Order__r.Type)
          ? 'Plan change' : eventTicket.Order__r.Type ;
      responseWrapper.createdDate = String.isNotBlank(string.valueOf(
          eventTicket.createdDate))?string.valueOf(
          eventTicket.createdDate.format('MMM-dd-yyyy')):'';
      responseWrapper.createdDateFilter = String.isNotBlank(string.valueOf(
          eventTicket.createdDate))?
          eventTicket.createdDate:null;
      responseWrapper.ticketUrl = '/'+eventTicket.Order__r.Id;
      //child loop for all history action associated to history event
      for (History_Action__c actionTicket : eventTicket.History_Actions__r) {
        if (responseMapIssue != null && (childFilterList.contains(actionTicket.Type__c)
            || childFilterList.isEmpty())) {
          for (Object issueTicketObj : (List<Object>)responseMapIssue.get('tickets')) {
            Map<String,Object> issueTicket = (Map<String,Object>)issueTicketObj;
            if (actionTicket.Ticket__r.Name == String.valueOf(
                ((Map<String,Object>)issueTicket.get('buganizerIssue'))
                .get('issueId'))) {
              historyActionIdList.add(actionTicket.Ticket__r.Name);
              childrenList.add(createChildResponseWrapper(actionTicket,issueTicket));
            }
          }
        }
        if ((String.isNotBlank(actionTicket.Ticket__r.Name)
            && !historyActionIdList.contains(actionTicket.Ticket__r.Name))
            || actionTicket.Order__c != null
            || (actionTicket.Ticket__c == null && actionTicket.Order__c == null)) {
          historyActionIdList.add(actionTicket.Ticket__r.Name);
          childrenList.add(createChildResponseWrapper(actionTicket,null));
        }
      }
      responseWrapper.children = childrenList;
    } else if (eventTicket != null) {
       responseWrapper.isBuganizerTicket = false;
       String Id;
       if (eventTicket.Type__c == Constants.HISTORY_EVENT.TYPE.SERVICE_VISIT
           && String.isNotBlank(eventTicket.External_Ticket__c)) {
         Id = getOperationTicketRecord(eventTicket.External_Ticket__c);
         responseWrapper.summary = eventTicket.Event_Note__c;
      } else {
        Id = eventTicket.Id;
        responseWrapper.summary = eventTicket.Email_Type__c;
      }
      responseWrapper.Id = Id;
      responseWrapper.bugafiberId = eventTicket.External_Ticket__c ;
      responseWrapper.type = eventTicket.Direction__c!=null && eventTicket.Type__c!=null
          ? eventTicket.Direction__c+' '+eventTicket.Type__c : eventTicket.Type__c;
      responseWrapper.createdDate = String.isNotBlank(string.valueOf(
          eventTicket.createdDate))?string.valueOf(
          eventTicket.createdDate.format('MMM-dd-yyyy')):'';
      responseWrapper.createdDateFilter = String.isNotBlank(string.valueOf(
          eventTicket.createdDate))?
          eventTicket.createdDate:null;
      responseWrapper.ticketUrl = '/'+Id;
      //child loop for all history action associated to history event
      for (History_Action__c actionTicket : eventTicket.History_Actions__r) {
        if (responseMapIssue != null && (childFilterList.contains(actionTicket.Type__c)
            || childFilterList.isEmpty())) {
          for (Object issueTicketObj : (List<Object>)responseMapIssue.get('tickets')) {
            Map<String,Object> issueTicket = (Map<String,Object>)issueTicketObj;
            if (actionTicket.Ticket__r.Name == String.valueOf(
                ((Map<String,Object>)issueTicket.get('buganizerIssue'))
                .get('issueId'))) {
              historyActionIdList.add(actionTicket.Ticket__r.Name);
              childrenList.add(createChildResponseWrapper(actionTicket,issueTicket));
            }
          }
        }
        if ((String.isNotBlank(actionTicket.Ticket__r.Name)
            && !historyActionIdList.contains(actionTicket.Ticket__r.Name))
            || actionTicket.Order__c != null
            || (actionTicket.Ticket__c == null && actionTicket.Order__c == null)) {
          historyActionIdList.add(actionTicket.Ticket__r.Name);
          childrenList.add(createChildResponseWrapper(actionTicket,null));
        }
      }
      responseWrapper.children = childrenList;
    } else if (ticket != null) {
      String Id;
      responseWrapper.isBuganizerTicket = true;
      if ('INSTALLATION_OPERATIONS'.equalsIgnoreCase(String.valueOf(
          ticket.get('ticketFlowDefType')))) {
         Id = getOperationTicketRecord(String.valueOf
            (((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId')));
         responseWrapper.ticketUrl = '/'+Id;
         responseWrapper.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
            ).get('work type')).get('enumValue'))+','+'Created on'+'{'+String.valueOf(
            ((DateTime)JSON.deserialize('"' +String.valueOf(
            ((Map<String,Object>)ticket.get('buganizerIssue')).
            get('createdTime'))+ '"', DateTime.class)).
            format('MMM-dd-yyyy'))+'}'+' '+'('+String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
            ).get('service visit status')).get('enumValue'))+')';
      } else if('NOC'.equalsIgnoreCase(String.valueOf(ticket.get('ticketFlowDefType')))
          || 'NIU'.equalsIgnoreCase(String.valueOf(ticket.get('ticketFlowDefType')))) {
        Id = String.valueOf(
            ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId'));
        responseWrapper.ticketUrl = System.label.History_Url+Id;
        if('NIU'.equalsIgnoreCase(String.valueOf(ticket.get('ticketFlowDefType')))) {
          responseWrapper.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('buganizerIssue')).
            get('issueState')).get('title'));
        } else if('NOC'.equalsIgnoreCase(String.valueOf(ticket.get('ticketFlowDefType')))) { 
          if('Outage'.equalsIgnoreCase(type)) {
            responseWrapper.summary = String.valueOf(((Map<String,Object>)(
                (Map<String,Object>)ticket.get('fieldValues')).get('service affected')
                ).get('enumValue'))+' '+'('+String.valueOf(((Map<String,Object>)
                ((Map<String,Object>)ticket.get('fieldValues')).get('impact')
                ).get('enumValue'))+')';
          } else if('known issue'.equalsIgnoreCase(type)) {
            responseWrapper.summary = String.valueOf(((Map<String,Object>)(
                (Map<String,Object>)ticket.get('buganizerIssue')).get('issueState')
                ).get('title'))+' '+'('+String.valueOf(((Map<String,Object>)(
                (Map<String,Object>)ticket.get('buganizerIssue')).get('issueState')
                ).get('status'))+')';
          }
        }
      } else if ('Internal Issue'.equalsIgnoreCase(type)) {
        responseWrapper.ticketUrl = System.Label.History_Url+String.valueOf
            (((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId'));
        responseWrapper.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
            ).get('sub type')).get('enumValue')) + '>' + String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
            ).get('symptom')).get('stringValue'));
      } else if('Outbound'.equalsIgnoreCase(type)){
        responseWrapper.ticketUrl = System.Label.History_Url+String.valueOf(
            ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId'));
            responseWrapper.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)ticket.get('fieldValues')
            ).get('notes')).get('stringValue'));
      } 
      responseWrapper.Id = Id;
      responseWrapper.bugafiberId = String.valueOf(
          ((Map<String,Object>)ticket.get('buganizerIssue')).get('issueId'));
      responseWrapper.type = type;
      responseWrapper.createdDate = String.valueOf(
          ((DateTime)JSON.deserialize('"' +String.valueOf(
          ((Map<String,Object>)ticket.get('buganizerIssue')).
          get('createdTime'))+ '"', DateTime.class)).format('MMM-dd-yyyy'));
      responseWrapper.createdDateFilter = (DateTime)JSON.deserialize('"' +String.valueOf(
          ((Map<String,Object>)ticket.get('buganizerIssue')).
          get('createdTime'))+ '"', DateTime.class);
      responseWrapper.children = childrenList;
    }
    return responseWrapper;
  }
  /*
   * @group ticket__c
   * @description createChildResponseWrapper method to generate child response wrapper
   * @param History_Action__c.
   * @return cls_children.
   */
  private static cls_children createChildResponseWrapper(History_Action__c actionTicket,
      Map<String,Object> issueTicket) {
    cls_children children = new cls_children();
    children.isChild = true;
    if (actionTicket != null && issueTicket != null) {
      children.isBuganizerTicket = true;
      children.Id = actionTicket.Ticket__c;
      children.bugafiberId = actionTicket.Ticket__r.Name;
      children.type = actionTicket.Type__c;
		children.symptom = actionTicket.Ticket__r.Symptom__c;
        if ( children.type !=null && children.Symptom != null){
		children.typeSymptom = actionTicket.Type__c+': '+actionTicket.Ticket__r.Symptom__c;
        } else{
            children.typeSymptom = actionTicket.Type__c;
        }
        if ('Issue'.equalsIgnoreCase(actionTicket.Type__c)) {
        children.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)issueTicket.get('fieldValues')
            ).get('sub type')).get('enumValue'))+'>'+String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)issueTicket.get('fieldValues')
            ).get('symptom')).get('stringValue'));
      } else {
        children.summary = String.valueOf(
            ((Map<String,Object>)((Map<String,Object>)issueTicket.get('fieldValues')
            ).get('sub type')).get('enumValue')) + '>' + String.valueOf(
            ((Map<String,Object>)issueTicket.get('fieldValues')
            ).get('cancellation reason'));
      }
      children.createdDate = String.isNotBlank(string.valueOf(
          actionTicket.Ticket__r.createdDate))?string.valueOf(
          actionTicket.Ticket__r.createdDate.format('MMM-dd-yyyy')):'';
      children.ticketUrl = '/'+actionTicket.Ticket__c;
    } else if (actionTicket.Ticket__c != null) {
      children.isBuganizerTicket = false;
      children.Id = actionTicket.Ticket__c;
      children.bugafiberId = actionTicket.Ticket__r.Name;
      children.type = actionTicket.Type__c;
		children.symptom = actionTicket.Ticket__r.Symptom__c;
		if ( children.type !=null && children.Symptom != null){
		children.typeSymptom = actionTicket.Type__c+': '+actionTicket.Ticket__r.Symptom__c;
        } else{
            children.typeSymptom = actionTicket.Type__c;
        }
      children.createdDate = String.isNotBlank(string.valueOf(
          actionTicket.Ticket__r.createdDate))?string.valueOf(
          actionTicket.Ticket__r.createdDate.format('MMM-dd-yyyy')):'';
      children.ticketUrl = '/'+actionTicket.Ticket__c;
      children.summary = actionTicket.Email_Subject__c;
    } else if (actionTicket.Order__c != null) {
      children.isBuganizerTicket = false;
      //children.Id = actionTicket.Order__r.Id;
      children.bugafiberId = actionTicket.Order__r.OrderNumber;
      children.type = actionTicket.Order__r.Type; 
      //actionTicket.Type__c;
      children.createdDate = String.isNotBlank(string.valueOf(
          actionTicket.Order__r.createdDate))?string.valueOf(
          actionTicket.Order__r.createdDate.format('MMM-dd-yyyy')):'';
      children.ticketUrl = '/'+actionTicket.Order__r.Id;
      children.summary = actionTicket.Order__r.Sub_Type__c+'>'+
          actionTicket.Order__r.vlocity_cmt__Reason__c;
    } else {
      children.isBuganizerTicket = false;
      children.Id = actionTicket.Id;
      children.bugafiberId = '';
      children.type = actionTicket.Type__c;
		children.symptom = actionTicket.Ticket__r.Symptom__c;
		if ( children.type !=null && children.Symptom != null){
		children.typeSymptom = actionTicket.Type__c+': '+actionTicket.Ticket__r.Symptom__c;
        } else{
            children.typeSymptom = actionTicket.Type__c;
        }
      children.createdDate = String.isNotBlank(string.valueOf(
          actionTicket.createdDate))?string.valueOf(
          actionTicket.createdDate.format('MMM-dd-yyyy')):'';
      children.ticketUrl = '/'+actionTicket.Id;
      children.summary = actionTicket.Email_Subject__c;
    }
    return children;
  }

  /*
   * @group Scheduling
   * @description US to Cancel service appointment in OFSC Part 2.
   * @param getAppointmentDetail Input to fetch the actual appointment details.
   * @param selected Input to create the reques for appointment cancellation.
   * @return appointment cancellation request using json generator in generateRequestJson method.
   */
  public static void getAFUType(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {
    AFU_Type__mdt AFUTypemdtRecord = new AFU_Type__mdt();
    if (String.isNotBlank(String.valueOf(input.get('AFUType')))) {
        AFUTypemdtRecord = [
            SELECT
              Id,
              Notes__c,
              Title__c
            FROM
              AFU_Type__mdt
            WHERE
              MasterLabel = :String.valueOf(input.get('AFUType'))
        ];
    outMap.put('AFUTypeNote',AFUTypemdtRecord.Notes__c);
    outMap.put('AFUTypeTitle',AFUTypemdtRecord.Title__c);
    }
  }

  /*
   * @group queryticket response Wrapper
   * @description Create a parent wrapper class to deserialie full response in expected manner.
   */
  @testVisible
  private class cls_historyResponseWrapperParent {
    public cls_historyResponseWrapper[] ticketResponse;
    public String pageToken;
    public String totalSize;
    public String pageSize;
  }
  /*
   * @group queryticket response Wrapper
   * @description Create a child wrapper class to return parent history action/event.
   */
  @testVisible
  private class cls_historyResponseWrapper {
    public cls_children[] children;
    public boolean isChild;
    public String Id;
    public String bugafiberId;
    public String type;
    public String createdDate;
    public DateTime createdDateFilter;
    public String ticketUrl;
    public String summary;
    public boolean isBuganizerTicket;
  }
  /*
   * @group queryticket response Wrapper
   * @description Create a child wrapper class to return child history action values.
   */
  @testVisible
  private class cls_children {
    public boolean isChild;
    public String type;
	 public String typeSymptom;
	 public String symptom;
    public String Id;
    public String bugafiberId;
    public String createdDate;
    public String ticketUrl;
    public String summary;
    public boolean isBuganizerTicket;
  }
  /*
   * @group queryticket response Wrapper
   * @description Create a wrapper to fetch filter values
   */
  @testVisible
  private class cls_type {
    public String value;
    public String level;
  }
}