/**
 * @group WarehouseActionsController
 * @description The Warehouse action controller is to fetch the warehouse from salesforce 
 * custom settings.
 */
public class WarehouseActionsController {
	@AuraEnabled(cacheable=true)
    //Method to get the Warehouse Locations from Custom Settings.
    public static List<String> getWarehouseLocations(){
        List<Warehouse_Location__c> warehouseLocationList = Warehouse_Location__c.getAll().values();
        List<String> warehouseDescriptionList = new List<String>();
        for(Warehouse_Location__c warehouseLocation : warehouseLocationList){
            warehouseDescriptionList.add(warehouseLocation.Description__c);
            
        }
        return warehouseDescriptionList;
    }
}