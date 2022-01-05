/**
 * @group FindSerialsAPI
 * @description The Find Serial is to call the API for finding the devices details and user.
 */
public class FindSerialsAPI {

  /**
   * @description Method to request the data from the api and get the response data.
   * @return the requested details.
   */
  public FindSerialsResponseWrapper callFindSerialAPI(FindSerialsRequestWrapper request){
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:FindSerials');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
    String body = JSON.serialize(request);
    req.setBody(body);
    Http http = new Http();
    HTTPResponse res = http.send(req);
    String responseBody = res.getBody();
    FindSerialsResponseWrapper findSerialResponseWrapper =
        (FindSerialsResponseWrapper)JSON.deserialize
            (responseBody, FindSerialsResponseWrapper.class);
    return findSerialResponseWrapper;
  }
}