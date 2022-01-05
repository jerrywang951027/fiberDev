/*
 * @group MockGenerator Class To mock API response
 * @description Class to generate mock response callout for test apex runtime execution.
 * Construct the fake test responses.
 */
@isTest
global without sharing class MockGenerator implements HttpCalloutMock {
  global MockGenerator(final String type) {
    this.type = type;
  }
  private String type;

  /*
   * @description Response method for address serviceability callouts.
   * @param request It contains HTTP callout request structure.
   * @return Mock response for APIs.
   */
  global HTTPResponse respond (HTTPRequest request) {

    // Mock response for SmartyStreet US Auto Complete Pro API
    if (type.equals(Constants.SERVICE.ADDRESS.SMARTYSTREET)) {
      HTTPResponse smartyStreetResponse = new HTTPResponse();
      StaticResource staticResourceValue = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = 'MockSmartyStreetProResponse'
          LIMIT 1];
      String body = staticResourceValue.Body.toString();
      smartyStreetResponse.setBody(body);
      smartyStreetResponse.setStatusCode(200);
      return smartyStreetResponse;
    }
    // Address Service API mock Response to get Address Id(Premises Identifier).
    else if (type.equals(Constants.SERVICE.ADDRESS.ADDRESS_SERVICE)
        && request.getMethod() == 'POST') {
      HTTPResponse addressResponse = new HTTPResponse();
      StaticResource staticResourceValue = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = 'AddressServiceResponse'
          LIMIT 1
      ];
      String body = staticResourceValue.Body.toString();
      addressResponse.setBody(body);
      addressResponse.setStatusCode(200);
      return addressResponse;
    }
    else if (type.equals('HelpCenter')) {
      HTTPResponse articleResponse = new HTTPResponse();
      StaticResource staticResourceValue = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = 'getKnowlegeArticle'
          LIMIT 1
      ];
      String body = staticResourceValue.Body.toString();
      articleResponse.setBody(body);
      articleResponse.setStatusCode(200);
      return articleResponse;
    }
    else if(type.equals('E911PubSubResponse')) {
      HttpResponse e911Response = new HttpResponse();
      StaticResource staticResourceValue = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = 'E911PubSubResponse'
          LIMIT 1
      ];
      String body = staticResourceValue.Body.toString();
      e911Response.setBody(body);
      e911Response.setStatusCode(200);
      return e911Response;
    }
    else if(type.equals('E911PubSubErrorResponse')) {
      HttpResponse e911Response = new HttpResponse();
      String body = '<?xml version="1.0"><E911OrderReportResponse>'
          +'<ResponseStatus><ErrorCode>400</ErrorCode></ResponseStatus>'
          +'</E911OrderReportResponse>';
      e911Response.setBody(body);
      e911Response.setStatusCode(400);
      e911Response.setStatus('Bad Request');
      return e911Response;
    }
    // Mock response for Address Service API to get Address servicable information.
    else if (request.getMethod() == 'GET') {
      HTTPResponse mockResponse = new HTTPResponse();
      StaticResource staticResourceValue = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = 'getDefinationMockResponse'
          LIMIT 1
      ];
      String body = staticResourceValue.Body.toString();
      mockResponse.setBody(body);
      mockResponse.setStatusCode(200);
      return mockResponse;
    }
    HTTPResponse responseCode = new HTTPResponse();
    responseCode.setBody('{Not Acceptable}');
    responseCode.setStatusCode(406);
    return responseCode;
  }
}