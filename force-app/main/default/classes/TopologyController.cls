/**
 * @group TopologyController
 * @description To transform and fetch Topology data.
 */
public with sharing class TopologyController {

  /*
   * @description To delete device related to accountId and mac address.
   */
  public void removeDeviceData(Map <String, Object> inputMap,
      Map <String, Object> outMap, Map <String, Object> optionsMap) {

    Map <String, Object> assetModelDataObject = (Map<String, Object>)inputMap.get('assetModelData');
    String model = (String)inputMap.get('model');
    Map <String, Object> outerMap = new Map <String, Object>();
    outMap.put('model', assetModelDataObject.get(model));
  }

}