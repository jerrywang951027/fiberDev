@isTest
public class OperationTicketDataTest {
  public static final Integer TICKET_ID = 123456789;

  /**
   * @description Method sets up the test data used in this class.
   */
  @testSetup static void setupTestData() {
    Account testAccount = TestDataFactory.getAccountData();
    testAccount.Account_Id__c = 'MOCKID123';
    testAccount.RecordTypeId = RecordTypeUtils.CONSUMER_ACCOUNT_ID;
    testAccount.vlocity_cmt__Status__c = 'Active';
    insert testAccount;
    Account testAccountData = TestDataFactory.getAccountData();
    testAccountData.RecordTypeId = RecordTypeUtils.SERVICE_ACCOUNT_ID;
    testAccountData.vlocity_cmt__Status__c = 'Active';
    insert testAccountData;

    Vlocity_cmt__Premises__c testPremise = TestDataFactory.getPremisesData(
        Constants.Premises.STATUS.UNVALIDATED);
    testPremise.vlocity_cmt__PremisesIdentifier__c = 'FAKE12345678';
    testPremise.Global_Address_Id__c = 'MOCK-c08e-Global-afb6-66ID5762c2fc';
    insert testPremise;
    testAccount.vlocity_cmt__PremisesId__c = testPremise.Id;
    update testAccount;

    vlocity_cmt__ServicePoint__c servicePointData =
        TestDataFactory.getServicePointData(testPremise.Id);
    insert servicePointData;
    Id standardPricebookId = Test.getStandardPricebookId();
    Order testOrders = TestDataFactory.getOrderData(testAccount.Id);
    testOrders.Pricebook2Id = standardPricebookId;
    testOrders.vlocity_cmt__DefaultPremisesId__c = testPremise.Id;
    testOrders.vlocity_cmt__OrderStatus__c = Constants.Order.STATUS.IN_PROGRESS;
    testOrders.Appointment_Ticket_Id__c = String.valueOf(TICKET_ID);
    insert testOrders;

    Product2 testProduct = TestDataFactory.getProductData('TestName', 'TestFamily',
        Constants.PRODUCT.PRODUCT_CODE.OFR_EQUIP_GWIFI);
    testProduct.Name = 'Google Wifi';
    insert testProduct;
    PricebookEntry pbEntry =
        TestDataFactory.getPriceBookEntry(standardPricebookId, testProduct.Id);
    insert pbEntry;
    OrderItem itemRecord = TestDataFactory.getOrderItemData (testOrders.Id, pbEntry.Id,
        testProduct.Id);
    insert itemRecord;

    Contact testContact = TestDataFactory.getContactData(testAccount.Id);
    insert testContact;
    Asset testAsset = TestDataFactory.getAssetData(testAccount.Id,
        testContact.Id);
    testAsset.Name = 'Google Wifi';
    insert testAsset;
  }
  private Static User technicianUser(String premName) {

    Profile technicianProfile = [
        SELECT Id
        FROM Profile
        WHERE Name = :Constants.PROFILE.NAME.TECHNICIAN];
    User vendorTechnicianUser = TestDataFactory.getUserData(technicianProfile.Id);
    insert vendorTechnicianUser;
    // Query your permission set name.
    PermissionSet vendor = [SELECT Id FROM PermissionSet WHERE Name = :premName];
    // Assign the above inserted user for the above Permission Set.
    PermissionSetAssignment vendorAssignment = new PermissionSetAssignment();
    vendorAssignment.AssigneeId = vendorTechnicianUser.Id;
    vendorAssignment.PermissionSetId = vendor.Id;
    insert vendorAssignment;
    return vendorTechnicianUser;
  } 
    
    
  @isTest static void getAllTickets() {
      
   User vendorTechnicianUser = technicianUser('Basic_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    OperationTicketData opTicket = new OperationTicketData();
    OperationTicketData.getAllTickets('str1','str2');
    Test.stopTest();
  }
  }
  @isTest static void getAllTicketsMethod() {
      
   User vendorTechnicianUser = technicianUser('Manage_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    OperationTicketData opTicket = new OperationTicketData();
    OperationTicketData.getAllTickets('str1','str2');
    Test.stopTest();
  }
  }
  @isTest static void getAllTicketsMethodPerm() {
      
   User vendorTechnicianUser = technicianUser('Vendor_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    OperationTicketData opTicket = new OperationTicketData();
    OperationTicketData.getAllTickets('str1','str2');
    Test.stopTest();
  }
  }
  @isTest static void getSalesforceId() {
     User vendorTechnicianUser = technicianUser('Basic_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
    //  Operation_Ticket__x operationRecord = [SELECT id, ExternalId FROM Operation_Ticket__x where ExternalId =:string.valueof(TICKET_ID)];
     // Operation_Ticket__x mockOperationTicket = new Operation_Ticket__x (
     // ExternalId = 
   // );
    Test.startTest();
    OperationTicketData opTicket = new OperationTicketData();
    OperationTicketData.getSalesforceId(string.valueof(TICKET_ID));
    Test.stopTest();
  }
  }
  @isTest static void getVendorManagerTeamEmails() {
     User vendorTechnicianUser = technicianUser('Basic_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    OperationTicketData opTicket = new OperationTicketData();
    OperationTicketData.getVendorManagerTeamEmails();
    Test.stopTest();
  }
  }
  @isTest static void getVendorManagerTeamEmailsMethod() {
     User vendorTechnicianUser = technicianUser('Vendor_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    OperationTicketData opTicket = new OperationTicketData();
    OperationTicketData.getVendorManagerTeamEmails();
    Test.stopTest();
  }
  }
  @isTest static void getVendorManagerTeamEmailsMethodPerm() {
     User vendorTechnicianUser = technicianUser('Manage_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    OperationTicketData opTicket = new OperationTicketData();
    OperationTicketData.getVendorManagerTeamEmails();
    Test.stopTest();
  }
  }
  }