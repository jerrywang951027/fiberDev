/**
 * @group Record Type
 * @description Utility methods to extract RecordType Id.
 */
public with sharing class RecordTypeUtils {

  public final static String CUSTOMER_LEAD_DEV_NAME = 'Customer_Lead';
  public final static String CONSUMER_ACCOUNT_DEV_NAME = 'Consumer';
  public final static String SERVICE_ACCOUNT_DEV_NAME = 'Service';
  public final static string OPPORTUNITY_MXU_DEV_NAME = 'MxU_Opportunity';
  public final static string OPPORTUNITY_MXU_NON_AA_DEV_NAME = 'MxU_Non_AA';
  public final static string LEAD_MXU_DEV_NAME = 'MxU_Lead';
  public final static string OPPORTUNITY_CUSTOMER_DEV_NAME = 'Customer_Opportunity';

  //Lead Record Type
  public static Id CUSTOMER_LEAD_ID =
      Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get(CUSTOMER_LEAD_DEV_NAME).getRecordTypeId();
  //Account Record Type
  public static Id CONSUMER_ACCOUNT_ID =
      Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(CONSUMER_ACCOUNT_DEV_NAME).getRecordTypeId();
  //Account Record Type
  public static Id SERVICE_ACCOUNT_ID =
      Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(SERVICE_ACCOUNT_DEV_NAME).getRecordTypeId();
    
  /*public static ID OPPORTUNITY_MXU =
      Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(OPPORTUNITY_MXU_DEV_NAME).getRecordTypeId();
    
  public static ID OPPORTUNITY_MXU_NON_AA =
      Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(OPPORTUNITY_MXU_NON_AA_DEV_NAME).getRecordTypeId();
    
  public static ID OPPORTUNITY_CUSTOMER =
      Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(OPPORTUNITY_CUSTOMER_DEV_NAME).getRecordTypeId();*/
}
/*public class RecordTypeUtils {
  public final static String CASE_ADDRESS_REVIEW_DEV_NAME = 'Address_Review';
  public final static String CASE_FIELD_SERVICE_DEV_NAME = 'GFiber_Field_Service';
  public final static string OPPORTUNITY_CUSTOMER_DEV_NAME = 'Customer_Opportunity';
  public final static string ACCOUNT_CUSTOMER_DEV_NAME = 'Customer_Account';
  public final static string LEAD_CUSTOMER_DEV_NAME = 'Customer_Lead';
  public final static string CONTACT_CUSTOMER_DEV_NAME = 'Customer_Contact';
  public final static string TASK_FIELD_SALES_DEV_NAME = 'Field_Sales_Task';
  public final static String CONSUMER_ACCOUNT_DEV_NAME = 'Consumer';
  public final static String SERVICE_ACCOUNT_DEV_NAME = 'Service';
  public final static String CUSTOMER_LEAD_DEV_NAME = 'Customer_Lead';

  public final static string OPPORTUNITY_MXU_DEV_NAME = 'MxU_Opportunity';
  public final static string OPPORTUNITY_MXU_NON_AA_DEV_NAME = 'MxU_Non_AA';
  public final static string ACCOUNT_MXU_DEV_NAME = 'MxU_Account';
  public final static string LEAD_MXU_DEV_NAME = 'MxU_Lead';
  public final static string CONTACT_MXU_DEV_NAME = 'MxU_Contact';
  public final static string TASK_MXU_DEV_NAME = 'MXU_Sales';

  public static Map<String, Map<String,RecordType>> recordTypeMap =
    new Map<String, Map<String,RecordType>>();
  //Lead Record Type
  public static Id CUSTOMER_LEAD_ID =
      Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get(CUSTOMER_LEAD_DEV_NAME).getRecordTypeId();
  //Account Record Type
  public static Id CONSUMER_ACCOUNT_ID =
      Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(CONSUMER_ACCOUNT_DEV_NAME).getRecordTypeId();
  //Account Record Type
  public static Id SERVICE_ACCOUNT_ID =
      Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(SERVICE_ACCOUNT_DEV_NAME).getRecordTypeId();
  public static ID CONTACT_CUSTOMER =
      Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get(CONTACT_CUSTOMER_DEV_NAME).getRecordTypeId();
  public static ID CASE_ADDRESS_REVIEW = 
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(CASE_ADDRESS_REVIEW_DEV_NAME).getRecordTypeId();
  public static ID CASE_FIELD_SERVICE =
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get(CASE_FIELD_SERVICE_DEV_NAME).getRecordTypeId();
  public static ID LEAD_CUSTOMER =
      Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get(LEAD_CUSTOMER_DEV_NAME).getRecordTypeId();
  public static ID ACCOUNT_CUSTOMER =
      Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCOUNT_CUSTOMER_DEV_NAME).getRecordTypeId();
  public static ID OPPORTUNITY_CUSTOMER =
      Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(OPPORTUNITY_CUSTOMER_DEV_NAME).getRecordTypeId();
  public static ID TASK_FIELD_SALES =
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
      .get(TASK_FIELD_SALES_DEV_NAME).getRecordTypeId();
  public static ID LEAD_MXU =
      Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get(LEAD_MXU_DEV_NAME).getRecordTypeId();
  public static ID ACCOUNT_MXU =
      Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(ACCOUNT_MXU_DEV_NAME).getRecordTypeId();
  public static ID CONTACT_MXU =
      Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get(CONTACT_MXU_DEV_NAME).getRecordTypeId();
  public static ID OPPORTUNITY_MXU =
      Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(OPPORTUNITY_MXU_DEV_NAME).getRecordTypeId();
  public static ID OPPORTUNITY_MXU_NON_AA =
      Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(OPPORTUNITY_MXU_NON_AA_DEV_NAME).getRecordTypeId();
  public static ID TASK_MXU =
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
      .get(TASK_MXU_DEV_NAME).getRecordTypeId();

  /** Load all active record types one time. */
 /* public static void loadRecordTypes() {
    if (recordTypeMap.size() == 0) {
      for (RecordType rt: [SELECT Id, Name, DeveloperName, SobjectType, IsActive
                          FROM RecordType
                          WHERE isActive = True]) {
        String sobjectType = rt.SobjectType;
        Map<String,RecordType> recordTypeObjMap = recordTypeMap.get(sobjectType);
        if ( recordTypeObjMap == null ) {
          recordTypeObjMap = new Map<String,RecordType>();
        }
        recordTypeObjMap.put(rt.DeveloperName,rt);
        recordTypeMap.put(sobjectType, recordTypeObjMap);
      }
    }
  }

  /** Get record type by sobject type and record type developer name. */
 /* public static RecordType getRecordType(String sobjectName, String rtDevName) {
    return getAllRecordTypesForObject(sobjectName).get(rtDevName);
  }

  /** Get record types by sobject type. */
  /*public static Map<String,RecordType> getAllRecordTypesForObject(
      String sobjectName) {
    loadRecordTypes();
    Map<String,RecordType> recordTypeObjMap = recordTypeMap.get(sobjectName);
    if (recordTypeObjMap == null) {
      recordTypeObjMap = new Map<String,RecordType>();
    }
    return recordTypeObjMap;
  }
}*/