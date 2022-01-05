public class ServiceTicketData {

  private static String userType = '';
  private static User userDetails;
  private final static List<String> PERMISSION_SET_NAMES =
      new List<String> {
        'Basic_Operation_Tickets',
        'Manage_Operation_Tickets',
        'Vendor_Operation_Tickets' };
  public ServiceTicketData() {
    userDetails = getLoggedInUseInfo();
  }
  private final static Map<String, String> FIELD_NAME_BY_FIELD_LABEL = new Map<String, String> {
    'address id' => 'addressId',
    'address' => 'fullAddress',
    'created time' => 'createdDate',
    'customer hardwired speed down' => 'customerHardwiredSpeed',
    'customer wireless primary location speed' => 'customerWirelessPrimaryLocationSpeed',
    'customer wireless secondary location speed' => 'customerWirelessSecondaryLocationSpeed',
    'directed work completed' => 'directedWorkCompleted',
    'fiberJack' => 'fiberJack',
    'fiber jack placement' => 'fiberJackPlacement',
    'fiber market' => 'fiberMarket',
    'fiber splice required'=> 'fiberSpliceRequired',
    'global address id' => 'globalAddressId',
    'modified time' => 'modifiedTime',
    'niu light level' => 'niuLightLevel',
    'ont light level' => 'ontLightLevel',
    'reran invisilight' => 'reRanInvisilight',
    'root cause' => 'cause',
    'RouterQuantity' => 'RouterQuantity',
    'service plan' => 'servicePlan',
    'service visit status' => 'serviceVisitStatus',
    'service appointment start' => 'appointmentDate',
    'sub type' => 'subType',
    'ticket id' => 'ticketId',
    'tech hardwired speed' => 'techHardwiredSpeed',
    'tech wireless secondary location speed' => 'techWirelessSecondaryLocationSpeed',
    'tech wireless speed' => 'techWirelessSpeed',
    'work type' => 'workType'
  };

  public class TicketDataWrapper {
    @AuraEnabled public String operationId;
    @AuraEnabled public String vendor;
    @AuraEnabled public String googleFiberMarket;
    @AuraEnabled public String technician;
    @AuraEnabled public long ticketId;
    @AuraEnabled public String accountId;
    @AuraEnabled public String orderId;
    @AuraEnabled public Datetime appointmentDate;
    @AuraEnabled public String accountStatus;
    @AuraEnabled public String appointmentType;
    @AuraEnabled public String servicePlan;
    @AuraEnabled public String status;
    @AuraEnabled public String customerId;
    @AuraEnabled public String address;
    @AuraEnabled public String ONT;
    @AuraEnabled public Decimal router;
    @AuraEnabled public String phone;
    @AuraEnabled public String userType;
    @AuraEnabled public Boolean noSalesforceRecordFound = true;
  }

  @AuraEnabled(cacheable = true)
  public static List<TicketDataWrapper> getAllTickets(String strMarket, String strSort) {
    User user = new User();
    for (PermissionSetAssignment permissionSetAssignment : [
        SELECT
          PermissionSet.Name,
          AssigneeId,
          Assignee.Name,
          Assignee.Fiber_Market__c,
          Assignee.Vendor__c,
          Assignee.Email
        FROM
          PermissionSetAssignment
        WHERE
          AssigneeId =:UserInfo.getUserId()
        AND
          PermissionSet.Name IN :PERMISSION_SET_NAMES
    ]) {
      if (permissionSetAssignment.PermissionSet.Name == 'Basic_Operation_Tickets') {
        userType = 'Basic';
        user.Email = permissionSetAssignment.Assignee.Email;
      } else if (permissionSetAssignment.PermissionSet.Name == 'Manage_Operation_Tickets') {
        userType = 'Manager';
      } else if (permissionSetAssignment.PermissionSet.Name == 'Vendor_Operation_Tickets') {
        userType = 'Vendor';
        user.Vendor__c = permissionSetAssignment.Assignee.Vendor__c;
        user.Fiber_Market__c = permissionSetAssignment.Assignee.Fiber_Market__c;
      }
    }
    HttpResponse ticketBuganizerData = makeGetCallout('',strMarket,user,userType);
      String jsonString = ticketBuganizerData.getBody();
      for (String fieldLabel : FIELD_NAME_BY_FIELD_LABEL.keySet()) {
        jsonString = jsonString.replace('"' + fieldLabel + '":',
        '"' + FIELD_NAME_BY_FIELD_LABEL.get(fieldLabel) + '":');
      }
      QueryTicketJSON deserialized;
      deserialized = (QueryTicketJSON)system.JSON.deserialize(jsonString, QueryTicketJSON.class);
      //Object jsonStringObject = JSON.deserialize(jsonString);

    Set<String> ticketRecordId = new Set<String>();
    List<TicketDataWrapper> ticketWrapper = new List<TicketDataWrapper>();
    Map<long, TicketDataWrapper> mapTicketDataWrapper = new Map<long, TicketDataWrapper>();
    for(Ticket record: deserialized.tickets){
      TicketDataWrapper ticketData = new TicketDataWrapper();
      ticketData.vendor = record.fieldValues.vendor.enumValue;
      ticketData.googleFiberMarket = record.fieldValues.fiberMarket.stringValue;
      ticketData.technician = record.fieldValues.assignee.stringValue;
      ticketData.ticketId = record.fieldValues.ticketId.integerValue;
      ticketRecordId.add(String.valueof(record.fieldValues.ticketId.integerValue));
      ticketData.appointmentDate = record.fieldValues.appointmentDate.timestampValue;
      ticketData.servicePlan = record.fieldValues.servicePlan.stringValue;
      mapTicketDataWrapper.put(ticketData.ticketId,ticketData);
      //ticketWrapper.add(ticketData);
    }
    //Set<String> strOperationId = (Set<String>)JSON.deserialize(JSON.serialize(mapTicketDataWrapper.keyset()), Set<String>.class);
    //System.debug(':::ticketRecordId::'+ticketRecordId);
    for (Operation_Ticket__x operationTicketRecord :[
        SELECT
          Id,
          Account__r.name,
          ExternalId,
          Address__c,
          Type__c,
          Vendor__c, Status__c, Service_Visit_Status__c,
          Service_Plan__c, Premises__c, Fiber_Market__c,
          Assignee__c, Appointment_Date__c, Order__c,Order__r.OrderNumber,
          Service_Account__r.name,Service_Account__r.vlocity_cmt__Status__c,
          Fiber_Jack__c, Router__c FROM Operation_Ticket__x]) {
          //System.debug(':::count::');
      TicketDataWrapper finalTicketData = new TicketDataWrapper();
      if(mapTicketDataWrapper.get(Integer.valueof(operationTicketRecord.ExternalId))!=null) {
        finalTicketData = mapTicketDataWrapper.get(integer.valueOf(operationTicketRecord.ExternalId));
        finalTicketData.accountId = operationTicketRecord.Service_Account__r.name;
        finalTicketData.orderId = operationTicketRecord.Order__r.OrderNumber;
        finalTicketData.accountStatus = operationTicketRecord.Service_Account__r.vlocity_cmt__Status__c;
        finalTicketData.customerId = operationTicketRecord.Account__r.name;
        finalTicketData.address = operationTicketRecord.Address__c;
        finalTicketData.ONT = operationTicketRecord.Fiber_Jack__c;
        finalTicketData.router = operationTicketRecord.Router__c;
        finalTicketData.operationId = operationTicketRecord.Id;
        finalTicketData.noSalesforceRecordFound = false;
        finalTicketData.userType = userType;
        ticketWrapper.add(finalTicketData);
        //System.debug(':::ticketWrapper::'+finalTicketData);
        //System.debug(':::ticketWrapperinside::'+ticketWrapper.size());
      }
    }
    for(Long rec: mapTicketDataWrapper.keySet()) {
      TicketDataWrapper finalTicketData = (TicketDataWrapper)mapTicketDataWrapper.get(rec);
      if(finalTicketData.noSalesforceRecordFound) {
        ticketWrapper.add(finalTicketData);
      }
    }
    //System.debug(':::ticketWrapper::'+ticketWrapper);
    return ticketWrapper;
  }
    /**
   * @description Method to make callout to external system.
   * @param url Endpoint URL.
   * @return Response of the callout.
   **/
  private static HttpResponse makeGetCallout(String sortValue, String marketValue, User user, String userType ) {
    String sortLabel;
    String querySort;
    String METHOD_NAME = 'makeGetCallout';
    String jsonBody = '';
    String queryFilter = Constants.BUGANIZER_TICKET.DEFAULT_FILTER;
    String queryOrder = querySort;//Constants.BUGANIZER_TICKET.DEFAULT_ORDER;
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:' + 'Generic/v1/bugafiber/querytickets');
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('GET');
    querySort = 'service appointment start: desc';
    queryOrder = querySort;

    //*************************

    if (userType == 'Basic') {
      queryFilter += ' assignee:' + user.Email;
      if (String.isNotBlank(marketValue)) {
        queryFilter += ' fiber market:' +marketValue;
      } 
      //queryOrder = querySort;
    } else if (userType == 'Vendor') {
      String vendorManagerTeamEmails = getVendorManagerTeamEmails();
      if (vendorManagerTeamEmails == '') {
        queryFilter += ' vendor:' + user.Vendor__c + ' fiber market:'
            + user.Fiber_Market__c;
        } else {
          queryFilter += ' vendor:' + user.Vendor__c + ' fiber market:'
              + user.Fiber_Market__c + ' assignee:(' + vendorManagerTeamEmails + ')';
        }
        queryOrder = querySort;
      } else if (userType == 'Manager') {
        if(String.isNotBlank(marketValue)) {
          queryFilter += ' fiber market:' +marketValue;
        } 
      }
      //*************************
      jsonBody = JSON.serialize(new Map<String, Object> {
        'orderBy' => (Object)queryOrder,
        'page_size' => (Object)15,
        'query' => (Object)queryFilter,
        'ticketFlowDefType' => (Object)'INSTALLATION_OPERATIONS'
      });
      req.setBody(jsonBody);
      Http http = new Http();
      HTTPResponse resp = http.send(req);
      try {
      //system.debug('!!!!!'+resp.getBody());
        return resp;
      } catch (Exception e) {
      LoggingUtility.insertExceptionLog('OperationTicketLandingPage', METHOD_NAME, e);
      throw e;
    }
  }
  public static User getLoggedInUseInfo() {
    User user = [
        SELECT
          Id,
          Email,
          ManagerId
        FROM
          User
        WHERE
          Id =:UserInfo.getUserId()
    ];
    
    for (PermissionSetAssignment permissionSetAssignment : [
        SELECT
          PermissionSet.Name,
          AssigneeId,
          Assignee.Name,
          Assignee.Fiber_Market__c,
          Assignee.Vendor__c,
          Assignee.Email
        FROM
          PermissionSetAssignment
        WHERE
          AssigneeId =:UserInfo.getUserId()
        AND
          PermissionSet.Name IN :PERMISSION_SET_NAMES ]) {
      if (permissionSetAssignment.PermissionSet.Name == 'Basic_Operation_Tickets') {
        userType = 'Basic';
        user.Email = permissionSetAssignment.Assignee.Email;
      } else if (permissionSetAssignment.PermissionSet.Name == 'Manage_Operation_Tickets') {
        userType = 'Manager';
      } else if (permissionSetAssignment.PermissionSet.Name == 'Vendor_Operation_Tickets') {
        userType = 'Vendor';
        user.Vendor__c = permissionSetAssignment.Assignee.Vendor__c;
        user.Fiber_Market__c = permissionSetAssignment.Assignee.Fiber_Market__c;
      }
    }
    return user;
  }
  public static String getVendorManagerTeamEmails() {
    String vendorManagerTeamEmails = '';
    for (User user : [
        SELECT
          Id,
          Email,
          ManagerId
        FROM
          User
        WHERE
          ManagerId =:UserInfo.getUserId()
    ]) {
      vendorManagerTeamEmails += vendorManagerTeamEmails != '' ? '|' + user.Email : user.Email;
    }
    return vendorManagerTeamEmails;
  }

  @AuraEnabled(cacheable = true)
  public static id getSalesforceId(String ticketId) {
    Operation_Ticket__x operationRecord = [SELECT id, ExternalId FROM Operation_Ticket__x where ExternalId =:ticketId];
    system.debug('operationRecord'+operationRecord);
    return operationRecord.Id;
  }
  public class QueryTicketJSON {
    @AuraEnabled public List<Ticket> tickets;
  }
  public class Ticket {
    @AuraEnabled public FieldValues fieldValues;
  }
  /**
  * @description Wrapper class to hold FieldValues details.
  */
  public class FieldValues {
    @AuraEnabled public IntegerWrap ticketId;
    @AuraEnabled public StringWrap addressId;
    @AuraEnabled public StringWrap assignee;
    @AuraEnabled public StringWrap fiberMarket;
    @AuraEnabled public TimeStampWrap appointmentDate;
    @AuraEnabled public StringWrap servicePlan;
    @AuraEnabled public EnumWrap serviceVisitStatus;
    @AuraEnabled public EnumWrap status;
    @AuraEnabled public EnumWrap vendor;
  }
  /**
  * @description Wrapper class to hold Enum Value.
  */
  public class EnumWrap{
    @AuraEnabled public String enumValue;
  }

 /**
  * @description Wrapper class to hold String Value.
  */
  public class StringWrap{
    @AuraEnabled public String stringValue;
  }

 /**
  * @description Wrapper class to hold Time Stamp Value.
  */
  public class TimeStampWrap {
    @AuraEnabled public DateTime timestampValue;
  }

 /**
  * @description Wrapper class to hold Integer Value.
  */
  public class IntegerWrap {
    @AuraEnabled public Integer integerValue;
  }
}