/**
 * @group CSR Console
 * @description Test class for EquipmentUtils to improve code coverage
  and test functionality.
 */
@isTest
public with sharing class EquipmentUtilsTest {
  /**
   * @description This method is used to set up test data.
   * @return null
   */
  @testSetup static void setupTestData() {
    Account testAccount = TestDataFactory.getAccountData();
    insert testAccount;

    Vlocity_cmt__Premises__c testPremises = TestDataFactory.getPremisesData(
        Constants.Premises.STATUS.UNVALIDATED);
    insert testPremises;

    Account testServiceAccount = TestDataFactory.getAccountData();
    testServiceAccount.RecordTypeId = RecordTypeUtils.SERVICE_ACCOUNT_ID;
    testServiceAccount.vlocity_cmt__Status__c = 'Active';
    testServiceAccount.Account_Id__c = '';
    testServiceAccount.vlocity_cmt__PremisesId__c = testPremises.Id;
    testServiceAccount.ParentId = testAccount.Id;
    insert testServiceAccount;

    Id standardPricebookId = Test.getStandardPricebookId();
    Order testOrder = TestDataFactory.getOrderData(testAccount.Id);
    testOrder.Pricebook2Id = standardPricebookId;
    testOrder.vlocity_cmt__DefaultPremisesId__c = testPremises.Id;
    testOrder.vlocity_cmt__OrderStatus__c = Constants.Order.STATUS.IN_PROGRESS;
    testOrder.vlocity_cmt__FulfilmentStatus__c = Constants.Order.STATUS.IN_PROGRESS;
    testOrder.vlocity_cmt__DefaultServiceAccountId__c = testServiceAccount.Id;
    insert testOrder;

    List<Product2> testProducts = new List<Product2>();
    Product2 testProduct1 = TestDataFactory.getProductData('1 Gig', 'Fiber',
        'OFR_Fiber1G');
    testProducts.add(testProduct1);
    Product2 testProduct2 = TestDataFactory.getProductData('Google Wifi', 'Fiber',
        'OFR_Equip_GWifi');
    testProducts.add(testProduct2);
    Product2 testProduct3 = TestDataFactory.getProductData('Mesh Extender', 'Fiber',
        'OFR_Equip_Mesh');
    testProducts.add(testProduct3);
    Product2 testProduct4 = TestDataFactory.getProductData('Additional Storage', 'Fiber',
        'OFR_Equip_GWifi');
    testProducts.add(testProduct4);
    insert testProducts;

    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    PricebookEntry testPricebookEntry1 = TestDataFactory.getPricebookEntry(
        standardPricebookId, testProduct1.Id);
    pricebookEntries.add(testPricebookEntry1);
    PricebookEntry testPricebookEntry2 = TestDataFactory.getPricebookEntry(
        standardPricebookId, testProduct2.Id);
    pricebookEntries.add(testPricebookEntry2);
    PricebookEntry testPricebookEntry3 = TestDataFactory.getPricebookEntry(
        standardPricebookId, testProduct3.Id);
    pricebookEntries.add(testPricebookEntry3);
    PricebookEntry testPricebookEntry4 = TestDataFactory.getPricebookEntry(
        standardPricebookId, testProduct4.Id);
    pricebookEntries.add(testPricebookEntry4);
    insert pricebookEntries;

    List<OrderItem> orderItems = new List<OrderItem>();
    OrderItem testOrderItemParent = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry1.Id, testProduct1.Id);
    insert testOrderItemParent;
    OrderItem testOrderItemParent1 = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry1.Id, testProduct1.Id);
    orderItems.add(testOrderItemParent1);
    OrderItem testOrderItemChild1 = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry2.Id, testProduct2.Id);
    testOrderItemChild1.vlocity_cmt__RootItemId__c = testOrderItemParent.Id;
    testOrderItemChild1.vlocity_cmt__ParentItemId__c = testOrderItemParent.Id;
    orderItems.add(testOrderItemChild1);
    OrderItem testOrderItemChild2 = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry2.Id, testProduct2.Id);
    testOrderItemChild2.vlocity_cmt__RootItemId__c = testOrderItemParent.Id;
    testOrderItemChild2.vlocity_cmt__ParentItemId__c = testOrderItemParent.Id;
    orderItems.add(testOrderItemChild2);
    OrderItem testOrderItemChild3 = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry3.Id, testProduct3.Id);
    testOrderItemChild3.vlocity_cmt__RootItemId__c = testOrderItemParent.Id;
    testOrderItemChild3.vlocity_cmt__ParentItemId__c = testOrderItemParent.Id;
    orderItems.add(testOrderItemChild3);
    OrderItem testOrderItemChild4 = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry4.Id, testProduct4.Id);
    testOrderItemChild4.vlocity_cmt__RootItemId__c = testOrderItemParent.Id;
    testOrderItemChild4.vlocity_cmt__ParentItemId__c = testOrderItemParent.Id;
    orderItems.add(testOrderItemChild4);
    OrderItem testOrderItemChild5 = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry4.Id, testProduct4.Id);
    testOrderItemChild5.vlocity_cmt__RootItemId__c = testOrderItemParent.Id;
    testOrderItemChild5.vlocity_cmt__ParentItemId__c = testOrderItemParent.Id;
    orderItems.add(testOrderItemChild5);
    insert orderItems;
  }

  /**
   * @description This is a test method to test invokeMethod() of class ConsoleUtils
   * overriden from vlocity_cmt.VlocityOpenInterface2.
   * @return null
   */
  @isTest static void countEquipmentShouldReturnTheEquipmentCount() {
    Map<String, Object> inputMap = new Map<String,Object>();
    Map<String, Object> outMap = new Map<String,Object>();
    Map<String, Object> options = new Map<String,Object>();

    Account serviceAccount = [
        SELECT
          Id, 
          ParentId
        FROM
          Account
        WHERE
          RecordTypeId = :RecordTypeUtils.SERVICE_ACCOUNT_ID
        LIMIT 1
    ];
    Order testOrder = [
        SELECT
          Id
        FROM
          Order
        WHERE
          vlocity_cmt__DefaultServiceAccountId__c = :serviceAccount.Id
        LIMIT 1
    ];
    List<OrderItem> testOrderItem = [
        SELECT
          Id,
          OrderId,
          vlocity_cmt__ParentItemId__c,
          vlocity_cmt__ServiceAccountId__c,
          Product2.Name,
          Quantity
        FROM
          OrderItem
        WHERE
          OrderId = :testOrder.Id
    ];
    List<OrderItem> googleWifiOrderItems = [
        SELECT
          Id,
          OrderId,
          vlocity_cmt__ParentItemId__c,
          vlocity_cmt__ServiceAccountId__c,
          Product2.Name
        FROM
          OrderItem
        WHERE
          OrderId = :testOrder.Id
        AND
          Product2.Name = 'Google Wifi'
    ];

    List<Object> productDetailsList = new List<Object>();
    for(OrderItem obj : testOrderItem){
      Map<String, Object> productDetails = new Map<String, Object>();
      if(obj.Product2.Name == 'Additional Storage'){
        productDetails.put('cloudStorage', '1TB');
      }
      if(obj.vlocity_cmt__ParentItemId__c != NULL ){
        productDetails.put('parent', obj.vlocity_cmt__ParentItemId__c);
      }
      if(obj.Product2.Name == 'Mesh Extender'){
        productDetails.put('type', obj.Product2.Name);
      }
      productDetails.put('id', obj.Id);
      productDetails.put('childName', obj.Product2.Name);
      productDetailsList.add(productDetails);
    }
    String methodName = 'countEquipmentMethod';
    inputMap.put('orderItems', productDetailsList);

    Test.startTest();
      ConsoleUtils ConsoleUtilsObject = new ConsoleUtils();
      Boolean result = ConsoleUtilsObject.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();

    List<object> nonParentEquipmentList = new List<Object>();
    List<object> parentEquipmentList = (List<Object>) outMap.get('nonParent');
    Map<String, Object> equipmentDetailsByField = (Map<String, Object>) parentEquipmentList[0];
    System.assert(result);
    System.assert(equipmentDetailsByField.get('value') == googleWifiOrderItems.size());
    System.assert(equipmentDetailsByField.get('childName') == 'Google Wifi');
  }
}