@isTest
public with sharing class V3CatalogTransformationTest {

@testSetup static void testData() {

Product2 prodObj1 = new Product2();
prodObj1.Family = 'Fiber';
prodObj1.vlocity_cmt__GlobalKey__c = Math.rint(Math.random() * 100000000) + 'abc';
prodObj1.Legacy_Product_Code__c = 'fiber_2g';
prodObj1.Name = '2 Gig';
prodObj1.ProductCode = 'OFR_Fiber_2G';
prodObj1.vlocity_cmt__Type__c = 'Internet';
//prodObj1.vlocity_cmt__ObjectTypeName__c = 'InternetServiceOffer Spec Type';
prodObj1.vlocity_cmt__SpecificationType__c = 'Offer';
//prodObj1.vlocity_cmt__ProductSpecName__c = '';
prodObj1.Zuora_Id__c = '2c92c0f8793acf0301793babdd80077f';
insert prodObj1;
       
product2 prodObj2 = new Product2();
prodObj2.Family = 'Fiber';
prodObj2.vlocity_cmt__GlobalKey__c = Math.rint(Math.random() * 100000000) + 'abc';
prodObj2.Legacy_Product_Code__c = 'STORAGE_BOX';
prodObj2.Name = 'Storage Box';
prodObj2.ProductCode = 'STORAGE_BOX';
prodObj2.vlocity_cmt__Type__c = 'Internet';
//prodObj2.vlocity_cmt__ObjectTypeName__c = 'InternetServiceOffer Spec Type';
prodObj2.vlocity_cmt__SpecificationType__c = 'Offer';
//prodObj2.vlocity_cmt__ProductSpecName__c = '';
prodObj2.Zuora_Id__c = '2c92c0f8793acf0301793babdd80077f';
insert prodObj2;
    
Pricebook2 standardBook = new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook', IsActive = true);

PricebookEntry priceBookEntryObj = new PricebookEntry();
priceBookEntryObj.Pricebook2Id = standardBook.Id;
priceBookEntryObj.Product2Id = prodObj1.Id;
priceBookEntryObj.vlocity_cmt__RecurringPrice__c = 0.00;
//priceBookEntryObj.Name = '2 Gig';
priceBookEntryObj.UnitPrice = 100;
insert priceBookEntryObj ;

vlocity_cmt__PriceList__c plObj = new vlocity_cmt__PriceList__c();
plObj.Name = 'National Price List';
plObj.vlocity_cmt__Code__c = 'xyz';
insert plObj;

vlocity_cmt__PricingVariable__c pvObj = new vlocity_cmt__PricingVariable__c();
pvObj.vlocity_cmt__AdjustmentMethod__c = 'Absolute';
pvObj.vlocity_cmt__ChargeType__c = 'Recurring';
pvObj.vlocity_cmt__RecurringFrequency__c = 'Monthly';
pvObj.vlocity_cmt__Code__c = 'xyz';
insert pvObj;

vlocity_cmt__PricingElement__c peObj = new vlocity_cmt__PricingElement__c();
peObj.vlocity_cmt__DisplayText__c = '$100';
peObj.vlocity_cmt__AdjustmentValue__c = 0.00;
peObj.vlocity_cmt__PricingVariableId__c = pvObj.Id;
insert peObj;

vlocity_cmt__PriceListEntry__c pleObj = new vlocity_cmt__PriceListEntry__c();
pleObj.vlocity_cmt__ProductId__c = prodObj1.id;
pleObj.vlocity_cmt__PriceListId__c = plObj.Id;
pleObj.vlocity_cmt__IsActive__c = true;
//pleObj.vlocity_cmt__OfferId__c = 'a4J8G000000blbdUAA';
pleObj.vlocity_cmt__DisplayText__c = '$100';
pleObj.vlocity_cmt__IsVirtualPrice__c = false;
pleObj.vlocity_cmt__IsBasePrice__c = false;
pleObj.vlocity_cmt__PricingElementId__c = peObj.Id;
insert pleObj;

vlocity_cmt__ProductChildItem__c pciObj = new vlocity_cmt__ProductChildItem__c();
pciObj.vlocity_cmt__ParentProductId__c = prodObj1.Id;
//pciObj.vlocity_cmt__ParentProductName__c = '2 Gig';
pciObj.vlocity_cmt__ChildProductId__c = prodObj2.Id;
pciObj.vlocity_cmt__IsRootProductChildItem__c = false;
pciObj.vlocity_cmt__Quantity__c = 1;
pciObj.vlocity_cmt__MinQuantity__c = 0;
pciObj.vlocity_cmt__MaxQuantity__c = 2;
pciObj.vlocity_cmt__MinimumChildItemQuantity__c = 0;
pciObj.vlocity_cmt__MaximumChildItemQuantity__c = 2;
pciObj.vlocity_cmt__IsOverride__c = false;
pciObj.vlocity_cmt__ChildLineNumber__c = '1';
insert pciObj;

vlocity_cmt__ProductRelationship__c prObj = new vlocity_cmt__ProductRelationship__c();
prObj.vlocity_cmt__Product2Id__c = prodObj1.Id;
prObj.vlocity_cmt__RelatedProductId__c = prodObj2.Id;
prObj.vlocity_cmt__RelationshipType__c = 'Requires';
prObj.vlocity_cmt__DefaultQuantity__c = 1;
prObj.vlocity_cmt__MinQuantity__c = 1;
prObj.vlocity_cmt__MaxQuantity__c = 1;
insert prObj;
    
Google_Product_Supplemental_Object__c gpsObj = new Google_Product_Supplemental_Object__c();
gpsObj.Name = '2 Gig';
gpsObj.Criteria__c = '(address.isResidential && !address.isGolong && !address.isFiberInside)';
gpsObj.Fiber_Market__c = 'Atlanta, GA; Austin, TX';
gpsObj.GFiber_Cost__c = 100;
gpsObj.GFiber_Device_Model__c = '';
gpsObj.Gfiber_Device_Type__c = '';
gpsObj.Product_Family__c = 'Internet';
gpsObj.Product_Line__c = 'Internet Service';
gpsObj.Product_Code__c = 'fiber_2g';
gpsObj.Product__c = prodObj1.Id;
gpsObj.Is_Component__c = true;
gpsObj.Is_Active__c = false;
gpsObj.GFiber_Min_Pv4_Subnet_Prefix__c = 0;
gpsObj.GFiber_Min_IPv6_Subnet_Prefix__c = 0;
gpsObj.Product_SubLine__c = 'Residential 2g';
insert gpsObj;
    
Google_Product_Rate_Plan_Object__c gprObj = new Google_Product_Rate_Plan_Object__c();
gprObj.Criteria__c = 'address.isResidential';
gprObj.Fiber_Market__c = 'Atlanta, GA; Austin, TX';
gprObj.Name = '[Tool] Extender Rate Plan for Residential';
gprObj.V3_Product__c = prodObj2.Id;
gprObj.Root_Container_Product__c = prodObj1.Id; 
gprObj.Product_Rate_Plan_Code__c = 'prp_tch_extender_network_box';
insert gprObj;    
}
    
@isTest
static void productTransformationTest() {
V3CatalogTransformation V3CatalogTransformationObj = new V3CatalogTransformation();

Test.startTest();
V3CatalogTransformationObj.productsTransformation();
Test.stopTest();
}

}