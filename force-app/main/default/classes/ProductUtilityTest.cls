/**
 * @group ProductUtilityTest
 * @description Test Class for ProductUtility
 */
@isTest
public class ProductUtilityTest {
  /**
   * @description This method is to create Test Data for all test methods.
   */
  //Constants
  public static final String FIBER_1G = 'OFR_Fiber1G';
  @testSetup
  private static void setupTestData() {

    // Creating Product for Fiber 1G
    Product2 fiber1G = new Product2(
        Name = 'Fiber 1G',
        ProductCode = FIBER_1G,
        vlocity_cmt__IsOrderable__c = true,
        Legacy_Product_Code__c = 'fiber_1000'
    );

    // Creating Product for Additional Google Wifi
    Product2 additionalWifi = new Product2(
        Name = 'Additional Wifi',
        ProductCode = 'OFR_Equip_AGWifi',
        vlocity_cmt__IsOrderable__c = true,
        Legacy_Product_Code__c = 'temp_test_AGWB'
    );

    insert new List<Product2>{fiber1G, additionalWifi};

      // Creating ProductChildItems
      vlocity_cmt__ProductChildItem__c prodChildItem = new vlocity_cmt__ProductChildItem__c(
        vlocity_cmt__ChildProductId__c = additionalWifi.Id,
        vlocity_cmt__ParentProductId__c = fiber1G.Id,
        vlocity_cmt__ChildLineNumber__c = '10'
      );

    insert new List<vlocity_cmt__ProductChildItem__c>{prodChildItem};
  }

  /**
   * @description This method is to to test
   * ProductUtility.getProductCodeByLegacyCode for Success Scenario.
   */
  @isTest
  private static void legacyProductCodeShouldReturnProduct() {
    // initializing Method Name
    String methodName = ProductUtility.GET_PRODUCT_CODE_BY_LEGACY_CODE_METHOD;

    // LegacyCode list for Input
    List<Map<String, Object>> legacyCodeList = new List<Map<String, Object>>{
      new Map<String, Object>{
        'legacyCode' => 'fiber_1000',
        'quantity' => 1,
        'type' => 'internet'
      },new Map<String, Object>{
        'legacyCode' => 'temp_test_AGWB',
        'quantity' => 1,
        'type' => 'equipment'
      }
    };

    // Initializing Maps for Input
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    ProductUtility productUtilityObj = new ProductUtility();

    // Passing Data to Input Map
    inputMap.put('legacyProductCodes', legacyCodeList);

    // Start Test
    Test.startTest();
      productUtilityObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();

    System.assert(outMap.get('productList') != null,'Product List is not null');
    List<Map<String, Object>> productList =
    (List<Map<String, Object>>)outMap.get('productList');

    // Unit test assert Start
    System.assert(!productList.isEmpty(),'Product List is not empty');
    System.assertEquals(2,productList.size(),'Product List size is 2');
    // Unit test assert End
  }

  /**
   * @description This method is to to test
   * ProductUtility.updateChildProductDetails for Success Scenario.
   */
  @isTest
  private static void passingQuantityAndOfferResponseShouldUpdateQuantity() {
    // initializing Method Name
    String methodName = ProductUtility.UPDATE_CHILD_PRODUCT_DETAILS_METHOD;

    // Sample Serialize Offer Response
    StaticResource sr = [
        SELECT
          Id,
          Body
        FROM
          StaticResource
        WHERE
          Name = 'OfferResponseFiber1gTestData'
        LIMIT 1];
    String offerResponseFiber1gTestData = sr.Body.toString();
    String additionalGoogleWifiCode = 'OFR_Equip_AGWifi';
    Integer updatedAdditionalGoogleWifiQuantity;
    Integer expectedAdditionalGoogleWifiQuantity = 1;

    String byorCode = 'OFR_Equip_BYOR';
    Integer updatedBYORQuantity;
    Integer expectedBYORQuantity = 1;

    // Sample Vlocity Offer Response List
    List<Map<String, Object>> offerResponseList =
    new List<Map<String, Object>>{
      (Map<String, Object>)
      JSON.deserializeUntyped(OfferResponseFiber1gTestData)
    };
    // Non Orderable Product Details for Input
    List<Map<String, Object>> nonOrderableProductList =
    new List<Map<String, Object>>{
      new Map<String, Object>{
        'productCode' => additionalGoogleWifiCode,
        'quantity' => expectedAdditionalGoogleWifiQuantity,
        'legacyProductCode' => 'temp_test_AGWB',
        'isOrderable' => false,
        'parentProductCode' => FIBER_1G,
        'hasChildItems'=> false
      },
      new Map<String, Object>{
        'productCode' => byorCode,
        'quantity' => expectedBYORQuantity,
        'legacyProductCode' => 'own_router',
        'isOrderable' => false,
        'parentProductCode' => FIBER_1G,
        'hasChildItems'=> false
      }
    };

    // Orderable Product Details for Input
    List<Map<String, Object>> orderableProductList =
    new List<Map<String, Object>>{
      new Map<String, Object>{
        'productCode' => FIBER_1G,
        'quantity' => 1,
        'legacyProductCode' => 'fiber_1000',
        'isOrderable' => true,
        'parentProductCode' => '',
        'hasChildItems'=> true
      }
    };

    // Initializing Maps for Input
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    ProductUtility productUtilityObj = new ProductUtility();

    // Passing Data to Input Map for Log Generation
    inputMap.put('nonOrderableProductList', nonOrderableProductList);
    inputMap.put('orderableProductList', orderableProductList);
    inputMap.put('offerResponseList', offerResponseList);

    // Start Test
    Test.startTest();
      productUtilityObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();

    // Getting the Updated Quantity from Offer Response
    Map<String, Object> responseList = (Map<String, Object>)(
        (List<Object>)outMap.get(
          'offerResponseList'
        ))[0];

    Map<String, Object> offerDetailsMap =
    (Map<String, Object>)responseList
    .get('offerDetails');

    Map<String, Object> offerMap =
        (Map<String, Object>)offerDetailsMap.get('offer');

    List<Object> childProducts = (List<Object>)offerMap.get('childProducts');

    List<Object> productGroupChildProducts =
        (List<Object>)(
          (Map<String, Object>)(
            (List<Object>)offerMap.get('productGroups')
          )[0]
        ).get('childProducts');

    // Looping through childProducts to get updated Quantity of Additional Google Wifi.
    for (Object childProduct : childProducts) {
      if (
        additionalGoogleWifiCode.equalsIgnoreCase(
          (String)((Map<String, Object>)childProduct).get('ProductCode')))
      {
        updatedAdditionalGoogleWifiQuantity =
            (Integer)((Map<String, Object>)childProduct).get('Quantity');
      }
    }
    // Looping through childProducts to get updated Quantity of Bring Your Own Router.
    for (Object childProduct : productGroupChildProducts) {
      if (byorCode.equalsIgnoreCase(
             (String)((Map<String, Object>)childProduct).get('ProductCode')))
      {
        updatedBYORQuantity =
            (Integer)((Map<String, Object>)childProduct).get('Quantity');
      }
    }
    // Unit test assert Start
      System.assertEquals(expectedAdditionalGoogleWifiQuantity, updatedAdditionalGoogleWifiQuantity,
          'Expected Additional Google Wifi (Child Product) Quantity'
          +'should match Updated Additional Google Wifi Quantity');
      System.assertEquals(expectedBYORQuantity, updatedBYORQuantity,
          'Expected BYOR (Child Product)'
          +'Quantity should match Updated BYOR Quantity');
    // Unit test assert End
  }

  /*
   * @description This method is to test Invalid Method name Scenario.
   */
  @isTest
  private static void passingInvalidMethodNameWillDoNothing() {
    // initializing Method Name
    String methodName = 'invalidMethod';

    // Initializing Maps for Input
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    ProductUtility productUtilityObj = new ProductUtility();

    // Start Test
    Test.startTest();
    Boolean result = productUtilityObj.invokeMethod(
      methodName,
      inputMap,
      outMap,
      optionsMap
    );
    Test.stopTest();

    // Unit test assert Start
      System.assert(!result);
    // Unit test assert End
  }

  /**
   * @description This method is to to test
   * ProductUtility.updateChildProductDetails for Success Scenario.
   */
  @isTest
  private static void passingProductConfigShouldUpdateQuantity() {
    // initializing Method Name
    String methodName = ProductUtility.UPDATE_CHILD_PRODUCT_QUANTITY_METHOD;

    // Sample Serialize Offer Response
    StaticResource sr = [
        SELECT
          Id,
          Body
        FROM
          StaticResource
        WHERE
          Name = 'OfferResponseFiber1gTestData'
        LIMIT 1];
    String offerResponseFiber1gTestData = sr.Body.toString();
    String additionalGoogleWifiCode = 'OFR_Equip_AGWifi';
    String includedGoogleWifiCode = 'OFR_Equip_GWifi';
    Integer expectedAdditionalGoogleWifiQuantity = 4;
    Integer actualGoogleWifiQuantity = 0;
    Integer actualGDriveQuantity = 0;

    String gDriveCode = 'OFR_Gdrive';
    Integer expectedGDriveQuantity = 1;

    // Sample Vlocity Offer Response List
    List<Map<String, Object>> offerResponseList =
        new List<Map<String, Object>>{
          (Map<String, Object>)
          JSON.deserializeUntyped(OfferResponseFiber1gTestData)
        };
    // Non Orderable Product Details for Input
    List<Object> nonOrderableProductList =
        new List<Object>{
          new Map<String, Object>{
            'productCode' => additionalGoogleWifiCode,
            'quantity' => expectedAdditionalGoogleWifiQuantity,
            'legacyProductCode' => 'wifi_box',
            'isOrderable' => false,
            'parentProductCode' => FIBER_1G,
            'hasChildItems'=> false
          },
          new Map<String, Object>{
            'productCode' => gDriveCode,
            'quantity' => expectedGDriveQuantity,
            'legacyProductCode' => 'gdrive_quota',
            'isOrderable' => false,
            'parentProductCode' => FIBER_1G,
            'hasChildItems'=> false
          },
          new Map<String, Object>{
            'productCode' => includedGoogleWifiCode,
            'quantity' => expectedAdditionalGoogleWifiQuantity,
            'legacyProductCode' => 'wifi_box',
            'isOrderable' => false,
            'parentProductCode' => FIBER_1G,
            'hasChildItems'=> false
          }
        };

    // Initializing Maps for Input
    Map<String, Object> inputMap = new map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new map<String, Object>();
    ProductUtility productUtilityObj = new ProductUtility();

    // Passing Data to Input Map for Log Generation
    inputMap.put('nonOrderableProducts', nonOrderableProductList);
    inputMap.put('productConfig',
      new List<Object>{offerResponseList[0].get('result')});

    // Start Test
    Test.startTest();
      productUtilityObj.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    List<Object> productConfigs = (List<Object>)outMap.get('productConfig');
    for(Object offerDetailObject: productConfigs) {
      Map<String, Object> offerDetail =
          (Map<String, Object>)((Map<String, Object>)(
          (Map<String, Object>)offerDetailObject).get('offerDetails'))
          .get('offer');
      for(Object childProductObject:
          (List<Object>)offerDetail.get('childProducts'))
      {
        Map<String, Object> childProduct =
            (Map<String, Object>)childProductObject;
            String productCode = String.valueOf(
                childProduct.get('ProductCode'));
            Integer quantity = Integer.valueOf(
                childProduct.get('Quantity'));
            if (productCode == gDriveCode) {
                actualGDriveQuantity = quantity;
            }
            else if (productCode == additionalGoogleWifiCode) {
              actualGoogleWifiQuantity = quantity;
              for(Object productGroup:
                  (List<Object>)offerDetail.get('productGroups'))
              {
                List<Object> childProducts =
                    (List<Object>)((Map<String, Object>)productGroup)
                    .get('childProducts');
                for(Object groupChildProductObject: childProducts) {
                  Map<String, Object> groupChildProduct =
                      (Map<String, Object>)groupChildProductObject;
                  String otherProductCode = String.valueOf(
                      groupChildProduct.get('ProductCode'));
                  if (otherProductCode == includedGoogleWifiCode) {
                     Integer groupChildQuantity = Integer.valueOf(
                         groupChildProduct.get('Quantity'));
                     actualGoogleWifiQuantity =
                        actualGoogleWifiQuantity + groupChildQuantity;
                     break;
                  }
                }
              }
            }
        }
        System.assertEquals(expectedAdditionalGoogleWifiQuantity, actualGoogleWifiQuantity,
            'Google WiFi quantitiy did not match');
        System.assertEquals(expectedGDriveQuantity, actualGDriveQuantity,
            'Gdrive quantity did not match');
    }
  }
}