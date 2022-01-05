/**
* @description This class is used for test coverage for CpqAppHandlerHookHelper class.
*/
@isTest
public class CpqAppHandlerHookHelperTest {
  /**
  * @description This method sets the test data.
  * @return null
  */
  @testSetup static void testSetup() {
    //Insert  vlocity_cmt__Premises__c record
    vlocity_cmt__Premises__c premises =
        new vlocity_cmt__Premises__c();
    premises.Name = 'TestPremises';
    insert premises;
    //Insert ServicePoint data
    vlocity_cmt__ServicePoint__c servicePoint =
        new vlocity_cmt__ServicePoint__c();
    servicePoint.Name = 'TestService';
    servicePoint.vlocity_cmt__PremisesId__c = Premises.id;
    servicePoint.MODEL__c = 'GFLT100';
    servicePoint.Network_Terminal_Type__c = 'Fiber Jack';
    servicePoint.vlocity_cmt__Status__c = 'Connected';
    insert servicePoint;
    //Insert Account data
    Account accountObject = new Account();
    accountObject.name = 'Test456';
    accountObject.vlocity_cmt__PremisesId__c = premises.Id;
    insert accountObject;
    //Insert product data
    Product2 googleWifiProduct = new Product2();
    googleWifiProduct.ProductCode = 'Included Google WiFi Box Test';
    googleWifiProduct.Name = 'OFR_Equip_GWifi_Test';
    googleWifiProduct.vlocity_cmt__Type__c = 'Equipment';
    googleWifiProduct.vlocity_cmt__SubType__c = 'ONT';
    insert googleWifiProduct;
    Id pricebookId = Test.getStandardPricebookId();
    //Insert a price book entry for the standard price book.
    //Standard price book entries require the standard price book ID we got earlier.
    PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId,
        Product2Id = googleWifiProduct.Id, UnitPrice = 10000, IsActive = true);
    insert standardPrice;
    //Create a custom price book
    Pricebook2 customPriceBook = new Pricebook2(Name = 'Custom Pricebook', isActive = true);
    insert customPriceBook;
    //Insert a price book entry with a custom price.
    PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = customPriceBook.Id, Product2Id = googleWifiProduct.Id,
        useStandardPrice = false, UnitPrice = 12000, IsActive = true);
    insert customPrice;

    //Insert order records
    List<Order> orderData = new List<Order>();
    Order orderObject = new Order();
    orderObject.Name = 'TestClassOrder';
    orderObject.AccountId = accountObject.id;
    orderObject.vlocity_cmt__DefaultServiceAccountId__c =
        accountObject.id;
    orderObject.vlocity_cmt__OrderStatus__c = 'In Progress';
    orderObject.Pickup_Deliver_Install_Date__c = Date.Today();
    orderObject.Professional_Install_Required__c = false;
    orderObject.EffectiveDate = Date.Today();
    orderObject.status = 'Draft';
    orderObject.Pricebook2Id = customPriceBook.Id;
    orderObject.vlocity_cmt__DefaultServicePointId__c=ServicePoint.id;
    orderData.add(orderObject);
    Order orderObject1 = new Order();
    orderObject1.Name = 'TestClassOrder1';
    orderObject1.AccountId = accountObject.id;
    orderObject1.vlocity_cmt__OrderStatus__c = 'In Progress';
    orderObject1.Pickup_Deliver_Install_Date__c = Date.Today();
    orderObject1.Professional_Install_Required__c= false;
    orderObject1.EffectiveDate = Date.Today();
    orderObject1.status = 'Draft';
    orderObject1.Pricebook2Id = customPriceBook.Id;
    orderObject1.vlocity_cmt__DefaultServicePointId__c = ServicePoint.id;
    orderData.add(orderObject1);
    insert orderData;
    //Data for vlocity_cmt__JSONAttribute__c for OrderItem
      List<StaticResource> staticResourceValues = new list<StaticResource>();
      staticResourceValues = [
        SELECT
          Id,
          Body
        FROM
          StaticResource
        WHERE
          Name IN ('ByorDeviceAttributesTestData',
                   'GoogleWifiDeviceAttributesTestData',
                   'NetworkBoxDeviceAttributesTestData')
        LIMIT 3];
    //Insert OrderItems data
    List<OrderItem> ordItems = new List<OrderItem>();
    OrderItem item = New orderItem();
    item.OrderId = orderData[0].id;
    item.Quantity = 5;
    item.Product2Id = googleWifiProduct.id;
    item.PricebookEntryId = customPrice.Id;
    item.UnitPrice = 50.0;
    item.vlocity_cmt__JSONAttribute__c = staticResourceValues[0].Body.toString();
    item.vlocity_cmt__Action__c = 'Add';
    ordItems.add(item) ;
    OrderItem item1 = New orderItem();
    item1.OrderId = orderData[1].id;
    item1.Quantity = 1;
    item1.Product2Id = googleWifiProduct.id;
    item1.PricebookEntryId = customPrice.Id;
    item1.UnitPrice = 50.0;
    item1.vlocity_cmt__JSONAttribute__c = staticResourceValues[1].Body.toString();
    item1.vlocity_cmt__Action__c = 'Add';
    ordItems.add(item1) ;
    OrderItem item2 = New orderItem();
    item2.OrderId = orderData[1].id;
    item2.Quantity = 1;
    item2.Product2Id = googleWifiProduct.id;
    item2.PricebookEntryId = customPrice.Id;
    item2.UnitPrice = 50.0;
    item2.vlocity_cmt__JSONAttribute__c = staticResourceValues[2].Body.toString();
    item2.vlocity_cmt__Action__c = 'Add';
    ordItems.add(Item2) ;
    insert ordItems;
  }
  //Test method to pass data related to GoogleWifi
  @isTest static void getGoogleWifiDeviceDataTest() {
    order orderObject = [
        SELECT
          Id,status
        FROM
          Order
        WHERE
          name = 'TestClassOrder'
        LIMIT 1];
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    inputMap.put('cartId', orderObject.id);
    String methodName = 'postCartsItems.PostInvoke';
    Test.startTest();
      CpqAppHandlerHookHelper cpqAppHandlerHookHelper = new cpqAppHandlerHookHelper();
      boolean run = CpqAppHandlerHookHelper.invokeMethod(methodName,inputMap,outputMap,optionsMap);
    Test.stopTest();
    System.assertEquals('Draft',
      orderObject.Status,
      'order status does not match.');
  }
  //Test method to pass data related to BYOR and Networkbox
  @isTest static void getNetworkboxDeviceDataTest() {
    order orderObject = [
        SELECT
          Id,vlocity_cmt__OrderStatus__c
        FROM
          Order
        WHERE
          name ='TestClassOrder1'
        LIMIT 1] ;
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    inputMap.put('cartId', orderObject.id);
    String methodName = 'getCartsItems.PostInvoke';
    Test.startTest();
      CpqAppHandlerHookHelper cpqAppHandlerHookHelper = new cpqAppHandlerHookHelper();
      boolean run1 = CpqAppHandlerHookHelper.invokeMethod(methodName,inputMap,outputMap,optionsMap);
    Test.stopTest();
      System.assertEquals('In Progress',
      orderObject.vlocity_cmt__OrderStatus__c,
      'order status does not match.');
  }
}