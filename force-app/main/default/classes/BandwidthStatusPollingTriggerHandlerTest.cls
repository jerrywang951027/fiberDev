/**
 * @description Test class for BandwidthStatusPollingTriggerHandler
 */
@isTest
public class BandwidthStatusPollingTriggerHandlerTest {

  /**
   * @description This method inserts the required data for unit test.
   * @return null
   */
  @TestSetup
  static void setupData(){
    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;
    Product2 product2 = TestDataFactory.getProductData('TestName','TestFamily',
      Constants.PRODUCT.PRODUCT_CODE.PRD_FBR_INTERNET);
    insert product2;
    Pricebook2 pBook = new Pricebook2(
        Id=Test.getStandardPriceBookId(), IsActive=true);
    PricebookEntry pbEntry = TestDataFactory.getPriceBookEntry(
        pBook.Id, product2.Id);
    insert pbEntry;
    Order orderRecord = TestDataFactory.getOrderData(accountRecord.Id);
    orderRecord.Pricebook2Id = pBook.Id;
    orderRecord.Is_Activated__c = false;
    orderRecord.Force_Billing__c = false;
    orderRecord.vlocity_cmt__OrderStatus__c =
        Constants.ORDER.STATUS.IN_PROGRESS;
    insert orderRecord;
    OrderItem itemRecord = TestDataFactory.getOrderItemData (
        orderRecord.Id, pbEntry.Id, product2.Id);
    insert itemRecord;
    vlocity_cmt__FulfilmentRequest__c fulfilmentRequest =
        TestDataFactory.getFrlData(orderRecord.Id);
    insert fulfilmentRequest;
    vlocity_cmt__FulfilmentRequestLine__c fulfilmentRequestLine =
    TestDataFactory.getFrlItemData(product2.Id, fulfilmentRequest.Id);
    fulfilmentRequestLine.vlocity_cmt__LineNumber__c = 'E911';
    fulfilmentRequestLine.Async_Transaction_Status__c = 'E911 In Progress';
    vlocity_cmt__FulfilmentRequestLine__c fulfilmentRequestLinePort =
    TestDataFactory.getFrlItemData(product2.Id, fulfilmentRequest.Id);
    fulfilmentRequestLinePort.vlocity_cmt__LineNumber__c = 'PortIn';
    fulfilmentRequestLinePort.Async_Transaction_Status__c =
        'Port-in In Progress';
    insert new List<vlocity_cmt__FulfilmentRequestLine__c>{
        fulfilmentRequestLine, fulfilmentRequestLinePort};
    // This turns all the Vlocity triggers on
    vlocity_cmt__TriggerSetup__c allTrigger =
        new vlocity_cmt__TriggerSetup__c(Name='AllTriggers',
        vlocity_cmt__IsTriggerOn__c=true);
    insert allTrigger;
    // Create dataraptor.
    vlocity_cmt__DRBundle__c e911Dr = new vlocity_cmt__DRBundle__c(
        Name = 'XOM_TransformE911PubSubResponse',
        vlocity_cmt__DRMapName__c = 'XOM_TransformE911PubSubResponse',
        vlocity_cmt__Type__c = 'Transform',
        vlocity_cmt__InterfaceObject__c = 'json',
        vlocity_cmt__InputType__c = 'XML',
        vlocity_cmt__OutputType__c = 'JSON'
    );
    vlocity_cmt__DRBundle__c portInDr = new vlocity_cmt__DRBundle__c(
        Name = 'XOM_TransformPortinPubSubResponse',
        vlocity_cmt__DRMapName__c = 'XOM_TransformPortinPubSubResponse',
        vlocity_cmt__Type__c = 'Transform',
        vlocity_cmt__InterfaceObject__c = 'json',
        vlocity_cmt__InputType__c = 'XML',
        vlocity_cmt__OutputType__c = 'JSON'
    );
    insert new List<vlocity_cmt__DRBundle__c> {e911Dr, portInDr};
    List<Object> transformErrorResponse = 
        (List<Object>)JSON.deserializeUntyped(
        '[{\"errorCode\":\"7401\",'+
        '\"errorDescription\":\"Order Rejected.'
        +'\"}]');
    // Create dataraptor mappings.
    List<vlocity_cmt__DRMapItem__c> drMaps = new List<vlocity_cmt__DRMapItem__c>{
        new vlocity_cmt__DRMapItem__c(
          Name='XOM_TransformE911PubSubResponse',
          vlocity_cmt__MapId__c ='XOM_TransformE911PubSubResponse1',
          vlocity_cmt__DomainObjectCreationOrder__c = 1,
          vlocity_cmt__InterfaceFieldAPIName__c = 'processingStatus', 
          vlocity_cmt__DomainObjectAPIName__c = 'json', 
          vlocity_cmt__DomainObjectFieldAPIName__c = 'processingStatus',
          vlocity_cmt__DomainObjectFieldType__c = 'String',
          vlocity_cmt__DefaultValue__c='EXCEPTION'
      ),
      new vlocity_cmt__DRMapItem__c(
          Name='XOM_TransformE911PubSubResponse',
          vlocity_cmt__MapId__c ='XOM_TransformE911PubSubResponse2',
          vlocity_cmt__DomainObjectCreationOrder__c = 2,
          vlocity_cmt__InterfaceFieldAPIName__c = 'errors', 
          vlocity_cmt__DomainObjectAPIName__c = 'json', 
          vlocity_cmt__DomainObjectFieldAPIName__c = 'errors',
          vlocity_cmt__DomainObjectFieldType__c = 'Object',
          vlocity_cmt__DefaultValue__c=JSON.serialize(transformErrorResponse)
      ),
      new vlocity_cmt__DRMapItem__c(
          Name='XOM_TransformPortinPubSubResponse',
          vlocity_cmt__MapId__c ='XOM_TransformPortinPubSubResponse1',
          vlocity_cmt__DomainObjectCreationOrder__c = 1,
          vlocity_cmt__InterfaceFieldAPIName__c = 'errors', 
          vlocity_cmt__DomainObjectAPIName__c = 'json', 
          vlocity_cmt__DomainObjectFieldAPIName__c = 'errors',
          vlocity_cmt__DomainObjectFieldType__c = 'Object',
          vlocity_cmt__DefaultValue__c=JSON.serialize(transformErrorResponse)
      ),
      new vlocity_cmt__DRMapItem__c(
          Name='XOM_TransformPortinPubSubResponse',
          vlocity_cmt__MapId__c ='XOM_TransformPortinPubSubResponse2',
          vlocity_cmt__DomainObjectCreationOrder__c = 2,
          vlocity_cmt__InterfaceFieldAPIName__c = 'processingStatus', 
          vlocity_cmt__DomainObjectAPIName__c = 'json', 
          vlocity_cmt__DomainObjectFieldAPIName__c = 'processingStatus',
          vlocity_cmt__DomainObjectFieldType__c = 'String',
          vlocity_cmt__DefaultValue__c='EXCEPTION'
      )
    };
    insert drMaps;
  }

  /**
   * @description This method test the functionality for the
   * E911 and Portin event subscribe.
   * @return null
   */
  @isTest
  static void publishingPollingEventShouldCallApi() {
    List<BandWidth_Status_Polling__e> events =
        new List<BandWidth_Status_Polling__e>();
    String actualPortinFrlAsyncStatus = null;
    String expectedPortinFrlAsyncStatus =
        Constants.FRL.ASYNC_TRANSACTION_STATUS.PORTIN_IN_PROGRESS;
    String actualE911FrlAsyncStatus = null;
    String expectedE911FrlAsyncStatus =
        Constants.FRL.ASYNC_TRANSACTION_STATUS.E911_IN_PROGRESS;
    List<vlocity_cmt__FulfilmentRequestLine__c> frls = [
        SELECT
          Id,
          vlocity_cmt__LineNumber__c
        FROM
          vlocity_cmt__FulfilmentRequestLine__c
        WHERE
          vlocity_cmt__LineNumber__c  = 'E911'
        OR
        vlocity_cmt__LineNumber__c  = 'PortIn'
    ];
    for(vlocity_cmt__FulfilmentRequestLine__c frl: frls) {
      BandWidth_Status_Polling__e event = new BandWidth_Status_Polling__e(
        FRL_Id__c = frl.Id,
        Current_Status__c = 'RECIEVED',
        Event_Type__c = frl.vlocity_cmt__LineNumber__c,
        Bandwidth_Order_Id__c = 'bc5d39d9-f965-4697-a944-80fc8c6e5'
      );
      events.add(event);
    }
    Test.startTest();
      Test.setMock(HttpCalloutMock.class,
          new MockGenerator('E911PubSubResponse'));
      EventBus.publish(events);
      Test.getEventBus().deliver();
    Test.stopTest();
    List<vlocity_cmt__FulfilmentRequestLine__c> updatedFrls = [
        SELECT
          Id,
          vlocity_cmt__LineNumber__c,
          Async_Transaction_Status__c
        FROM
          vlocity_cmt__FulfilmentRequestLine__c
        WHERE
          vlocity_cmt__LineNumber__c  = 'E911'
        OR
          vlocity_cmt__LineNumber__c  = 'PortIn'
    ];
    for(vlocity_cmt__FulfilmentRequestLine__c updatedFrl: updatedFrls) {
      if(updatedFrl.vlocity_cmt__LineNumber__c == 'E911') {
        actualE911FrlAsyncStatus = updatedFrl.Async_Transaction_Status__c;
      } else if(updatedFrl.vlocity_cmt__LineNumber__c == 'PortIn') {
        actualPortinFrlAsyncStatus = updatedFrl.Async_Transaction_Status__c;
      }
    }
    System.assertEquals(expectedPortinFrlAsyncStatus, actualPortinFrlAsyncStatus,
        'Portin frl async status did not matched.');    
    System.assertEquals(expectedE911FrlAsyncStatus, actualE911FrlAsyncStatus,
        'E911 frl async status did not matched.');
  }
  
  /**
   * @description This method test the scenario when 
   * the callout returns 400 status code.
   * @return null
   */
  @isTest
  static void passingIncorrectOrderIdShouldCreateErrorLog() {
    String expectedDescription = '<?xml version="1.0"><E911OrderReportResponse>'
          +'<ResponseStatus><ErrorCode>400</ErrorCode></ResponseStatus>'
          +'</E911OrderReportResponse>Bad Request';
    String expectedClassName =
        BandwidthStatusPollingCallout.CLASS_NAME;
    String expectedMethodName =
        BandwidthStatusPollingCallout.API_CALLOUT_METHOD_NAME;
    vlocity_cmt__FulfilmentRequestLine__c frl = [
        SELECT
          Id,
          vlocity_cmt__LineNumber__c
        FROM
          vlocity_cmt__FulfilmentRequestLine__c
        WHERE
          vlocity_cmt__LineNumber__c  = 'E911'
    ];
    BandWidth_Status_Polling__e event = new BandWidth_Status_Polling__e(
        FRL_Id__c = frl.Id,
        Current_Status__c = 'RECIEVED',
        Event_Type__c = 'E911',
        Bandwidth_Order_Id__c = 'bc5d39d9-f965-4697-a944-80fc8c6e5'
    );
    Test.startTest();
      Test.setMock(HttpCalloutMock.class,
          new MockGenerator('E911PubSubErrorResponse'));
      EventBus.publish(event);
      Test.getEventBus().deliver();
    Test.stopTest();
    Log__c log = [
        SELECT
          Id,
          Class__c,
          Method__c,
          Description__c
        FROM
          Log__c
        LIMIT 1
    ];
    System.assertEquals(expectedClassName, log.Class__c,
        'Class name did not matched.');
    System.assertEquals(expectedMethodName, log.Method__c,
        'Method name did not matched.');
    System.assertEquals(expectedDescription, log.Description__c,
        'Description did not matched.');
  }

  /**
   * @description This method test when wrong Event_Type__c is inserted.
   * @return null
   */
  @isTest
  static void passingIncorrectEventShouldCreateErrorLog() {
    String expectedDescription =
        BandwidthStatusPollingTriggerHandler.ERROR_MESSAGE_EVENT_TYPE_NOT_MATCHED;
    String expectedClassName =
        BandwidthStatusPollingTriggerHandler.CLASS_NAME;
    String expectedMethodName =
        BandwidthStatusPollingTriggerHandler.SET_CALLOUT_DETAILS_METHOD_NAME;
    vlocity_cmt__FulfilmentRequestLine__c frl = [
        SELECT
          Id,
          vlocity_cmt__LineNumber__c
        FROM
          vlocity_cmt__FulfilmentRequestLine__c
        WHERE
          vlocity_cmt__LineNumber__c  = 'E911'
    ];
    BandWidth_Status_Polling__e event = new BandWidth_Status_Polling__e(
        FRL_Id__c = frl.Id,
        Current_Status__c = 'RECIEVED',
        Event_Type__c = 'CreateSubscription',
        Bandwidth_Order_Id__c = 'bc5d39d9-f965-4697-a944-80fc8c6e5'
    );
    Test.startTest();
      EventBus.publish(event);
      Test.getEventBus().deliver();
    Test.stopTest();
    expectedDescription = String.format(expectedDescription,
        new List<String>{event.Event_Type__c});
    Log__c log = [
        SELECT
          Id,
          Class__c,
          Method__c,
          Description__c
        FROM
          Log__c
        LIMIT 1
    ];
    System.assertEquals(expectedClassName, log.Class__c,
        'Class name did not matched.');
    System.assertEquals(expectedMethodName, log.Method__c,
        'Method name did not matched.');
    System.assertEquals(expectedDescription, log.Description__c,
        'Description did not matched.');
  }

}