/*
*  @group TestClass-TicketingUtils
*  @description Test class for TicketingUtils to improve code coverage.
*/
@isTest
public class TicketingUtilsTest {
  /**
   * @description To cover the request creation with installation type node
  * @param NA
  * @return requestBody without installation type node
  */
  @isTest
  public static void cancelAppointmentRequestShouldReplaceInstallWithInstallation(){
    Map<String,Object> input = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    StaticResource staticResourceValue = [ SELECT Id, Body FROM StaticResource WHERE
        Name = 'CancelAppointmentInstallRequest' LIMIT 1 ];
    String inputStr = staticResourceValue.Body.toString();
    input = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
    TicketingUtils cancelAppointmentRequest =
        new TicketingUtils();
    cancelAppointmentRequest.invokeMethod('cancelAppointmentRequest',input,outMap,options);
    String response = String.valueOf(outMap.get('sequenceResponse'));
    System.assertEquals(true,String.valueOf(
        ((Map<String,Object>)(outMap.get('sequenceResponse'))).get('appointmentType')
        ).contains('installation'));
  }
  
  /**
   * @description To cover the request creation without installation type node
   * @param NA
   * @return requestBody without installation type node
   */
  @isTest
  public static void cancelAppointmentRequestShouldNotReplaceRepairWithInstallation(){
    Map<String,Object> input = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    StaticResource staticResourceValue = [ SELECT Id, Body FROM StaticResource WHERE
        Name = 'CancelAppointmentRepairRequest' LIMIT 1 ];
    String inputStr = staticResourceValue.Body.toString();
    input = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
    TicketingUtils cancelAppointmentRequest =
        new TicketingUtils();
    cancelAppointmentRequest.invokeMethod('cancelAppointmentRequest',input,outMap,options);
    String response = String.valueOf(outMap.get('details'));
    System.assertEquals(false,String.valueOf(
        ((Map<String,Object>)(outMap.get('sequenceResponse'))).get('appointmentType')
        ).contains('installation'));
  }
  
  /**
   * @description To cover the To cover empty paramer value
   * @param NA
   * @return null requestBody
   */
  @isTest
  public static void cancelAppointmentBlankRequestShouldReturnBlank(){
    Map<String,Object> input = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    StaticResource staticResourceValue = [ SELECT Id, Body FROM StaticResource WHERE
        Name = 'CancelAppointmentBlankRequest' LIMIT 1 ];
    String inputStr = staticResourceValue.Body.toString();
    input = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
    TicketingUtils cancelAppointmentRequest =
        new TicketingUtils();
    cancelAppointmentRequest.invokeMethod('cancelAppointmentRequest',input,outMap,options);
    String response = String.valueOf(outMap.get('details'));
    System.assertEquals(true,String.isBlank(String.valueOf(outMap.get('sequenceResponse'))));
  }

  /**
  * @description this test method validates if the Validate key follows
  * the expected formation rules.
  */
  @isTest
  static void ticketIdShouldReturnWorklogTemplate() {
    Worklog_Template__mdt workTemplate = [
        SELECT
          MasterLabel,
          Template__c
        FROM
          Worklog_Template__mdt
        LIMIT 1
    ];

    Operation_Ticket__x mockOperationTicket = new Operation_Ticket__x (
        Type__c = workTemplate.MasterLabel
    );
    TicketingUtils.mockedRequests.add(mockOperationTicket);
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    String methodName = 'getWorklogTemplate';
    inputMap.put('ticketId','FAKE_ID');

    TicketingUtils worklog = new TicketingUtils();
    Test.startTest();
      worklog.invokeMethod(methodName, inputMap, outMap, optionsMap);
      List<Map<String, Object>> ticketMasterLabelList =
          (List<Map<String, Object>>)outMap.get('options');
    Test.stopTest();
    Map<String, String> allOptionsMap = new Map<String, String>();
    for(Map<String, Object> options : ticketMasterLabelList){
          allOptionsMap.put((String)options.get('masterLabel'),(String)options.get('value'));
    }
    System.assertEquals(true,
        allOptionsMap.containsKey(workTemplate.MasterLabel),
          methodName+' should return masterlabel by criteria');
  }

   /**
   * @description This is the method to check the MasterLabel of worklog metadata.
   */
  @isTest
  private static void labelNameShouldReturnWorklogTemplate() {

    Worklog_Template__mdt worklogTemplatControllerMetaData = [
        SELECT
          MasterLabel
        FROM
          Worklog_Template__mdt
        LIMIT 1
    ];
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    String methodName = 'populateTemplates';
    TicketingUtils template = new TicketingUtils();
    Test.StartTest();
      template.invokeMethod(methodName, inputMap, outMap, optionsMap);
      List<Map<String, Object>> templateList =
          (List<Map<String, Object>>)outMap.get('options');
    Test.stopTest();
    Map<String, String> allOptionsMap = new Map<String, String>();
    for(Map<String, Object> options : templateList){
          allOptionsMap.put((String)options.get('label'),(String)options.get('value'));
    }
    System.assertEquals(true,
        allOptionsMap.containsKey(worklogTemplatControllerMetaData.MasterLabel),
          methodName+' should return template labels by criteria');
  }
  
  /**
   * @description To cover the HistoryAction and HistoryEvent based on typeAttribute != null &&
   * category == 'Action' value
   * @param NA
   * @return HistoryEvent and HistoryAction record
   */
   // positive test
  @isTest
  public static void getIssueTicketShouldFetchAllHistoryEventWithFilterValue() {
    Operation_Ticket__x mockOperationTicket = new Operation_Ticket__x (
        ExternalId = '202583921 '
    );
    TicketingUtils.mockedTicketResponse = mockOperationTicket;
     // Create Account Record
    Account objectAccount = TestDataFactory.getAccountData();
    insert objectAccount;
    // Create History Event Record
    History_Event__c history = TestDataFactory.getHistoryEventData();
    history.External_Ticket__c = '202592700';
    history.Account__c = objectAccount.Id;
    insert history;
    // Create Serive Visit History Event Record
    History_Event__c serviceVisitHistory = TestDataFactory.getHistoryEventData();
    serviceVisitHistory.External_Ticket__c = '202583921';
    //serviceVisitHistory.Type__c = 'Service Visit';
    serviceVisitHistory.Account__c = objectAccount.Id;
    insert serviceVisitHistory;
    // Create StandAlone History Event Record
    History_Event__c StandAloneHistory = TestDataFactory.getHistoryEventData();
    StandAloneHistory.External_Ticket__c = '402583921';
    StandAloneHistory.Account__c = objectAccount.Id;
    insert StandAloneHistory;
    // Create Ticket Record
    Ticket__c ticket = TestDataFactory.getTicketData();
    ticket.Account__c = objectAccount.Id;
    ticket.Name = '202588261';
    insert ticket;
    Ticket__c ticketTwo = TestDataFactory.getTicketData();
    ticketTwo.Account__c = objectAccount.Id;
    ticketTwo.Name = '202587897';
    insert ticketTwo;
    // Create History Action Record
    History_Action__c historyAction = TestDataFactory.getHistoryActionData(
        history.Id,null);
    historyAction.Ticket__c = ticket.Id;
    insert historyAction;
    // Create History Action Record withaout event
    History_Action__c historyActionNoEvent = TestDataFactory.getHistoryActionData(
        null,null);
    historyActionNoEvent.Ticket__c = ticket.Id;
    historyActionNoEvent.Type__c = 'Door to Door';
    insert historyActionNoEvent;
    // Create History Action Record withaout Order/Ticket
    History_Action__c historyActionNoOrderTciket = TestDataFactory.getHistoryActionData(
        StandAloneHistory.Id,null);
    historyActionNoOrderTciket.Order__c = null;
    historyActionNoOrderTciket.Ticket__c = null;
    historyActionNoOrderTciket.Type__c = 'Notification';
        StaticResource staticResourceValue = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'HistoryEventResponse'
        LIMIT 1];
   String inputStr = staticResourceValue.Body.toString();
   Map<String,Object> input = new Map<String,Object>();
   Map<String,Object> outMap = new Map<String,Object>();
   Map<String,Object> options = new Map<String,Object>();
   List<String> filterList = new List<String>();
   input = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
   input.put('accountId',objectAccount.Id);
   TicketingUtils historyEventAction = new TicketingUtils();
   //List to store input filter value
   List<Object> typeFilterList =  (List<Object>)input.get('type');
   for(Object typeFilter : typeFilterList){
     Map<String,Object> filterMap = (Map<String,Object>)typeFilter;
     filterList.add(String.valueOf(filterMap.get('value')));
   }
   Test.startTest();
   historyEventAction.invokeMethod('extractHistory',input,outMap,options);
   Test.stopTest();
   String response = String.valueOf(outMap.get('allIssueTicketList'));
   Map<String,Object> detailsResponse = (Map<String,Object>)
       JSON.deserializeUntyped(response);
   //check if input filter is working
   System.AssertEquals(true,filterList.contains(String.valueOf(
       ((Map<String,Object>)((List<Object>)detailsResponse.get('ticketResponse'))[3]
       ).get('type'))));
   System.assertEquals(true,String.isnotBlank(String.valueOf(
       detailsResponse.get('ticketResponse'))));
  }
  
  /**
   * @description To cover the HistoryAction and HistoryEvent based on accountId != null &&
   * @param NA
   * @return HistoryEvent and HistoryAction record
   */
   // positive test
  @isTest
  public static void getIssueTicketShouldFetchAllHistoryEventMappedWithAccountId() {
     // Create Account Record
    Account objectAccount = TestDataFactory.getAccountData();
    insert objectAccount;
    // Create Order Record
    Order objectOrder = TestDataFactory.getOrderData(objectAccount.Id);
    insert objectOrder;
    // Create History Event Record
    History_Event__c history = TestDataFactory.getHistoryEventData();
    history.External_Ticket__c = '202592700';
    history.Account__c = objectAccount.Id;
    insert history;
    // Create StandAlone History Event Record
    History_Event__c StandAloneHistoryOne = TestDataFactory.getHistoryEventData();
    StandAloneHistoryOne.External_Ticket__c = '462583921';
    StandAloneHistoryOne.Account__c = objectAccount.Id;
    insert StandAloneHistoryOne;
    // Create Ticket Record
    Ticket__c ticketThree = TestDataFactory.getTicketData();
    ticketThree.Account__c = objectAccount.Id;
    ticketThree.Name = '212587897';
    insert ticketThree;
    // Create History Action Record with Ticket==null for StandAloneHistory
    History_Action__c historyActionWithNoTicketValue = TestDataFactory.getHistoryActionData(
        StandAloneHistoryOne.Id,null);
    historyActionWithNoTicketValue.Ticket__c = null;
    historyActionWithNoTicketValue.Order__c = null;
    historyActionWithNoTicketValue.Type__c = 'Issue';
    insert historyActionWithNoTicketValue;
    // Create History Action Record withaout event
    History_Action__c historyActionNoEvent = TestDataFactory.getHistoryActionData(
        null,null);
    historyActionNoEvent.Ticket__c = ticketThree.Id;
    historyActionNoEvent.Type__c = 'Door to Door';
    insert historyActionNoEvent;
    // Create History Action Record with Ticket!=null for StandAloneHistory
    History_Action__c historyActionWithTicketValue = TestDataFactory.getHistoryActionData(
        StandAloneHistoryOne.Id,null);
    historyActionWithTicketValue.Ticket__c = ticketThree.Id;
    historyActionWithTicketValue.Type__c = 'Issue';
    insert historyActionWithTicketValue;
    // Create History Action Record with Ticket!=null for StandAloneHistory
    History_Action__c historyActionWithOrderValue = TestDataFactory.getHistoryActionData(
        StandAloneHistoryOne.Id,null);
    historyActionWithOrderValue.Order__c = objectOrder.Id;
    historyActionWithOrderValue.Type__c = 'Issue';
    insert historyActionWithOrderValue;
        StaticResource staticResourceValue = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'HistoryEventResponseWithoutFilter'
        LIMIT 1];
    String inputStr = staticResourceValue.Body.toString();
    Map<String,Object> input = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    List<String> filterList = new List<String>();
    input = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
    input.put('accountId',objectAccount.Id);
    TicketingUtils historyEventAction = new TicketingUtils();
    Test.startTest();
    historyEventAction.invokeMethod('extractHistory',input,outMap,options);
    Test.stopTest();
    String response = String.valueOf(outMap.get('allIssueTicketList'));
    Map<String,Object> detailsResponse = (Map<String,Object>)
        JSON.deserializeUntyped(response);
    //check if Output ticketResponse is not blank
    System.assertEquals(true,String.isnotBlank(String.valueOf(
        detailsResponse.get('ticketResponse'))));
    //check if summary is not blank in Output ticketResponse
    System.AssertEquals(true,String.isNotBlank(String.valueOf(
        ((Map<String,Object>)((List<Object>)detailsResponse.get('ticketResponse'))[1]
        ).get('summary'))));
    //check if ticketUrl is not blank in Output ticketResponse
    System.AssertEquals(true,String.isNotBlank(String.valueOf(
        ((Map<String,Object>)((List<Object>)detailsResponse.get('ticketResponse'))[1]
        ).get('ticketUrl'))));
  }
  
  /**
   * @description To cover the HistoryAction and HistoryEvent based on leadId != null &&
   * category == 'Action' value
   * @param NA
   * @return HistoryEvent and HistoryAction record
   */
   // positive test
  @isTest
  public static void getIssueTicketShouldFetchAllHistoryEventMappedWithWithLeadId() {
    //Create Lead Record
    Lead objectLead = TestDataFactory.getLeadData();
    insert objectLead;
    // Create StandAlone History Event Record
    History_Event__c StandAloneHistoryOne = TestDataFactory.getHistoryEventData();
    StandAloneHistoryOne.External_Ticket__c = '462583921';
    StandAloneHistoryOne.Lead__c = objectLead.Id;
    insert StandAloneHistoryOne;
    // Create History Action Record with Ticket==null for StandAloneHistory
    History_Action__c historyActionWithNoTicketValue = TestDataFactory.getHistoryActionData(
        StandAloneHistoryOne.Id,null);
    historyActionWithNoTicketValue.Ticket__c = null;
    historyActionWithNoTicketValue.Order__c = null;
    historyActionWithNoTicketValue.Type__c = 'Issue';
    insert historyActionWithNoTicketValue;
        StaticResource staticResourceValue = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'HistoryEventResponseWithoutFilter'
        LIMIT 1];
    String inputStr = staticResourceValue.Body.toString();
    Map<String,Object> input = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    List<String> filterList = new List<String>();
    input = (Map<String,Object>)JSON.deserializeuntyped(inputStr);
    input.put('leadId',objectLead.Id);
    TicketingUtils historyEventAction = new TicketingUtils();
    Test.startTest();
    historyEventAction.invokeMethod('extractHistory',input,outMap,options);
    Test.stopTest();
    String response = String.valueOf(outMap.get('allIssueTicketList'));
    Map<String,Object> detailsResponse = (Map<String,Object>)
        JSON.deserializeUntyped(response);
    //check if Output ticketResponse is not blank
    System.assertEquals(true,String.isnotBlank(String.valueOf(
        detailsResponse.get('ticketResponse'))));
    //check if summary is not blank in Output ticketResponse
    System.AssertEquals(true,String.isNotBlank(String.valueOf(
        ((Map<String,Object>)((List<Object>)detailsResponse.get('ticketResponse'))[0]
        ).get('summary'))));
    //check if ticketUrl is not blank in Output ticketResponse
    System.AssertEquals(true,String.isNotBlank(String.valueOf(
        ((Map<String,Object>)((List<Object>)detailsResponse.get('ticketResponse'))[0]
        ).get('ticketUrl'))));
  }
}