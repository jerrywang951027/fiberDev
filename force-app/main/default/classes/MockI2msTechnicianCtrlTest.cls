// Mock reponse I2msTechnicianController
@isTest
public class MockI2msTechnicianCtrlTest {
  public class MockExtractJSON implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req){
      String criteria = String.join (new List <String>
        {'{"criteria":{"deviceOwnershipCriteria":'+
        '{"ownershipStatuses":["PRE_ASSIGNED_SPARE"]',
        '"newOwners":["sudhamalla"]}}}'},',');
      String body = String.join(new List <String>
        {'{"serials": [{"serialKey": {"serialNumber": "CP2112SAYPE"',
        '"gpn": "1063603-01"},"parentSerialKey": {},"currentStatus": "ON_HAND"',
        '"lastKnownGoogleLocationCode": "NITMO01F"',
        '"deviceOwnership": {"serialKey": {"serialNumber": "CP2112SAYPE"',
        '"gpn": "1063603-01"},"currentAttribute": {"ownershipStatus": "PRE_ASSIGNED_SPARE"',
        '"newOwner": "guptaso","commitTime": "2021-11-10T19:53:18Z"',
        '"transactionType": "ISSUE_OUT_SPARE","googleLocationCode": "NITMO01F"',
        '"user": "GUPTASO"}},"lastUpdatedTime": "2021-07-13T22:08:33Z"}]}'},',');
      // Validate Request JSON
      System.assertEquals(criteria, req.getBody(), 'request error');
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('content-type', 'application/json');
      res.setBody(body);
      return res;
    }
  }

  public class MockUpdateDeviceOwnership implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req){
      String updateDevice = String.join(new List <String>
        {'{"updateRequest":[{"deviceOwnership":{"currentAttribute":{"user":"sudhamalla"',
        '"transactionType":"UNASSIGN "},"serialKey":{"gpn":"1063757-01"',
        '"serialNumber":"CP2102SAGM9"}}',
        '"updateMask":"deviceOwnership.currentAttribute.versionNumber',
        'deviceOwnership.currentAttribute.ownershipStatus',
        'deviceOwnership.currentAttribute.transactionType',
        'deviceOwnership.currentAttribute.commitTime',
        'deviceOwnership.currentAttribute.user',
        'deviceOwnership.currentAttribute.currentOwner',
        'deviceOwnership.currentAttribute.newOwner',
        'deviceOwnership.currentAttribute.googleLocationCode',
        'deviceOwnership.currentAttribute.assignedToAccount',
        'deviceOwnership.currentAttribute.externalReferences',
        'deviceOwnership.currentAttribute.defectReason',
        'deviceOwnership.currentAttribute.comments',
        'deviceOwnership.currentAttribute.deviceStatuse"}]}'},',');
      String body = String.join (new List <String>
        {'{"deviceOwnership":[{"serialKey": {"serialNumber": "CP2102SAGM9"',
        '"gpn": "1063757-01"},"currentAttribute": {"transactionType": "UNASSIGN"}}]}'
        },',');
      // Validate Request JSON
      System.assertEquals(updateDevice, req.getBody(), 'request error');
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('content-type', 'application/json');
      res.setBody(body);
      return res;
    }
  }

  public class MockConfirmLost implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req){
      String updateConfirmLost = String.join(new List <String>
        {'{"updateRequest":[{"deviceOwnership":{"currentAttribute":{"googleLocationCode":"NITTX01FS"',
        '"currentOwner":"WAREHOUSE","ownershipStatus":"CONFIRMED_LOST"',
        '"user":"sudhamalla","transactionType":"CONFIRMED_LOST"}',
        '"serialKey":{"gpn":"1063757-01","serialNumber":"CP2103SAHZC"}}',
        '"updateMask":"deviceOwnership.currentAttribute.versionNumber',
        'deviceOwnership.currentAttribute.ownershipStatus',
        'deviceOwnership.currentAttribute.transactionType',
        'deviceOwnership.currentAttribute.commitTime',
        'deviceOwnership.currentAttribute.user',
        'deviceOwnership.currentAttribute.currentOwner',
        'deviceOwnership.currentAttribute.newOwner',
        'deviceOwnership.currentAttribute.googleLocationCode',
        'deviceOwnership.currentAttribute.assignedToAccount',
        'deviceOwnership.currentAttribute.externalReferences',
        'deviceOwnership.currentAttribute.defectReason',
        'deviceOwnership.currentAttribute.comments',
        'deviceOwnership.currentAttribute.deviceStatuse"}]}'},',');
      String body = String.join (new List <String>
        {'{"deviceOwnership":[{"serialKey":{"serialNumber":"CP2103SAHZC"',
        '"gpn":"1063757-01"},"currentAttribute":{"ownershipStatus":"CONFIRMED_LOST"',
        '"currentOwner":"WAREHOUSE","transactionType":"CONFIRMED_LOST"',
        '"googleLocationCode":"NITTX01FS"}}]}'},',');
      // Validate Request JSON
      System.assertEquals(updateConfirmLost, req.getBody(), 'request error');
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('content-type', 'application/json');
      res.setBody(body);
      return res;
    }
  }
}