/**
 * @group FindChildSerialsAPI
 * @description The Find Child Serial is to call the API for finding the child devices attached
 * with parent device.
 */
public class FindChildSerialsAPI {

  /**
   * @description Method to request the data from the api and get the response data.
   * @return child device details.
   */
  public static FindChildSerialsResponseWrapper
    callFindChildSerialsAPI(FindChildSerialsRequestWrapper request){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:FindChildSerials');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
        String body = JSON.serialize(request);
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        FindChildSerialsResponseWrapper findChildSerialsResponseWrapperInstance
            = (FindChildSerialsResponseWrapper)JSON.deserialize(responseBody
            , FindChildSerialsResponseWrapper.class);
        return findChildSerialsResponseWrapperInstance;
  }
}