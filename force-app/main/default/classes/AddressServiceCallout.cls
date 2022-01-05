/*
* @group AddressServiceability
* @description This class will verify the address serviceability with regard to
* SmartyStreet API and address service API.
*/
global with sharing class AddressServiceCallout implements vlocity_cmt.VlocityOpenInterface2  {

  public static String CLASS_NAME = 'AddressServiceCallout';

  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * getCalloutSmartyStreet and getAddressInfo method.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  public Boolean invokeMethod(String methodName, Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    if (methodName.equals('getCalloutSmartyStreet')) {
      getCalloutSmartyStreet(input, outMap, options);
    }
      else if (methodName.equals('getAddressInfo')) {
      getAddressInfo(input, outMap, options);
    }
    return true;
  }

  /*
   * @description Calls US Autocomplete Pro API to get nearby adddress from SmartyStreet.
   * @param street Input to fetch the actual address.
   * @param selected Input to fetch the actual address with entries information.
   * @return SearchCriteria Wrapper class for US Autocomplete Pro API response.
   */
  public static void getCalloutSmartyStreet(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    String METHOD_NAME = 'getCalloutSmartyStreet';
    String endPoint;
    String methodType;
    String street = String.valueOf(input.get('street'));
    String selected = String.valueOf(input.get('selected'));

    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      API_Base_Info__mdt addressAPI =
          APIUtils.getCustomMetadataRecords(Constants.SERVICE.ADDRESS.SEARCH_ADDRESS);
      for (API_Info__mdt endPointURL : AddressAPI.API_Utils__r) {
        endPoint = endPointURL.Endpoint__c;
        methodType = endPointURL.Method__c;
      }
      String endPointUrl =
          String.format(AddressAPI.Base_URL__c + endPoint + AddressAPI.Api_Password__c +
          + '&max_results={0}&search={1}&selected={2}',
          new List<String>{
            AddressAPI.Content_Type__c,// {0}
            street,// {1}
            selected// {2}
          });
      request.setEndpoint(endPointUrl);
      request.setHeader(Constants.SERVICE.ADDRESS.REFERER, AddressAPI.Api_Username__c);
      request.setMethod(methodType);
      HttpResponse response = http.send(request);
      if (response.getBody() != null) {
        outMap.put('addressList', response.getBody());
      }
    } catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
  }

  /*
   * @description Get required address information along with address Id - pass request data
   * (response of SmartyStreet) to get complete address.
   * @param SmartyStreet Response of SmartyStreet US Auto complete Pro API.
   * @return Complete Address along with serviceable details
   */
  public static void getAddressInfo(Map<String, Object> input,
      Map<String, Object> outMap, Map<String, Object> options) {

    String METHOD_NAME = 'getAddressInfo';
    String smartyStreet = String.valueOf(input.get('smartyStreet'));
    String addressId;
    DefinitionInfo jsonDataWrap = new DefinitionInfo();
    Address jsonAddressWrap;
    AddressData jsonSearch = new AddressData();
    SearchAddress searchAddressWrap;
    String endPoint;
    String methodType;
    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndpoint('callout:Generic/v1/address/searchaddresses');
      request.setMethod('POST');
      request.setHeader(Constants.SERVICE.ADDRESS.CONTENT_TYPE, 'application/json');
      request.setBody(smartyStreet);
      HttpResponse response = http.send(request);
      if (response.getStatusCode() == 200 && response.getBody() != null) {
        searchAddressWrap = (SearchAddress)System.JSON.deserialize(
            Response.getBody(), SearchAddress.class);
        if (searchAddressWrap.entries != null) {
          for(Entries searchEntries : searchAddressWrap.entries) {
            addressId = searchEntries.address.addressId;
            jsonAddressWrap = (String.isNotEmpty(addressId)) ?
                searchEntries.address : null;
          }
          if (jsonAddressWrap != null) {
            jsonDataWrap = (String.isNotEmpty(addressId)) ?
                getAddressDefinitionByGlobalAddressId(jsonAddressWrap.addressId) : null;
            jsonDataWrap.latitude = jsonAddressWrap.Geometry.location.latitude;
            jsonDataWrap.longitude = jsonAddressWrap.Geometry.location.longitude;
          }
        }
      }
      jsonSearch = (AddressData)System.JSON.deserialize(smartyStreet, AddressData.class);
      jsonDataWrap.street = jsonSearch.search_criteria.street;
      jsonDataWrap.unitNumber = jsonSearch.search_criteria.unitNumber;
      jsonDataWrap.state = jsonSearch.search_criteria.state;
      jsonDataWrap.city = jsonSearch.search_criteria.city;
      jsonDataWrap.zip5 = jsonSearch.search_criteria.zip5;
      jsonDataWrap.checkAddress = Constants.SERVICE.ADDRESS.TRUE_STR;
    }
    catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
    outMap.put('serviceAddressData', JSON.serialize(jsonDataWrap));
  }

  /*
   * @description To retrieve the Serviceable Address information.
   * @param addressId Response of search address API: getAddressId.
   * @return DefinitionInfo Wrapper class for getDefinition response.
   */
  @AuraEnabled(cacheable = true)
  public static DefinitionInfo getAddressDefinitionByGlobalAddressId(String addressId) {

    final String METHOD_NAME = 'getDefinition';

    AddressDetails jsonDefinition = new AddressDetails();
    DefinitionInfo jsonDataWrap = new DefinitionInfo();
    String endPoint;
    String methodType;

    try {
      Http https = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndpoint('callout:Generic/v1/address/definition/'+addressId);
      request.setMethod('GET');
      HttpResponse response = https.send(request);
      String responseWrap = response.getBody();
      if (response.getStatusCode() == 200 && response.getBody() != null) {
        jsonDefinition  = (AddressDetails)System.JSON.deserialize(
            response.getBody(), AddressDetails.class);
        jsonDataWrap = jsonDefinition.definition ;
      }
    }
    catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, e);
      throw e;
    }
    return jsonDataWrap;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper method to store the data coming from getDefination API
   * from getAddress method.
   */
  public class AddressDetails {

    @AuraEnabled public DefinitionInfo definition;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store the data comming from getdefination API
   */
  public class DefinitionInfo {

    @AuraEnabled public String addressId;
    @AuraEnabled public String deploymentStatus;
    @AuraEnabled public String dealStatus;
    @AuraEnabled public String serviceability;
    @AuraEnabled public String serviceabilityStartDate;
    @AuraEnabled public String eligibility;
    @AuraEnabled public String eligibilityStartDate;
    @AuraEnabled public String ineligibleReason;
    @AuraEnabled public String addressEquipmentState;
    @AuraEnabled public String updateTime;
    @AuraEnabled public string street;
    @AuraEnabled public string unitNumber;
    @AuraEnabled public string city;
    @AuraEnabled public string state;
    @AuraEnabled public string zip5;
    @AuraEnabled public double latitude;
    @AuraEnabled public double longitude;
    @AuraEnabled public string checkAddress;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store response of smartystreet API.
   */
  public class SearchCriteria {

    @AuraEnabled public List<Suggestions> suggestions;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store SmartyStreet API response.
   */
  public class suggestions {
    @AuraEnabled public String street_line;
    @AuraEnabled public String secondary;
    @AuraEnabled public String city;
    @AuraEnabled public String state;
    @AuraEnabled public String zipcode;
    @AuraEnabled public Integer entries;
    @AuraEnabled public String unitNumber;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store the data of addressSearch API (searchAddress method).
   */
  public class SearchAddress {

    @AuraEnabled public List<Entries> entries;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store the address information data.
   */
  public class Entries {
    @AuraEnabled public Address address;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store the data of address information.
   */
  public class Address {

    @AuraEnabled public searchCriteriaInfo search_criteria;
    @AuraEnabled public String addressId;
    @AuraEnabled public Geometry Geometry;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store the data of geographical location.
   */
  public class LocationInfo {

    @AuraEnabled public double latitude;
    @AuraEnabled public double longitude;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store request data for search address API.
   */
  public class AddressData {

    @AuraEnabled public SearchCriteriaInfo search_criteria;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store request data for search address API.
   */
  public class SearchCriteriaInfo {

    public String city;
    public String unitNumber;
    public String state;
    public String street;
    public String zip5;
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store the data of location information.
   */
  public class Geometry {

    @AuraEnabled public LocationInfo location;
  }
}