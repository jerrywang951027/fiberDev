/*
 * @group OperationTicket
 * @description Test class to check the functionality of the BuganizerDataSourceConnection.
 */
@isTest
public with sharing class BuganizerDataSourceConnectionTest {

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

  /**
   * @description Test method to invoke sync() of BuganizerDataSourceConnection class.
   **/
  @isTest static void syncShouldReturnListOfTableDescribingExternalSystemSchema() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    BuganizerDataSourceConnection connectionObj =
        new BuganizerDataSourceConnection(connectionParams);

    Test.startTest();
      List<DataSource.Table> tables = connectionObj.sync();
    Test.stopTest();

    System.assert(tables[0].name ==
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME,
        tables[0].name + ' doesn\'t seem an expected table name');
  }

  /**
   * @description Test method to invoke query() of BuganizerDataSourceConnection class
   * when filters are not applied.
   * Vendor operation permission user
   **/
  @isTest
  static void vendorOperationTicketsPermSetShouldAllowUserToQueryOperationTicket() {

    User vendorTechnicianUser = technicianUser('Vendor_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
      BuganizerDataSourceConnection connectionObj =
          new BuganizerDataSourceConnection(connectionParams);
      DataSource.QueryContext context = (DataSource.QueryContext)getContext(false, false);
      Test.startTest();
        DataSource.TableResult tableResult = connectionObj.query(context);
      Test.stopTest();
      Map<String, Object> dataRow = tableResult.rows[0];
      Integer ticketId = (Integer)dataRow.get('ExternalId');
      System.assert(tableResult.tableName
          .contains(Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME),
          'It seems '+tableResult.tableName + ' is not an expected table name');
      System.assert(ticketId == TICKET_ID, 'It seems '+ ticketId +
          ' is not an expected ticket id');
    }
  }

  /**
   * @description Test method to invoke query() of BuganizerDataSourceConnection class
   * when filters are not applied.
   * Basic operation permission user
   **/
  @isTest
  static void basicOperationTicketsPermSetShouldAllowUserToQueryOperationTicket() {

    User vendorTechnicianUser = technicianUser('Basic_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
      BuganizerDataSourceConnection connectionObj =
          new BuganizerDataSourceConnection(connectionParams);
      DataSource.QueryContext context = (DataSource.QueryContext)getContext(false, false);
      Test.startTest();
        DataSource.TableResult tableResult = connectionObj.query(context);
      Test.stopTest();
      Map<String, Object> dataRow = tableResult.rows[0];
      Integer ticketId = (Integer)dataRow.get('ExternalId');
      System.assert(tableResult.tableName
          .contains(Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME),
          'It seems '+tableResult.tableName + ' is not an expected table name');
      System.assert(ticketId == TICKET_ID, 'It seems '+ ticketId +
          ' is not an expected ticket id');
    }
  }

  /**
   * @description Test method to invoke query() of BuganizerDataSourceConnection class
   * when filters are not applied.
   * Manage operation permission user
   **/
  @isTest
  static void manageOperationTicketsPermSetShouldAllowUserToQueryOperationTicket() {

    User vendorTechnicianUser = technicianUser('Manage_Operation_Tickets');
    System.runAs(vendorTechnicianUser) {

      DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('QueryTicketMockResponseJson');
      mock.setHeader('Content-Type', 'application/json');
      mock.setStatusCode(200);
      Test.setMock(HttpCalloutMock.class, mock);
      BuganizerDataSourceConnection connectionObj =
          new BuganizerDataSourceConnection(connectionParams);
      DataSource.QueryContext context = (DataSource.QueryContext)getContext(false, false);
      Test.startTest();
        DataSource.TableResult tableResult = connectionObj.query(context);
      Test.stopTest();
      Map<String, Object> dataRow = tableResult.rows[0];
      Integer ticketId = (Integer)dataRow.get('ExternalId');
      System.assert(tableResult.tableName
          .contains(Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME),
          'It seems '+tableResult.tableName + ' is not an expected table name');
      System.assert(ticketId == TICKET_ID, 'It seems '+ ticketId +
          ' is not an expected ticket id');
    }
  }

  /**
   * @description used to extract technician user test data creation
   **/
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

  /**
   * @description Test method to invoke query() of BuganizerDataSourceConnection class
   * when filters are applied.
   **/
  @isTest static void queryShouldFetchBuganizerTicketsWithAdditionalFilter() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('QueryTicketMockResponseJson');
    mock.setHeader('Content-Type', 'application/json');
    mock.setStatusCode(200);
    Test.setMock(HttpCalloutMock.class, mock);
    BuganizerDataSourceConnection connectionObj =
        new BuganizerDataSourceConnection(connectionParams);
    DataSource.QueryContext context = (DataSource.QueryContext)getContext(true, false);

    Test.startTest();
      DataSource.TableResult tableResult = connectionObj.query(context);
    Test.stopTest();

    Map<String, Object> dataRow = tableResult.rows[0];
    Integer ticketId = (Integer)dataRow.get('ExternalId');
    System.assert(tableResult.tableName
        .contains(Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME),
        'It seems '+tableResult.tableName + ' is not an expected table name');
    System.assert(ticketId == TICKET_ID, 'It seems '+ ticketId +
        ' is not an expected ticket id');
  }

  /**
   * @description Test method to invoke search() of BuganizerDataSourceConnection class.
   **/
  @isTest static void searchShouldReturnSearchedBuganizerTicket() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('QueryTicketMockResponseJson');
    mock.setHeader('Content-Type', 'application/json');
    mock.setStatusCode(200);
    Test.setMock(HttpCalloutMock.class, mock);
    BuganizerDataSourceConnection connectionObj =
        new BuganizerDataSourceConnection(connectionParams);
    DataSource.SearchContext context = (DataSource.SearchContext)getContext(true, true);

    Test.startTest();
      DataSource.TableResult tableResult = connectionObj.search(context)[0];
    Test.stopTest();

    Map<String, Object> dataRow = tableResult.rows[0];
    Integer ticketId = (Integer)dataRow.get('ExternalId');

    System.assert(tableResult.tableName
          .contains(Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME),
          'It seems '+tableResult.tableName +
          ' is not an expected table name');
    System.assert(ticketId == TICKET_ID, 'It seems '+ ticketId +
          ' is not an expected ticket id');
  }

  /**
   * @description Method to get DataSource.QueryContext of query. Or, DataSource.SearchContext of
   *     search. Contains information about the table, columns, filters etc.
   * @param isWithFilter Boolean - true if filters are applied and false if filters are not
   *     applied.
   * @param isSearch Boolean - true if DataSource.SearchContext is required and false if
   *     DataSource.QueryContext is required.
   **/
  private static Object getContext(Boolean isWithFilter, Boolean isSearch) {
    Vlocity_cmt__Premises__c premises = [
        SELECT
          Id,
          Name
        FROM
          Vlocity_cmt__Premises__c
        LIMIT 1
    ];
    Order orderData = [
        SELECT
          Id,
          Name
        FROM
          Order
        LIMIT 1
    ];
    Account accountData = [
        SELECT
          Id,
          Name
        FROM
          Account
        LIMIT 1
    ];
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    BuganizerDataSourceConnection connectionObj =
        new BuganizerDataSourceConnection(connectionParams);
    List<DataSource.Table> tables = connectionObj.sync();
    List<DataSource.ColumnSelection> columnSelections = new List<DataSource.ColumnSelection>();
    DataSource.ColumnSelection columnSelection = new DataSource.ColumnSelection();
    columnSelection.tableName =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME;
    columnSelection.columnName = 'ExternalId';
    columnSelection.aggregation = DataSource.QueryAggregation.NONE;
    columnSelections.add(columnSelection);

    List<DataSource.filter> subFilters = new List<DataSource.filter>();

    subFilters.add(filter('status', 'NEW'));
    subFilters.add(filter('premisesId', premises.Id));
    subFilters.add(filter('orderId', orderData.Id ));
    subFilters.add(filter('consumerAccountId', accountData.Id));

    DataSource.filter subFilter = new DataSource.filter();
    subFilter.columnName = null;
    subFilter.columnValue = null;
    subFilter.subfilters = subFilters;
    subFilter.tableName = Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME;
    subFilter.type = DataSource.FilterType.AND_;

    DataSource.TableSelection tableSelection = new DataSource.TableSelection();
    tableSelection.columnsSelected = columnSelections;
    tableSelection.filter = isWithFilter ? subFilter : null;
    tableSelection.order = null;
    tableSelection.tableSelected =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME;

    if (!isSearch) {
      DataSource.QueryContext context = new DataSource.QueryContext();
      context.metaData = tables;
      context.offset = 0;
      context.maxResults = 10;
      context.tableSelection = tableSelection;

      return context;
    } else {
      List<DataSource.TableSelection> tableSelections =  new List<DataSource.TableSelection>();
      tableSelections.add(tableSelection);

      DataSource.SearchContext searchContext =
          new DataSource.SearchContext(tables, 0, 10, tableSelections, String.valueOf(TICKET_ID));

      return searchContext;
    }
  }

  /**
   * @description Method sets up the test data used in this class for dataSourceFilter.
   */
  private Static DataSource.filter filter(String name, String value) {

    DataSource.filter dataSourceFilter = new DataSource.filter();
    dataSourceFilter.columnName = Name;
    dataSourceFilter.columnValue = Value;
    dataSourceFilter.subfilters = null;
    dataSourceFilter.tableName =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME;
    dataSourceFilter.type = DataSource.FilterType.NOT_EQUALS;
    return dataSourceFilter;
  }

  /*@istest static void testWrapper() {
    BuganizerDataSourceConnection.FieldValues fieldval = new BuganizerDataSourceConnection.FieldValues();
    BuganizerDataSourceConnection.BooleanWrap wrap = new BuganizerDataSourceConnection.BooleanWrap();
    wrap.booleanValue = true;
    fieldval.fiberSpliceRequired = wrap;  
  }*/
    
        
}