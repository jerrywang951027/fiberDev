/**
 * @group CSR Console
 * @description Test class for CloneObject to improve code coverage
 */
@isTest
public class CloneObjectTest {
  /**
   * @description This method is used to set up test data.
   * @return null
   */
  @testSetup
  public static void setupTestData() {
    Logging_Level__c loggingLevel = TestDataFactory.getLoggingSetting() ;
    insert loggingLevel ;
    Account testAccount = TestDataFactory.getAccountData() ;
    insert testAccount ;
    Id standardPricebookId = Test.getStandardPricebookId() ;
    List <Order> orderList = new List <Order>() ;
    Order testOrder = TestDataFactory.getOrderData(testAccount.Id) ;
    testOrder.Pricebook2Id = standardPricebookId ;
    insert testOrder ;
    Product2 testProduct = TestDataFactory.getProductData ('Prod A', 'Additional Service',
        'OFR_Storage_1TB') ;
    insert testProduct ;
    PricebookEntry testPricebookEntry = TestDataFactory.getPricebookEntry (
        standardPricebookId, testProduct.Id) ;
    insert testPricebookEntry ;
    OrderItem testOrderItem = TestDataFactory.getOrderItemData (testOrder.id,
        testPricebookEntry.Id, testProduct.Id) ;
    insert testOrderItem ;

  }

  /**
   * @description This is a test method to test invokeMethod() of class CloneObject
   * overriden from vlocity_cmt.VlocityOpenInterface2.
   * @return null
   */
  @isTest
  public static void cloneObjectShouldReturnOrderWithOrderProducts() {
    Map <String, Object> input = new Map <String, Object>() ;
    Order order = [
      SELECT
        Id
      FROM
        Order
      LIMIT 1
    ] ;
    String methodName = 'cloneOrderWithOrderProducts' ;
    input.put ('OrderId', order.Id) ;

    Map <String, Object> output = new Map <String, Object>() ;
    Map <String, Object> options = new Map <String, Object>() ;
    
    Test.StartTest() ;
      ConsoleUtils ConsoleUtilsObject = new ConsoleUtils() ;
      Boolean result = ConsoleUtilsObject.invokeMethod (methodName, input, output, options) ;
    Test.StopTest() ;
    System.debug (result) ;
    System.assert (result) ;
  }
}