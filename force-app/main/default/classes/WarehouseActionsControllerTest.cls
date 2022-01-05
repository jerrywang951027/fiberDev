/**
 * @group WarehouseActionController
 * @description Test class for WarehouseActionController to improve code coverage
 * and test functionality.
 */
@isTest
public class WarehouseActionsControllerTest {
  @isTest
  public static void getWarehouseLocationsShouldReturnLocation(){
    String warehouse = 'TestWarehouse';
    Warehouse_Location__c warehouseLocation = new Warehouse_Location__c();
    warehouseLocation.name = 'TestWarehouseCode';
    warehouseLocation.Description__c = warehouse;
    insert warehouseLocation;
    Test.startTest();
    List<String> warehouseDescriptionList = WarehouseActionsController.getWarehouseLocations();
    Test.stopTest();
    System.assert(warehouseDescriptionList[0] == warehouse,'Description should be' + warehouse);
  }
}