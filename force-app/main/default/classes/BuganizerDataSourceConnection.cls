/**
 * @description Extends the DataSource.Connection class to enable
 *     salesforce sync the external system's metadata schema
 *     and to handle queries and searches of the external data.
 **/

global with sharing class BuganizerDataSourceConnection extends DataSource.Connection {
  private static Set<String> addressIds = new Set<String>();
  private static Set<String> globalAddressIds = new Set<String>();
  private static String filters = '';
  private static Map<String, Set<String>> filterValuesByLookup =
      new Map<String, Set<String>>();
  private static String queryMoreToken;
  private static String searchString = '';
  private static Set<String> ticketIds = new Set<String>();
  private static User userDetails;
  private static String userType = '';
  private static Map<String, String> parentAccoutIdByServiceAccountId =
      new Map<String, String>();
  private static Map<String, String> accountStatusByServiceAccountId =
      new Map<String, String>();
  private static Map<String, String> servicePlanByOrderId =
      new Map<String, String>();
  private static Map<String, account> primaryContactByAccount =
      new Map<String, account>();
  private static Map<String, String> fullAddressByPremisesId = new Map<String, String>();

  private final static String CLASS_NAME = 'BuganizerDataSourceConnection';
  private final static List<String> LOOKUP_FIELD_NAMES =
      new List<String> {'premisesId', 'orderId',
      'consumerAccountId', 'serviceAccountId'};
  private final static String PAGE_SIZE = '"page_size": 15,';
  private final static List<String> PERMISSION_SET_NAMES =
      new List<String> {'Basic_Operation_Tickets', 'Manage_Operation_Tickets',
      'Vendor_Operation_Tickets'};

  /**
   * @description Field names in salesforce by field names in buganizer map.
   *     Add field name from buganizer as key and field name in salesforce to be
   *     replaced in the response.
   **/
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

  /**
   * @description Field names in buganizer map by field names in salesforce.
   *     Add field name from buganizer as key and field name in salesforce to be replaced
   *     in the response.
   **/
  private final static Map<String, String>  FIELD_LABEL_BY_FIELD_NAME {get {
    Map<String, String> fieldLabelByFieldName = new Map<String, String>();
    for (String label : FIELD_NAME_BY_FIELD_LABEL.keySet()) {
      fieldLabelByFieldName.put(FIELD_NAME_BY_FIELD_LABEL.get(label), label);
    }
    fieldLabelByFieldName.put('ExternalId', 'ticket id');
    return fieldLabelByFieldName;
  }}
  /**
   * @description Class to create custom exception when callout fails.
   **/
  public class IncorrectResponseException extends Exception{}
  /**
   * @description Class to create custom exception when callout fails.
   **/
  public class InvalidOperatorException extends Exception{}

  global BuganizerDataSourceConnection(DataSource.ConnectionParams connectionParams) {
    userDetails = getLoggedInUseInfo();
  }

  /**
   * @description Called when external object needs to get a list of
   *     schema from external data source, for example when the
   *     administrator clicks "Validate and Sync" in the user internface for the
   *     external data source.
   *     In simple terms, an indirect lookup relationship utilizes either a standard or
   *     custom object as a parent, and an external object as a child.
   *     Now, in an external lookup, the situation is reversed: the external object becomes
   *     the parent record.
   *     However, the child record of external lookup relationships could either be an external,
   *     custom, or standard object.
   * @return DataSource.Table data of the External Table.
   **/
  override global List<DataSource.Table> sync() {
    List<DataSource.Table> tables = new List<DataSource.Table>();
      // fields
    List<DataSource.Column> columns;
    columns = new List<DataSource.Column>();
    columns.add(createColumn(0, 'ExternalId', true, 'ExternalId', 255, 'ExternalId', null, null,
        true, Datasource.DataType.STRING_SHORT_TYPE));//Required
    columns.add(createColumn(0, 'DisplayUrl', true, 'DisplayUrl', 255, 'DisplayUrl', null, null,
        true, Datasource.DataType.URL_TYPE));//Required
      //External object
    DataSource.Table buganizerTicketTable = new DataSource.Table();
    buganizerTicketTable.labelSingular =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_SINGULAR_LABEL;
    buganizerTicketTable.labelPlural =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_PLURAL_LABEL;
    buganizerTicketTable.description =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_DESCRIPTION;
    buganizerTicketTable.name =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME;
    buganizerTicketTable.nameColumn =
        Constants.BUGANIZER_TICKET.BUGANIZER_TICKET_TABLE_DETAILS.TABLE_NAME;
    buganizerTicketTable.columns = columns;
    tables.add(buganizerTicketTable);
    return tables;
  }

  /**
   * @description Called to query and get results from the external
   *     system for SOQL queries, list views, and detail pages
   *     for an external object that’s associated with the
   *     external data source.
   *     The queryContext argument represents the query to run
   *     against a table in the external system.
   *     Returns a list of rows as the query results.
   * @param context Context of query. Contains information about the table,
   *     columns, filters etc.
   * @return DataSource.TableResult data to be fetched for external object.
   **/
  override global DataSource.TableResult query(DataSource.QueryContext context) {
    String table = context.tableSelection.tableSelected;
    filters = buildQuery('', context.tableSelection.filter);
    if (!filterValuesByLookup.isEmpty()) {
      Map<String, String> addressIdByPremisesId = getAddressIdByPremisesName();
      Map<String, String> ticketIdByOrderId = getTicketIdByOrderId();
      Map<String, String> ticketIdsByAccountId = getTicketIdsByAccountId();
      if (!addressIdByPremisesId.isEmpty()) {
        filters = filters.replaceAll('premisesId', 'address id');
        for(String premisesId : addressIdByPremisesId.keySet()) {
          filters = filters.replace(premisesId, addressIdByPremisesId.get(premisesId));
        }
      }
      if (!ticketIdByOrderId.isEmpty()) {
        filters = filters.replaceAll('orderId', 'ticket id');
        for(String orderId : ticketIdByOrderId.keySet()) {
          filters = filters.replace(orderId, ticketIdByOrderId.get(orderId));
        }
      }
      if (!ticketIdsByAccountId.isEmpty()) {
        filters = filters.replaceAll('consumerAccountId', 'ticket id');
        for(String consumerAccountId : ticketIdsByAccountId.keySet()) {
          filters = filters.replace(consumerAccountId,
              '(' + ticketIdsByAccountId.get(consumerAccountId) + ')');
        }
      }
      if (!ticketIdsByAccountId.isEmpty()) {
        filters = filters.replaceAll('serviceAccountId', 'ticket id');
        for(String serviceAccountId : ticketIdsByAccountId.keySet()) {
          filters = filters.replace(serviceAccountId,
              '(' + ticketIdsByAccountId.get(serviceAccountId) + ')');
        }
      }
    }
    List<Map<String, Object>> rows = populateLookupFields(getRows(table));
    context.queryMoreToken = queryMoreToken; // To implement pagination.

    return DataSource.TableResult.get(context, rows);
  }

  /**
   * @description Method to get the filters.
   * @param query Query for buganizer.
   * @param filter Filter apllied in the query.
   * @return Expression for filter for bugafiber API.
   **/
  private String buildQuery(String query, DataSource.Filter filter) {
    if (filter == null) {
      return query;
    }
    String append;
    DataSource.FilterType type = filter.type;
    List<Map< String, Object>> retainedRows = new List<Map< String,Object>>();

    switch on type {
      when NOT_ {
        DataSource.Filter subfilter = filter.subfilters.get(0);
        append = buildQuery('-', subfilter);// NOT sign in buganiser
      }
      when AND_ {
        append = getFilterCompound(' ', filter.subfilters);// AND sign in buganiser
      }
      when OR_ {
        append = getFilterCompound('|', filter.subfilters);// OR sign in buganiser
      }
      when else {
        append = getFilterExpression(filter);
      }
    }
    return query + append;
  }

  /**
   * @description Method to get the compound filters.
   * @param operator Compound operator.
   * @param subfilters List of DataSource.Filter data having compound filters.
   * @return Expression with compound operators.
   **/
  private String getFilterCompound(String operator, List<DataSource.Filter> subfilters) {
    if (!subfilters.isEmpty()) {
      string expression = '(';
      List<String> operands = new List<String>();
      for (DataSource.Filter subfilter : subfilters) {
        operands.add(buildQuery('', subfilter));
      }
      expression += String.join(operands, operator);
      expression += ')';
      return expression;
    } else {
      return '';
    }
  }

  /**
   * @description Method to get the filter expression.
   * @param filter DataSource.Filter data having non compound filters.
   * @return Expression with non compounf operators.
   **/
  private string getFilterExpression(DataSource.Filter filter) {
    string METHOD_NAME = 'getFilterExpression';
    string columnName = FIELD_LABEL_BY_FIELD_NAME.containsKey(filter.columnName)
        ? FIELD_LABEL_BY_FIELD_NAME.get(filter.columnName) : filter.columnName;
    string expression = '';
    string operator;
    object expectedValue = filter.columnValue;
    if (LOOKUP_FIELD_NAMES.indexOf(columnName) != -1) {
      string lookupFieldName = LOOKUP_FIELD_NAMES[LOOKUP_FIELD_NAMES.indexOf(columnName)];
      Set<String> filterValues = filterValuesByLookup.containsKey(lookupFieldName) ?
          filterValuesByLookup.get(lookupFieldName) : new Set<String>();
      filterValues.add(String.valueOf(expectedValue));
      filterValuesByLookup.put(lookupFieldName, filterValues);
    }
    try {
      switch on filter.type {
        when EQUALS{
          operator = ':'; // Equal sign in buganiser
        }
        when NOT_EQUALS{
          operator = '-'; // Not Equal sign in buganiser
        }
        when LESS_THAN{
          operator = '<';
        }
        when GREATER_THAN{
          operator = '>';
        }
        when LESS_THAN_OR_EQUAL_TO{
          operator = '<=';
        }
        when GREATER_THAN_OR_EQUAL_TO{
          operator = '>=';
        }
        when else {
          throw new InvalidOperatorException('Not a valid operator : ' + filter.type);
        }
      }
    } catch (InvalidOperatorException e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }

    if (operator != '-') {
    expression = columnName + operator + expectedValue;
    } else {
    expression = operator + columnName + ':' + expectedValue;
    }

    return expression;
  }

  /**
   * @description Called to do a full text search and get results from
   *     the external system for SOSL queries and Salesforce
   *     global searches.
   *     The SearchContext argument represents the query to run
   *     against a table in the external system.
   *     Returns results for each table that the SearchContext
   *     requested to be searched.
   * @param context DataSource.SearchContext of search. Contains information about the table,
   *     columns, filters etc.
   * @return DataSource.TableResult data to be fetched for External Object.
   **/
  override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
    List<DataSource.TableResult> results = new List<DataSource.TableResult>();
    searchString = context.searchPhrase;
    String table = context.tableSelections[0].tableSelected;
    List<Map<String, Object>> rows = populateLookupFields(getRows(table));
    results.add(DataSource.TableResult.get(true, null, table, rows));

    return results;
  }

  /**
   * @description Method to get the data to be shown in the list view.
   * @param table External Object name.
   * @return Rows to be populated in the External Object.
   **/
  private List<Map<String, Object>> getRows(String table) {
    String METHOD_NAME = 'getRows';
    List<Map<String, Object>> rows = new List<Map<String, Object>>();
    try {
      HttpResponse response = makeGetCallout();
      if (response != null) {
        String jsonString = response.getBody();
        for (String fieldLabel : FIELD_NAME_BY_FIELD_LABEL.keySet()) {
          jsonString = jsonString.replace('"' + fieldLabel + '":',
          '"' + FIELD_NAME_BY_FIELD_LABEL.get(fieldLabel) + '":');
        }

        QueryTicketJSON deserialized;
        deserialized = (QueryTicketJSON)system.JSON.deserialize(jsonString, QueryTicketJSON.class);

        if (deserialized.tickets != null) {
          for (Ticket ticket : deserialized.tickets) {
            rows.add(populateDataToRow(ticket));
          }
        }
        if (deserialized.nextPageToken != null) {
          queryMoreToken = deserialized.nextPageToken;
        }
      }
    } catch (Exception e)  {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
    return rows;
  }

  /**
   * @description Method to make callout to external system.
   * @param url Endpoint URL.
   * @return Response of the callout.
   **/
  private static HttpResponse makeGetCallout() {
    String METHOD_NAME = 'makeGetCallout';
    String jsonBody = '';
    String queryFilter = Constants.BUGANIZER_TICKET.DEFAULT_FILTER;
    String queryOrder = Constants.BUGANIZER_TICKET.DEFAULT_ORDER;
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:' + 'Generic/v1/bugafiber/querytickets');
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('GET');

    if(searchString == '') {
      if (filters == '') {
        if (userType == 'Basic') {
          queryFilter += ' assignee:' + userDetails.Email;
          queryOrder = 'service appointment start: desc';
        } else if (userType == 'Vendor') {
          String vendorManagerTeamEmails = getVendorManagerTeamEmails();
          if (vendorManagerTeamEmails == '') {
            queryFilter += ' vendor:' + userDetails.Vendor__c + ' fiber market:'
                + userDetails.Fiber_Market__c;
          } else {
            queryFilter += ' vendor:' + userDetails.Vendor__c + ' fiber market:'
            + userDetails.Fiber_Market__c + ' assignee:(' + vendorManagerTeamEmails + ')';
          }
          queryOrder = 'service appointment start: desc';
        } else if (userType == 'Manager') {
          queryOrder = 'service appointment start: desc';
        }
      } else {
        queryFilter = filters;
      }
    } else {
      queryFilter = 'ticket id:' + searchString;
    }
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
      if (resp.getstatusCode() == 200) {
        return resp;
      } else {
        throw new IncorrectResponseException('Error while connecting to Buganizer.');
      }
    } catch (IncorrectResponseException e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
  }

  /**
   * @description Method to form data to be shown in the list view.
   * @param ticketObject Deserialised ticket data.
   * @return Data row.
   **/
  private Map<String,Object> populateDataToRow(Ticket ticketObject) {
    TicketUserData ticketUserDataObject = ticketObject.ticketUserData;
    FieldValues fieldValueObject = ticketObject.fieldValues;

    ticketIds.add(String.valueOf(fieldValueObject.ticketId.integerValue));

    Map<String,Object> newRow = new Map<String,Object>();
    newRow.put('ExternalId', fieldValueObject.ticketId.integerValue);
    newRow.put('DisplayUrl', null);

    newRow.put('actions', (fieldValueObject.actions != null)
        ? fieldValueObject.actions.enumValue : '');
    if (fieldValueObject.addressId.stringValue != null) {
      addressIds.add(fieldValueObject.addressId.stringValue);
      newRow.put('addressId', fieldValueObject.addressId.stringValue);
    } else {
      newRow.put('addressId', null);
    }
    if (fieldValueObject.globalAddressId.stringValue != null) {
      globalAddressIds.add(fieldValueObject.globalAddressId.stringValue);
      newRow.put('globalAddressId', fieldValueObject.globalAddressId.stringValue);
    } else {
      newRow.put('globalAddressId', null);
    }
    newRow.put('assignee', fieldValueObject.assignee.stringValue != null ?
        fieldValueObject.assignee.stringValue : 'Not Assigned');
    newRow.put('createdDate', fieldValueObject.createdDate.timestampValue != null ?
        fieldValueObject.createdDate.timestampValue : null);
    newRow.put('customerHardwiredSpeed',
        fieldValueObject.customerHardwiredSpeed.stringValue != null
        ? fieldValueObject.customerHardwiredSpeed.stringValue : null);
    newRow.put('customerWirelessPrimaryLocationSpeed',
        fieldValueObject.customerWirelessPrimaryLocationSpeed.stringValue != null
        ? fieldValueObject.customerWirelessPrimaryLocationSpeed.stringValue : null);
    newRow.put('customerWirelessSecondaryLocationSpeed',
        fieldValueObject.customerWirelessSecondaryLocationSpeed.stringValue != null
        ? fieldValueObject.customerWirelessSecondaryLocationSpeed.stringValue : null);
    newRow.put('directedWorkCompleted', fieldValueObject.directedWorkCompleted.booleanValue);
    newRow.put('fiberJackPlacement', (fieldValueObject.fiberJackPlacement.stringValue != null && 
          fieldValueObject.fiberJackPlacement.stringValue == 'yes') ? true: false);  
    newRow.put('fiberMarket', fieldValueObject.fiberMarket.stringValue!=null
        ? fieldValueObject.fiberMarket.stringValue : '');
    newRow.put('fiberSpliceRequired', fieldValueObject.fiberSpliceRequired.booleanValue);
    newRow.put('modifiedTime', fieldValueObject.modifiedTime.timestampValue != null
        ? fieldValueObject.modifiedTime.timestampValue : null);
    newRow.put('niuLightLevel', fieldValueObject.niuLightLevel.doubleValue != null
        ? fieldValueObject.niuLightLevel.doubleValue : 0.0);
    newRow.put('objects', fieldValueObject.objects != null
        ? fieldValueObject.objects.enumValue : '');
    newRow.put('ontLightLevel', fieldValueObject.ontLightLevel.doubleValue != null
        ? fieldValueObject.ontLightLevel.doubleValue : 0.0);
    newRow.put('order', fieldValueObject.ticketId.integerValue);
    newRow.put('reRanInvisilight', (fieldValueObject.reRanInvisilight.enumValue != null &&
          fieldValueObject.reRanInvisilight.enumValue == 'yes') ? true: false);
    newRow.put('cause', fieldValueObject.cause != null ? fieldValueObject.cause.enumValue : '');
    newRow.put('appointmentDate', fieldValueObject.appointmentDate.timestampValue != null
        ? fieldValueObject.appointmentDate.timestampValue : null);
    newRow.put('servicePlan', fieldValueObject.servicePlan.stringValue!=null
        ? fieldValueObject.servicePlan.stringValue : '');
    newRow.put('serviceVisitStatus', fieldValueObject.serviceVisitStatus!=null
        ? fieldValueObject.serviceVisitStatus.enumValue : '');
    newRow.put('status', fieldValueObject.serviceVisitStatus != null
        ? fieldValueObject.serviceVisitStatus.enumValue : '');
    newRow.put('subType', fieldValueObject.subType != null
        ? fieldValueObject.subType.enumValue : '');
    newRow.put('symptoms', fieldValueObject.symptoms !=null
        ? fieldValueObject.symptoms.enumValue : '');
    newRow.put('techHardwiredSpeed', fieldValueObject.techHardwiredSpeed.stringValue != null
        ? fieldValueObject.techHardwiredSpeed.stringValue : null);
    newRow.put('techWirelessSecondaryLocationSpeed',
        fieldValueObject.techWirelessSecondaryLocationSpeed.stringValue != null
        ? fieldValueObject.techWirelessSecondaryLocationSpeed.stringValue : null);
    newRow.put('techWirelessSpeed', fieldValueObject.techWirelessSpeed.stringValue != null
        ? fieldValueObject.techWirelessSpeed.stringValue : null);
    newRow.put('vendor', fieldValueObject.vendor != null ? fieldValueObject.vendor.enumValue : '');
    newRow.put('type', fieldValueObject.workType != null
        ? fieldValueObject.workType.enumValue : '');

    return newRow;
  }

  /**
   * @description Method to create column for External Table.
   * @param decimalPlaces If the data type is numeric, the number of decimal places to the right
   *     of the decimal point.
   * @param description Description of what the column represents.
   * @param filterable Whether a result set can be filtered based on the values of the column.
   * @param label User-friendly name for the column that appears in the Salesforce user interface.
   * @param length If the column is a string data type, the number of characters in the column.
   *     If the column is a numeric data type, the total number of digits on both sides of
   *     the decimal point, but excluding the decimal point.
   * @param name Name of the column in the external system.
   * @param referenceTargetField API name of the custom field on the parent object whose values
   *     are compared against this column’s values. Matching values identify related records
   *     in an indirect lookup relationship. Applies only when the column’s data type is
   *     INDIRECT_LOOKUP_TYPE. For other data types, this value is ignored.
   * @param referenceTo API name of the parent object in the relationship that’s represented by
   *     this column. Applies only when the column’s data type is LOOKUP_TYPE,
   *     EXTERNAL_LOOKUP_TYPE, or INDIRECT_LOOKUP_TYPE. For other data types, this value is
   *     ignored.
   * @param sortable Whether a result set can be sorted based on the values of the column via an
   *     ORDER BY clause.
   * @param type Data type of the column.
   * @return DataSource.Column object.
   **/
  public static DataSource.Column createColumn(Integer decimalPlaces, String description,
      Boolean filterable, String label, Integer length, String name, String referenceTargetField,
      String referenceTo, Boolean sortable, DataSource.DataType type) {
    DataSource.Column col = new DataSource.Column();
    col.decimalPlaces = decimalPlaces;
    col.description = description;
    col.filterable = filterable;
    col.label = label;
    col.length = length;
    col.name = name;
    col.referenceTargetField = referenceTargetField;
    col.referenceTo = referenceTo;
    col.sortable = sortable;
    col.type = type;

    return col;
  }

  /**
   * @description Method to Order by Ticket Id.
   * @param ticketIds Set of Bugafiber ticket ids.
   * @return Map of Orders by corresponding Ticket Id.
   **/
  public static Map<String, Order> getOrderByTicketId() {
    Map<String, Order> orderByTicketId = new Map<String, Order>();
    for (Order order : [
        SELECT
          Id,
          AccountId,
          Appointment_Ticket_Id__c
        FROM
          Order
        WHERE
          Appointment_Ticket_Id__c IN :ticketIds
    ]) {
      orderByTicketId.put(order.Appointment_Ticket_Id__c, order);
    }
    return orderByTicketId;
  }

  /**
   * @description Method to Premises Id by Address Id.
   * @param addressIds Set of addressIds form Bugafiber Api
   * @return Map of Premises Id by corresponding Address Id.
   **/
  public static Map<String, String> getPremisesIdAccountIdByAddressId(){
    // vlocity_cmt__PremisesIdentifier__c will be changed to Global_Address_Id__c in future

    Map<String, String> premiseIdAccountIdByAddressId = new Map<String, String>();
    Map<String, String> premiseIdByAddressId = new Map<String, String>();
    Map<String, String> accountIdByAddressId = new Map<String, String>();
    for (vlocity_cmt__Premises__c premises : [
        SELECT
          Id,
          Global_Address_Id__c,
          vlocity_cmt__StreetAddress__c,
          vlocity_cmt__City__c,
          vlocity_cmt__State__c,
          vlocity_cmt__Country__c
        FROM
          vlocity_cmt__Premises__c
        WHERE
          Global_Address_Id__c IN : globalAddressIds
    ]) {
      String address =
          premises.vlocity_cmt__StreetAddress__c + ', ' +premises.vlocity_cmt__City__c + ', ' + 
          premises.vlocity_cmt__State__c + ',' + premises.vlocity_cmt__Country__c;
      fullAddressByPremisesId.put(premises.Id, address);
      premiseIdByAddressId.put(premises.Global_Address_Id__c, premises.Id);
    }
    if (!premiseIdByAddressId.isEmpty()) {
      for (Account account : [
        SELECT
          Id,
          vlocity_cmt__PremisesId__c,
          vlocity_cmt__PremisesId__r.Global_Address_Id__c,
          ParentId,
          RecordType.Name,
          vlocity_cmt__Status__c,
          Parent.vlocity_cmt__PrimaryContactId__c,
          Parent.vlocity_cmt__PrimaryContactId__r.name,
          Parent.vlocity_cmt__PrimaryContactId__r.email,
          Parent.vlocity_cmt__PrimaryContactId__r.phone
        FROM
          Account
        WHERE
          vlocity_cmt__PremisesId__c IN :premiseIdByAddressId.values()
        AND
          (RecordTypeId = :RecordTypeUtils.CONSUMER_ACCOUNT_ID
          OR RecordTypeId = :RecordTypeUtils.SERVICE_ACCOUNT_ID)
        AND
          (vlocity_cmt__Status__c = 'Pending' OR vlocity_cmt__Status__c = 'Active')
      ]) {
        if(account.RecordTypeId == RecordTypeUtils.CONSUMER_ACCOUNT_ID) {
          accountIdByAddressId.put(account.vlocity_cmt__PremisesId__r
             .Global_Address_Id__c, account.Id);
        } else if(account.RecordTypeId == RecordTypeUtils.SERVICE_ACCOUNT_ID) {
          accountIdByAddressId.put(account.vlocity_cmt__PremisesId__r
             .Global_Address_Id__c, account.Id);
          parentAccoutIdByServiceAccountId.put(account.Id, account.ParentId);
          accountStatusByServiceAccountId.put(account.Id, account.vlocity_cmt__Status__c);
            if (account.ParentId !=Null &&
                account.Parent.vlocity_cmt__PrimaryContactId__c != NULL) {
              primaryContactByAccount.put(account.id, account);
            }
        }
      }
      for (String globalAddressId : premiseIdByAddressId.keySet()) {
        premiseIdAccountIdByAddressId.put(
            globalAddressId, premiseIdByAddressId.get(globalAddressId) +
            (accountIdByAddressId.containsKey(globalAddressId) ? ('_' +
            accountIdByAddressId.get(globalAddressId)) : ''));
      }
    }
    return premiseIdAccountIdByAddressId;
  }

  /**
   * @description Method to Address Id by Premises Id.
   * @return Map of Address Id by corresponding Premises Id.
   **/
  public static Map<String, String> getAddressIdByPremisesName() {

    Map<String, String> addressIdByPremisesId = new Map<String, String>();
    if (filterValuesByLookup.containsKey('premisesId') &&
        !filterValuesByLookup.get('premisesId').isEmpty()) {
      for (vlocity_cmt__Premises__c premises : [
          SELECT
            Id,
            Name,
            Global_Address_Id__c,
            vlocity_cmt__StreetAddress__c,
            vlocity_cmt__City__c,
            vlocity_cmt__State__c,
            vlocity_cmt__Country__c
          FROM
            vlocity_cmt__Premises__c
          WHERE
            Id IN :filterValuesByLookup.get('premisesId')
      ]) {
        String address =
            premises.vlocity_cmt__StreetAddress__c + ' ' +premises.vlocity_cmt__City__c + ' ' + 
            premises.vlocity_cmt__State__c + ' ' + premises.vlocity_cmt__Country__c;
        addressIdByPremisesId.put(premises.Id, premises.Global_Address_Id__c);
      }
    }
    return addressIdByPremisesId;
  }

  /**
   * @description Method to Ticket Id by Order Id.
   * @return Map of Ticket Id by corresponding Order Id.
   **/
  public static Map<String, String> getTicketIdByOrderId(){
    Map<String, String> ticketIdByOrderId = new Map<String, String>();
    if (filterValuesByLookup.containsKey('orderId') &&
        !filterValuesByLookup.get('orderId').isEmpty()) {
      for (Order order : [
          SELECT
            Id,
            OrderNumber,
            Appointment_Ticket_Id__c
          FROM
            Order
          WHERE
            Id IN :filterValuesByLookup.get('orderId')
        ]) {
          ticketIdByOrderId.put(order.Id, order.Appointment_Ticket_Id__c);
      }
    }
    return ticketIdByOrderId;
  }

  /**
   * @description Method to Ticket Ids by Account Id.
   * @return Map of Ticket Ids by corresponding Account Id.
   **/
  public static Map<String, String> getTicketIdsByAccountId() {
    Map<String, String> ticketIdsByAccountId = new Map<String, String>();
    if (filterValuesByLookup.containsKey('consumerAccountId') &&
        !filterValuesByLookup.get('consumerAccountId').isEmpty()) {
      for (Order order : [
          SELECT
            Id,
            Appointment_Ticket_Id__c,
            AccountId
          FROM
            Order
          WHERE
            AccountId IN :filterValuesByLookup.get('consumerAccountId')
      ]) {
        if(order.Appointment_Ticket_Id__c != null) {
          String ticketIds = ticketIdsByAccountId.containsKey(order.AccountId) ?
              order.Appointment_Ticket_Id__c + '|' + ticketIdsByAccountId.get(order.AccountId) :
              order.Appointment_Ticket_Id__c;
          ticketIdsByAccountId.put(order.AccountId, ticketIds);
        }
      }
    }
    return ticketIdsByAccountId;
  }

  /**
   * @description Method to populated lookup fields.
   * @param ticketRows Data row to for populating lookup fields.
   * @return List of data row with populated lookup fields.
   **/
  public static List<Map<String,Object>> populateLookupFields(
      List<Map<String,Object>> ticketRows) {
    Integer routerCount;
    List<Map<String,Object>> rows = ticketRows;
    Map<String, Order> orderByTicketId = getOrderByTicketId();
    Map<String, String> premisesIdAccountIdByAddressId =
        getPremisesIdAccountIdByAddressId();
    List<OrderItem> routerOrderItem = new List<OrderItem>();
    List<OrderItem> servicePlanOrderItem = new List<OrderItem>();
    List<Asset> routerAssetItem = new List<Asset>();
    List<vlocity_cmt__ServicePoint__c> servicePointList = new List<vlocity_cmt__ServicePoint__c>();
    routerOrderItem = getRouterCount(ticketRows,orderByTicketId);
    routerAssetItem = getAssetCount(ticketRows,premisesIdAccountIdByAddressId);
    servicePointList = getFiberJackModel(ticketRows,premisesIdAccountIdByAddressId);
    servicePlanOrderItem = getServicePlan(orderByTicketId,ticketRows);
    for(Map<String,Object> row : rows) {
      Integer ticketId = (Integer)row.get('ExternalId');
      if (orderByTicketId.containsKey(String.valueOf(ticketId))) {
        row.put('orderId', orderByTicketId.get(String.valueOf(ticketId)).Id);
        String servicePlan = 'NA';
        for(OrderItem orderItem : servicePlanOrderItem) {
          if(orderItem.OrderId == orderByTicketId.get(String.valueOf(ticketId)).Id) {
            servicePlan = orderItem.Product2.Name;
          }
        }
        row.put('productPlan', servicePlan);
        String orderType = String.valueOf(row.get('type'));
        if (!routerOrderItem.isEmpty() &&
            (orderType.equalsIgnoreCase(Constants.BUGAFIBER.TYPE.UPGRADE)
            || orderType.equalsIgnoreCase(Constants.BUGAFIBER.TYPE.Install))){
          routerCount = 0;
          for(OrderItem ordItem : routerOrderItem) {
            //servicePlanByOrderId.put(ordItem.Id, ordItem.Product.Name);
            if(ordItem.Order.Appointment_Ticket_Id__c.equalsIgnoreCase(String.valueOf(ticketId))) {
              routerCount = routerCount+1;
            }
            row.put('RouterQuantity', routerCount);
          }
        } else {
          row.put('RouterQuantity', 0);
        }
      }
      String globalAddressId = (String)row.get('globalAddressId');
      if (!premisesIdAccountIdByAddressId.isEmpty() &&
          premisesIdAccountIdByAddressId.containsKey(globalAddressId)) {
        if (premisesIdAccountIdByAddressId.get(globalAddressId).contains('_')) {
          row.put('premisesId', premisesIdAccountIdByAddressId.get(globalAddressId).split('_')[0]);
          String serviceAccountId =
              premisesIdAccountIdByAddressId.get(globalAddressId).split('_')[1];
          row.put('consumerAccountId', parentAccoutIdByServiceAccountId.get(serviceAccountId));
          row.put('serviceAccountId', serviceAccountId);
          row.put('accountStatus', accountStatusByServiceAccountId.get(serviceAccountId));
          if (!primaryContactByAccount.isEmpty()) {
            row.put('customerName', primaryContactByAccount.get(
                serviceAccountId).Parent.vlocity_cmt__PrimaryContactId__r.name);
            row.put('customerPhone', primaryContactByAccount.get(
                serviceAccountId).Parent.vlocity_cmt__PrimaryContactId__r.phone);
            row.put('customerEmail', primaryContactByAccount.get(
                serviceAccountId).Parent.vlocity_cmt__PrimaryContactId__r.email);
          }
          String strType = String.valueOf(row.get('type'));
          if (strType == 'Repair' ) {
            routerCount = 0;
            for(Asset asset : routerAssetItem) {
              if(serviceAccountId.equalsIgnoreCase(asset.vlocity_cmt__ServiceAccountId__c)) {
                routerCount = routerCount+1;
              }
            row.put('RouterQuantity', routerCount);
            }
          }
        } else {
          row.put('premisesId', premisesIdAccountIdByAddressId.get(globalAddressId));
        }
         String premisesId =  String.valueOf(row.get('premisesId'));
         String fiberJack = 'Not Present';
         row.put('fullAddress', fullAddressByPremisesId.get(premisesId));
         if(!servicePointList.isEmpty() && String.isNotBlank(premisesId)) {
           for(vlocity_cmt__ServicePoint__c servicePoint : servicePointList) {
             if(premisesId.equalsIgnoreCase(servicePoint.vlocity_cmt__PremisesId__c)) {
               fiberJack = (servicePoint.Model__c != NULL) ? servicePoint.Model__c :'Not Present' ;
             }
           }
         }
         row.put('fiberJack', fiberJack);
      }
    }
    return rows;
  }

  /**
   * @description Method to get logged in User information
   * @return Logged in User details.
   */
  public static User getLoggedInUseInfo() {
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
    return user;
  }

  /**
   * @description Method to get the emails of the users for whom the logged in User is
   *     Manager to.
   * @return Concatinated emails
   */
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

  /**
   * @description Fetch value of model number from service point(Fiber Jack).
   */
  Public static List<vlocity_cmt__ServicePoint__c> getFiberJackModel (List<Map<String,Object>>
      ticketRows, Map<String, String> premisesIdAccountIdByAddressId) {
   List<String> premiseIdList = new List <String>();
   for(Map<String,Object> row : ticketRows){
   String globalAddressId = (String)row.get('globalAddressId');
     if(!premisesIdAccountIdByAddressId.isEmpty() &&
         premisesIdAccountIdByAddressId.containsKey(globalAddressId)) {
       if(!premisesIdAccountIdByAddressId.isEmpty() &&
           premisesIdAccountIdByAddressId.containsKey(globalAddressId) &&
           premisesIdAccountIdByAddressId.get(globalAddressId).contains('_')) {
         premiseIdList.add(premisesIdAccountIdByAddressId.get(globalAddressId).split('_')[0]);
       } else {
        premiseIdList.add(String.valueOf(premisesIdAccountIdByAddressId.get(globalAddressId)));
       }
     }
   }
   List<vlocity_cmt__ServicePoint__c> servicePoint = [
        SELECT Id, Model__c, vlocity_cmt__PremisesId__c
        FROM vlocity_cmt__ServicePoint__c
        WHERE vlocity_cmt__PremisesId__c IN :premiseIdList
        LIMIT 1];
   return servicePoint;
  }

  /**
   * @description Fetch total number of router used in order based on operation ticket
   */
  Public static List<OrderItem> getServicePlan (Map<String, Order> orderByTicketId,
      List<Map<String,Object>> rows){
    List<String> productName = new List<String>{'100 meg', 'neighborhood', '1 gig', '2 gig'};
    List<String> listOfUpgradeOrderId = new List<String>();
    List<OrderItem> ListOfOrderItemObj = new List<OrderItem>();
    String servicePlan;
    String orderId;
    List<String> orderidList = new List<String>();
    for(Map<String,Object> row : rows) {
      Integer ticketId = (Integer)row.get('ExternalId');
      if (orderByTicketId.containsKey(String.valueOf(ticketId))) {
        orderidList.add(orderByTicketId.get(String.valueOf(ticketId)).Id);
      }
    }
    ListOfOrderItemObj = [SELECT Id,
          Order.Appointment_Ticket_Id__c,
          Product2.Name,
          OrderId
          FROM OrderItem
          WHERE Product2.Name IN :productName
          AND OrderId IN :orderidList LIMIT 1];
   servicePlan = (ListOfOrderItemObj.isEmpty()) ? 'NA' : ListOfOrderItemObj[0].Product2.Name;
   servicePlanByOrderId.put(orderId, servicePlan);
   return ListOfOrderItemObj;
  }

  /**
   * @description Fetch total number of router used in order based on operation ticket
   */
  Public static List<OrderItem> getRouterCount (List<Map<String,Object>> ticketRows,
      Map<String, Order> orderByTicketId){
    List<String> routerValue = new List<String>{'Google Wifi','Multi-Gig Router','Network Box'};
    Integer productCount;
    List<String> listOfUpgradeOrderId = new List<String>();
    List<String> listOfInstallOrderId = new List<String>();
    List<OrderItem> ListOfOrderItemObj = new List<OrderItem>();
    List<OrderItem> ListOfOrderTotalItemObj = new List<OrderItem>();
    for(Map<String,Object> row : ticketRows){
      Integer ticketId = (Integer)row.get('ExternalId');
      if (orderByTicketId.containsKey(String.valueOf(ticketId))) {
        if(Constants.BUGAFIBER.TYPE.UPGRADE.equalsIgnoreCase(String.valueOf(row.get('type')))) {
          listOfUpgradeOrderId.add(orderByTicketId.get(String.valueOf(ticketId)).Id);
        } else if(Constants.BUGAFIBER.TYPE.Install.equalsIgnoreCase(
            String.valueOf(row.get('type')))) {
          listOfInstallOrderId.add(orderByTicketId.get(String.valueOf(ticketId)).Id);
        }
      }
    }
    if (!listOfUpgradeOrderId.isEmpty()) {
      ListOfOrderItemObj = [SELECT Id,
          Order.Appointment_Ticket_Id__c,
          Product2.Name
          FROM OrderItem
          WHERE Product2.Name IN :routerValue
          AND OrderId IN :listOfUpgradeOrderId
          AND vlocity_cmt__Action__c = :Constants.ORDER_ITEM.ACTION.ADD];
      if(!ListOfOrderItemObj.isEmpty()){
        ListOfOrderTotalItemObj.addAll(ListOfOrderItemObj);
      }
    }else if (!listOfInstallOrderId.isEmpty()) {
      ListOfOrderItemObj = [SELECT Id,
          Order.Appointment_Ticket_Id__c,
          Product2.Name
          FROM OrderItem
          WHERE Product2.Name IN :routerValue
          AND OrderId IN :listOfInstallOrderId];
      if(!ListOfOrderItemObj.isEmpty()){
        ListOfOrderTotalItemObj.addAll(ListOfOrderItemObj);
      }
   }
   return ListOfOrderTotalItemObj;
  }

  /**
   * @description Fetch total number of router used in Asset based on operation ticket
   */
  Public static List<Asset> getAssetCount (List<Map<String,Object>> ticketRows,
      Map<String, String> premisesIdAccountIdByAddressId){
    List<string> routerValue = new List<string>{'Multi-Gig Router', 'Google Wifi', 'Network Box'};
    List<String> accountIdList = new List<String>();
    List<Asset> assetList = new List<Asset>();
    for(Map<String,Object> row : ticketRows) {
      String globalAddressId = (String)row.get('globalAddressId');
      if (!premisesIdAccountIdByAddressId.isEmpty() &&
          premisesIdAccountIdByAddressId.containsKey(globalAddressId)) {
        if (premisesIdAccountIdByAddressId.get(globalAddressId).contains('_') &&
            'Repair'.equalsIgnoreCase(string.valueOf(row.get('type')))) {
          accountIdList.add(premisesIdAccountIdByAddressId.get(globalAddressId).split('_')[1]);
        }
      }
    }
    assetList = [SELECT Id,
        vlocity_cmt__ServiceAccountId__c
        FROM Asset
        WHERE Name IN :routerValue
        AND vlocity_cmt__ServiceAccountId__c IN :accountIdList];
    return assetList;
  }

 /**
  * @description Wrapper class to deserialize response from Query Ticket API.
  */
  public class QueryTicketJSON {
    @AuraEnabled public List<Ticket> tickets;
    @AuraEnabled public String nextPageToken;
    @AuraEnabled public Long totalSize;
  }

 /**
  * @description Wrapper class to hold Ticket details.
  */
  public class Ticket {
    @AuraEnabled public FieldValues fieldValues;
    @AuraEnabled public TicketUserData ticketUserData;
  }

 /**
  * @description Wrapper class to hold TicketUserData details.
  */
  public class TicketUserData {
    @AuraEnabled public UserAccountWrap userAccountInfo;
  }

 /**
  * @description Wrapper class to hold UserAccountWrap details.
  */
  public class UserAccountWrap {
    @AuraEnabled public String consumerAccountId;
    @AuraEnabled public String serviceAccountId;
  }

 /**
  * @description Wrapper class to hold FieldValues details.
  */
  public class FieldValues {
    @AuraEnabled public IntegerWrap ticketId;
    @AuraEnabled public EnumWrap actions;
    @AuraEnabled public StringWrap addressId;
    @AuraEnabled public StringWrap assignee;
    @AuraEnabled public TimeStampWrap createdDate;
    @AuraEnabled public StringWrap customerHardwiredSpeed;
    @AuraEnabled public StringWrap customerWirelessPrimaryLocationSpeed;
    @AuraEnabled public StringWrap customerWirelessSecondaryLocationSpeed;
    @AuraEnabled public BooleanWrap directedWorkCompleted;
    @AuraEnabled public StringWrap fiberJackPlacement;
    @AuraEnabled public StringWrap fiberMarket;
    @AuraEnabled public BooleanWrap fiberSpliceRequired;
    @AuraEnabled public StringWrap globalAddressId;
    @AuraEnabled public TimeStampWrap modifiedTime;
    @AuraEnabled public DoubleWrap niuLightLevel;
    @AuraEnabled public EnumWrap objects;
    @AuraEnabled public DoubleWrap ontLightLevel;
    @AuraEnabled public EnumWrap reRanInvisilight;
    @AuraEnabled public EnumWrap cause;
    @AuraEnabled public TimeStampWrap appointmentDate;
    @AuraEnabled public StringWrap servicePlan;
    @AuraEnabled public EnumWrap serviceVisitStatus;
    @AuraEnabled public EnumWrap status;
    @AuraEnabled public EnumWrap subType;
    @AuraEnabled public EnumWrap symptoms;
    @AuraEnabled public StringWrap techHardwiredSpeed;
    @AuraEnabled public StringWrap techWirelessSecondaryLocationSpeed;
    @AuraEnabled public StringWrap techWirelessSpeed;
    @AuraEnabled public EnumWrap vendor;
    @AuraEnabled public EnumWrap workType;
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
  * @description Wrapper class to hold Boolean Value.
  */
  public class BooleanWrap {
    @AuraEnabled public Boolean booleanValue;
  }

 /**
  * @description Wrapper class to hold Double Value.
  */
  public class DoubleWrap {
    @AuraEnabled public Double doubleValue;
  }

 /**
  * @description Wrapper class to hold Integer Value.
  */
  public class IntegerWrap {
    @AuraEnabled public Integer integerValue;
  }
}