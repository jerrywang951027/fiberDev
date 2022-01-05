// Mock reponse i2msFindSerialAPI
@isTest
public class Mocki2msFindSerialAPI {

    public class mock_FindSerialRestMethod implements HttpCalloutMock {
      public HttpResponse res;
      public HttpResponse respond(HttpRequest req){
        // Validate Request JSON
       System.assertEquals(' { "criteria" :{"deviceOwnershipCriteria": { "newOwners": "pthatha" }, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }', req.getBody(), 'request error');
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"serials": [ { "serialKey": { "serialNumber": "GLNFNS161801408", "gpn": "72004225-07-R" }, "parentSerialKey": { "serialNumber": "KMS005913300109", "gpn": "86009146-01" }, "deviceOwnership": { "serialKey": { "serialNumber": "GLNFNS161801408", "gpn": "72004225-07-R" }, "currentAttribute": { "ownershipStatus": "PRE_ASSIGNED_SPARE", "newOwner": "pthatha", "commitTime": "2021-11-10T20:12:53Z", "transactionType": "UNASSIGN", "user": "SINDHURIY" }, "attributeHistories": [ { "commitTime": "2021-05-07T01:57:03Z", "googleLocationCode": "WHMOKCAF" }, { "ownershipStatus": "PRE_ASSIGNED_SPARE", "newOwner": "sindhuriy", "commitTime": "2021-09-16T17:57:05Z", "transactionType": "ISSUE_OUT_SPARE", "googleLocationCode": "NITTX01F", "user": "SINDHURIY" }, { "commitTime": "2021-09-16T18:22:07Z", "transactionType": "UNASSIGN" }, { "ownershipStatus": "PRE_ASSIGNED_SPARE", "newOwner": "pthatha", "commitTime": "2021-11-30T19:43:06Z" } ] }, "lastUpdatedTime": "2021-05-07T01:57:03Z" } } ] }');
        return res;
      }
    }

    public class mock_FindSerialRestMethodNull implements HttpCalloutMock {
      public HttpResponse res;
      public HttpResponse respond(HttpRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type', 'application/json');
        res.setStatusCode(200);
        res.setBody('');
        return res;
      }
    }

    public class mock_FindChildSerialRestMethod implements HttpCalloutMock {
      public HttpResponse res;
      public HttpResponse respond(HttpRequest req){
        // Validate Request JSON
        System.assertEquals('{"parentSerialKey": {"serial_number": "KMS005913300109","gpn": "86009146-01"}}', req.getBody(), 'request error');
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{ "serials": [ { "serialKey": { "serialNumber": "GLNFNS161801408", "gpn": "72004225-07-R" }, "parentSerialKey": { "serialNumber": "KMS005913300109", "gpn": "86009146-01" }, "deviceOwnership": { "serialKey": { "serialNumber": "GLNFNS161801408", "gpn": "72004225-07-R" }, "currentAttribute": { "ownershipStatus": "PRE_ASSIGNED_SPARE", "newOwner": "pthatha", "commitTime": "2021-11-10T20:12:53Z", "transactionType": "UNASSIGN", "user": "SINDHURIY" } }, "lastUpdatedTime": "2021-05-07T01:57:03Z" } ] }');
        return res;
      }
    }

    public class mock_FindChildSerialRestMethodNull implements HttpCalloutMock {
      public HttpResponse res;
      public HttpResponse respond(HttpRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type', 'application/json');
        res.setStatusCode(200);
        res.setBody('');
        return res;
      }
    }
}