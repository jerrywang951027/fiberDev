/*
 * @group SearchController
 * @description Test class for SearchController to improve code coverage and test functionality.
 */
@isTest
public class SearchControllerTest {

  /**
   * @description Test data set up method.
   * @param NA
   * @return null
   */
  @testSetup
  private static void setupTestData() {

    List<Contact> updateContact = new List<Contact>();
    List<Asset> updateAsset = new List<Asset>();
    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    Account accountObject = TestdataFactory.getAccountData();
    insert accountObject;
    Contact testContactFirst = TestDataFactory.getContactData(accountObject.Id);
    Contact testContactSecond = TestDataFactory.getContactData(accountObject.Id);
    list<Contact> testContacts = new list<Contact>{testContactFirst, testContactSecond};
    insert testContacts;
    Vlocity_cmt__Premises__c testPremises = TestdataFactory.getPremisesData(null);
    insert testPremises;
    Lead testLead = TestdataFactory.getLeadData();
    testLead.vlocity_cmt__PremisesId__c  = testPremises.Id;
    insert testLead;
    Ticket__c ticketRecord = TestdataFactory.getTicketData();
    ticketRecord.Account__c = accountObject.Id;
    insert ticketRecord;
    History_Event__c historyEvent = TestDataFactory.getHistoryEventData();
    historyEvent.Account__c = accountObject.Id;
    historyEvent.External_Ticket__c = TestDataFactory.EXTERNAL_TICKET;
    insert historyEvent;
    Asset assetObject = TestDataFactory.getAssetData(accountObject.Id,
        testContactFirst.Id);
    insert assetObject;

    Id standardPricebookId = Test.getStandardPricebookId();
    Order testOrders = TestDataFactory.getOrderData(accountObject.Id);
    insert testOrders;

    Product2 testProduct = TestDataFactory.getProductData('TestName', 'TestFamily',
        Constants.PRODUCT.PRODUCT_CODE.OFR_EQUIP_GWIFI);
    testProduct.Name = 'Google Wifi';
    insert testProduct;
    vlocity_cmt__FulfilmentRequest__c FRData = TestDataFactory.getFrlData(testOrders.Id);
    insert FRData;
    vlocity_cmt__FulfilmentRequestLine__c FRLData =
        TestDataFactory.getFrlItemData(testProduct.Id, FRData.Id);
    FRLData.Tracking_Number__c ='989898989999';
    insert FRLData;
  }

  /*
  * @description Check to retrieve contact details based on Phone number/Email/Ticket Number.
  */
  @isTest
  private static void emailShouldReturnCustomerDetails() {

    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    inputMap.put('emailAddress', TestdataFactory.EMAIL_VALUE);
    SearchController addressSearch = new SearchController();
    Test.startTest();
      Boolean result = addressSearch.invokeMethod('getCustomerDetails',inputMap, outMap, options);
    Test.stopTest();
    System.assert(json.serialize(outMap.get('details')).contains('contactList'));
    System.assert(result);
  }

  /*
   * @description Check to retrieve Lead information based on Phone number/Email/Ticket
   * Number Address.
   */
  @isTest
  private static void phoneShouldReturnCustomerDetails() {

    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    inputMap.put('phoneNumber', TestdataFactory.PHONE_VALUE);
    SearchController addressSearch = new SearchController();
    Test.startTest();
      Boolean result = addressSearch.invokeMethod('getCustomerDetails',inputMap, outMap, options);
    Test.stopTest();
    System.assert(json.serialize(outMap.get('details')).contains('contactList'));
    System.assert(result);
  }

  /*
   * @description Check to retrieve Premises information based on AddressId.
   */
  @isTest
  private static void addressIdShouldReturnCustomerDetails() {

    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    SearchController addressSearch = new SearchController();
    vlocity_cmt__Premises__c premises = [
        SELECT vlocity_cmt__PremisesIdentifier__c
        FROM vlocity_cmt__Premises__c];
    premises.vlocity_cmt__PremisesIdentifier__c = TestdataFactory.PREMISES_IDENTIFIER;
    update premises;
    inputMap.put('addressId', premises.vlocity_cmt__PremisesIdentifier__c);
    Test.startTest();
      Boolean result =
          addressSearch.invokeMethod('getCustomerDetailsByAddressId',inputMap, outMap, options);
    Test.stopTest();
    System.assert(json.serialize(outMap.get('details')).contains('premisesList'));
    System.assert(result);
  }

  /*
   * @description Check to retrieve Lead information based on Phone number/Email Address.
   */
  @isTest
  private static void ticketShouldReturnCustomerDetails() {

    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    inputMap.put('ticketNumber', TestdataFactory.TICKET_NUMBER);
    SearchController addressSearch = new SearchController();
    Test.startTest();
      Boolean result = addressSearch.invokeMethod('getCustomerDetails',inputMap, outMap, options);
    Test.stopTest();
    System.assert(json.serialize(outMap.get('details')).contains('contactList'));
    System.assert(result);
  }

  /*
   * @description Check to retrieve Lead information based on Contact Ticket Id.
   */
  @isTest
  private static void historyEventShouldReturnCustomerDetails() {

    History_Event__c historyEventData = [
        SELECT
          Id,
          External_Ticket__c
        FROM History_Event__c
        LIMIT 1];
    Ticket__c ticketData =[
        SELECT
          Id,
          Name
        FROM Ticket__c
        LIMIT 1
    ];
    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    inputMap.put('ticketNumber', TestdataFactory.EXTERNAL_TICKET);
    SearchController addressSearch = new SearchController();
    Test.startTest();
      Boolean result = addressSearch.invokeMethod('getCustomerDetails',inputMap, outMap, options);
    Test.stopTest();
    System.assertNotEquals(historyEventData.External_Ticket__c, ticketData.Name,
        'History Event ticket and Ticket object number should not match');
    System.assert(json.serialize(outMap.get('details')).contains('contactList'));
    System.assert(result);
  }

  /*
   * @description Check to retrieve Account details  based on SerialNumber.
   */
  @isTest
  private static void serialNumberShouldReturnCustomerDetails() {

    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    inputMap.put('inputSerialNumber',TestdataFactory.SERIAL_NUMBER);
    SearchController addressSearch = new SearchController();
    Test.startTest();
      Boolean result =
          addressSearch.invokeMethod('getCustomerDetailsBySerialNumber',inputMap, outMap, options);
    Test.stopTest();
    System.assert(json.serialize(outMap.get('details')).contains('contactList'));
    System.assert(result);
  }

  /*
   * @description Check to retrieve Account details  based on SerialNumber.
   */
  @isTest
  private static void trackingNumberShouldReturnCustomerDetails() {

    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    inputMap.put('inputSerialNumber','989898989999');
    SearchController addressSearch = new SearchController();
    Test.startTest();
      Boolean result =
          addressSearch.invokeMethod('getCustomerDetailsBySerialNumber',inputMap, outMap, options);
    Test.stopTest();
    System.assert(json.serialize(outMap.get('details')).contains('contactList'));
    System.assert(result);
  }

  /*
   * @description Check to retrieve Account or Lead details  based on name.
   */
  @isTest
  static void nameSearchShouldReturnCustomerDetails() {

    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();
    Lead leadRecord = [
        SELECT
          Id,
          FirstName,
          LastName
        FROM
          Lead
        LIMIT 1
    ];
    inputMap.put('inputName', leadRecord.FirstName +' '+leadRecord.LastName);
    SearchController addressSearch = new SearchController();
    Test.startTest();
      Boolean result =
          addressSearch.invokeMethod('getCustomerDetailsByName',inputMap, outMap, options);
    Test.stopTest();
    System.assert(json.serialize(outMap.get('details')).contains('contactList'));
    System.assert(result);
  }
}