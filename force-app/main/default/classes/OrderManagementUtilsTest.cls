/**
 * @group DateHelper
 * @description Class for Functionality related to updating of date.
 */
@isTest
public class OrderManagementUtilsTest {

  // Initialize class constants.
  private static final String FORMAT_URL_METHOD_NAME = 'formatUrl';
  private static final String INPUT_MAP_BANDWIDTH_PORTIN_ORDER_ID = 'bandwidthPortinOrderId';
  private static final String INPUT_MAP_FIBER_BILLING_LINE_KEY = 'fiberBillingCFSLine';
  private static final String INPUT_MAP_RATE_PLAN_ID_KEY = 'ratePlanId';
  private static final String INPUT_MAP_REMOVE_PRODUCT_KEY = 'removeProducts';
  private static final String INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY =
      'removedProductsChangeOfPlan';
  private static final String INPUT_MAP_UPDATE_PRODUCT_KEY = 'updateProducts';
  private static final String INPUT_MAP_URL_STRING = 'urlString';
  private static final String INPUT_MAP_ZUORA_INSTANCE_ID_KEY = 'zuoraProductInstanceID';
  private static final String OUTPUT_MAP_FORMATTED_URL_KEY = 'formattedUrl';
  private static final String PORTIN_ORDER_ID = '51008687-92ee-4bbe-aafe-2372ddc05d43';
  private static final String PRODUCT_TYPE = 'Internet';
  private static final String RATE_PLAN_INSTANCE_ID = '51384d21-3804-68b2-1c15-e13fc2a9ef84';
  private static final String ZUORA_EXTERNAL_ID = '2314563123';
  public static final String CHILD_GPN = '72004270-08';
  public static final String CPE_TYPE = 'Google Wifi';
  public static final String MODEL_NAME = 'GFRG200';
  public static final String ORDER_TYPE = 'Equipment';
  public static final String SERIAL_NUMBER = '4704HT004LC';
  public static final String SUB_TYPE = 'Router';
    
  @testSetup
  private static void setupData() {
    Zuora__SubscriptionRatePlan__c zuoraIns = new Zuora__SubscriptionRatePlan__c();
    zuoraIns.RatePlanInstanceID__c = RATE_PLAN_INSTANCE_ID;
    zuoraIns.Zuora__External_Id__c = ZUORA_EXTERNAL_ID;
    insert zuoraIns;
  }

  /**
   * @description This method is to test.
   */
  @isTest
  private static void getFutureShipmentDateShouldReturnShipmentDate() {
    // Initializing Method Name
    String methodName =
        OrderManagementUtils.GET_FUTURE_SHIPMENT_DATE_METHOD_NAME;
    // Initialising date-time field.
    DateTime expectedDateTime = System.now().addHours(2);
    // Initializing Maps for Input
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    OrderManagementUtils orderManagementObj = new OrderManagementUtils();
    // Start Test
    Test.startTest();
      orderManagementObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    DateTime actualDateTime =
        DateTime.valueOf(outMap.get('updateDateTime'));
    // Unit test assert Start
    System.assertEquals(expectedDateTime.date(),actualDateTime.date(),
        'actual Date should match the expected Date');
    System.assertEquals(expectedDateTime.hour(), actualDateTime.hour(),
        'actual Date should match the expected Date');
    // Unit test assert End
  }
  /**
   * @description This method is to test if the method is found or not.
   */
  @isTest
  private static void invalidMethodNameShouldReturnNothing() {
    // Initializing Method Name
    String methodName = null;
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    OrderManagementUtils orderManagementObj = new OrderManagementUtils();
    try {
      // Start Test
      Test.startTest();
        Boolean result = orderManagementObj.invokeMethod( methodName, inputMap, outMap, optionsMap);
        System.assert(false, 'Exception expected');
      Test.stopTest();
    }catch (Exception e) {
       // Unit test assert Start
       System.assert(e.getMessage().contains('Attempt to de-reference a null object'));
       // Unit test assert End
     }
  }

  /**
  * @description this test method validates if the generated key follows
  * the expected formation rules
  */
  @isTest
  static void validateGeneratedKey() {

    final String KEY_PREFIX = 'GF';
    final Integer KEY_LENGTH = 16;
    final Integer SEGMENT_SIZE = 4;
    Map<String,Object> inputMap = new Map<String,Object>();
    Map<String,Object> outMap = new Map<String,Object>();
    Map<String,Object> options = new Map<String,Object>();

    inputMap.put('prefix', KEY_PREFIX);
    inputMap.put('totalLength', KEY_LENGTH);
    inputMap.put('segmentSize', SEGMENT_SIZE);
    OrderManagementUtils orderManagementObj = new OrderManagementUtils();

    Test.startTest();

    orderManagementObj.invokeMethod('generateKey', inputMap, outMap, options);

    Test.stopTest();

    String generatedId = (String) outMap.get('returnedKey');

    // Testing Size
    // adding 4 related to the "-"  characters
    System.assertEquals(KEY_LENGTH, generatedId.remove(KeyGenerator.SEPARATOR).length(),
        'generateRandomId() returned value ' + generatedId +
        ' with length different than ' + KEY_LENGTH);

    // Testing prefix position
    System.assert(generatedId.startsWith(KEY_PREFIX),
        'generateRandomId() returned value ' + generatedId +
        ' with different prefix than ' + KEY_PREFIX);

    List<String> segments = generatedId.split(KeyGenerator.SEPARATOR);

    // check the size of inner segments, exlucding first and last

    for(Integer i =1; i < segments.size() - 1; i++){

      System.assertEquals(SEGMENT_SIZE, segments[i].length(),
        'generateRandomId() returned value ' + generatedId +
        ' with inner segment size different than ' + SEGMENT_SIZE);
    }

  }

  /**
   * @description This method covers the merging of the name from
   * gpnsAssetModels into GPNDetails json.
   * @return null
   */
  @isTest
  static void passingGpnAssetModelShouldUpdateModel(){
    String actualModelName = null;
    Map<String, Object> modelDetails = new Map<String, Object>{
      'name' => MODEL_NAME,
      'displayName' => MODEL_NAME
    };
    Map<String, Object> gpnsAssetModel = new Map<String, Object>{
      CHILD_GPN => modelDetails
    };
    Map<String, Object> childSerial = new Map<String, Object>{
      'SerialNumber' => '4704HT004LC',
      'GPN' => CHILD_GPN
    };
    Map<String, Object> gpnDetail = new Map<String, Object>{
      'ChildSerialNumbers' => new List<Object>{childSerial}
    };
    Map<String, Object> inputMap = new Map<String, Object>{
      'GPNDetails' => new List<Object>{gpnDetail},
      'gpnsAssetModels' => gpnsAssetModel
    };
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Test.startTest();
      OrderManagementUtils orderManagementObj =
          new OrderManagementUtils();
      orderManagementObj.invokeMethod(
          OrderManagementUtils.MERGE_MODEL_NAME_METHOD_NAME,
          inputMap, outMap, options);
    Test.stopTest();
    List<Object> actualGpnDetails = (List<Object>)outMap.get(
        'GPNDetails');
    Map<String, Object> actualGpnDetail =
        (Map<String, Object>)actualGpnDetails[0];
    List<Object> actualChildSerials = (List<Object>)actualGpnDetail
        .get('ChildSerialNumbers');
    Map<String, Object> actualChildSerial =
        (Map<String, Object>)actualChildSerials[0];
    System.assertEquals(MODEL_NAME, actualChildSerial.get('Model'),
        'Model name did not matched.');
  }

  /**
   * @description This method covers the merging of the serial number from
   * childSerialNodes into orderedEquipments json if condition matched.
   * @return null
   */
  @isTest
  static void passingChildSerialShouldUpdateSerialNumber(){
    Map<String, Object> childSerial = new Map<String, Object>{
      'SerialNumber' => SERIAL_NUMBER,
      'Model' => MODEL_NAME,
      'cpeType' => CPE_TYPE,
      'subType' => SUB_TYPE
    };
    Map<String, Object> orderEquipment = new Map<String, Object>{
      'cpeType' => CPE_TYPE,
      'subType' => SUB_TYPE,
      'type' => ORDER_TYPE
    };
    Map<String, Object> inputMap = new Map<String, Object>{
      'childSerialNodes' => new List<Object>{childSerial},
      'orderedEquipment' => new List<Object>{orderEquipment}
    };
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Test.startTest();
      OrderManagementUtils orderManagementObj =
          new OrderManagementUtils();
      orderManagementObj.invokeMethod(
          OrderManagementUtils.MERGE_SERIAL_NUMBER_METHOD_NAME,
          inputMap, outMap, options);
    Test.stopTest();
    List<Object> actualOrderedEquipments = (List<Object>)outMap.get(
        'orderedEquipment');
    Map<String, Object> actualOrderedEquipment =
        (Map<String, Object>)actualOrderedEquipments[0];
    System.assertEquals(SERIAL_NUMBER, actualOrderedEquipment.get('SerialNumber'),
        'Serial number should be added.');
  }

  /**
   * @description This method covers the scenario for passing the incorrect
   * method name.
   */
  @isTest
  static void passingIncorrectMethodNameShouldReturnResultFalse() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Test.startTest();
      OrderManagementUtils orderManagementObj =
          new OrderManagementUtils();
      Boolean result = orderManagementObj.invokeMethod(
          'incorrectMethodName',
          inputMap, outMap, options);
    Test.stopTest();
    System.assert(!result, 'Method name found.');
  }
    
 /**
 * @description This method covers the merging of rate plan id to remove
 * product.
 * @param null
 */
  @isTest
  private static void processRemoveProductsShouldAddRatePlanId() { 
    Map<String, Object> removeProduct = new Map<String, Object>{
      'zuoraProductInstanceID' => RATE_PLAN_INSTANCE_ID,
      'productType' => PRODUCT_TYPE
    };
    Map<String, Object> removeProducts = new Map<String, Object>{
      'removeProducts' => new List<Object>{removeProduct}
    };
    Map<String, Object> fiberBillingCFSLine = new Map<String, Object>{
      'fiberBillingCFSLine' => removeProducts
    };
    Map<String, Object> inputMap = fiberBillingCFSLine;
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Boolean addZuoraRatePlan;
      
    Test.StartTest();
      addZuoraRatePlan = new OrderManagementUtils().invokeMethod(
          'addzuorarateplanid', inputMap, outMap, options);
    Test.StopTest();
    
    Map<String, Object> lineKeyMap = 
        (Map<String, Object>) outMap.get(INPUT_MAP_FIBER_BILLING_LINE_KEY);
    List<Object> jsonAttList = 
        (List<Object>)lineKeyMap.get(INPUT_MAP_REMOVE_PRODUCT_KEY);
    Map<String, Object> jsonAttMap = (Map<String, Object>)jsonAttList[0];
    System.assertEquals (ZUORA_EXTERNAL_ID, 
        jsonAttMap.get(INPUT_MAP_RATE_PLAN_ID_KEY ),
        'Should add rate plan id to remove product node.');
  }
    
 /**
 * @description This method covers the merging of rate plan id to update
 * product.
 * @param null
 */
  @isTest
  private static void processUpdateProductsShouldAddRatePlanId() { 
    Map<String, Object> updateProduct = new Map<String, Object>{
      'zuoraProductInstanceID' => RATE_PLAN_INSTANCE_ID,
      'productType' => PRODUCT_TYPE
    };
    Map<String, Object> updateProducts = new Map<String, Object>{
      'updateProducts' => new List<Object>{updateProduct}
    };
    Map<String, Object> fiberBillingCFSLine = new Map<String, Object>{
      'fiberBillingCFSLine' => updateProducts
    };
    Map<String, Object> inputMap = fiberBillingCFSLine;
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Boolean addZuoraRatePlan;
      
    Test.StartTest();
      addZuoraRatePlan = new OrderManagementUtils().invokeMethod(
          'addzuorarateplanid', inputMap, outMap, options);
    Test.StopTest();
    
    Map<String, Object> lineKeyMap = 
        (Map<String, Object>) outMap.get(INPUT_MAP_FIBER_BILLING_LINE_KEY);
    List<Object> jsonAttList = 
        (List<Object>)lineKeyMap.get(INPUT_MAP_UPDATE_PRODUCT_KEY);
    Map<String, Object> jsonAttMap = (Map<String, Object>)jsonAttList[0];
    System.assertEquals (ZUORA_EXTERNAL_ID, 
        jsonAttMap.get(INPUT_MAP_RATE_PLAN_ID_KEY),
        'Should add rate plan id to add product node.');
  }

  @isTest
  private static void passingAddressShouldReturnHouseNoAndStreetName() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    String actualAddress = '731 Whiteman Ambers Avenue';
    String expectedHouseNumber = '731';
    String expectedStreetName = 'Whiteman Ambers Avenue';
    inputMap.put(OrderManagementUtils.INPUT_MAP_ADDRESS_KEY,
        actualAddress);
    Test.startTest();
      OrderManagementUtils utils = new OrderManagementUtils();
      utils.invokeMethod(OrderManagementUtils.SPLIT_ADDRESS_METHOD_NAME,
          inputMap, outMap, options);
    Test.stopTest();
    String actualHouseNumber = String.valueOf(outMap.get(
        OrderManagementUtils.OUTPUT_MAP_HOUSE_NUMBER_KEY));
    String actualStreetName = String.valueOf(outMap.get(
        OrderManagementUtils.OUTPUT_MAP_STREET_NAME_KEY));
    System.assertEquals(expectedHouseNumber, actualHouseNumber,
         'House number did not matched.');
    System.assertEquals(expectedStreetName, actualStreetName,
         'Street name did not matched.');
  }
  
  /**
 * @description This method format the Url
 * and apend order Id.
 * @param null
 */
  @isTest
  private static void passingUrlShouldBeFormatted() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    inputMap.put(OrderManagementUtils.INPUT_MAP_ARGUMENTS,
        new List<Object>{PORTIN_ORDER_ID});
    inputMap.put(OrderManagementUtils.INPUT_MAP_FORMATTING_URL,
        '/portins/{0}/activationStatus');
    Test.startTest();
      OrderManagementUtils utils = new OrderManagementUtils();
      utils.invokeMethod(OrderManagementUtils.FORMAT_URL_METHOD_NAME,
          inputMap, outMap, options);
    Test.stopTest();
    String formattedUrl = String.valueOf(
        outMap.get(OrderManagementUtils.OUTPUT_MAP_FORMATTED_URL_KEY));
    System.assertEquals(true, formattedUrl.contains(PORTIN_ORDER_ID),
         'Formatted url should contain the portin order id.');
  }

}