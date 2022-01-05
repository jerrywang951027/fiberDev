/**
 * @group DeviceOwnershipBatchChangeAPI
 * @description The Device batch Update is to call the API for updating the status and ownership
 * of the device.
 */
public class DeviceOwnershipBatchChangeAPI {

/**
 * Method to be use for updating the owner of the device and status of the device.
 * @return response.
 */
public static DeviceOwnershipBatchChangeResWrapper
  updateOwner(
      DeviceOwnershipBatchChangeRequestWrapper deviceOwnershipBatchChangeRequestWrapperInstnace) {
      HttpRequest req = new HttpRequest();
      req.setEndpoint('callout:BatchUpdateDevice');
      req.setMethod('POST');
      req.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
      String body = JSON.serialize(deviceOwnershipBatchChangeRequestWrapperInstnace);
      req.setBody(body);
      Http http = new Http();
      HTTPResponse res = http.send(req);
      String responseBody = res.getBody();
      DeviceOwnershipBatchChangeResWrapper response = (DeviceOwnershipBatchChangeResWrapper)
      JSON.deserialize(responseBody, DeviceOwnershipBatchChangeResWrapper.class);
      return response;
  }
}