/*This Class is uesd to transform data  modelled from SFI EPC(V3) into the format close
to current V2 data modelling exposed to integration layer(V2)*/
global class V3CatalogTransformation extends
    vlocity_cmt.DefaultSystemInterface {

 //Initialize Class Constants.
 public final String CLASS_NAME = 'V3CatalogTransformation';
 public final String PRODUCT_TRANSFORM_METHOD_NAME = 'productsTransformation';
 public
  static final String ADJUSTMENT_PRICE_LIST_KEY = 'adjustmentPriceList';
 public
  static final String NON_ADJUSTMENT_PRICE_LIST_KEY = 'nonAdjustmentPriceList';
 public
  static final String ADJUSTMENT_KEY = 'adjustment';

  // This method used to perform products transformation.
  global void productsTransformation() {
    Map<Id, Integer> prdWithNonAdjCount = new Map<Id, Integer>();
    Map<Id, Product2> prdocuctsWithCardinalityChange = new Map<Id, Product2>();
    Map<Id, Product2> nonAdjProducts = new Map<Id, Product2>();
    Map<Id, String> prdocuctsWithNoCardinalityChange = new Map<Id, String>();
    Map<Id, Product2> singleRatePlanWithOneCharge = new Map<Id, Product2>();
    Map<Id, Product2> singleRatePlanWithTwoCharge = new Map<Id, Product2>();
    Map<Id, Product2> multiRatePlanCharges = new Map<Id, Product2>();
    try {
      List<vlocity_cmt__PriceListEntry__c> productPriceListEntries =
          new list<vlocity_cmt__PriceListEntry__c>();
      List<Product2> productList = new list<Product2>();
      Map<Id, Product2> productDataMap = new Map<Id, Product2>([
          SELECT Family,
            Id,
            Name,
            ProductCode,
            Legacy_Product_Code__c,
            vlocity_cmt__Type__c,
            vlocity_cmt__ObjectTypeName__c,
            vlocity_cmt__SpecificationType__c,
            vlocity_cmt__ProductSpecName__c,
            Zuora_Id__c,
            (SELECT 
              Id, Name, vlocity_cmt__RecurringPrice__c 
            FROM
              PricebookEntries),
            (SELECT
              vlocity_cmt__ProductId__c,
                vlocity_cmt__PriceListId__r.Name,
                vlocity_cmt__OfferId__c,
                Id,
                vlocity_cmt__DisplayText__c,
                vlocity_cmt__PricingElementId__r.vlocity_cmt__DisplayText__c,
                vlocity_cmt__PricingElementAmount__c,
                vlocity_cmt__PricingElementId__r.vlocity_cmt__AdjustmentValue__c,
                vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__AdjustmentMethod__c,
                vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c,
                vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__RecurringFrequency__c,
                vlocity_cmt__IsVirtualPrice__c,
                vlocity_cmt__IsBasePrice__c
             FROM 
               vlocity_cmt__ProductPriceListEntries__r
             WHERE 
               vlocity_cmt__IsActive__c = true),
            (SELECT
              vlocity_cmt__ParentProductId__c,
                vlocity_cmt__ParentProductName__c,
                vlocity_cmt__ChildProductId__c,
                vlocity_cmt__ChildProductName__c,
                vlocity_cmt__IsRootProductChildItem__c,
                vlocity_cmt__Quantity__c,
                vlocity_cmt__MinQuantity__c,
                vlocity_cmt__MaxQuantity__c,
                vlocity_cmt__MinimumChildItemQuantity__c,
                vlocity_cmt__MaximumChildItemQuantity__c,
                vlocity_cmt__IsOverride__c,
                vlocity_cmt__ChildProductId__r.Legacy_Product_Code__c,
                vlocity_cmt__ParentProductId__r.Legacy_Product_Code__c,
                vlocity_cmt__MinMaxDefaultQty__c
             FROM
             vlocity_cmt__ProductChildItems__r),
            (SELECT vlocity_cmt__Product2Id__r.Name,
                vlocity_cmt__RelationshipType__c,
                vlocity_cmt__RelatedProductId__r.Name
             FROM 
             vlocity_cmt__RelatedProduct__r),
            (SELECT Name,
                Criteria__c,
                Fiber_Market__c,
                GFiber_Cost__c,
                GFiber_Device_Model__c,
                Gfiber_Device_Type__c,
                Product_Family__c,
                Product_Line__c,
                Product_Code__c,
                Product__c,
                Is_Component__c,
                Is_Active__c,
                GFiber_Min_Pv4_Subnet_Prefix__c,
                GFiber_Min_IPv6_Subnet_Prefix__c,
                Product_SubLine__c
              FROM
                Google_Product_Supplemental_Objects__r),
            (SELECT Criteria__c,
                Fiber_Market__c,
                Name,
                V3_Product__c,
                Root_Container_Product__c,
                Product_Rate_Plan_Code__c
             FROM Google_Product_Rate_Plan_Objects1__r)
          FROM Product2
          WHERE IsActive =true
          AND vlocity_cmt__GlobalKey__c != null
      ]);
      Map<Id, vlocity_cmt__ProductChildItem__c> productChildItems =
          new Map<Id, vlocity_cmt__ProductChildItem__c>([
            SELECT
              Id,
              Name,
              vlocity_cmt__ChildLineNumber__c,
              vlocity_cmt__ChildProductId__c, vlocity_cmt__ChildProductName__c,
              vlocity_cmt__GlobalKey__c, vlocity_cmt__IsRootProductChildItem__c,
              vlocity_cmt__MaximumChildItemQuantity__c,
              vlocity_cmt__MaxQuantity__c,
              vlocity_cmt__MinimumChildItemQuantity__c,
              vlocity_cmt__MinMaxDefaultQty__c,
              vlocity_cmt__MinQuantity__c,
              vlocity_cmt__IsOverride__c,
              
              vlocity_cmt__ChildProductId__r.Legacy_Product_Code__c,
              vlocity_cmt__ParentProductId__r.Legacy_Product_Code__c,
              vlocity_cmt__ParentProductId__c,
              vlocity_cmt__ParentProductName__c,
              vlocity_cmt__Quantity__c,
              vlocity_cmt__RelationshipType__c,
              vlocity_cmt__SelectionMethodImplementation__c,
              vlocity_cmt__SeqNumber__c,
                (SELECT Name,
                   vlocity_cmt__OverridingProductChildItemId__c,
                   vlocity_cmt__ProductId__c,
                   vlocity_cmt__ProductId__r.Name
                 FROM
                  vlocity_cmt__OverrideDefinitions__r)
            FROM vlocity_cmt__ProductChildItem__c ]);
      productList = productDataMap.values();
      Integer counter = 0;
      for (Product2 productRecord : productList) {
        if (productRecord.Legacy_Product_Code__c != null &&
            /*productRecord.Google_Product_Supplemental_Objects__r != Null &&
            productRecord.Google_Product_Rate_Plan_Objects1__r != Null &&*/
            (productRecord.Legacy_Product_Code__c=='fiber_1000'||
             productRecord.Legacy_Product_Code__c=='drive_quota_1_tb'||
             productRecord.Legacy_Product_Code__c=='fiber_2g' ||
             productRecord.Legacy_Product_Code__c=='neighborhood_100' ||
             productRecord.Legacy_Product_Code__c=='phone_battery' ||
             productRecord.ProductCode=='OFR_Equip_Mesh' ||
             productRecord.ProductCode=='OFR_Equip_GWifi' /*||
             productRecord.Legacy_Product_Code__c=='phone' */
            )
            ) {
          Set<id> rootProcutIds = getRootProduct(
              productChildItems.values(), productRecord.id, productRecord.id);
          Boolean isSingleRatePlanWithTwoCharge = false;
          for (vlocity_cmt__ProductChildItem__c productChildItem :
              productChildItems.values()) {
            if((ProductChildItem.vlocity_cmt__ChildProductId__c ==
                productRecord.id) &&
                ProductChildItem.vlocity_cmt__IsOverride__c == False) {
              List<vlocity_cmt__OverrideDefinition__c> overrideDefinitions =
                  new List<vlocity_cmt__OverrideDefinition__c>();
              if (ProductChildItem.vlocity_cmt__OverrideDefinitions__r != Null &&
                  ProductChildItem.vlocity_cmt__OverrideDefinitions__r.size() >
                  0) {
                multiRatePlanCharges.put(productRecord.id, productRecord);
              }
              else if (!multiRatePlanCharges.keySet().contains(
                  productRecord.id) && ProductChildItem.vlocity_cmt__ChildProductId__c ==
                  productRecord.id) {
                isSingleRatePlanWithTwoCharge = true;
                rootProcutIds =
                    getRootProduct(productChildItems.values(), productRecord.id,
                    productRecord.id);
                if (rootProcutIds.size() > 0) {
                  for (Id rootproductId : rootProcutIds) {
                    product2 rootProduct = productDataMap.get(rootproductId);
                    list<vlocity_cmt__ProductChildItem__c> rootOfChildProducts =
                        new list<vlocity_cmt__ProductChildItem__c>();
                    rootOfChildProducts =
                        rootProduct.vlocity_cmt__ProductChildItems__r;
                    Boolean isLegacyProductCodePresentInHierarchy =
                        isLegacyProductCodePresentInHierarchy(
                            productChildItems.values(), (String)rootProductId,
                            (String)productRecord.Id,
                            productRecord.Legacy_Product_Code__c);
                    if (IsLegacyProductCodePresentInHierarchy == true &&
                        !singleRatePlanWithTwoCharge.keySet().contains(
                        productRecord.id)) {
                      singleRatePlanWithTwoCharge.put(productRecord.id, productRecord);
                    }
                  }
                }
              }
            }
          }
          if(!multiRatePlanCharges.containsKey(productRecord.id) &&
              !singleRatePlanWithTwoCharge.containsKey(productRecord.id)) {
            singleRatePlanWithOneCharge.put(productRecord.id, productRecord);
          }
        }
      }
      if(singleRatePlanWithOneCharge != Null && !singleRatePlanWithOneCharge.isEmpty()) {
        singleRatePlanWithOneCharge(singleRatePlanWithOneCharge,
            productChildItems);
      }
      if(singleRatePlanWithTwoCharge != Null && !singleRatePlanWithTwoCharge.isEmpty()) {
        multiRatePlan(singleRatePlanWithTwoCharge, productChildItems, productDataMap);
      }
      if(multiRatePlanCharges != Null && !multiRatePlanCharges.isEmpty()) {
        multiRatePlan(multiRatePlanCharges, productChildItems, productDataMap);
      }
    } catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, PRODUCT_TRANSFORM_METHOD_NAME,
          e.getMessage());
    }
  }

  // Method with single rate plan with one charge
  global boolean singleRatePlanWithOneCharge(
      map<Id, Product2> singleRatePlanProducts,
      Map<Id, vlocity_cmt__ProductChildItem__c> productChildItems) {
    list<GFQQ_Product2__c> singleRatePlanList = new list<GFQQ_Product2__c>();
    List<GFQQ_Product_Rate_Plan__c> listProductRatePlans =
        new list<GFQQ_Product_Rate_Plan__c>();
    List<GFQQ_Product_Rate_Plan_Charge__c> listRatePlanCharges =
        new list<GFQQ_Product_Rate_Plan_Charge__c>();
    List<GFQQ_Product_Rate_Plan_Charge_Tier__c> listRatePlanChargeTiers =
        new list<GFQQ_Product_Rate_Plan_Charge_Tier__c>();
    List<GFQQ_Product_Option__c> options = new List<GFQQ_Product_Option__c>();
    list<Sobject> insertSobjectRecords = new list<Sobject>();
    if (singleRatePlanProducts.values().size() > 0) {
      for (product2 productRecord : singleRatePlanProducts.values()) {
        GFQQ_Product2__c singleRatePlan = new GFQQ_Product2__c();
        GFQQ_Product_Rate_Plan__c productRatePlan =
            new GFQQ_Product_Rate_Plan__c();
        GFQQ_Product_Rate_Plan_Charge__c ratePlanCharge =
            new GFQQ_Product_Rate_Plan_Charge__c();
        GFQQ_Product_Rate_Plan_Charge_Tier__c ratePlanChargeTier =
            new GFQQ_Product_Rate_Plan_Charge_Tier__c();
        GFQQ_Product2__c productReference = new GFQQ_Product2__c();
        ProductReference.MyExtID__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Product_Code__c;
        singleRatePlan.MyExtID__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Product_Code__c;
        singleRatePlan.Name = productRecord.Name;
        singleRatePlan.Family__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Product_Family__c;
        singleRatePlan.Criteria__c =
            productRecord.Google_Product_Supplemental_Objects__r[0].Criteria__c;
        singleRatePlan.Fiber_Market__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Fiber_Market__c;
        singleRatePlan.Product_Code__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Product_Code__c;
        singleRatePlan.Component__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Is_Component__c;
        singleRatePlan.Product_Line__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Product_Line__c;
        singleRatePlan.Product_Sub_Line__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Product_SubLine__c;
        singleRatePlan.IsActive__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Is_Active__c;
        singleRatePlan.GFiber_Cost__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .GFiber_Cost__c;
        singleRatePlan.GFiber_Device_Model__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .GFiber_Device_Model__c;
        singleRatePlan.Gfiber_Device_Type__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .Gfiber_Device_Type__c;
        singleRatePlan.GFiber_Min_IPv4_Subnet_Prefix__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .GFiber_Min_Pv4_Subnet_Prefix__c;
        singleRatePlan.GFiber_Min_IPv6_Subnet_Prefix__c =
            productRecord.Google_Product_Supplemental_Objects__r[0]
                .GFiber_Min_IPv6_Subnet_Prefix__c;
        GFQQ_Product_Rate_Plan__c productRateReference =
            new GFQQ_Product_Rate_Plan__c();
        productRateReference.MyExtID__c =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0]
                .Product_Rate_Plan_Code__c;
        productRatePlan.MyExtID__c =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0]
                .Product_Rate_Plan_Code__c;
        productRatePlan.Product__r = ProductReference;
        productRatePlan.Name =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0].Name;
        productRatePlan.Criteria__c =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0].Criteria__c;
        productRatePlan.Fiber_Market__c =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0]
                .Fiber_Market__c;
        productRatePlan.Product_Plan_Rate_Code__c =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0]
                .Product_Rate_Plan_Code__c;
        GFQQ_Product_Rate_Plan_Charge__c productRatePlanChargeReference =
            new GFQQ_Product_Rate_Plan_Charge__c();
        productRatePlanChargeReference.MyExtID__c =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0]
                .Product_Rate_Plan_Code__c;
        RatePlanCharge.Product_Rate_Plan__r = productRateReference;
        RatePlanCharge.MyExtID__c =
            productRecord.Google_Product_Rate_Plan_Objects1__r[0]
                .Product_Rate_Plan_Code__c;
        RatePlanCharge.Charge_Type__c =
            productRecord.vlocity_cmt__ProductPriceListEntries__r[0]
                .vlocity_cmt__PricingElementId__r
                .vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c;
        RatePlanCharge.Charge_Model__c = 'Flat Fee';
        RatePlanCharge.Name = productRecord.Legacy_Product_Code__c;
        ratePlanChargeTier.Product_Rate_Plan_Charge__r =
            productRatePlanChargeReference;
        ratePlanChargeTier.Price__c =
            productRecord.vlocity_cmt__ProductPriceListEntries__r[0]
                .vlocity_cmt__PricingElementAmount__c;
        ratePlanChargeTier.Name = productRecord.Legacy_Product_Code__c;
        listProductRatePlans.add(productRatePlan);
        listRatePlanCharges.add(RatePlanCharge);
        listRatePlanChargeTiers.add(ratePlanChargeTier);
        singleRatePlanList.add(singleRatePlan);
        List<Sobject> sobjectsList = createProductOptions(productRecord,
            productRecord.Google_Product_Supplemental_Objects__r[0]);
        if(sobjectsList != null && !sobjectsList.isEmpty()) {
          singleRatePlanList.add((GFQQ_Product2__c)sobjectsList[0]);
          options.add((GFQQ_Product_Option__c)sobjectsList[1]);
        }
      }
      insertSobjectRecords.addAll(singleRatePlanList);
      insertSobjectRecords.addAll(listProductRatePlans);
      insertSobjectRecords.addAll(listRatePlanCharges);
      insertSobjectRecords.addAll(listRatePlanChargeTiers);
      insertSobjectRecords.addAll(options);
      if (insertSobjectRecords.size() > 0) {
        insert insertSobjectRecords;
      }
    }
    return true;
  }
  // This method creates GFQQ_Product_Option__c records if auxiliary productOption is available.
  private List<Sobject> createProductOptions(Product2 product,
      Google_Product_Supplemental_Object__c productSupplementalObject) {
    List<Sobject> sobjects = new List<Sobject>();
    List<Google_Product_Option_Object__c> productOptions = [
      SELECT
        Name,
        MaxQuantity__c,
        MinQuantity__c,
        Required__c,
        Selected__c,
        ConfiguredSKU__c,
        ConfiguredSKU__r.Product_Code__c,
        OptionalSKU__c,
        OptionalSKU__r.Name,
        OptionalSKU__r.Criteria__c,
        OptionalSKU__r.Fiber_Market__c,
        OptionalSKU__r.GFiber_Cost__c,
        OptionalSKU__r.GFiber_Device_Model__c,
        OptionalSKU__r.Gfiber_Device_Type__c,
        OptionalSKU__r.Product_Family__c,
        OptionalSKU__r.Product_Line__c,
        OptionalSKU__r.Product_Code__c,
        OptionalSKU__r.Product__c,
        OptionalSKU__r.Is_Component__c,
        OptionalSKU__r.Is_Active__c,
        OptionalSKU__r.GFiber_Min_Pv4_Subnet_Prefix__c,
        OptionalSKU__r.GFiber_Min_IPv6_Subnet_Prefix__c,
        OptionalSKU__r.Product_SubLine__c
      FROM
        Google_Product_Option_Object__c
      WHERE
        ConfiguredSKU__c = :productSupplementalObject.Id
    ];
    if(productOptions != null && !productOptions.isEmpty()) {
      for(Google_Product_Option_Object__c productOption: productOptions) {
        GFQQ_Product_Option__c option = new GFQQ_Product_Option__c();
        option.Selected__c = productOption.Selected__c;
        option.Required__c = productOption.Required__c;
        option.MaxQuantity__c = productOption.MaxQuantity__c;
        option.MinQuantity__c = productOption.MinQuantity__c;
        option.ConfiguredSKU__r = setRatePlanProduct(null,
           productOption.ConfiguredSKU__r.Product_Code__c);
        option.OptionalSKU__r = setRatePlanProduct(null,
            productOption.OptionalSKU__r.Product_Code__c);
        GFQQ_Product2__c optionalSkuProduct = setRatePlanProduct(productOption.OptionalSKU__r,
            productOption.OptionalSKU__r.Product_Code__c);
        sobjects.add(optionalSkuProduct);
        sobjects.add(option);
      }
    }
    return sobjects;
  }

// This method will return the all root product ids.
 public
  static Set<Id> getRootProduct(
      List<vlocity_cmt__ProductChildItem__c> productChildItems,
      String productId, String oldProductId) {
    Set<Id> rootIds = new Set<Id>();
    for (vlocity_cmt__ProductChildItem__c currentChildItem :
         productChildItems) {
      if (currentChildItem.vlocity_cmt__ChildProductId__c == productId) {
        rootIds.addAll(getRootProduct(
            productChildItems, currentChildItem.vlocity_cmt__ParentProductId__c,
            oldProductId));
      } else if (currentChildItem.vlocity_cmt__ParentProductId__c ==
                     productId &&
                 currentChildItem.vlocity_cmt__ParentProductId__c !=
                     oldProductId &&
                 currentChildItem.vlocity_cmt__ChildProductId__c == null &&
                 !isChildOfAnyProduct(
                     productChildItems,
                     currentChildItem.vlocity_cmt__ParentProductId__c)) {
        System.debug(':::Exit Condition:::' + currentChildItem);
        rootIds.add(currentChildItem.vlocity_cmt__ParentProductId__c);
      }
    }
    return rootIds;
  }

 // This method return true if product is child of any other product.
 private
  static boolean isChildOfAnyProduct(
      List<vlocity_cmt__ProductChildItem__c> productChildItems,
      String productId) {
    for (vlocity_cmt__ProductChildItem__c productChildItem :
         productChildItems) {
      if (productChildItem.vlocity_cmt__ChildProductId__c == productId) {
        return true;
      }
    }
    return false;
  }

 // This method will returns root product ids where product with same legacy code.
 public
  static Set<Id> filterRootProducts(
      List<vlocity_cmt__ProductChildItem__c> productChildItems,
      Set<Id> rootPrdIds, String legacyCode, String currentProductId) {
    for (Id rootPrdId : rootPrdIds) {
      if (!isLegacyProductCodePresentInHierarchy(
              productChildItems, rootPrdId, currentProductId, legacyCode)) {
        rootPrdIds.remove(rootPrdId);
      }
    }
    return rootPrdIds;
  }

  // This method returns true if same legacy code presentin hierarchy.
  Public static Boolean isLegacyProductCodePresentInHierarchy(
      List<vlocity_cmt__ProductChildItem__c> productChildItems,
      String productId, String oldProductId, String legacyCode) {
    Boolean isLegacyCodePresent = false;
    for (vlocity_cmt__ProductChildItem__c productChildItem :
         productChildItems) {
      if (productChildItem.vlocity_cmt__ParentProductId__c == productId &&
          productChildItem.vlocity_cmt__ChildProductId__c != null) {
        if (productChildItem.vlocity_cmt__ChildProductId__c != oldProductId &&
            productChildItem.vlocity_cmt__ChildProductId__r
                    .Legacy_Product_Code__c == legacyCode) {
          return true;
        }
        isLegacyCodePresent = isLegacyProductCodePresentInHierarchy(
            productChildItems, productChildItem.vlocity_cmt__ChildProductId__c,
            oldProductId, legacyCode);
        if (isLegacyCodePresent) {
          return isLegacyCodePresent;
        }
      }
    }
    return isLegacyCodePresent;
  }

  // This method performs multiRatePlan operations.
  global void multiRatePlan(
      map<Id, Product2> multiRatePlanProducts,
      Map<Id, vlocity_cmt__ProductChildItem__c> productChildItems,
      Map<Id, Product2> productDataMap) {
    List<SObject> insertObjectsList = new List<SObject>();
    List<Product2> multiRatePlanProductslist = multiRatePlanProducts.values();
    if (multiRatePlanProductslist != null) {
      for (Product2 mutliRateProductRecord : multiRatePlanProductslist) {
        GFQQ_Product2__c multiRatePlanProduct = new GFQQ_Product2__c();
        GFQQ_Product2__c multiRatePlanProductReference = new GFQQ_Product2__c();
        List<GFQQ_Product2__c> listProducts = new List<GFQQ_Product2__c>();
        List<GFQQ_Product_Rate_Plan__c> listProductRatePlans =
            new List<GFQQ_Product_Rate_Plan__c>();
        List<GFQQ_Product_Rate_Plan_Charge__c> listRatePlanCharges =
            new List<GFQQ_Product_Rate_Plan_Charge__c>();
        List<GFQQ_Product_Rate_Plan_Charge_Tier__c> listRatePlanChargeTiers =
            new List<GFQQ_Product_Rate_Plan_Charge_Tier__c>();
        Product2 addOnProduct = getAddonProductWithLegacyCode(
            mutliRateProductRecord.Legacy_Product_Code__c,
            mutliRateProductRecord.Id, productDataMap.values());
        Set<Id> rootSWithSameLegacyCode = new Set<Id>();
        vlocity_cmt__PriceListEntry__c adjustmentPriceList = null;
        vlocity_cmt__PriceListEntry__c nonAdjustmentPriceList = null;
        vlocity_cmt__PriceListEntry__c addOnNonAdjustmentPriceList = null;
        Google_Product_Supplemental_Object__c productSuppObject =
            getProductSupplementalObject(
                mutliRateProductRecord.Google_Product_Supplemental_Objects__r,
                mutliRateProductRecord.Id);
        multiRatePlanProduct = setRatePlanProduct(
            productSuppObject, productSuppObject.Product_Code__c);
        multiRatePlanProductReference =
            setRatePlanProduct(null, multiRatePlanProduct.MyExtID__c);
        listProducts.add(multiRatePlanProduct);
        for (vlocity_cmt__PriceListEntry__c priceListEntry :
             mutliRateProductRecord.vlocity_cmt__ProductPriceListEntries__r) {
          if (adjustmentPriceList == null &&
              priceListEntry.vlocity_cmt__PricingElementId__r
                  .vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c
                  .equalsIgnoreCase('Adjustment')) {
            adjustmentPriceList = priceListEntry;
          } else if (nonAdjustmentPriceList == null &&
                     !priceListEntry.vlocity_cmt__PricingElementId__r
                          .vlocity_cmt__PricingVariableId__r
                          .vlocity_cmt__ChargeType__c.equalsIgnoreCase(
                              'Adjustment')) {
            nonAdjustmentPriceList = priceListEntry;
          }
        }
        for (vlocity_cmt__PriceListEntry__c priceListEntry :
             addOnProduct.vlocity_cmt__ProductPriceListEntries__r) {
          if (!priceListEntry.vlocity_cmt__PricingElementId__r
                   .vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c
                   .equalsIgnoreCase('Adjustment')) {
            addOnNonAdjustmentPriceList = priceListEntry;
            break;
          }
        }
        Set<Id> rootIds = getRootProduct(productChildItems.values(),
                                         mutliRateProductRecord.id,
                                         mutliRateProductRecord.id);
        if (rootIds.size() > 0) {
          rootsWithSameLegacyCode =
              filterRootProducts(productChildItems.Values(), rootIds,
                                 mutliRateProductRecord.Legacy_Product_Code__c,
                                 mutliRateProductRecord.Id);
        }
        if (rootsWithSameLegacyCode.size() > 0) {
          for (Id rootProductId : rootsWithSameLegacyCode) {
            GFQQ_Product_Rate_Plan__c productRatePlan =
                new GFQQ_Product_Rate_Plan__c();
            GFQQ_Product_Rate_Plan__c productRatePlanReference =
                new GFQQ_Product_Rate_Plan__c();
            GFQQ_Product_Rate_Plan_Charge__c ratePlanCharge1 =
                new GFQQ_Product_Rate_Plan_Charge__c();
            GFQQ_Product_Rate_Plan_Charge__c ratePlanCharge1Reference =
                new GFQQ_Product_Rate_Plan_Charge__c();
            GFQQ_Product_Rate_Plan_Charge__c ratePlanCharge2 =
                new GFQQ_Product_Rate_Plan_Charge__c();
            GFQQ_Product_Rate_Plan_Charge__c ratePlanCharge2Reference =
                new GFQQ_Product_Rate_Plan_Charge__c();
            GFQQ_Product_Rate_Plan_Charge_Tier__c ratePlanChargeTier1 =
                new GFQQ_Product_Rate_Plan_Charge_Tier__c();
            GFQQ_Product_Rate_Plan_Charge_Tier__c ratePlanChargeTier2 =
                new GFQQ_Product_Rate_Plan_Charge_Tier__c();
            Product2 rootProductRecord = productDataMap.get(rootProductId);
            // Exclude root products when it does not have legacy code. Example:
            // 1 Gig Downgrade as root offer for Mesh Extender.
            if (rootProductRecord == null ||
                rootProductRecord.Legacy_Product_Code__c == null) {
              continue;
            }
            Integer maxCardinality =
                getMaxCardinality(productChildItems, mutliRateProductRecord,
                                  rootProductRecord, false);
            Integer addOnMaxCardinality = getMaxCardinality(
                productChildItems, addOnProduct, rootProductRecord, true);
            Google_Product_Rate_Plan_Object__c ratePlanObject =
                getRatePlanObject(
                    mutliRateProductRecord.Google_Product_Rate_Plan_Objects1__r,
                    rootProductId);
            ratePlanChargeTier1 = setChargeTier(
                maxCardinality,
                new Map<String, vlocity_cmt__PriceListEntry__c>{
                    ADJUSTMENT_PRICE_LIST_KEY => adjustmentPriceList,
                    NON_ADJUSTMENT_PRICE_LIST_KEY => nonAdjustmentPriceList},
                ratePlanObject.Product_Rate_Plan_Code__c + ' 1');
            ratePlanChargeTier2 =
                setChargeTier(addOnMaxCardinality + maxCardinality,
                              new Map<String, vlocity_cmt__PriceListEntry__c>{
                                  NON_ADJUSTMENT_PRICE_LIST_KEY =>
                                      addOnNonAdjustmentPriceList},
                              ratePlanObject.Product_Rate_Plan_Code__c + '2');

            ratePlanCharge1 = setRatePlanCharge(
                nonAdjustmentPriceList.vlocity_cmt__PricingElementId__r
                    .vlocity_cmt__PricingVariableId__r
                    .vlocity_cmt__ChargeType__c,
                ratePlanObject.Product_Rate_Plan_Code__c + ' 1',
                ratePlanObject.Product_Rate_Plan_Code__c + '1');
            ratePlanCharge1Reference =
                setRatePlanCharge(null, null, ratePlanCharge1.MyExtID__c);
            ratePlanCharge2 = setRatePlanCharge(
                nonAdjustmentPriceList.vlocity_cmt__PricingElementId__r
                    .vlocity_cmt__PricingVariableId__r
                    .vlocity_cmt__ChargeType__c,
                ratePlanObject.Product_Rate_Plan_Code__c + ' 2',
                ratePlanObject.Product_Rate_Plan_Code__c + '2');
            ratePlanCharge2Reference =
                setRatePlanCharge(null, null, ratePlanCharge2.MyExtID__c);
            ratePlanChargeTier1.Product_Rate_Plan_Charge__r =
                ratePlanCharge1Reference;
            ratePlanChargeTier2.Product_Rate_Plan_Charge__r =
                ratePlanCharge2Reference;
            productRatePlan = setProductRatePlan(
                ratePlanObject, ratePlanObject.Product_Rate_Plan_Code__c);
            productRatePlanReference =
                setProductRatePlan(null, productRatePlan.MyExtID__c);
            ratePlanCharge1.Product_Rate_Plan__r = productRatePlanReference;
            ratePlanCharge2.Product_Rate_Plan__r = productRatePlanReference;
            productRatePlan.Product__r = multiRatePlanProductReference;
            // rootProceListEntries =
            // rootProductRecord.get(rootProductRecord.id).;
            listProductRatePlans.add(productRatePlan);
            listRatePlanCharges.add(ratePlanCharge1);
            listRatePlanCharges.add(ratePlanCharge2);
            listRatePlanChargeTiers.add(ratePlanChargeTier1);
            listRatePlanChargeTiers.add(ratePlanChargeTier2);
          }
        }
        insertObjectsList.addAll(listProducts);
        insertObjectsList.addAll(listProductRatePlans);
        insertObjectsList.addAll(listRatePlanCharges);
        insertObjectsList.addAll(listRatePlanChargeTiers);
      }
    }
    if (!insertObjectsList.isEmpty()) {
      insert insertObjectsList;
    }
  }

 // It retuns the max maxCardinality from the productChildItems of the product.
 private
  Integer getMaxCardinality(
      Map<Id, vlocity_cmt__ProductChildItem__c> productChildItems,
      Product2 offerProduct, Product2 rootProduct, Boolean isAddonProduct) {
    for (vlocity_cmt__ProductChildItem__c productChildItem :
         productChildItems.values()) {
      if (!isAddonProduct &&
          productChildItem.vlocity_cmt__ChildProductId__c == offerProduct.Id &&
          !productChildItem.vlocity_cmt__IsOverride__c) {
        if (productChildItem.vlocity_cmt__OverrideDefinitions__r == null) {
          return Integer.valueOf(productChildItem.vlocity_cmt__MaxQuantity__c);
        } else {
          Integer maxCardinality = 0;
          Boolean isCardinalityFound = false;
          for (vlocity_cmt__OverrideDefinition__c overrideDefinition :
               productChildItem.vlocity_cmt__OverrideDefinitions__r) {
            if (overrideDefinition.vlocity_cmt__ProductId__c ==
                rootProduct.Id) {
              vlocity_cmt__ProductChildItem__c overrideChildItem =
                  productChildItems.get(
                      overrideDefinition
                          .vlocity_cmt__OverridingProductChildItemId__c);
              maxCardinality = Integer.valueOf(
                  overrideChildItem.vlocity_cmt__MaxQuantity__c);
              isCardinalityFound = true;
              break;
            }
          }
          if (!isCardinalityFound) {
            maxCardinality =
                Integer.valueOf(productChildItem.vlocity_cmt__MaxQuantity__c);
          }
          return maxCardinality;
        }
      } else if (isAddonProduct &&
                 productChildItem.vlocity_cmt__ChildProductId__c ==
                     offerProduct.Id &&
                 productChildItem.vlocity_cmt__ParentProductId__c ==
                     rootProduct.Id) {
        return Integer.valueOf(productChildItem.vlocity_cmt__MaxQuantity__c);
      }
    }
    return 0;
  }

 // This method will return the product with same legacy code.
 private
  Product2 getAddonProductWithLegacyCode(String legacyCode, String oldProductId,
                                         List<Product2> productList) {
    Product2 addOnProduct = null;
    for (Product2 product : productList) {
      if (legacyCode == product.Legacy_Product_Code__c &&
          product.Id != oldProductId) {
        addOnProduct = product;
        break;
      }
    }
    return addOnProduct;
  }

 // This method sets the fields of GFQQ_Product_Rate_Plan_Charge_Tier__c record.
 private
  GFQQ_Product_Rate_Plan_Charge_Tier__c setChargeTier(
      Integer maxCardinality,
      Map<String, vlocity_cmt__PriceListEntry__c> priceListEntries,
      String changeTierName) {
    GFQQ_Product_Rate_Plan_Charge_Tier__c chargeTier =
        new GFQQ_Product_Rate_Plan_Charge_Tier__c();
    chargeTier.Name = changeTierName;
    chargeTier.Ending_Unit__c = maxCardinality;
    vlocity_cmt__PriceListEntry__c adjustmentPriceList =
        priceListEntries.get(ADJUSTMENT_PRICE_LIST_KEY);
    vlocity_cmt__PriceListEntry__c nonAdjustmentPriceList =
        priceListEntries.get(NON_ADJUSTMENT_PRICE_LIST_KEY);
    if (adjustmentPriceList != null) {
      chargeTier.Price__c = calculateChargeTierPrice(
          nonAdjustmentPriceList.vlocity_cmt__PricingElementAmount__c,
          adjustmentPriceList.vlocity_cmt__PricingElementId__r
              .vlocity_cmt__AdjustmentValue__c,
          adjustmentPriceList.vlocity_cmt__PricingElementId__r
              .vlocity_cmt__PricingVariableId__r
              .vlocity_cmt__AdjustmentMethod__c);
    } else {
      chargeTier.Price__c =
          nonAdjustmentPriceList.vlocity_cmt__PricingElementAmount__c;
    }
    return chargeTier;
  }

 // This method calculates the charge tier price based on adjustment method.
 private
  Decimal calculateChargeTierPrice(Decimal nonAdjustmentPrice,
                                   Decimal adjustmentPrice,
                                   String adjustmentMethod) {
    Decimal result = 0;
    if (adjustmentMethod.equalsIgnoreCase('Percent')) {
      result = (nonAdjustmentPrice * adjustmentPrice) / 100;
    }
    return result;
  }

  //this method retuns auxiliary rate plan object.
 private
  Google_Product_Rate_Plan_Object__c getRatePlanObject(
      List<Google_Product_Rate_Plan_Object__c> ratePlanObjects,
      String rootProductId) {
    Google_Product_Rate_Plan_Object__c ratePlan = null;
    for (Google_Product_Rate_Plan_Object__c ratePlanObject : ratePlanObjects) {
      if (ratePlanObject.Root_Container_Product__c == rootProductId) {
        ratePlan = ratePlanObject;
      }
    }
    return ratePlan;
  }

  // This method sets the fields of rate plan charge record.
 private
  GFQQ_Product_Rate_Plan_Charge__c setRatePlanCharge(
      String chargeType, String chargeName, String chargeRefernceForeignKey) {
    GFQQ_Product_Rate_Plan_Charge__c charge =
        new GFQQ_Product_Rate_Plan_Charge__c();
    if (chargeType != null && chargeName != null) {
      charge.Charge_Model__c = 'Flat Fee';
      charge.Name = chargeName;
      charge.Charge_Type__c = chargeType;
    }
    charge.MyExtID__c = chargeRefernceForeignKey;
    return charge;
  }

 // This method sets the fields of rate plan record.
 private
  GFQQ_Product_Rate_Plan__c setProductRatePlan(
      Google_Product_Rate_Plan_Object__c ratePlanObject,
      String ratePlanReferenceForeignkey) {
    GFQQ_Product_Rate_Plan__c ratePlan = new GFQQ_Product_Rate_Plan__c();
    if (ratePlanObject != null) {
      ratePlan.Name = ratePlanObject.Name;
      ratePlan.Criteria__c = ratePlanObject.Criteria__c;
      ratePlan.Fiber_Market__c = ratePlanObject.Fiber_Market__c;
      ratePlan.Product_Plan_Rate_Code__c =
          ratePlanObject.Product_Rate_Plan_Code__c;
      // ratePlan.Product__c = ratePlanObject.Root_Container_Product__c;
    }
    ratePlan.MyExtID__c = ratePlanReferenceForeignkey;
    return ratePlan;
  }

 // This method retuern the SupplementalObject of the offerd product.
 private
  Google_Product_Supplemental_Object__c getProductSupplementalObject(
      List<Google_Product_Supplemental_Object__c> supplementalObjects,
      String offerProductId) {
    Google_Product_Supplemental_Object__c suppObject = null;
    for (Google_Product_Supplemental_Object__c supplementalObject :
         supplementalObjects) {
      if (supplementalObject.Product__c == offerProductId) {
        suppObject = supplementalObject;
      }
    }
    return suppObject;
  }

 // This method sets the fields of rate plan product record.
 private
  GFQQ_Product2__c setRatePlanProduct(
      Google_Product_Supplemental_Object__c supplementalObject,
      String productReferenceForeignKey) {
    GFQQ_Product2__c product = new GFQQ_Product2__c();
    if (supplementalObject != null) {
      product.Name = supplementalObject.Name;
      product.Family__c = supplementalObject.Product_Family__c;
      product.Criteria__c = supplementalObject.Criteria__c;
      product.Fiber_Market__c = supplementalObject.Fiber_Market__c;
      product.Product_Code__c = supplementalObject.Product_Code__c;
      product.Component__c = supplementalObject.Is_Component__c;
      product.Product_Line__c = supplementalObject.Product_Line__c;
      product.Product_Sub_Line__c = supplementalObject.Product_SubLine__c;
      product.IsActive__c = supplementalObject.Is_Active__c;
      product.Cms_Lineup_Id__c = '';
      product.GFiber_Cost__c = supplementalObject.GFiber_Cost__c;
      product.GFiber_Device_Model__c =
          supplementalObject.GFiber_Device_Model__c;
      product.Gfiber_Device_Type__c = supplementalObject.Gfiber_Device_Type__c;
      product.GFiber_Min_IPv4_Subnet_Prefix__c =
          supplementalObject.GFiber_Min_Pv4_Subnet_Prefix__c;
      product.GFiber_Min_IPv6_Subnet_Prefix__c =
          supplementalObject.GFiber_Min_IPv6_Subnet_Prefix__c;
    }
    product.MyExtID__c = productReferenceForeignKey;
    return product;
  }
} // end of the class