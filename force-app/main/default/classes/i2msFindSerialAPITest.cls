@isTest
public class i2msFindSerialAPITest {

  @testSetup
    static void ModelDescriptionBasedOnGPNTest() {
      String warehouse = 'TestWarehouse';
      i2ms_Model_Description__c modelAndDescription = new i2ms_Model_Description__c();
      modelAndDescription.name = 'TestGPN';
      modelAndDescription.Description__c = 'TestDescription';
      modelAndDescription.Model__c = 'TestModel';
      insert modelAndDescription;
    }

  @isTest
    static void FindSerialRestMethodTest() {
      //Set mock callout
      Test.startTest(); 
      Test.setMock(HttpCalloutMock.class, new Mocki2msFindSerialAPI.mock_FindSerialRestMethod());
      String resString = i2msFindSerialAPI.FindSerialRestMethod(' { "criteria" :{"deviceOwnershipCriteria": { "newOwners": "pthatha" }, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }');
      Test.stopTest();
    }

    @isTest
    static void FindSerialRestMethodNullTest() {
      //Set mock callout
      Test.startTest(); 
      Test.setMock(HttpCalloutMock.class, new Mocki2msFindSerialAPI.mock_FindSerialRestMethodNull());
      String resString = i2msFindSerialAPI.FindSerialRestMethod('');
      Test.stopTest();
    }

    @isTest
    static void FindChildSerialRestMethodTest() {
      //Set mock callout
      Test.startTest(); 
      Test.setMock(HttpCalloutMock.class, new Mocki2msFindSerialAPI.mock_FindChildSerialRestMethod());
      i2msFindSerialAPI.FindChildSerialRestMethod('{"parentSerialKey": {"serial_number": "KMS005913300109","gpn": "86009146-01"}}');
      Test.stopTest();
    }

    @isTest
    static void FindChildSerialRestMethodNullTest() {
      //Set mock callout
      Test.startTest(); 
      Test.setMock(HttpCalloutMock.class, new Mocki2msFindSerialAPI.mock_FindChildSerialRestMethodNull());
      i2msFindSerialAPI.FindChildSerialRestMethod('');
      Test.stopTest();
    }

    @isTest
    static void checkIfUserExistsTest() {
      //Test data setup
      User testUser = new User();
      testUser.Username = 'testusername@abc.com';
      testUser.LastName = 'LastName_Test';
      testUser.Alias = 'Test';
      testUser.TimeZoneSidKey = 'America/Chicago';
      testUser.LocaleSidKey = 'en_US';
      testUser.LanguageLocaleKey = 'en_US';
      testUser.EmailEncodingKey = 'ISO-8859-1';
      testUser.ProfileId = UserInfo.getProfileId();
      testUser.Email = 'testusername@abc.com';
      insert testUser;
      Group testGroup = new Group(Name = 'Warehouse_Test');
      insert testGroup;
      GroupMember testGM = new GroupMember(UserOrGroupId = testUser.ID,GroupId = testGroup.id);
      insert testGM;
      Boolean resultExists;
      List<User> validUsers =  i2msFindSerialAPI.checkIfUserExists('Warehouse_Test');
      for(User listValidUser : validUsers){
        if(listValidUser.Email == 'testusername@abc.com'){
          resultExists = true;  
        }
      }
      System.assert(resultExists);
    }

    @isTest
    static void ModelDescriptionBasedOnGPN_ModelTest() {
      Boolean resultExists;
      List<i2ms_Model_Description__c> modelAndDescription = i2msFindSerialAPI.ModelDescriptionBasedOnGPN();
      for(i2ms_Model_Description__c listmodelAndDescription : modelAndDescription){
        if(listmodelAndDescription.Model__c == 'TestModel'){
          resultExists = true;  
        }
      }
      System.assert(resultExists);    
    }

    @isTest
    static void ModelDescriptionBasedOnGPN_DescriptionTest() {
      Boolean resultExists;
      List<i2ms_Model_Description__c> modelAndDescription = i2msFindSerialAPI.ModelDescriptionBasedOnGPN();
      for(i2ms_Model_Description__c listmodelAndDescription : modelAndDescription){
        if(listmodelAndDescription.Description__c == 'TestDescription'){
          resultExists = true;  
        }
      }
      System.assert(resultExists);    
    }

    @isTest
    static void WarehouseMappingTest() {
      Boolean resultExists;
      String warehouse = 'TestWarehouse';
      Warehouse_Location__c warehouseLocation = new Warehouse_Location__c();
      warehouseLocation.name = 'TestWarehouseCode';
      warehouseLocation.Description__c = warehouse;
      insert warehouseLocation;
      List<Warehouse_Location__c> warehouseDescriptionList = i2msFindSerialAPI.WarehouseMapping();
      for(Warehouse_Location__c listwarehouseDescription : warehouseDescriptionList){
        if(listwarehouseDescription.Name == 'TestWarehouseCode'){
          resultExists = true;  
        }
      }
      System.assert(resultExists);  
    }
}