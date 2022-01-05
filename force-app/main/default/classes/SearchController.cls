/**
 * @group SearchController
 * @description To retrieve Contact, Lead, Premises records to invoke in customer search page.
 */
global with sharing class SearchController implements vlocity_cmt.VlocityOpenInterface2 {

  public static final String CLASS_NAME = 'SearchController';

  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * getCustomerDetails, getCustomerDetailsByAddressId,
   * getCustomerDetailsByName and getCustomerDetailsBySerialNumber method.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  public Boolean invokeMethod(String methodName, Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    if (methodName.equals('getCustomerDetails')) {
      getCustomerDetails(input, outMap, options);
    }
    else if(methodName.equals('getCustomerDetailsByAddressId')) {
      getCustomerDetailsByAddressId(input, outMap, options);
    }
    else if(methodName.equals('getCustomerDetailsByName')) {
      getCustomerDetailsByName(input, outMap, options);
    }
    else if(methodName.equals('getCustomerDetailsBySerialNumber')) {
      getCustomerDetailsBySerialNumber(input, outMap, options);
    }
    return true;
  }

  /*
   * @description To retrieve Contact, Lead, Premises records based on the input.
   * @param phoneNumber To invoke the list of Contact, Lead and Premises records.
   * @param email To invoke the list of Contact, Lead and Premises records.
   * @param ticket To invoke the list of Contact,Lead and Premise records.
   * @return List of Contacts, Leads, Premises
   */

  public static void getCustomerDetails(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    String METHOD_NAME = 'getCustomerDetails';
    String phoneNumber = String.valueOf(input.get('phoneNumber'));
    String emailAddress = String.valueOf(input.get('emailAddress'));
    String ticketNumber = String.valueOf(input.get('ticketNumber'));

    SobjectDetail addressDetails = new SobjectDetail();
    String leadStatus = Constants.LEAD.STATUS.DISQUALIFIED;
    Set<Id> accountId = new Set<Id>();
    try {
      // phoneOrEmail : Search criteria used to differentiate in query based on input params
      String phoneOrEmail;
      if (String.isNotEmpty(phoneNumber)) {
        phoneOrEmail = ' Phone = :phoneNumber';
      }
      else if (String.isNotEmpty(emailAddress)) {
        phoneOrEmail = ' Email = :emailAddress';
      }
      Set<Id> premisesId = new Set<Id>();
      String leadQuery =
          'SELECT Id, Name, Phone, Email, Status, Sub_Status__c, '
            +'vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, '
            +'vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, '
            +'vlocity_cmt__PremisesId__r.vlocity_cmt__State__c, '
            +'vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, '
            +'vlocity_cmt__PremisesId__r.vlocity_cmt__Country__c '
          +'FROM Lead WHERE Status != :leadStatus AND';
      String contactQuery =
          'SELECT Account.Name, Account.vlocity_cmt__Status__c, '
            +'Account.vlocity_cmt__PremisesId__c, AccountId, Name,Phone, Email '
          +'FROM Contact '
          +'WHERE ';
      if(String.isNotEmpty(phoneOrEmail)) {
        addressDetails.contactList = Database.query(contactQuery + phoneOrEmail);
        addressDetails.leadList = Database.query(leadQuery + phoneOrEmail);
        for (Contact accountPremisesId : addressDetails.contactList) {
          premisesId.add(accountPremisesId.Account.vlocity_cmt__PremisesId__c);
        }
        addressDetails.premisesList = [
            SELECT
              Id, Name, vlocity_cmt__StreetAddress__c, vlocity_cmt__City__c, vlocity_cmt__State__c,
              vlocity_cmt__PostalCode__c, vlocity_cmt__Country__c, Address_Type__c,
              Eligibility__c, Ineligibility_Reason__c
            FROM
              vlocity_cmt__Premises__c
            WHERE
              Id IN :premisesId
        ];
      }
      else if(String.isNotEmpty(ticketNumber)) {
        for(Ticket__c tckt: [
            SELECT
              Account__c
            FROM
              Ticket__c
            WHERE Name = :ticketNumber
            AND Account__c !=NULL
            Limit 1]) {
          accountId.add(tckt.Account__c);
        }
        if (accountId.isEmpty()){
          for(History_Event__c historyEventTicket: [
              SELECT
                Account__c,
                External_Ticket__c
              FROM
                History_Event__c
              WHERE External_Ticket__c = :ticketNumber
              AND Account__c !=NULL
              Limit 1]) {
            accountId.add(historyEventTicket.Account__c);
          }
        }
        if (!accountId.isEmpty()) {
          addressDetails.contactList =
              Database.query(contactQuery + 'AccountId = :accountId' );
        }
      }
    }
    catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
    outMap.put('details', JSON.serialize(addressDetails));
  }

  /*
   * @description To retrieve Contact, Lead, Premises records based on the input
   * @param addressId Input to invoke the list of Contact, Lead and Premises records
   * @return List of Contacts, Leads, Premises
   */
  public static void getCustomerDetailsByAddressId(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    final String METHOD_NAME = 'getCustomerDetailsByAddressId';
    String addressId = String.valueOf(input.get('addressId'));
    SobjectDetail addressDetails = new SobjectDetail();
    try {
      List<Lead> leadAddressList = new List<Lead>();
      List<vlocity_cmt__Premises__c> premisesAddressList = new List<vlocity_cmt__Premises__c>();
      Set<Id> premisesId = New Set<Id>();
      if (String.isNotEmpty(addressId)) {
        premisesAddressList = [
            SELECT
              Id, Address_Type__c, Name, vlocity_cmt__AutoNumber__c,
              vlocity_cmt__StreetAddress__c, vlocity_cmt__City__c,
              vlocity_cmt__State__c, vlocity_cmt__PostalCode__c, vlocity_cmt__Country__c,
              Eligibility__c, Ineligibility_Reason__c
            FROM
              vlocity_cmt__Premises__c
            WHERE
              vlocity_cmt__PremisesIdentifier__c = :addressId
        ];
        addressDetails.premisesList = premisesAddressList;
        for (vlocity_cmt__Premises__c accountPremisesId : premisesAddressList) {
          premisesId.add(accountPremisesId.Id);
        }
        List<Contact> contactData = [
            SELECT
              Account.Name, Account.vlocity_cmt__Status__c,
              Account.vlocity_cmt__PremisesId__c, AccountId, Name, Phone, Email
            FROM
              Contact
            WHERE
              Account.vlocity_cmt__PremisesId__c IN :premisesId
        ];
        addressDetails.contactList = contactData;
        //***************************************************************************************************************************
        /*if (!contactData.isEmpty() && contactData.AccountId != NULL) {
          contactData.Account
        }*/
        //***************************************************************************************************************************
        leadAddressList = [
            SELECT
              Id, Name, Phone, Email, Status, Sub_Status__c,
              vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
              vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
              vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
              vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
              vlocity_cmt__PremisesId__r.vlocity_cmt__Country__c
            FROM
              Lead
            WHERE
              Status != :Constants.LEAD.STATUS.DISQUALIFIED AND
              vlocity_cmt__PremisesId__r.vlocity_cmt__PremisesIdentifier__c = :addressId
        ];
        addressDetails.leadList = leadAddressList;
      }
    }
    catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
    outMap.put('details', JSON.serialize(addressDetails));
  }

  /*
   * @description To retrieve Contact, Lead, Premises records based on the input.
   * @param inputName To invoke the list of Contact, Lead and Premises records.
   * @return List of Contacts, Leads, Premises
   */
  public static void getCustomerDetailsByName(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    final String METHOD_NAME = 'getCustomerDetailsByName';
    SobjectDetail addressDetails = new SobjectDetail();
    String leadStatus = Constants.LEAD.STATUS.DISQUALIFIED;
    try {
      String inputName = String.valueOf(input.get('inputName'));
      List<String> leadName = inputName.split(' ');
      String firstName = leadName[0];
      String lastName = leadName[1];

      addressDetails.contactList = [
          SELECT Account.Name, Account.vlocity_cmt__Status__c,
            Account.vlocity_cmt__PremisesId__c, AccountId, Name, Phone, Email
          FROM Contact
          WHERE Account.Name = :inputName];
      addressDetails.leadList = [
          SELECT Id, Name, Phone, Email, Status, Sub_Status__c,
            vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
            vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
            vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
            vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
            vlocity_cmt__PremisesId__r.vlocity_cmt__Country__c
          FROM
            Lead
          WHERE
            Status != :leadStatus AND FirstName = :firstName AND LastName = :lastName];
    } catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
    }
    outMap.put('details', JSON.serialize(addressDetails));
  }

  /*
   * @description To retrieve Contact, Lead, Premises records based on the input.
   * @param inputSerialNumber To invoke the list of Contact, Lead and Premises records.
   * @return List of Contacts.
   */
  public static void getCustomerDetailsBySerialNumber(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    final String METHOD_NAME = 'getCustomerDetailsBySerialNumber';
    String inputSerialNumber = String.valueOf(input.get('inputSerialNumber'));
    SobjectDetail addressDetails = new SobjectDetail();
    String leadStatus = Constants.LEAD.STATUS.DISQUALIFIED;
    try{
      system.debug('inputSerialNumber:::'+inputSerialNumber);
      String inputValue;
      boolean isTracking = true;
      String contactId = '';
      if(String.isNotEmpty(inputSerialNumber)) {
        for(Asset ast:[
            Select
              Id,
              ContactId,
              SerialNumber
            FROM Asset
            WHERE SerialNumber = :inputSerialNumber
            LIMIT 1]) {
          isTracking = false;
          if(ast != null) {
            contactId = ast.ContactId;
            inputValue = ' Id = :contactId';
          } else {
            isTracking = true;
          }
        }
        if(isTracking) {
          vlocity_cmt__FulfilmentRequestLine__c fulfilmentReqLine =
              new vlocity_cmt__FulfilmentRequestLine__c();
          fulfilmentReqLine = [
              SELECT Id, Tracking_Number__c, vlocity_cmt__FulfilmentRequestID__c,
                vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c
              FROM vlocity_cmt__FulfilmentRequestLine__c
              WHERE Tracking_Number__c = :inputSerialNumber
              LIMIT 1];
          system.debug('fulfilmentReqLine'+fulfilmentReqLine);
          if (fulfilmentReqLine != Null) {
            String accountId = fulfilmentReqLine.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__AccountId__c;
            inputValue = ' AccountId = :accountId';
          }
        }
      }
      if(inputValue !=null) {
        String contactQuery =
            'SELECT Account.Name, Account.vlocity_cmt__Status__c, '
              +'Account.vlocity_cmt__PremisesId__c, AccountId, Name, Phone, Email '
            +'FROM Contact '
            +'WHERE ';
        addressDetails.contactList = Database.query(contactQuery + inputValue);
        system.debug('addressDetails.contactList:::'+addressDetails.contactList);
      }
    } catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
    outMap.put('details', JSON.serialize(addressDetails));
  }

  /*
   * @description Wraper method used to integrate three object to
   * send data to customer search layout.
   */
  public class SobjectDetail {

    @AuraEnabled public List<Contact> contactList {get;set;}
    @AuraEnabled public List<Lead> leadList {get;set;}
    @AuraEnabled public List<vlocity_cmt__Premises__c> premisesList {get;set;}
  }
}