/**
* @group TestClass-CartUtils
* @description Test class for CartUtils to improve code coverage
  and test functionality.
*/
@isTest
public with sharing class CartUtilsTest {

 /**
  *  @description test data set up method
  */
  @testSetup
  static void setupTestData() {
    Logging_Level__c loggingLevel = TestDataFactory.getLoggingSetting();
    insert loggingLevel;
    Account testAccount = TestDataFactory.getAccountData();
    insert testAccount;
    Id standardPricebookId = Test.getStandardPricebookId();
    List<Order> orderList = new List<Order>();
    Order testOrder = TestDataFactory.getOrderData(testAccount.Id);
    testOrder.Pricebook2Id = standardPricebookId;
    insert testOrder;
    Product2 testProduct = TestDataFactory.getProductData('Prod A', 'Additional Service',
        'OFR_Storage_1TB');
    insert testProduct;
    PricebookEntry testPricebookEntry = TestDataFactory.getPricebookEntry(
        standardPricebookId, testProduct.Id);
    insert testPricebookEntry;
    OrderItem testOrderItem = TestDataFactory.getOrderItemData(testOrder.id,
        testPricebookEntry.Id, testProduct.Id);
    insert testOrderItem;
  }

  /**
   * @description Test method to update action, subAction and status of OrderItem as Pause
   */
  @isTest
  static void invokeShouldUpdateOrderItemStatusAndActionType() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String,Object> options = new Map<String, Object>();
    String methodName = 'updateOrderProduct';
    Order order = [
        SELECT
          Id
        FROM
          Order
        LIMIT 1
    ];
    inputMap.put('fdoId', order.Id);
    inputMap.put('status', Constants.ORDER_ITEM.STATUS.SUSPENDED);
    inputMap.put('actionType', Constants.ORDER_ITEM.ACTION.SUSPEND);
    inputMap.put('subAction', Constants.ORDER_ITEM.SUBACTION.PAUSE);
    CartUtils updateCart = new CartUtils();
    Test.startTest();
      Boolean result = updateCart.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();
    OrderItem orderProduct = [
        SELECT
          Id,
          vlocity_cmt__Action__c,
          vlocity_cmt__ProvisioningStatus__c,
          vlocity_cmt__SubAction__c
        FROM
          OrderItem
        WHERE
          orderId = :order.Id
        LIMIT 1
    ];
    System.assertEquals(Constants.ORDER_ITEM.ACTION.SUSPEND, orderProduct.vlocity_cmt__Action__c);
    System.assertEquals(Constants.ORDER_ITEM.STATUS.SUSPENDED,
        orderProduct.vlocity_cmt__ProvisioningStatus__c);
    System.assertEquals(Constants.ORDER_ITEM.SUBACTION.PAUSE,
        orderProduct.vlocity_cmt__SubAction__c);
  }
  /**
   * @description test method to cover negative scenario of not accepting the methodName as null.
   */
  @isTest
  static void invokeShouldNotUpdateOrderProduct() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String,Object> options = new Map<String, Object>();
    String methodName = '';
    CartUtils updateCart = new CartUtils();
    Test.startTest();
      Boolean result = updateCart.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();
    System.AssertEquals(result, false, 'Method name does not match.');
  }
}