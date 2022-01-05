public class MxUConstants {
  public class Opportunity_Stage {
    public final String DEAL_WON = '4 - Deal Won';
    public final String PENDING_CONTRACT =
        '3 - Pending Contract';
    public final String SURVEY_REQUESTED =
        '2 - Survey / Design Requested';
    public final String PITCH = '1 - Pitch';
    public final String OPEN = '0 - Open';
    public final String DISQUALIFIED = 'Disqualified';
    public final String TERMINATION_BY_OWNER = 'Termination Requested by Owner';
    public final String TERMINATION_BY_GOOGLE_FIBER = 'Termination Requested by Google Fiber';
    public final Set<String> INACTIVE_STAGES = new Set<String> {
        TERMINATION_BY_OWNER,
        TERMINATION_BY_GOOGLE_FIBER,
        'Terminated',
        DISQUALIFIED
    };
  }

  public class Opportunity_SubStatus {
    public final String PAUSED = 'Paused';
    public final String BUILD_METHOD_CHANGE = 'Build method change';
    public final String DEAL_FOLDER_APPROVED = 'Deal Folder approved, out for signature';
    public final String SIGNED_AA_RECEIVED = 'Signed AA received, awaiting countersignature';
  }

  public class Opportunity_DateTermInitiatesOnPicklist {
    public final String EFFECTIVE_DATE = 'Effective Date';
    public final String IRU_DATE = 'IRU Date';
  }

  public class Opportunity_NameSuffix {
    public final String FIBER = ' - Fiber';
    public final String WEBPASS = ' - Webpass';
    public final String DAF = ' - DAF';
  }

  public class Opportunity_MarketingExclusivity {
    public final String YES = 'Yes';
    public final String NO = 'No';
  }

  public class Opportunity_DafSigned {
    public final String YES = 'Yes';
    public final String NO = 'No';
    public final String NA = 'N/A';
  }

  public class Opportunity_ContractType {
    public final String DAF = 'DAF';
    public final String MDU_AA_SHORT_FORM = 'MDU AA - Short Form';
    public final String MTU_AA_SHORT_FORM = 'MTU AA - Short Form';
    public final String MTU_AA_RETROFIT = 'MTU AA - Retrofit';
  }

  public class Opportunity_Type {
    public final String DAF = 'DAF';
  }

  public class Property_BuildTypes {
    public final String WEBPASS = 'Webpass';
    public final String SUBWAY = 'Subway';
    public final String EPC = 'EPC';
    public final String THIRD_PARTY_ASSET = 'Third Party Asset';
  }

  public class Property_PropertyClassification {
    public final String RETROFIT = 'Retrofit';
  }

  public class Property_Market {
    public final String KANSAS_CITY = 'Kansas City';
  }

 public class Property_EmailTemplate {
    public final String HHP_HYBRID_EMAIL_TEMPLATE = 'HHP_HYBRID_EMAIL_TEMPLATE';
    public final String HHP_NON_HYBRID_EMAIL_TEMPLATE = 'HHP_NON_HYBRID_EMAIL_TEMPLATE';
    public final String HHA_HYBRID_EMAIL_TEMPLATE = 'HHA_HYBRID_EMAIL_TEMPLATE';
    public final String HHA_NON_HYBRID_EMAIL_TEMPLATE = 'HHA_NON_HYBRID_EMAIL_TEMPLATE';
 }

  public class Property_ServiceCompetitors {
    public final String CENTURYLINK_NON_GIGABIT = 'CenturyLink [non Gigabit]';
  }

  public class Property_TriggerConfigurationLabel {
    public final String SEND_OSP_NOTIFICATION= 'SendOSPEmailNotification';
  }

  public class Property_RestrictedAccessOptions {
    public final String NO_DOOR_HANGERS_ALLOWED = 'No Door Hangers Allowed';
    public final String NO_D2D_ALLOWED = 'No D2D Allowed';
  }

  public class Property_PropertyType {
    public final String COMMERCIAL = 'Commercial';
    public final String PRIVATE_ROADS = 'Private Roads';
  }

  public class OspReview_BuildStatusPicklist {
    public final String HH = 'HH (Future)';
    public final String HHA = 'HHA (In Design)';
    public final String HHP = 'HHP (Active)';
  }

  public class OspReview_BuildSubStatusPicklist {
    public final String NEED_EXTENSION_OR_OVERPULL = 'Need Extension/Overpull';
    public final String DROP_CLOSURE_DESIGNED = 'Drop Closure Designed';
    public final String NOT_IN_BUILD_AREA = 'Not in Build Area';

  }

  public class OspReview_HybridRing {
    public final String IS_HYBRIDRING = 'Yes';
    public final String ISNOT_HYBRIDRING = 'No';
  }

  public class OspReview_TechOpsServiceabilityPicklist {
    public final String REVIEWED = 'Reviewed';
    public final String TO_BE_REVIEWED = 'To Be Reviewed';
    public final String NEED_MORE_INFO = 'Need More Information';
  }

  public class OspReview_PropertyClassificationPicklist {
    public final String GREENFIELD = 'Greenfield';
  }

  public class OspReview_EmailTemplates {
   public final String OSP_REVIEW = 'Submit_for_TechOps_Review' ;
  }

  public class Lead_StatusPicklist {
   public final String NEW_VALUE = 'New';
   public final String IN_PROGRESS = 'In Progress';
   public final String ON_HOLD = 'On Hold';
   public final String DISQUALIFIED = 'Disqualified';
   public final String CONVERTED = 'Converted';
   public final String QUALIFIED_BY_SALES = 'Qualified by Sales';
   public final String QUALIFIED_BY_SALES_AND_TECHOPS = 'Qualified by Sales and Tech Ops';
   public final String STAND_BY = 'Stand By';
  }

  public class Lead_AccountRelationshipPicklist {
    public final String PROPERTY_OWNER = 'Property Owner';
    public final String PROPERTY_MANAGER = 'Property Manager';
    public final String EQUITY_BACKER = 'Equity Backer';
    public final String LAND_DEVELOPER = 'Land Developer';
    public final String GREENFIELD_DEVELOPER = 'Greenfield Developer';
    public final String OTHER = 'Other';
  }

  public class User_UserName {
    public final String CONNECTION_USER = 'Connection User';
  }

  public class Property2CampaignUtilOptConsts {
    public final String OPT_INSERT = 'INSERT';
    public final String OPT_DELETE = 'DELETE';
  }

  public class MxURelatedAccountTypeConsts {
   public final String PROPERTY_OWNER = 'Property Owner';
   public final String PROPERTY_MANAGER = 'Property Manager';
   public final String GREENFIELD_DEVELOPER = 'Greenfield Developer';
   public final String LAND_DEVELOPER = 'Land Developer';
   public final String EQUITY_BACKER = 'Equity Backer';
   public final String NONE = 'None';
  }

  public class OspReviewConsts {
    public final OspReview_BuildStatusPicklist BUILD_STATUS =
        new OspReview_BuildStatusPicklist();
    public final OspReview_BuildSubStatusPicklist BUILD_SUB_STATUS =
        new OspReview_BuildSubStatusPicklist();
    public final OspReview_TechOpsServiceabilityPicklist SERVICEABILITY =
        new OspReview_TechOpsServiceabilityPicklist();
    public final OspReview_PropertyClassificationPicklist PROPERTY_CLASS =
        new OspReview_PropertyClassificationPicklist();
    public final OspReview_EmailTemplates EMAIL_TEMPLATE =
        new OspReview_EmailTemplates();
    public final OspReview_HybridRing HYBRID_RING =
        new OspReview_HybridRing();
  }

  public class MxULeadConsts {
    public final Lead_StatusPicklist STATUS =
      new Lead_StatusPicklist();
    public final Lead_AccountRelationshipPicklist ACCOUNT_RELATIONSHIP =
        new Lead_AccountRelationshipPicklist();
  }

  public class OpportunityConsts {
    public final Opportunity_Stage STAGE =
        new Opportunity_Stage();
    public final Opportunity_SubStatus SUB_STATUS =
        new Opportunity_SubStatus();
    public final Opportunity_DateTermInitiatesOnPicklist DATE_TERM_INITIATES_ON =
        new Opportunity_DateTermInitiatesOnPicklist();
    public final Opportunity_NameSuffix NAME_SUFFIX =
        new Opportunity_NameSuffix();
    public final Opportunity_MarketingExclusivity MARKETING_EXCLUSIVITY =
        new Opportunity_MarketingExclusivity();
    public final Opportunity_DafSigned DAF_SIGNED = new Opportunity_DafSigned();
    public final Opportunity_ContractType CONTRACT_TYPE =
        new Opportunity_ContractType();
    public final Opportunity_Type TYPE = new Opportunity_Type();
  }

  public class PropertyConsts {
    public final Property_BuildTypes BUILD_TYPE =
        new Property_BuildTypes();
    public final Property_PropertyClassification PROPERTY_CLASSIFICATION =
        new Property_PropertyClassification();
    public final Property_Market MARKET =
        new Property_Market();
    public final Property_EmailTemplate EMAIL_TEMPLATE =
        new Property_EmailTemplate();
    public final Property_ServiceCompetitors SERVICE_COMPETITORS =
        new Property_ServiceCompetitors();
    public final Property_TriggerConfigurationLabel CONFIGURATION_LABEL =
        new Property_TriggerConfigurationLabel();
    public final Property_RestrictedAccessOptions RESTRICTED_ACCESS_OPTIONS =
        new Property_RestrictedAccessOptions();
    public final Property_PropertyType PROPERTY_TYPE =
        new Property_PropertyType();
  }

  public class UserConsts {
    public final User_UserName USERNAME =
        new User_UserName();
  }

  public class Property2CampaignConsts {
    public final Property2CampaignUtilOptConsts OPT
        = new Property2CampaignUtilOptConsts();
  }

  /* ***** Inner classes instances to access it's properties in
   *            static context
   */
  public static OspReviewConsts OspReview = new OspReviewConsts();
  public static MxULeadConsts MxULead = new MxULeadConsts();
  public static MxURelatedAccountTypeConsts MxURelatedAcctType
      = new MxURelatedAccountTypeConsts();
  public static OpportunityConsts Opportunity = new OpportunityConsts();
  public static PropertyConsts Property = new PropertyConsts();
  public static UserConsts User = new UserConsts();
  public static Property2CampaignConsts Operation =
      new Property2CampaignConsts();
}