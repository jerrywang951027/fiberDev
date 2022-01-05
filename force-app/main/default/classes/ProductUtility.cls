/**
 * @group ProductUtility
 * @description Utility Class for Functionality related to Products
 */
global class ProductUtility implements vlocity_cmt.VlocityOpenInterface2 {

  //Constant
  public static final String CLASS_NAME = 'ProductUtility';
  public static final String GET_PRODUCT_CODE_BY_LEGACY_CODE_METHOD = 'getProductCodeByLegacyCode';
  public static final String UPDATE_CHILD_PRODUCT_DETAILS_METHOD = 'updateChildProductDetails';
  public static final String UPDATE_CHILD_PRODUCT_QUANTITY_METHOD = 'updateChildProductsQuantity';

  /**
    * @description This method is mandatory for vlocity Open interface.
    */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options) {
    // check if method is found. initialze it to true.
    boolean result = true;
    try {
      // If Method name is not blank
      if (
        String.isNotBlank(methodName) &&
        GET_PRODUCT_CODE_BY_LEGACY_CODE_METHOD
        .equalsIgnoreCase(methodName)
      ) {
        getProductCodeByLegacyCode(inputMap, outMap, options);
      } else if (
        String.isNotBlank(methodName) &&
        UPDATE_CHILD_PRODUCT_DETAILS_METHOD
        .equalsIgnoreCase(methodName)
      ) {
        updateChildProductDetails(inputMap, outMap, options);
      }
      else if(
        String.isNotBlank(methodName) &&
        UPDATE_CHILD_PRODUCT_QUANTITY_METHOD
        .equalsIgnoreCase(methodName)
      ) {
        updateChildProductsQuantity(inputMap, outMap, options);
      }
      else {
        // Method is not found. Return false
        result = false;
      }
    } catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, methodName, e);
      throw e;
    }
    return result;
  }

  /**
    * @description This method return list of Map with Below Node
    * productCode
    * quantity
    * legacyProductCode
    * isOrderable
    * parentProductCode
    * hasChildItems
    */
  private static void getProductCodeByLegacyCode(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options)
  {
    // List of LegacyProductCodes.
    List<String> legacyProductCodes;
    // Final Offer response with updated quantity.
    List<Map<String, Object>> finalProductList;
    // Set of Orderable Product Salesforce Ids.
    Set<Id> orderableProductIds = new Set<Id>();
    // Map of ProductId to Has Child Products [Boolean].
    Map<Id, Boolean> hasChildProductByProductId = new Map<Id, Boolean>();
    // Map of Child Product Ids to its Parent Product Code.
    Map<Id, String> productCodeByProductId = new Map<Id, String>();
    // Map of Parent Product Ids to its Child Product Code.
    Map<Id, String> parentProductCodeByProductId = new Map<Id, String>();
    // Map of Legacy Code to Product quantity
    Map<String, Integer> quantityByLegacyCode = new Map<String, Integer>();

    // Looping through legacyProductCodes passed as input
    // and populating legacyProductCodes and quantityByLegacyCode Map.
    if (inputMap.get('legacyProductCodes') != null) {
      legacyProductCodes = new List<String>();
      for (Object legacyCode : (List<Object>)inputMap.get('legacyProductCodes')) {
        Map<String, Object> legacyCodeMap = (Map<String, Object>)legacyCode;
        legacyProductCodes.add(String.valueOf(legacyCodeMap.get('legacyCode')));
        quantityByLegacyCode.put(
          String.valueOf(legacyCodeMap.get('legacyCode')),
          Integer.valueOf(legacyCodeMap.get('quantity'))
        );
      }
    }

    // If legacyProductCodes is not empty then query the Products based on Legacy Codes
    if (legacyProductCodes != null && !legacyProductCodes.isEmpty()) {
      List<Product2> productList = [
        SELECT
          Id,
          ProductCode,
          vlocity_cmt__IsOrderable__c,
          Legacy_Product_Code__c
        FROM
          Product2
        WHERE
          Legacy_Product_Code__c IN :legacyProductCodes
      ];

      // Filling orderableProductIds set for Orderable Products.
      for (Product2 productObject : productList) {
        if (productObject.vlocity_cmt__IsOrderable__c) {
          orderableProductIds.add(productObject.Id);
        }
      }

      // If orderableProductIds are not Empty then query vlocity_cmt__ProductChildItem__c
      // to get Child Products for Each Orderable Products.
      if (!orderableProductIds.isEmpty()) {
        List<vlocity_cmt__ProductChildItem__c> productChildItems = [
          SELECT
            Id,
            vlocity_cmt__ChildProductId__c,
            vlocity_cmt__ParentProductId__r.ProductCode
          FROM
            vlocity_cmt__ProductChildItem__c
          WHERE
            vlocity_cmt__ParentProductId__c IN : orderableProductIds
        ];

        // If Child Products found then populate
        // hasChildProductByProductId and productCodeByProductId Map
        if (!productChildItems.isEmpty()) {
          for (vlocity_cmt__ProductChildItem__c productChildItem : productChildItems) {
            hasChildProductByProductId.put(
              productChildItem.vlocity_cmt__ParentProductId__c,
              productChildItem.Id != null
            );
            productCodeByProductId.put(
              productChildItem.vlocity_cmt__ChildProductId__c,
              productChildItem.vlocity_cmt__ParentProductId__r.ProductCode
            );
          }
        }
      }

      // If productList is not blank then create a List of Map with below details
      /**
      * productCode
      * quantity
      * legacyProductCode
      * isOrderable
      * parentProductCode
      * hasChildItems
      */
      if (!productList.isEmpty()) {
        finalProductList = new List<Map<String, Object>>();
        for (Product2 prd : productList) {
          Map<String, Object> productInstance = new Map<String, Object>();
          productInstance.put('productCode', prd.ProductCode);
          productInstance.put('quantity', quantityByLegacyCode.get(prd.Legacy_Product_Code__c));
          productInstance.put('legacyProductCode', prd.Legacy_Product_Code__c);
          productInstance.put('isOrderable', prd.vlocity_cmt__IsOrderable__c);
          productInstance.put(
            'parentProductCode',
            productCodeByProductId.get(prd.Id) != null
            ? productCodeByProductId.get(prd.Id)
            : ''
          );
          productInstance.put(
            'hasChildItems',
            (
              hasChildProductByProductId.get(prd.Id) != null
              ? hasChildProductByProductId.get(prd.Id)
              : false
            )
          );
          finalproductList.add(productInstance);
        }
        // putting final result in outMap to pass it to the Integration Procedure.
        outMap.put('productList', finalProductList);
      }
    }
  }

  /**
    * @description This method updated the quantity of Product in the Vlocity Offer
    * Response for Basket Creation.
    */
  private static void updateChildProductDetails(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {

    // Vlocity Offer Response List
    List<Object> offerResponseList = (List<Object>) inputMap.get('offerResponseList');
    // List of Non-Orderable Products
    List<Object> nonOrderableProductList = (List<Object>) inputMap.get('nonOrderableProductList');
    // List of Orderable Products
    List<Object> orderableProductList = (List<Object>) inputMap.get('orderableProductList');
    // Map of Product Code to Vlocity Offer Response for that Product.
    Map<String, Object> offerResponseByProductCode = new Map<String, Object>();
    // Map of Orderaable Product Code to Quantity
    Map<String, Integer> quantityByProductCode = new Map<String, Integer>();
    // Map of Child Product Code to its parent Product Code
    Map<String, String> childProductCodeByProductCode = new Map<String, String>();

    // Loop through orderableProductList and populate offerResponseByProductCode.
    for (Object orderableProduct : orderableProductList) {
      offerResponseByProductCode.put(
        String.valueOf(((Map<String, Object>)orderableProduct).get('productCode')),
        Integer.valueOf(((Map<String, Object>)orderableProduct).get('quantity'))
      );
    }

    // generating Map of ProductCode vs Offer Response for Orderable Products.
    for (Object offerResponse : offerResponseList) {
      Map<String, Object> offerResponseMap = new Map<String, Object>();
      offerResponseMap = (Map<String, Object>)offerResponse;
      String productCode =
        String.valueOf(
          getNodeValueFromOfferResponse(
            (Map<String, Object>)offerResponseMap.get('result'),
            'ProductCode'
          )
        );
      childProductCodeByProductCode
        .putAll(
          getChildProductCodeMap(
            (Map<String, Object>)offerResponseMap.get('result'),
            productCode
          )
        );
      offerResponseByProductCode.put(productCode, offerResponseMap.get('result'));
    }

    // Looping through nonOrderableProductList and update Quantity in Offer response.
    for (Object nonOrderableProduct : nonOrderableProductList) {
      // getting child Product Code
      String productCode =
        String.valueOf(
          ((Map<String, Object>)nonOrderableProduct).get('productCode')
        );
      // Getting Offer Response of Child Product's Product Code
      Map<String, Object> parentOfferResponse =
        (Map<String, Object>)offerResponseByProductCode
          .get(childProductCodeByProductCode.get(productCode));
      // Boolean indicating Child Product found in Offer Response.
      Boolean isMatchFound = false;

      // Getting Child Product List from offer Response
      List<Object> childProducts =
        (List<Object>)getNodeValueFromOfferResponse(
          parentOfferResponse,
          'childProducts'
        );

      Map<String, Object> parentOfferDetailMap =
        (Map<String, Object>)(
          (Map<String, Object>)parentOfferResponse.get('offerDetails')
        ).get('offer');

      // Updating Quantity of Parent Offer.
      parentOfferDetailMap.put(
        'Quantity',
        offerResponseByProductCode.get(
          String.valueOf(
            getNodeValueFromOfferResponse(
              parentOfferResponse,
              'ProductCode'
            )
          )
        )
      );

      // Looping through childProducts and if child product code found update the quantity.
      for (Object childProduct : childProducts) {
        Map<String, Object> childProductMap = (Map<String, Object>)childProduct;
        if (productCode.equalsIgnoreCase(String.valueOf(childProductMap.get('ProductCode')))) {
          isMatchFound = true;
          Integer quantityToUpdate =
          Integer.valueOf(
            ((Map<String, Object>)nonOrderableProduct).get('quantity')
          );
          childProductMap.put('Quantity', quantityToUpdate);
        }
      }
      // If child product not found search in ProductGroups node in offer Response.
      if (!isMatchFound) {
        if (
          getNodeValueFromOfferResponse(parentOfferResponse,
            'productGroups') != null
          &&
          !((List<Object>)
            getNodeValueFromOfferResponse(
              parentOfferResponse,
              'productGroups'
            )
          ).isEmpty()
        ) {
          childProducts =
          (List<Object>)(
            (Map<String, Object>)(
              ((List<Object>)getNodeValueFromOfferResponse(
                parentOfferResponse,
                'productGroups'
              ))[0]
            )
          ).get('childProducts');

          for (Object childProduct : childProducts) {
            Map<String, Object> childProductMap = (Map<String, Object>)childProduct;
            if (productCode.equalsIgnoreCase(String.valueOf(childProductMap.get('ProductCode')))) {
              isMatchFound = true;
              Integer quantityToUpdate =
              Integer.valueOf(
                ((Map<String, Object>)nonOrderableProduct).get('quantity')
              );
              childProductMap.put('Quantity', quantityToUpdate);
            }
          }
        }
      }
      // Send the updated offerList back to Integration Procedure.
      outMap.put('offerResponseList', offerResponseByProductCode.values());
    }
  }

  /**
  * @description This method return the node value from the offer response passed.
    Sample Offer Response
    {
      "offerDetails" : {
        "offer" : {
          "node":"value" <-- returns this node [key is passed as argument]
        }
      }
    }
  */
  private static Object getNodeValueFromOfferResponse(
    Map<String, Object> offerResponse,String node) {
    return
    (
      (Map<String, Object>)(
        (Map<String, Object>)offerResponse
        .get('offerDetails'))
      .get('offer')
    ).get(node);
  }

  /**
    * @description This method returns child Product Map for a
    Parent Product from Offer Response of the parent Product Code.
      Sample Offer Response
      {
        "offerDetails" : {
        "offer" : {
          "childProducts":[], <-- returns this node
          "productGroups" : [{
            "childProducts":[] <-- returns this node
          }]
        }
      }
    }
  */
  private static Map<String, String> getChildProductCodeMap(
    Map<String, Object> parentOfferResponse,
    String parentProductCode
  ) {
    Map<String, String> childProductCodeByProductCode = new Map<String, String>();

      if (
        getNodeValueFromOfferResponse(parentOfferResponse, 'childProducts') != null
        &&
        !((List<Object>)getNodeValueFromOfferResponse(
          parentOfferResponse,
          'childProducts'
        )).isEmpty()
      ) {
        List<Object> childProducts =
          (List<Object>)getNodeValueFromOfferResponse(
            parentOfferResponse,
            'childProducts'
          );

        for (Object childProduct : childProducts) {
          childProductCodeByProductCode.put(
            String.valueOf(((Map<String, Object>)childProduct).get('ProductCode')),
            parentProductCode
          );
        }
      }

      if (
        getNodeValueFromOfferResponse(
          parentOfferResponse,
          'productGroups'
        ) != null
        &&
        !((List<Object>)getNodeValueFromOfferResponse(
          parentOfferResponse,
          'productGroups'
        )).isEmpty()
      ) {
        List<Object> childProducts =
          (List<Object>)(
            (Map<String, Object>)(
              (List<Object>)getNodeValueFromOfferResponse(
                parentOfferResponse,
                'productGroups'))[0]
        ).get('childProducts');
        if (!childProducts.isEmpty()) {
          for (Object childProduct : childProducts) {
            childProductCodeByProductCode.put(
              String.valueOf(
                ((Map<String, Object>)childProduct)
                .get('ProductCode')),
              parentProductCode
            );
          }
        }
      }
    return childProductCodeByProductCode;
  }

  /**
    * @description This method updates the quantity of the non-orderable
    * products with quantities in the nonOrderableProducts list.
    * @param inputMap
    * @param outMap
    * @param options
    */
  private static void updateChildProductsQuantity(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    Map<String, Object> quantityByLegacyCode = new Map<String, Object>();
    Map<String, String> legacyCodeByProductCode = new Map<String, String>();
    List<Object> productConfigs = (List<Object>)inputMap.get('productConfig');
    List<Object> nonOrderableProducts =
      (List<Object>)inputMap.get('nonOrderableProducts');

    createLegacyCodeAndQuantityMap(nonOrderableProducts,
      quantityByLegacyCode, legacyCodeByProductCode);

    for(Object offerDetailObject: productConfigs) {
      Map<String, Object> offerDetail = 
        (Map<String, Object>)((Map<String, Object>)(
          (Map<String, Object>)offerDetailObject).get('offerDetails'))
            .get('offer');
      if(offerDetail.get('childProducts') != null) {
        updateQuantity(
          (List<Object>)offerDetail.get('childProducts'),
          offerDetail,
          legacyCodeByProductCode,
          quantityByLegacyCode
        );
      }
      if(offerDetail.get('productGroups') != null) {
        for(Object productGroup: 
          (List<Object>)offerDetail.get('productGroups')) {
          updateQuantity((List<Object>)(
            (Map<String, Object>)productGroup).get('childProducts'),
            offerDetail,
            legacyCodeByProductCode,
            quantityByLegacyCode
          );
        }
      }
    }
    outMap.put('productConfig', productConfigs);
  }

  /**
    * @description This method creates map for legacy codes of the 
    * product and also creates a map for quantity, product code and 
    * size from non-orderable products list.
    * @param nonOrderableProducts
    * @param quantityByLegacyCode
    * @param legacyCodeByProductCode
    */
  private static void createLegacyCodeAndQuantityMap(
    List<Object> nonOrderableProducts,
    Map<String, Object> quantityByLegacyCode,
    Map<String, String> legacyCodeByProductCode
  ) {
    for(Object nonOrderableProduct: nonOrderableProducts) {
      Map<String, Object> nonOrderable = (Map<String, Object>)nonOrderableProduct;
      String productCode = String.valueOf(nonOrderable.get('productCode'));
      String legacyCode = String.valueOf(nonOrderable.get('legacyProductCode'));
      legacyCodeByProductCode.put(
        String.valueOf(nonOrderable.get('productCode')),
        String.valueOf(nonOrderable.get('legacyProductCode'))
      );
      if(quantityByLegacyCode.get(legacyCode) != null) {
        Map<String, Object> existingProduct =
          (Map<String, Object>)quantityByLegacyCode.get(legacyCode);
        existingProduct.put('otherProductCode', productCode);
        quantityByLegacyCode.put(legacyCode, existingProduct);
      }
      else {
        Map<String, String> product = new Map<String, String>();
        product.put('orderedQuantity',
          String.valueOf(nonOrderable.get('quantity')));
        product.put('productCode', productCode);
        quantityByLegacyCode.put(legacyCode, product);
      }
    }
  }

  /**
    * @description This method updates the quantity of the childProducts list.
    * @param childProducts
    * @param offerDetail
    * @param legacyCodeByProductCode
    * @param quantityByLegacyCode
    */
  private static void updateQuantity(
    List<Object> childProducts,
    Map<String, Object> offerDetail,
    Map<String, String> legacyCodeByProductCode,
    Map<String, Object> quantityByLegacyCode
  ) {
    for(Object childProductObject: (List<Object>)childProducts) {
      Map<String, Object> childProduct =
        (Map<String, Object>)childProductObject;
      String productCode = String.valueOf(
        childProduct.get('ProductCode'));
      String legacyCode = legacyCodeByProductCode.get(productCode);
      if(legacyCode == null){
        continue;
      }
      Map<String, Object> quantityData =
        (Map<String, Object>)quantityByLegacyCode.get(legacyCode);
      String otherProductCode = 
          quantityData.containsKey('otherProductCode') ?
          String.valueOf(quantityData.get('otherProductCode')) : null;
      Integer quantity = Integer.valueOf(childProduct.get('Quantity'));
      Integer maxQuantity = Integer.valueOf(childProduct.get('MaxQuantity'));
      Integer orderedQuantity = Integer.valueOf(
        quantityData.get('orderedQuantity'));
      if(otherProductCode == null) {
        childProduct.put('Quantity', orderedQuantity);
      }
      else {
        if(otherProductCode == productCode){
          otherProductCode =
            String.valueOf(quantityData.get('productCode'));
        }
        Integer remainingQuantity = updateRemainingQuantityInProductGroups(
          (List<Object>)offerDetail.get('productGroups'),
          otherProductCode,
          orderedQuantity
        );
        legacyCodeByProductCode.remove(otherProductCode);
        if(remainingQuantity == 0) {
          continue;
        }
        childProduct.put('Quantity', remainingQuantity);
      }
    }
  }

  /**
    * @description This method updates the updates the remaining quantity
    * of the product groups child products if quantity is less than 
    * maxQuantity else it returns the remaining quantity.
    * @param productGroups
    * @param productCode
    * @param orderedQuantity
    * @return Integer This method returns 0 if the quantity is less than
    * max quantity in the child products of the product groups else
    * returns the remaining quantity.
    */
  private static Integer updateRemainingQuantityInProductGroups(
    List<Object> productGroups,
    String productCode,
    Integer orderedQuantity
  ) {
    for(Object productGroup: productGroups) {
      List<Object> childProducts =
        (List<Object>)((Map<String, Object>)productGroup)
          .get('childProducts');
      for(Object childProductObject: childProducts) {
        Map<String, Object> childProduct =
          (Map<String, Object>)childProductObject;
        String childProductCode = String.valueOf(
          childProduct.get('ProductCode'));
        if(childProductCode == productCode) {
          Integer quantity = Integer.valueOf(childProduct.get('Quantity'));
          Integer maxQuantity = Integer.valueOf(childProduct.get('MaxQuantity'));
          if(maxQuantity == quantity) {
            return orderedQuantity;
          }
          else if(orderedQuantity <= quantity) {
            childProduct.put('Quantity', orderedQuantity);
            return 0;
          }
          else {
            return orderedQuantity - quantity;
          }
        }
      }
    }
    return 0;
  }

}