/**
* @group Constant
* @description This file includes the following:
* 1) Default Values for various SObject fields (under DEFAULT_VALUE)
* 2) Available Values for Picklist fields (under {SOBJECT}.{FIELD})
*
* The classes in this file should be listed in alphabetical order, by SObject
* and then Field, with the {SOBJECT}DefaultValue at the top (if applicable) and the
* generic {SOBJECT}Const at the end.
*
* General Use: Constants.{SOBJECT}.{FIELD}.{VALUE}
* Example: Constants.ACCOUNT.TYPE.CUSTOMER_ACCOUNT
*/
// TODO: This class will be cleaned up as other classes are submitted for review.
public class Constants {
  public final String PHONE = '5555555555';
  public final String EMAIL_VALUE = 'test@test.com';
  /* ***** Inner classes instances to access it's properties in static context ***** */
  public static AddressReviewControllerConsts ADDRESS = new AddressReviewControllerConsts();
  public static AddressServiceabilityConsts SERVICE = new AddressServiceabilityConsts();
  public static AssetStatusPicklistConsts ASSET = new AssetStatusPicklistConsts();
  public static BugafiberConst BUGAFIBER = new BugafiberConst();
  public static BuganizerTicketConts BUGANIZER_TICKET = new BuganizerTicketConts();
  public static CasesConsts CASES = new CasesConsts();
  public static FrlConsts FRL = new FrlConsts();
  public static GenericParameterConstant CONSTANT = new GenericParameterConstant();
  public static GeopointeConsts GEOPOINTE = new GeopointeConsts();
  public static HistoryEventConsts HISTORY_EVENT = new HistoryEventConsts();
  public static HistoryActionConsts HISTORY_ACTION = new HistoryActionConsts();
  public static KnowledgeArticleConsts KNOWLEDGE = new KnowledgeArticleConsts();
  public static LeadDefaultValuesConsts LEAD = new LeadDefaultValuesConsts();
  public static LoggingLevelConst LOGGING_LEVEL = new LoggingLevelConst();
  public static NotificationConstant NOTIFICATION = new NotificationConstant();
  public static OrderConsts ORDER = new OrderConsts();
  public static OrderItemConsts ORDER_ITEM = new OrderItemConsts();
  public static PremisesConsts PREMISES = new PremisesConsts();
  public static ProductConsts PRODUCT = new ProductConsts();
  public static ProductUtilityConsts PRODUCT_UTILITY = new ProductUtilityConsts();
  public static ProfileConsts PROFILE = new ProfileConsts();
  public static ServicePointConsts SERVICE_POINT = new ServicePointConsts();
  public static TaskConsts TASK = new TaskConsts();
  public static TicketDefaultValuesConsts TICKET = new TicketDefaultValuesConsts();
  public static XOMCalloutServiceConsts CALLOUT_SERVICE = new XOMCalloutServiceConsts();

  /**
  *  @group AddressReview
  *  @description It contains constants for Address Review Controller
  */

  public class AddressReviewController {
    public final String FAILURE_RESPONSE = 'Update failed';
    public final String OPEN_TICKET = 'OpenTicket';
    public final String SUCCESS_RESPONSE = 'Updated Successfully';
    public final String UPDATE_DOOR_KNOCK_COUNT = 'updateDoorKnockCountOnLeads';
  }

  /**
  *  @group AddressServiceability
  *  @description It contains constants for Address Serviceability
  */
  public class AddressServiceability {
    public final String ADDRESS_DEFINITION = 'AddressDefinition';
    public final String ADDRESS_ID = 'AddressId';
    public final String ADDRESS_SERVICE = 'AddressService';
    public final String CONTENT_TYPE = 'Content-Type';
    //public final String EMPTY_STRING = '';
    public final String REFERER = 'Referer';
    public final String SEARCH_ADDRESS = 'SearchAddress';
    public final String SMARTYSTREET = 'SmartyStreet';
    public final String TRUE_STR = 'true';
  }

  /**
  *  @group Asset
  *  @description It contains constants for Asset.Status
  */
  public class AssetStatusPicklist {
    public final String CONNECT = 'Connect';
    public final String DISCONNECT = 'Disconnect';
    public final String INACTIVE = 'Inactive';
  }

  /**
  *  @group bugafiber
  *  @description It contains constants for bugafiber request/response.
  */
  public class BugafiberConst {
    public final BugafiberTicketType TYPE = new BugafiberTicketType();
    public final BugafiberTicketTitle TITLE = new BugafiberTicketTitle();
    public final BugafiberTicketCode TICKET_CODE = new BugafiberTicketCode();
    public final BugafiberTicketStatus STATUS = new BugafiberTicketStatus();
  }

  /**
  *  @ bugafiber
  *  @description It contains constants for bugafiber ticket type.
  */
  public class BugafiberTicketType {
      public final String CONTACT = 'CS_CONTACT';
      public final String UPGRADE = 'Upgrade';
      public final String INSTALL = 'Install';
      public final String REPAIR = 'Repair';
  }

  /**
  *  @ bugafiber
  *  @description It contains constants for bugafiber ticket status.
  */
  public class BugafiberTicketStatus {
      public final String OPEN = 'Open';
      public final String RESOLVED = 'resolved';
  }

  /**
  *  @ bugafiber
  *  @description It contains constants for bugafiber ticket code.
  */
  public class BugafiberTicketCode {
      public final String CONTACT  ='CONTACT';
  }

  /**
  *  @ bugafiber
  *  @description It contains constants for bugafiber ticket title.
  */
  public class BugafiberTicketTitle {
      public final String INBOUND_CONTACT  ='Inbound Contact Ticket';
  }

  /**
  *  @ buganizer
  *  @description It contains constants for buganizer ticket table details.
  */
  public class BuganizerTicketTableDetails {
    public final String TABLE_NAME = 'Buganizer_Ticket';
    public final String TABLE_SINGULAR_LABEL = 'Buganizer Ticket';
    public final String TABLE_PLURAL_LABEL = 'Buganizer Tickets';
    public final String TABLE_DESCRIPTION = 'External Table for External Datasource';
  }
 /**
  *  @ buganizer
  *  @description It contains constants for buganizer details.
  */
  public class BuganizerTicketConts {
    public final String DEFAULT_FILTER =
        '(status:Open | resolved:1d) work type:(Upgrade|Install|Repair)';
    public final String DEFAULT_ORDER = 'issue_id: desc';
    public final BuganizerTicketTableDetails BUGANIZER_TICKET_TABLE_DETAILS =
        new BuganizerTicketTableDetails();
  }

  /**
  *  @group Case
  *  @description It contains constants for Case
  */
  public class CaseDefault {
    public final String SUBJECT = 'Lead created in progress status';
  }

  /**
  *  @group CasesConsts
  *  @description Instantiation for Cases
  */
  public class CasesConsts {
    public final Cases CASES = new Cases();
  }

  /**
  *  @group GenericParameter
  *  @description It contains constants for General Constant
  */
  public class GenericParameter {
  public final String ACTION_NAME = 'ActionName';
  public final String ADDRESS_SERVICE = 'AddressService';
  public final String PHONE_TYPE = 'Phone';
  public final String QUEUE = 'Queue';
  public final String RECORD_ID = 'Id';
  }

  /**
  *  @group Geopointe
  *  @description It contains constants for Geopointe Flow Parameters
  */
  public class GeopointeFlowParameters {
    public final String DISQUALIFIED = 'Disqualified';
    public final String IN_PROGRESS = 'InProgress';
    public final String NO_ANSWER = 'NoAnswer';
    public final String SIGNUP = 'SignUp';
  }

  /**
  * @group HistoryAction
  * @description History_Action__c.Type__c
  */
  public class HistoryActionType {
    public final String CUSTOMER_FOLLOW_UP = 'Customer Follow up';
    public final String CUSTOMER_INTERACTION = 'Customer Interaction';
    public final String CUSTOMER_NOT_INTERESTED = 'Customer Not Interested';
    public final String NO_ANSWER = 'No Answer';
    public final String NOTIFICATION = 'Notification';
    public final String SIGN_UP_LEAD = 'Sign-Up Lead';
    public final String RE_ENGAGE = 'Re-engage';
    public final String ISSUE = 'Issue';
  }

  /**
  * @group HistoryEvent
  * @description History_Event__c.Direction__c
  */
  public class HistoryEventDirection {
    public final String INBOUND = 'Inbound';
    public final String OUTBOUND = 'Outbound';
  }

  /**
  * @group HistoryEvent
  * @description History_Event__c.External_Ticket__c
  */
  public class HistoryEventExternalTicket {
    public final String TICKET_ID = '1234';
  }

  /**
  * @group HistoryEvent
  * @description It contains constants for History Event Status
  */
  public class HistoryEventStatus {
    public final String OPEN = 'Open';
    public final String CLOSE = 'Closed';
  }

  /**
  *  @group HistoryEvent
  *  @description It contains constants for History Event Type
  */
  public class HistoryEventType {
    public final String CALL_TYPE = 'Call';
    public final String CHAT_TYPE = 'Chat';
    public final String DOOR_TO_DOOR = 'Door to Door';
    public final String EMAIL = 'Email';
    public final String FIBER_SPACE = 'Fiber Space';
    public final String PHONE_TYPE = 'Phone';
    public final String INBOUND_CALL = 'Inbound call';
    public final String OUTBOUND_CALL = 'Outbound call';
    public final String SERVICE_VISIT = 'Service Visit';
    public final String SMS = 'SMS';
    public final String SOCIAL = 'Social';
  }

  /**
  *  @group KnowledgeArticle
  *  @description constants for Knowledge Article
  */
  public class KnowledgeArticle {
    public final String BILLING = 'Billing';
    public final String LOCATION_DETAILS = 'Location Details';
    public final String NETWORK_SETTINGS = 'Network Settings';
    public final String ORDERS = 'Orders';
    public final String OVERVIEW = 'Overview';
    public final String SERVICE_VISITS = 'Service Visits';
    public final String TROUBLESHOOTING = 'Troubleshooting';
  }

 /**
  *  @group System Notifications
  *  @description constants for Notification
  */
  public class NotificationConstant {
    public final NotificationBody BODY = new NotificationBody();
    public final NotificationClass NOTIFICATION_CLASS = new NotificationClass();
    public final NotificationType TYPE = new NotificationType();
  }

 /**
  *  @group System Notifications
  *  @description constants for Notification Type
  */
  public class NotificationType {
    public final String ACCOUNT = 'Account';
  }

 /**
  *  @group System Notifications
  *  @description constants for Notification Body
  */
  public class NotificationBody {
    public final String MULTIPLE_CONTACTS =
        'Customer has contacted us about this account multiple times recently';
  }

 /**
  *  @group System Notifications
  *  @description constants for Notification Class
  */
  public class NotificationClass {
    public final String NOTIFICATION_SYSTEM = 'System';
  }

  /**
  *  @group Order
  *  @description Order.Status
  */
  public class OrderStatus{
    public final String CANCELLED = 'Cancelled';
    public final String DRAFT = 'Draft';
    public final String IN_PROGRESS = 'In Progress';
    public final String READY_TO_SUBMIT = 'Ready to Submit';
    public final String SUPERSEDED = 'Superseded';  
  }

  /**
  *  @group OrderItem
  *  @description OrderItem.Status
  */
  public class OrderItemStatus {
    public final String SUSPENDED = 'Suspended';
  }

  /**
  *  @group OrderItem
  *  @description OrderItem.SubAction
  */
  public class OrderItemSubAction {
    public final String PAUSE= 'Pause';
  }

  /**
  *  @group OrderItem
  *  @description OrderItem.Action
  */
  public class OrderItemAction {
    public final String ADD = 'Add';
    public final String SUSPEND = 'Suspend';
  }

  /**
  *  @group Lead
  *  @description It contains constants for Lead
  */
  public class LeadDefaultValues {
    public final String ADDRESS_GENERATED = 'Address generated';
    public final String LEAD_DEFAULT_COMPANY = 'Unknown';
    public final String LEAD_DEFAULT_FIRSTNAME = 'Unknown';
    public final String LEAD_DEFAULT_LASTNAME = 'Unknown';
    public final String LEAD_DEFAULT_PHONE = 'Unknown';
    public final String SALES_QUEUE = 'Sales_Queue';
  }

  /**
  *  @group Lead
  *  @description It contains constants for Lead.How_The_Customer_Will_Signup__c
  */
  public class LeadHowCustomerWillSignUpPicklist {
    public final String ADMIN_PORTAL = 'Admin Portal';
  }

  /**
  *  @group Lead
  *  @description It contains constants for Lead Objection Reason
  */
  public class LeadObjectionReasonPicklist {
    public final String DOOR_SLAM_UNHUNG_UP = 'Door Slam/Hung Up';
    public final String EXISTING_CONTRACT = 'Existing contract';
    public final String FORCE_CANCELLATION = 'Force Cancellation';
    public final String HAPPY_WITH_CURRENT_PROVIDER = 'Happy with current provider';
    public final String INELIGIBLE_ADDRESS = 'Ineligible Address';
    public final String INSTALLATION_TIMEFRAME = 'Installation timeframe';
    public final String MOVING_SOON = 'Moving soon';
    public final String NEEDS_MORE_TIME = 'Needs more time';
    public final String NON_DECISION_MAKER = 'Non-decision maker';
    public final String PAYMENT_METHOD = 'Payment method';
    public final String PENDING_ADDRESS = 'Pending Address Review';
    public final String PREVIOUS_POOR_EXPERIENCE_WITH_FIBER = 'Previous poor experience with Fiber';
    public final String PRICE = 'Price';
    public final String PRODUCT = 'Product';
    public final String UNHAPPY_WITH_CONSTRUCTION = 'Unhappy with Construction';
    public final String UNRESPONSIVE_IN_CHATS = 'Unresponsive in Chat';
    public final String VACANT = 'Vacant';
  }

  /**
  *  @group Lead
  *  @description It contains constants for Lead Record Type
  */
  public class LeadRecordType {
    public final String CUSTOMER_LEAD = 'Customer_Lead';
  }

  /**
  *  @group Lead
  *  @description It contains constants for Lead Source
  */
  public class LeadSourcePicklist {
    public final String ADDRESS_REVIEW = 'Address Review';
    public final String ADDRESS_SERVICEABLE = 'Address Service';
  }

  /**
  *  @group Lead
  *  @description It contains constants for Lead Status
  */
  public class LeadStatusPicklist {
    public final String CONVERTED = 'Converted';
    public final String DISQUALIFIED = 'Disqualified';
    public final String IN_PROGRESS = 'In Progress';
    public final String ON_HOLD = 'On Hold';
    public final String STATUS_NEW = 'New';
  }

  /**
  *  @group Lead
  *  @description It contains constants for Lead Sub Status
  */
  public class LeadSubStatusPicklist {
    public final String ADDRESS_ISSUE = 'Address Issue';
    public final String ATTEMPTED_CONTACT = 'Attempted Contact';
    public final String DO_NOT_CONTACT = 'Do Not Contact';
    public final String EXPRESSION_INTEREST = 'Expression of Interest';
    public final String NEEDS_FOLLOW_UP = 'Needs Follow Up';
    public final String NOT_INTERESTED = 'Not Interested';
    public final String PENDING_SIGNUP = 'Pending Signup';
    public final String PITCH_MADE = 'Pitch Made';
    public final String PRE_REGISTERED = 'Pre-Registered';
    public final String PENDING_PROOF_OF_RESIDENCE = 'Pending Proof of Residence';
    public final String READY_FOR_CONTACT = 'Ready for Contact';
    public final String VACANT = 'Vacant';
  }

  /**
  * @group Logging Level
  * @description Logging_Level__c.Level__c
  */
  public class LoggingLevelLevel {
    public final String LOG_SETTING = 'Default';
  }

  /**
  *  @group Premises
  *  @description It contains constants for Premises Status
  */
  public class PremisesStatusPicklist {
    public final String NOT_SERVICEABLE = 'Not Serviceable';
    public final String SERVICEABLE = 'Serviceable';
    public final String SUBMITTED_FOR_REVIEW = 'Submitted for Review';
    public final String UNVALIDATED = 'Unvalidated';
  }

  /**
  *  @group Profile
  *  @description It contains constants for Profile Name
  */
  public class ProfileName {
    public final String TECHNICIAN = 'Technician';
  }

  /**
  *  @group Task
  *  @description It contains constants for Tasks Type
  */
  public class TasksTypePicklist {
    public final String FOLLOW_UP_CALL = 'Follow up call';
  }

  /**
  *  @group Ticket
  *  @description It contains constants for Ticket Status
  */
  public class TicketStatusPicklist {
    public final String OPEN = 'Open';
    public final String RESOLVED = 'Resolved';//TicketType
  }

  /**
  *  @group Ticket
  *  @description It contains constants for Ticket Status
  */
  public class TicketType {
    public final String ADDRESS_REVIEW = 'Address Review';
  }

  /**
  *  @group AddressReview
  *  @description Instantiation for Address Review Controller
  */
  public class AddressReviewControllerConsts {
    public final AddressReviewController REVIEW = new AddressReviewController();
  }

  /**
  *  @group AddressServiceabilityConsts
  *  @description Instantiation for Address Servicablity
  */
  public class AddressServiceabilityConsts {
    public final AddressServiceability ADDRESS = new AddressServiceability();
  }

  /**
  *  @group AssetStatusPicklistConsts
  *  @description Instantiation for Asset Status Picklist
  */
  public class AssetStatusPicklistConsts {
    public final AssetStatusPicklist STATUS = new AssetStatusPicklist();
  }

  /**
  *  @group GeneralConstantConsts
  *  @description Instantiation for General Constant
  */
  public class GenericParameterConstant {
    public final GenericParameter Constant = new GenericParameter();
  }

  /**
  *  @group GeopointeConsts
  *  @description Instantiation for Geopointe
  */
  public class GeopointeConsts {
    public final GeopointeFlowParameters GEOPOINTE = new GeopointeFlowParameters();
  }

  /**
  * @group HistoryAction
  * @description Instantiation for History Action
  */
  public class HistoryActionConsts {
    public final HistoryActionType TYPE = new HistoryActionType();
  }

  /**
  * @group HistoryEventConsts
  * @description Instantiation for History Event
  */
  public class HistoryEventConsts {
    public final HistoryEventDirection DIRECTION = new HistoryEventDirection();
    public final HistoryEventStatus STATUS = new HistoryEventStatus();
    public final HistoryEventType TYPE = new HistoryEventType();
    public final HistoryEventExternalTicket TICKET = new HistoryEventExternalTicket();
    public final String ExternalTicketId='205524227';
  }

  /**
  *  @group Knowledge Article
  *  @description Instantiation for Article
  */
  public class KnowledgeArticleConsts {
    public final KnowledgeArticle ARTICLE = new KnowledgeArticle();
  }

  /**
  *  @group PremisesConsts
  *  @description Instantiation for Premises
  */
  public class PremisesConsts {
    public final PremisesStatusPicklist STATUS = new PremisesStatusPicklist();
  }

  /**
  *  @group ProfileConsts
  *  @description Instantiation for Profile
  */
  public class ProfileConsts {
    public final ProfileName NAME = new ProfileName();
  }

  /**
  *  @group LeadConsts
  *  @description Instantiation for Lead
  */
  public class LeadDefaultValuesConsts {
    public final LeadHowCustomerWillSignUpPicklist SIGN_UP =
        new LeadHowCustomerWillSignUpPicklist();
    public final LeadObjectionReasonPicklist OBJECTION_REASON = new LeadObjectionReasonPicklist();
    public final LeadSourcePicklist LEAD_SOURCE = new LeadSourcePicklist();
    public final LeadStatusPicklist STATUS = new LeadStatusPicklist();
    public final LeadSubStatusPicklist SUB_STATUS = new LeadSubStatusPicklist();
    public final LeadRecordType RECORDTYPE = new LeadRecordType();
    public final LeadDefaultValues DEFAULT_VALUES = new LeadDefaultValues();
  }

  /**
  * @group Logging Level
  * @description Logging_Level__c
  */
  public class LoggingLevelConst {
    public final LoggingLevelLevel LEVEL = new LoggingLevelLevel();
  }

  /**
  *  @group OrderConsts
  *  @description Instantiation for Order
  */
  public class OrderConsts {
    public final OrderStatus STATUS = new OrderStatus();
  }

 /**
  *  @group OrderConsts
  *  @description Instantiation for OrderItem
  */
  public class OrderItemConsts {
    public final OrderItemStatus STATUS = new OrderItemStatus();
    public final OrderItemAction ACTION = new OrderItemAction();
    public final OrderItemSubAction SUBACTION = new OrderItemSubAction();
  }

  /**
  *  @group TaskConsts
  *  @description Instantiation for Task
  */
  public class TaskConsts {
    public final TasksTypePicklist TYPES = new TasksTypePicklist();
  }

  /**
  *  @group TicketConsts
  *  @description Instantiation for Ticket
  */
  public class TicketDefaultValuesConsts {
    public final TicketStatusPicklist STATUS = new TicketStatusPicklist();
    public final TicketType Type = New TicketType();
    public final String Name = '204975966';
  }

  /**
   * @group XOMCalloutServiceConsts
   * @description Contains constants for XOM_CalloutService and XOM_CalloutServiceTest
  */
  public class XOMCalloutServiceConsts {
    public final String CLASS_NAME = 'XOM_CalloutService';
    public final String PROCESS_IP_METHOD = 'processIPResponse';
    public final String API_RESPONSE_ERROR_MESSAGE = 'API Callout Response is unsuccessfull';
    public final String EXECUTE_ITEM_METHOD = 'executeItem';
    public final String IP_BLANK_MESSAGE = 'Integration Procedure name is not provided';
    public final String INTEGRATION_PROCEDURE_METHOD = 'invokeIntegrationProcedure';
    public final String API_RESPONSE_NODE_KEY = 'APIResponse';
    public final String ACCOUNT_ID_KEY = 'accountId';
    public final String ORDER_ID_KEY = 'orderId';
    public final String ORCH_ITEM_ID_KEY = 'orchestrationItemId';
    public final String ORCH_ITEM_NAME_KEY = 'orchestrationItemName';
    public final String ORCH_PLAN_ID_KEY = 'orchestrationPlanId';
    public final String IP_NAME_KEY = 'integrationProcedureName';
    public final String SUCCESS_KEY = 'success';
    public final String VALID_ORCH_ITME = 'TestValidItem';
    public final String INVALID_ORCH_ITME = 'TestInvalidItem';
  }

  /**
   * @group ProductUtilityConsts
   * @description Contains constants for ProductUtility and ProductUtilityTest
   */
  public class ProductUtilityConsts {
    public final String GET_PRODUCT_CODE_BY_LEGACY_CODE_METHOD = 'getProductCodeByLegacyCode';
    public final String UPDATE_CHILD_PRODUCT_DETAILS_METHOD = 'updateChildProductDetails';
    public final Integer DEFAULT_PRODUCT_GROUP_INDEX = 0;
  }
  /* @group ProductConsts
   * @description Instantiation for Product
   */
  public Class ProductConsts {
    public final ProductCode PRODUCT_CODE = new ProductCode();
    public final ProductTypePicklist TYPE = new ProductTypePicklist();
    public final ProductSubTypePicklist SUB_TYPE =
        new ProductSubTypePicklist();
  }
  /*
   * @group Order
   * @description PRODUCT.PRODUCT_CODE
   */
  public class ProductCode {
    public final String GOOGLE_WIFI = 'Google Wifi';
    public final String MULTI_GIG_ROUTER = 'Multi-Gig Router';
    public final String NETWORK_BOX = 'Network Box';
    public final String OFR_EQUIP_GWIFI = 'OFR_Equip_GWifi';
    public final String PRD_FBR_INTERNET = 'PRD_FBR_Internet';
    public final String SVE_BILLING = 'SVE_Billing';
  }
  /* @group FulfilmentRequestLine
   * @description Instantiation for vlocity_cmt__FulfilmentRequestLine__c
   */
  public Class FrlConsts {
    public final FrlFulfilmentStatus FULFILMENT_STATUS = new FrlFulfilmentStatus();
    public final FrlAction ACTION = new FrlAction();
    public final FrlAsyncTransactionStatusPicklist ASYNC_TRANSACTION_STATUS =
        new FrlAsyncTransactionStatusPicklist();
  }
  /*
   * @group FulfilmentRequestLine
   * @description vlocity_cmt__FulfilmentRequestLine__c.vlocity_cmt__FulfilmentStatus__c
   */
  public class FrlFulfilmentStatus {
        public final String IN_PROGRESS = 'In Progress';
  }
  /*
   * @group FulfilmentRequestLine
   * @description vlocity_cmt__FulfilmentRequestLine__c.vlocity_cmt__Action__c
   */
  public class FrlAction {
    public final String DISCONNECT = 'Disconnect';
  }

  /**
   * @group FulfilmentRequestLine
   * @description vlocity_cmt__FulfilmentRequestLine__c.Async_Transaction_Status__c
   */
  public class FrlAsyncTransactionStatusPicklist {
    public final String E911_COMPLETE = 'E911 Complete';
    public final String E911_IN_PROGRESS = 'E911 In Progress';
    public final String PORTIN_COMPLETE = 'Port-in Complete';
    public final String PORTIN_IN_PROGRESS = 'Port-in In Progress';
  }

  /**
   * @group Product2
   * @description Product2.vlocity_cmt__SubType__c
   */
  public class ProductSubTypePicklist {
    public final String ONT = 'ONT';
    public final String PROFESSIONAL_INSTALL = 'Professional Installation';
  }

  /**
   * @group Product2
   * @description Product2.vlocity_cmt__Type__c
   */
  public class ProductTypePicklist {
    public final String EQUIPMENT = 'Equipment';
  }

  /**
   * @group ServicePoint
   * @description Instantiation for vlocity_cmt__ServicePoint__c
   */
  public class ServicePointConsts {
    public final ServicePointStatusPicklist STATUS =
        new ServicePointStatusPicklist();
    public final ServicePointNetworkTerminalTypePicklist NETWORK_TERMINAL_TYPE =
        new ServicePointNetworkTerminalTypePicklist();
  }

  /**
   * @group ServicePoint
   * @description vlocity_cmt__ServicePoint__c.vlocity_cmt__Status__c
   */
  public class ServicePointStatusPicklist {
    public final String CONNECTED = 'Connected';
  }

  /**
   * @group ServicePoint
   * @description vlocity_cmt__ServicePoint__c.Network_Terminal_Type__c
   */
  public class ServicePointNetworkTerminalTypePicklist {
    public final String FIBER_JACK = 'Fiber Jack';
    public final String OPTICAL_CONNECTOR = 'Optical Connector';
  }

}