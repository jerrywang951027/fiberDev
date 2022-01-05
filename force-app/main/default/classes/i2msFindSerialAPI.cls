/**
   * @group i2msFindSerialAPI
   * @description Class to get API's response and static information
   */

public class i2msFindSerialAPI {
  // API call for FindSerial, get data from SAP based on requested parameters.
  @AuraEnabled
  public static string FindSerialRestMethod(String requestParameter){
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setEndpoint('callout:FindSerials');
    httpRequest.setMethod('POST');
    httpRequest.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
    httpRequest.setBody(requestParameter);
    String strResponse = null;
    try {
    Http http = new Http();
      HttpResponse httpResponse = http.send(httpRequest);
      if (httpResponse.getStatusCode() == 200 ) {
        strResponse = httpResponse.getBody();
      }
      else {
        throw new CalloutException(httpResponse.getBody());
      }
    }
      catch(Exception ex) {
        throw ex;
      }
    if(!String.isBlank(strResponse)) {
      return strResponse;
    }else{
      return null;
    }
  }

  // FindChildSerial API to get child element based on parent serial provided.
  @AuraEnabled
  public static string FindChildSerialRestMethod(String requestChildParameter){
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setEndpoint('callout:FindChildSerials');
    httpRequest.setMethod('POST');
    httpRequest.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
    httpRequest.setBody(requestChildParameter);
    String strResponse = null;
    try {
      Http http = new Http();
      HttpResponse httpResponse = http.send(httpRequest);
      if (httpResponse.getStatusCode() == 200 ) {
        strResponse = httpResponse.getBody();
      }
      else {
        throw new CalloutException(httpResponse.getBody());
      }
    }
    catch(Exception ex) {
      throw ex;
    }
    if(!String.isBlank(strResponse)) {
      return strResponse;
    }else{
      return null;
    }
  }

  // Get user's public group authority for warehouse passed in.
  @AuraEnabled
  public static List<User> checkIfUserExists(String location){
    List<User> lstPublicGroup = [SELECT Email FROM User WHERE Id IN
          (SELECT UserorGroupId FROM GroupMember WHERE Group.Name = :location)];
    return lstPublicGroup;
  }

  // Get model and description from custom settings- 'Model and Description'
  @AuraEnabled(cacheable=true)
  public static List<i2ms_Model_Description__c> ModelDescriptionBasedOnGPN() {
    return i2ms_Model_Description__c.getAll().values();
  }

  // Get warehouse and description mapping from custom settings- 'Warehouse Location'
  @AuraEnabled(cacheable=true)
  public static List<Warehouse_Location__c> WarehouseMapping() {
    return Warehouse_Location__c.getAll().values();
  }
}