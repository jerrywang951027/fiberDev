/**
 * @group Test
 * @description This class contains methods for creating data used for testing
 * purposes only. Each method should do the following:
 *
 * 1) Return an SObject with all required/common fields filled with default
 * values. The returned SObject must be able to successfully insert WITHOUT
 * modification.
 *
 * 2) Any required or common fields that do not have default values should be
 * set via params.
 *
 * 3) The method should NOT perform any DML operations. This prevents the method
 * from being used in loops if a test requires an arbitrary number of records.
 *
 * 4) Method should be named "get{SOBJECT_TYPE}Data" or "get{RECORD_TYPE}Data"
 */
@isTest
public with sharing class TestDataFactory {

  public static final String PHONE_VALUE = '5555555555';
  public static final String EMAIL_VALUE = 'test@test.com';
  public static final String PREMISES_IDENTIFIER = '96692';
  public static final String TICKET_NUMBER = '123456789';
  public static final String SERIAL_NUMBER = 'abcde1234';

  public class AddressReviewController {
    public final String FAILURE_RESPONSE = 'Update failed';
    public final String OPEN_TICKET = 'OpenTicket';
    public final String SUCCESS_RESPONSE = 'Updated Successfully';
    public final String UPDATE_DOOR_KNOCK_COUNT = 'updateDoorKnockCountOnLeads';
  }
  /*
   * @description getPremises provides a new vlocity_cmt__Premises__c SObject
   * with all required fields filled.
   * @param status Serviceability status
   * @return a new vlocity_cmt__Premises__c SObject
   */
  public static vlocity_cmt__Premises__c getPremisesData(String status) {
    vlocity_cmt__Premises__c premisesData = new vlocity_cmt__Premises__c(
        Name = 'Premise',
        vlocity_cmt__StreetAddress__c = 'Street',
        vlocity_cmt__State__c = 'State',
        vlocity_cmt__City__c = 'City',
        vlocity_cmt__PostalCode__c = '12345',
        vlocity_cmt__Status__c = status);

    return premisesData;
  }

  /*
   * @description getTaskData provides a new Task SObject with all required
   * fields filled.
   * @param whatId related What (SObject)
   * @return a new Task SObject
   */
  public static Task getTaskData(Id whatId) {
    Task taskData = new Task(
        Subject = 'Call',
        WhatId = whatId);

    return taskData;
  }

  /*
   * @description getAccountData provides a new Account SObject with all
   * required fields filled.
   * @return a new Account SObject
   */
  public static Account getAccountData() {
    Account accountData = new Account(
        Name = 'AcctTest',
        Type = 'Prospect',
        Account_Id__c ='9259705422');

    return accountData;
  }

  /*
   * @description getContactData provides a new Contact SObject with all
   * required fields filled.
   * @param accountId related Account Id
   * @return a new Contact SObject
   */
  public static Contact getContactData(Id accountId) {
    Contact contactData = new Contact(
        AccountId = accountId,
        Email = EMAIL_VALUE,
        LastName = 'LastName',
        Phone = PHONE_VALUE);

    return contactData;
  }

  /*
   * @description getAssetData provides a new Asset SObject with all required
   * fields filled.
   * @param accountId related Account Id
   * @param contactId related Contact Id
   * @return a new Asset SObject
   */
  public static Asset getAssetData(Id accountId, Id contactId) {
    Asset assetData = new Asset(
        Name = 'Name',
        AccountId = accountId,
        ContactId = contactId,
        SerialNumber = SERIAL_NUMBER );

    return assetData;
  }

  /*
   * @description getOrderData provides a new Order SObject with all required
   * fields filled.
   * @param accountId related Account.Id
   * @return a Order SObject
   */
  public static Order getOrderData(Id accountId) {
    Order orderData = new Order(
        Name = 'Name',
        AccountId = accountId,
        BillingStreet = 'Street',
        BillingCity = 'City',
        BillingState = 'State',
        BillingPostalCode = '12345',
        BillingCountry = 'US',
        EffectiveDate = Date.today(),
        Force_Billing__c = true,
        Is_Activated__c = true,
        Status = Constants.ORDER.STATUS.DRAFT,
        vlocity_cmt__OrderStatus__c =
          Constants.ORDER.STATUS.READY_TO_SUBMIT);
    return orderData;
  }

  /**
   * @description getLeadData provides a new Lead SObject with all required
   * fields filled.
   * @return a Lead SObject
   */
  public static Lead getLeadData() {
    Long timeStr = DateTime.now().getTime();

    Lead leadData = new Lead(
        Email = 'test' + timeStr + '@test.com',
        Company = 'Company',
        LastName = 'LastName-' + timeStr,
        FirstName = 'FirstName-' + timeStr,
        Phone = PHONE_VALUE);

    return leadData;
  }

  /**
   * @description getRandomStr provides a String with random characters
   * @param stringLength the length of the string returned
   * @return a String of random characters
   */
  public static String generateRandomString(Integer stringLength) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';

    while (randStr.length() < stringLength) {
       Integer randomIndex = Math.mod(
           Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(randomIndex, randomIndex+1);
    }

    return randStr;
  }

  /**
   * @description getHistoryEventData provides a new History_Event__c SObject
   * with all required fields filled.
   * @return a new History_Event__c SObject
   */
  public static History_Event__c getHistoryEventData () {
    History_Event__c historyEventData = new History_Event__c(
        Direction__c = Constants.HISTORY_EVENT.DIRECTION.OUTBOUND,
        Door_Open__c = true,
        Type__c = Constants.HISTORY_EVENT.TYPE.DOOR_TO_DOOR);

    return historyEventData;
  }

  /**
   * @description getProductData provides a new Product2 SObject with all
   * required fields filled.
   * @param name Product2.Name
   * @param family Product2.Family
   * @param productCode Product2.ProductCode
   * @return a new Product2 SObject
   */
  public static Product2 getProductData(String name, String family,
       String productCode) {
    Product2 productData = new Product2(
        Name = name,
        Family = family,
        IsActive = true,
        ProductCode = productCode);
    return productData;
  }

  /**
   * @description getPriceBookEntryData provides a new PricebookEntry SObject
   * with all required fields filled.
   * @param priceBookId PricebookEntry.Pricebook2Id
   * @param productId PricebookEntry.Product2Id
   * @return a new PricebookEntry SObject
   */
  public static PricebookEntry getPriceBookEntry(Id priceBookId, Id productId){
    PricebookEntry priceBookEntryData = new PricebookEntry(
        IsActive = true,
        Pricebook2Id = priceBookId,
        Product2Id = productId,
        UnitPrice = 1);

    return priceBookEntryData;
  }

  /**
   * @description getOrderItem provides a new OrderItem SObject with all
   * required fields filled.
   * @param orderId OrderItem.OrderId
   * @param priceBookEntryId OrderItem.PricebookEntryId
   * @param productId OrderItem.Product2Id
   * @return a new OrderItem SObject
   */
  public static OrderItem getOrderItemData (Id orderId, Id priceBookEntryId,
      Id productId) {
    OrderItem orderItemData = new OrderItem(
        OrderId = orderId,
        PricebookEntryId = priceBookEntryId,
        Product2Id = productId,
        Quantity = 1,
        UnitPrice = 1);

    return orderItemData;
  }

  /**
   *  @description Method to create History Action
   *  @param orderId, historyEventId
   *  @return historyAction
   */
  public static History_Action__c getHistoryActionData(Id historyEventId,
        Id orderId) {
    History_Action__c historyActionData = new History_Action__c(
        History_Event__c = historyEventId,
        Order__c = orderId,
        Type__c = Constants.HISTORY_ACTION.TYPE.Notification);

    return historyActionData;
  }

   /**
   *  @description Method to create History Action with type Issue
   *  @param orderId, historyEventId
   *  @return historyAction
   */
  /*public static History_Action__c getHistoryActionDataIssue(Id historyEventId,
        Id orderId) {
    History_Action__c historyActionData = new History_Action__c(
        History_Event__c = historyEventId,
        Order__c = orderId,
        Type__c = 'Issue');

    return historyActionData;
  }*/

  /**
   * @description : create Logging Setting
   * @param : NA
   * @return : setting
   */
  public static Logging_Level__c getLoggingSetting() {
    Logging_Level__c setting = new Logging_Level__c(
        Name = Constants.LOGGING_LEVEL.LEVEL.LOG_SETTING,
        Level__c = Constants.LOGGING_LEVEL.LEVEL.LOG_SETTING);

    return setting;
  }

  /**
  *  @description Method to create Geopointe check in record
  *  @param doInsert, whatId
  *  @return CheckInItem
  */
  public static geopointe__Check_In__c getCheckInData (String whatId, String whyData) {
    geopointe__Check_In__c checkInItem = new geopointe__Check_In__c(geopointe__What_ID__c = whatId,
        geopointe__Why_Text__c=whyData);
    return CheckInItem;
  }

  /**
  *  @description Method to create Geopointe check in record
  *  @param doInsert, whatId
  *  @return CheckInItem
  */
  public static Ticket__c getTicketData () {
    Ticket__c ticketData = new Ticket__c(Status__c = 'Open', Name = TICKET_NUMBER);
    return ticketData;
  }
  /**
   * @description getFrlData provides a new Fulfilment Request SObject with all required
   * fields filled.
   * @param orderData
   * @return a Fulfilment Request SObject
   */
  public static vlocity_cmt__FulfilmentRequest__c getFrlData(Id orderId) {
      vlocity_cmt__FulfilmentRequest__c frlData= new vlocity_cmt__FulfilmentRequest__c(
      vlocity_cmt__OrderId__c = orderId);
    return frlData;
  }
  /**
   * @description getFrlItemData provides a new Fulfilment Request Line SObject with all required
   * fields filled.
   * @param product2Data
   * @return a FulfilmentRequestLine SObject
   */
  public static vlocity_cmt__FulfilmentRequestLine__c getFrlItemData (
    Id product2Id, Id fulfilmentRequestId) {
    vlocity_cmt__FulfilmentRequestLine__c frlItemData= new vlocity_cmt__FulfilmentRequestLine__c(
        Force_Billing__c = true,
        Pickup_Deliver_Install_Date__c= Date.Today(),
        vlocity_cmt__Product2Id__c = product2Id,
        vlocity_cmt__FulfilmentRequestID__c = fulfilmentRequestId);
    return frlItemData;
  }
    
  /*
   * @description getEmailMessageData provides a new EmailMessage SObject with all
   * required fields filled.
   * @return a new EmailMessage SObject
   */

   public static Email_Message__c getEmailMessageData () {
    Email_Message__c emailMessageData = new Email_Message__c(
        Subject__c= 'Subject',
        To_Address__c = EMAIL_VALUE);

    return emailMessageData;
  }
    
}