/**
 * @group TestClass-OrderingUtils
 * @description Test class for OrderingUtils to improve code coverage
 * and test functionality.
 */
@isTest
public with sharing class OrderingUtilsTest {
  // constant variables
  private Static final Integer EXPECTED_INDIVIDUAL_QUANTITY = 1;
  private Static final Integer INITIAL_QUANTITY_TWO = 2;
  private Static final Integer EXPECTED_TOTAL_QUANTITY = 4;
  private Static final String LINE_NUMBER_ONE = '0001';
  private Static final String LINE_NUMBER_TWO = '0002';
 /**
 * @description This method sets the test data.
 * @param null
 */
  @testSetup
  private static void setupData() {
    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;
    Product2 product2 = TestDataFactory.getProductData('TestName','TestFamily',
      Constants.PRODUCT.PRODUCT_CODE.PRD_FBR_INTERNET);
    insert product2;
    Pricebook2 pBook = new Pricebook2(Id=Test.getStandardPriceBookId(), IsActive=true);
    PricebookEntry pbEntry = TestDataFactory.getPriceBookEntry(pBook.Id, product2.Id);
    insert pbEntry;
    Order orderRecord = TestDataFactory.getOrderData(accountRecord.Id);
    orderRecord.Pricebook2Id = pBook.Id;
    orderRecord.Is_Activated__c = false;
    orderRecord.Force_Billing__c = false;
    insert orderRecord;
    List<OrderItem> listOfOrderItem = new List<OrderItem>();
    OrderItem itemRecord = TestDataFactory.getOrderItemData (orderRecord.Id, pbEntry.Id,
        product2.Id);
    itemrecord.Quantity= INITIAL_QUANTITY_TWO;
    itemrecord.vlocity_cmt__LineNumber__c = LINE_NUMBER_ONE;
    listOfOrderItem.add(itemrecord);
    OrderItem itemRecord1 = TestDataFactory.getOrderItemData (orderRecord.Id, pbEntry.Id,
        product2.Id);
    itemrecord1.Quantity= INITIAL_QUANTITY_TWO;
    itemrecord1.vlocity_cmt__LineNumber__c = LINE_NUMBER_TWO;
    listOfOrderItem.add(itemrecord1);
    insert listOfOrderItem;
  }

  @isTest
  private static void splitOrderItemShouldSplitOrderItemsWithQuantityOne() {
    Order orders = [
        SELECT
          Id,
          Force_Billing__c 
        FROM
          Order
        LIMIT 1
    ];
    List<OrderItem> orderItemList = [
        SELECT
          Id,
          Quantity 
        FROM
          OrderItem
    ];
    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('orderId', orders.Id);
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Boolean splitOrderItem;
    System.assertEquals(INITIAL_QUANTITY_TWO, orderItemList.size(),
        'Should have two Order Item.');  
    System.assertEquals(INITIAL_QUANTITY_TWO, orderItemList[0].Quantity,
        'First order item should have quantity two.');
    System.assertEquals(INITIAL_QUANTITY_TWO, orderItemList[1].Quantity,
        'Second order item should have quantity two.');
    
    Test.StartTest();
      splitOrderItem = new OrderingUtils().invokeMethod(
          'splitorderitem', inputMap, outMap, options);
    Test.StopTest();
    
    List<OrderItem> orderItemUpdatedList = [
        SELECT
          Id,
          Quantity 
        FROM
          OrderItem
    ];
    System.assertEquals(EXPECTED_TOTAL_QUANTITY, orderItemUpdatedList.size(),
        'Should have four order items.');
    for (OrderItem oi : orderItemUpdatedList) {
      System.assertEquals(EXPECTED_INDIVIDUAL_QUANTITY, oi.Quantity,
          'Should have order item with quantity one.');
    }
  }
    
  @isTest
  private static void splitOrderItemShouldThrowError() {
    Order orders = [
        SELECT
          Id,
          Force_Billing__c 
        FROM
          Order
        LIMIT 1
    ];
    orders.Status = 'Activated';
    update orders;
    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('orderId', orders.Id);
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Boolean exceptionOccured = false;
    
    Test.StartTest();
      try {
          new OrderingUtils().invokeMethod(
          'splitorderitem', inputMap, outMap, options);
      } catch (Exception e) {
          exceptionOccured = true;
      }
      
    Test.StopTest();
      
    System.assert(exceptionOccured, 'An Exception was thrown.');
  }
}