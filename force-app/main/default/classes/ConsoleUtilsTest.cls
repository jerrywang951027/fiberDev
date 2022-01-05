/**
   * @group Console Utils
   * @description Test class for Console Utils method
   */  
  @isTest
  public class ConsoleUtilsTest {
  /**
   * @description This method is used to set up test data.
   * @return null
   */
  @testSetup
  public static void setupTestData(){
    Logging_Level__c loggingLevel = TestDataFactory.getLoggingSetting();
    insert loggingLevel;
    Account testAccount = TestDataFactory.getAccountData();
    insert testAccount;
    Id standardPricebookId = Test.getStandardPricebookId();
    List <Order> orderList = new List <Order> ();
    Order testOrder = TestDataFactory.getOrderData (testAccount.Id);
    testOrder.Pricebook2Id = standardPricebookId;
    insert testOrder;
    Product2 testProduct = TestDataFactory.getProductData ('Prod A', 'Additional Service',
        'OFR_Storage_1TB');
    insert testProduct;
    PricebookEntry testPricebookEntry = TestDataFactory.getPricebookEntry (
        standardPricebookId, testProduct.Id);
    insert testPricebookEntry;
    OrderItem testOrderItem = TestDataFactory.getOrderItemData (testOrder.id,
        testPricebookEntry.Id, testProduct.Id);
    insert testOrderItem;

  }
    /**
     * @description This is a test method to test invokeMethod() of class RandomKeyGenerator
     * overriden from vlocity_cmt.VlocityOpenInterface2.
     * @return null
     */
    @isTest
    static void invokeGenerateRandomNumberShouldReturnRandomNumber() {
      Map<String, Object> outMap = new Map<String, Object>();
      Map<String, Object> options = new Map<String, Object>();
      Map<String, Object> inputMap = new Map<String, Object>();
      Test.startTest();
        ConsoleUtils objGenerateRandomNumber = new ConsoleUtils();
        objGenerateRandomNumber.invokeMethod('generateRandomNumber', inputMap, outMap, options);
      Test.stopTest();
      string returnedKey = (string)outMap.get('returnedKey');
      System.assertEquals(5, returnedKey.length());
    }
    /**
     * @description This is a test method to test invokeMethod() of class RandomKeyGenerator with generateRandomId
     * overriden from vlocity_cmt.VlocityOpenInterface2.
     * @return null
     */
    @isTest
    static void invokeGenerateRandomIdShouldReturnId() {
      Map<String, Object> outMap = new Map<String, Object>();
      Map<String, Object> options = new Map<String, Object>();
      Map<String, Object> inputMap = new Map<String, Object>();
      inputMap.put('prefix', '011');
      inputMap.put('totalLength', 10);
      inputMap.put('segmentSize', 3);
      Test.startTest();
        ConsoleUtils objGenerateRandomId = new ConsoleUtils();
        objGenerateRandomId.invokeMethod('generateKey', inputMap, outMap, options);
      Test.stopTest();
      integer length = (integer)inputMap.get('totalLength') + (integer)inputMap.get('segmentSize');
      string randomId = (string)outMap.get('returnedKey');
      System.assertEquals(length, randomId.length());
  }
  
  /**
   * @description This is a test method to test invokeMethod() of class CloneObject
   * overriden from vlocity_cmt.VlocityOpenInterface2.
   * @return null
   */
  @isTest
  public static void invokeCloneObjectShouldReturnOrderWithOrderProducts() {
    Map <String, Object> input = new Map <String, Object> ();
    Order order = [
      SELECT
        Id
      FROM
        Order
      LIMIT 1
    ];
    String methodName = 'cloneOrderWithOrderProducts';
    input.put ('OrderId', order.Id);

    Map <String, Object> output = new Map <String, Object> ();
    Map <String, Object> options = new Map <String, Object> ();
    
    Test.StartTest();
      ConsoleUtils ConsoleUtilsObject = new ConsoleUtils ();
      Boolean result = ConsoleUtilsObject.invokeMethod (methodName, input, output, options);
    Test.StopTest();
    System.debug (result);
    System.assert (result);
  }
}