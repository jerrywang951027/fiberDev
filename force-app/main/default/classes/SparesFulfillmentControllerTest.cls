/**
 * @group SparesFulfillmentController
 * @description Test class for SparesFulfillmentController to improve code coverage
 * and test functionality.
 */
@isTest
public class SparesFulfillmentControllerTest {
  @isTest
  public static void testSearchSparepartsForUser(){
    i2ms_Model_Description__c i2msModelDescriptionRecord = new i2ms_Model_Description__c();
    i2msModelDescriptionRecord.Name = 'TestGPN';
    i2msModelDescriptionRecord.Description__c = 'Test Description';
    insert i2msModelDescriptionRecord;
    Test.setMock(HttpCalloutMock.class, new MockClasses.SearchSparepartsForUserMock());
    Test.startTest();
    String deviceWrapperListAsString = SparesFulfillmentController.searchSparepartsForUser('abc');
    Test.stopTest();
    System.assert(deviceWrapperListAsString.contains(i2msModelDescriptionRecord.Description__c));
}
  
  @isTest
  public static void testAssignSerialsToUser(){
    Test.setMock(HttpCalloutMock.class, new MockClasses.AssignSerialsToUserMock());
    String warehouse = 'TestWarehouse';
    Warehouse_Location__c warehouseLocation = new Warehouse_Location__c();
    warehouseLocation.name = 'TestWarehouseCode';
    warehouseLocation.Description__c = warehouse;
    insert warehouseLocation;
    i2ms_Model_Description__c i2msModelDescriptionRecord = new i2ms_Model_Description__c();
    i2msModelDescriptionRecord.Name = 'TestGPN';
    i2msModelDescriptionRecord.Description__c = 'Test Description';
    insert i2msModelDescriptionRecord;
    Test.startTest();
    String deviceWrapperListAsString = SparesFulfillmentController.assignSerialsToUser('TestUser'
          , 'TestSerialNumber'
          , ''
          , ''
          , ''
          , ''
          , warehouse);
    Test.stopTest();
    System.assert(deviceWrapperListAsString.contains(i2msModelDescriptionRecord.Description__c));   
  }
}