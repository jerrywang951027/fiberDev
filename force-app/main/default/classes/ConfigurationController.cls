/**
 * @group ConfigurationController
 * @description To transform and fetch configuration data.
 */
public with sharing class ConfigurationController {

  private final static String GET_DEVICES_API = 'callout:Generic/v1/asset/model:query';

  /*
   * @description To transform asset model response to key and value pair Map structure.
   */
  public void transformAssetModelResponse(Map <String, Object> inputMap,
      Map <String, Object> outMap, Map <String, Object> optionsMap) {

    Map <String, Object> assetModelDataObject = (Map<String, Object>)inputMap.get('assetModelData');
    String model = (String)inputMap.get('model');
    Map <String, Object> outerMap = new Map <String, Object>();
    outMap.put('model', assetModelDataObject.get(model));
  }

  /*
   * @description To transform serial number array to key and value pair Map structure.
   */
  public void transformSerialNumberList(Map <String, Object> inputMap, Map <String, Object> outMap,
      Map <String, Object> optionsMap) {

    List <Object> serialNumberObject = (List <Object>)inputMap.get('serialNumber');
    Map <String, Object> outerMap = new Map <String, Object>();
    List <Object> serialNumberList = new List <Object>();

    for (Object record: serialNumberObject) {
      Map <String, String> serialNumberMap = new Map <String, String>();
      serialNumberMap.put('key', String.valueof(record));
      serialNumberList.add(serialNumberMap);
    }
    outMap.put('serialNumberList', JSON.serialize(serialNumberList));
  }

  /*
   * @description To delete configuration data.
   */
  public void deleteConfigurationData(Map <String, Object> inputMap, Map <String, Object> outMap,
      Map <String, Object> optionsMap) {

    List <String> fieldsToDeleteList = inputMap.get('configFieldsToDelete') != null &&
        String.isNotBlank(String.valueOf(inputMap.get('configFieldsToDelete'))) ?
        String.valueOf(inputMap.get('configFieldsToDelete')).split(',') : null;
    Map <String, Object> configMap = (Map <String, Object> ) inputMap.get('config');

    if (fieldsToDeleteList.size() > 0) {
      for (String record: fieldsToDeleteList) {
        switch on record.split('\\.').size() {
          when 1 {
            configMap.remove(record.split('\\.')[0]);
          }
          when 2 {
            Map <String, Object> firstInnerMap =
                (Map <String, Object> ) configMap.get(record.split('\\.')[0]);
            firstInnerMap.remove(record.split('\\.')[1]);
            configMap.put(record.split('\\.')[0], firstInnerMap);
          }
          when
          else {
            Map <String, Object> firstInnerMap =
                (Map <String, Object> ) configMap.get(record.split('\\.')[0]);
            Map <String, Object> secondInnerMap =
                (Map <String, Object> ) firstInnerMap.get(record.split('\\.')[1]);
            secondInnerMap.remove(record.split('\\.')[2]);
            firstInnerMap.put(record.split('\\.')[1], secondInnerMap);
            configMap.put(record.split('\\.')[0], firstInnerMap);
          }
        }
        outMap.put('config', configMap);
      }
    }
  }

  /*
   * @description To merge Account and default configuration data.
   */
  public void mergeConfigurationData(Map <String, Object> inputMap, Map <String, Object> outMap,
      Map <String, Object> optionsMap) {

    Map <String, Object> configMap = inputMap.get('config') != null ?
        (Map <String, Object>)inputMap.get('config') : null;
    Map <String, Object> defaultConfigMap = inputMap.get('defaultConfig') != null ?
        (Map <String, Object>)inputMap.get('defaultConfig') : null;
    if (configMap != null) {
      defaultConfigMap = updateMap(defaultConfigMap, configMap);
    }
    outMap.put('config', defaultConfigMap);
  }

  /*
   * @description A recursive call to perform merge action between configuration data.
   */
  public Map <String, Object> updateMap(Map <String, Object> defaultConfigMap,
      Map <String, Object> configMap) {
    if (configMap != null && defaultConfigMap != null) {
      for (String record: configMap.keyset()) {
        if (defaultConfigMap.get(record) == null) {
          defaultConfigMap.put(record, configMap.get(record));
        } else if (String.valueOf(configMap.get(record)).startsWith('{')) {
          updateMap((Map <String, Object> ) defaultConfigMap.get(record),
              (Map <String, Object> ) configMap.get(record));
        } else {
          defaultConfigMap.put(record, configMap.get(record));
        }
      }
    }
    return defaultConfigMap != null ? defaultConfigMap : new Map <String, Object>();
  }

  /*
   * @description To fetch asset model data and send in response.
   */
  public void fetchAssetModelData(Map <String, Object> inputMap,
      Map <String, Object> outMap, Map <String, Object> optionsMap) {

    List <Object> assetModelListObject = (List <Object>)inputMap.get('assetModelData');
    List <Object> assetModelResponseList = new List <Object>();
    for (Object record: assetModelListObject) {
      Object model = ((Map <String, Object>)record).get('model');
      String modelName = (String)((Map <String, Object>)model).get('name');
      Map <String, Object> responseMap = httpCallout(modelName);
      Map <String, Object> innerMap = new Map <String, Object>();
      innerMap.put('name', (String)((Map <String, Object> )record).get('addressId'));
      innerMap.put('addressId', (String)((Map <String, Object> )record).get('addressId'));
      innerMap.put('serialNo', (String)((Map <String, Object> )record).get('serialNo'));
      innerMap.put('installInfo', ((Map <String, Object> )record).get('installInfo'));
      if (responseMap.get('response') != null) {
        Object responseData = ((Map <String, Object>)responseMap).get('response');
        Object assetModelData = ((Map <String, Object>)responseData).get(modelName);
        innerMap.put('model', assetModelData);
      }
      assetModelResponseList.add(innerMap);
    }

    String model = (String)inputMap.get('model');
    Map <String, Object> outerMap = new Map <String, Object>();
    outMap.put('cpes', assetModelResponseList);
  }

  /*
   * @description To make httpcallout for asset model data and send response back.
   */
  public Map <String, Object> httpCallout(String modelName) {

    QueryAssetModel requestBody = new QueryAssetModel();
    requestBody.name = modelName;
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(GET_DEVICES_API);
    request.setMethod('POST');
    request.setHeader(Constants.SERVICE.ADDRESS.CONTENT_TYPE, 'application/json');
    request.setBody(JSON.serialize(requestBody));
    HttpResponse response = http.send(request);

    Map <String, Object> responseMap = new Map <String, Object> ();
    if (response.getStatusCode() == 200 && response.getBody() != null) {
      Object responseData = JSON.deserializeUntyped(response.getBody());
      responseMap.put('response', ((Map <String, Object>)responseData).get('assetModels'));
    }
    return responseMap;
  }

  /*
   * @description To create response structure of configuration data.
   * Expected nodes in response structure are
   * serialNumber it contains serialNumber of an device,
   * nickname it contains nickname of an device,
   * deviceType it contains device type like router,
   * cpeServiceConfig it contains configuration data.
   */
  public void fetchConfigurationData(Map <String, Object> inputMap, Map <String, Object> outMap,
      Map <String, Object> optionsMap) {

    List <Object> serialNumberListObject = (List <Object>)inputMap.get('serialNumberList');
    List <Object> configurationListObject = (List <Object>)inputMap.get('configurationList');
    Map <String, Object> accountConfigurationMap = inputMap.get('accountConfiguration') != null ?
        (Map <String, Object>)inputMap.get('accountConfiguration') : null;

    List <Object> serialNumberObject = inputMap.get('serialNumber') != null ?
        (List <Object>)inputMap.get('serialNumber') : null;
    String accountId = (String)inputMap.get('accountId');
    List <String> serialNumbersNotBoundToAccount = new List <String>();

    Map <String, Object> configurationMap = new Map <String, Object>();
    Map <String, Object> outerMap = new Map <String, Object>();

    for (Object record: configurationListObject) {
      if (((Map <String, Object> )record).get('jsonBody') != null) {
        configurationMap.put((String)((Map <String, Object> )record).get('serialNumber'),
            JSON.deserializeUntyped((String)((Map <String, Object> )record).get('jsonBody')));
      }
    }

    for (Object record: serialNumberListObject) {
      Map <String, Object> innerMap = new Map <String, Object>();
      if (((Map <String, Object> )record).get('serialNumber') != null) {
        List <String> deviceType = new List <String>();
        deviceType.add((String)((Map <String, Object> )record).get('deviceType'));
        innerMap.put('serialNumber', (String)((Map <String, Object> )record).get('serialNumber'));
        innerMap.put('nickname', (String)((Map <String, Object> )record).get('nickname'));
        innerMap.put('deviceType', deviceType);

        if (configurationMap.get((String)((Map <String, Object> )record).get('serialNumber')) !=
            null && accountConfigurationMap != null) {
          accountConfigurationMap = updateMap(accountConfigurationMap,
              (Map <String, Object>)configurationMap.get((String)((Map <String,
              Object>)record).get('serialNumber')));
          innerMap.put('cpeServiceConfig', accountConfigurationMap);
        } else if (configurationMap.get((String)((Map <String, Object>)record).get('serialNumber'))
            != null) {
          innerMap.put('cpeServiceConfig',
              configurationMap.get((String)((Map <String, Object> )record).get('serialNumber')));
        } else if (accountConfigurationMap != null) {
          innerMap.put('cpeServiceConfig', accountConfigurationMap);
        }
        if (accountId.equalsIgnoreCase((String)((Map <String, Object> )record).get('accountId')) ||
            accountId.equalsIgnoreCase((String)((Map <String, Object> )record)
            .get('serviceAccountId'))) {
          outerMap.put((String)((Map <String, Object> )record).get('serialNumber'), innerMap);
        }
      }
    }

    outMap.put('finalOutput', JSON.serialize(outerMap));

    if (serialNumberObject != null) {
      for (Object serialNumber: serialNumberObject) {
        if (outerMap.get(String.valueof(serialNumber)) == null) {
          serialNumbersNotBoundToAccount.add(String.valueof(serialNumber));
          outMap.put('isError', 'true');
        }
      }
      if (serialNumbersNotBoundToAccount != null && !serialNumbersNotBoundToAccount.isEmpty()) {
        outMap.put('errorMessage', 'Serial numbers not bound to account ' + accountId +
          ': ' + String.join(serialNumbersNotBoundToAccount, ','));
      }
    }
  }
  
  /*
   * @description To transform device service response to key and value pair Map structure.
   */
  public void transformDeviceServiceData(Map <String, Object> inputMap, Map <String, Object> outMap,
      Map <String, Object> optionsMap) {
    
     List <Object> deviceDataListObject = (List <Object>)inputMap.get('deviceData');
     List <Object> assetDataListObject = (List <Object>)inputMap.get('assetData');
     String accountId = (String)inputMap.get('accountId');
     String oui = (String)inputMap.get('oui');
     
     List <Object> deviceDataList = new List <Object>();
     Map <String, Object> assetDataMap = new Map <String, Object>();
     
     for (Object record: assetDataListObject) {
       Map <String, Object> innerAssetMap = new Map <String, Object>();
        innerAssetMap.put('serialNumber',  (String)((Map <String, Object> )record).get('serialNumber'));
        innerAssetMap.put('deviceType',  (Object)((Map <String, Object> )record).get('deviceType'));
        innerAssetMap.put('nickname',  (String)((Map <String, Object> )record).get('nickname'));
       assetDataMap.put((String)((Map <String, Object> )record).get('serialNumber'), (Object)innerAssetMap);
     }
     
     for (Object record: deviceDataListObject) {

      Map <String, Object> innerMap = new Map <String, Object>();
        Map <String, Object> cpeMap = new Map <String, Object>();
        Map <String, Object> deviceData = new Map <String, Object>();
        Map <String, Object> informInfo = new Map <String, Object>();
        
        Object assetMapObject = (Object)((Map <String, Object>)assetDataMap)
            .get((String)((Map <String, Object> )record).get('deviceId'));

      Object deviceProperties = ((Map <String, Object>)record).get('properties');
        Object deviceStatus = ((Map <String, Object>)record).get('status');
        innerMap.put('accountId', (String)accountId);
        cpeMap.put('oui', oui);
        cpeMap.put('serialNumber', (String)((Map <String, Object> )record).get('deviceId'));
        cpeMap.put('productClass', (String)((Map <String, Object> )deviceProperties).get('model'));
        innerMap.put('cpeId', (Object)cpeMap);
        
        if (((Map <String, Object>)deviceProperties).get('swVersion') != null) {
          informInfo.put('swVersion', (String)((Map <String, Object> )deviceProperties).get('swVersion'));
        }
        if (((Map <String, Object>)deviceStatus).get('lastBootTimeMs') != null) {
          informInfo.put('bootInformTimeMs', (String)((Map <String, Object> )deviceStatus).get('lastBootTimeMs'));
        }
        if (((Map <String, Object>)deviceStatus).get('ipAddress') != null) {
          informInfo.put('ipAddress', (String)((Map <String, Object> )deviceStatus).get('ipAddress'));
        }
        if(((Map <String, Object>)assetMapObject).get('deviceType') != null) {
          deviceData.put('deviceType', (Object)((Map <String, Object> )assetMapObject).get('deviceType'));
        }
        if(((Map <String, Object>)assetMapObject).get('nickname') != null) {
          innerMap.put('nickname', (String)((Map <String, Object> )assetMapObject).get('nickname'));
        }
        deviceData.put('parameterRoot', 'Device');
        if (informInfo.keyset().size() > 0) {
          deviceData.put('informInfo', (Object)informInfo);
        }
        innerMap.put('deviceData', (Object)deviceData);
        deviceDataList.add(innerMap);
     }
     
     outMap.put('device', deviceDataList);
  }

  /*
   * @group Address Wrapper
   * @description Wrapper class to store request data for search address API.
   */
  public class QueryAssetModel {

    public String name;
  }
}