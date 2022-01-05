/**
 * @group MockClasses
 * @description Mock classes for HTTP Callouts to improve code coverage
 * and test functionality.
 */
@isTest
global class MockClasses {
  global class SearchSparepartsForUserMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      FindSerialsResponseWrapper findSerialsResponseWrapperInstance
        = new FindSerialsResponseWrapper();
      SerialKey serialKeyInstance = new SerialKey();
      serialKeyInstance.serialNumber = 'TestSerialNumber';
      serialKeyInstance.gpn = 'TestGPN';
      Serial serialInstance = new Serial();
      serialInstance.serialKey = serialKeyInstance;
      List<Serial> serialList = new List<Serial>();
      serialList.add(serialInstance);
      findSerialsResponseWrapperInstance.serials = serialList;
      res.setBody(JSON.serialize(findSerialsResponseWrapperInstance));
      res.setStatusCode(200);
      return res;
    }
}

  global class AssignSerialsToUserMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(200);
      if(req.getEndPoint() == 'callout:FindSerials'){
        FindSerialsResponseWrapper findSerialsResponseWrapperInstance 
          = new FindSerialsResponseWrapper();
        SerialKey serialKeyInstance = new SerialKey();
        serialKeyInstance.serialNumber = 'TestSerialNumber';
        serialKeyInstance.gpn = 'TestGPN';

        CurrentAttribute currentAttributeInstance = new CurrentAttribute();
        currentAttributeInstance.newOwner = null;

        DeviceOwnershipResponse deviceOwnershipInstance = new DeviceOwnershipResponse();
        deviceOwnershipInstance.currentAttribute = currentAttributeInstance;

        Serial serialInstance = new Serial();
        serialInstance.currentStatus = 'ON_HAND';
        serialInstance.lastKnownGoogleLocationCode = 'TestWarehouseCode';
        serialInstance.serialKey = serialKeyInstance;
        serialInstance.deviceOwnership = deviceOwnershipInstance;

        List<Serial> serialList = new List<Serial>();
        serialList.add(serialInstance);
        findSerialsResponseWrapperInstance.serials = serialList;
        res.setBody(JSON.serialize(findSerialsResponseWrapperInstance));
      }
      else if(req.getEndPoint() == 'callout:FindChildSerials'){
        FindChildSerialsResponseWrapper findChildSerialsResponseWrapperInstance
          = new FindChildSerialsResponseWrapper();
        FindChildResSerialKey serialKeyInstance = new FindChildResSerialKey();
        serialKeyInstance.serialNumber = 'TestSerialNumber';
        serialKeyInstance.gpn = 'TestGPN';

        CurrentAttribute currentAttributeInstance = new CurrentAttribute();
        currentAttributeInstance.newOwner = null;

        DeviceOwnershipResponse deviceOwnershipInstance = new DeviceOwnershipResponse();
        deviceOwnershipInstance.currentAttribute = currentAttributeInstance;
        FindChildResSerial findChildResSerialInstance = new FindChildResSerial();
        findChildResSerialInstance.serialKey = serialKeyInstance;

        List<FindChildResSerial> findChildResSerialList = new List<FindChildResSerial>();
        findChildResSerialList.add(findChildResSerialInstance);

        findChildSerialsResponseWrapperInstance.serials = findChildResSerialList;
        res.setBody(JSON.serialize(findChildSerialsResponseWrapperInstance));
      }
      else if(req.getEndPoint() == 'callout:BatchUpdateDevice'){
        DeviceOwnershipBatchChangeResWrapper deviceOwnershipBatchChangeResWrapperInstance
          = new DeviceOwnershipBatchChangeResWrapper();
        SerialKey serialKeyInstance = new SerialKey();
        serialKeyInstance.serialNumber = 'TestSerialNumber';
        serialKeyInstance.gpn = 'TestGPN';

        DeviceOwnershipChangeResponseOwnership deviceOwnershipChangeResponseOwnershipInstance 
          = new DeviceOwnershipChangeResponseOwnership();
        deviceOwnershipChangeResponseOwnershipInstance.serialKey = serialKeyInstance;
        List<DeviceOwnershipChangeResponseOwnership> deviceOwnershipChangeResponseOwnershipList
          = new List<DeviceOwnershipChangeResponseOwnership>();
        deviceOwnershipChangeResponseOwnershipList
          .add(deviceOwnershipChangeResponseOwnershipInstance);
        deviceOwnershipBatchChangeResWrapperInstance.deviceOwnership
          = deviceOwnershipChangeResponseOwnershipList;
        res.setBody(JSON.serialize(deviceOwnershipBatchChangeResWrapperInstance));
      }
      return res;
    }
  }
}