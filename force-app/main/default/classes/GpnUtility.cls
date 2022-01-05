/**
 * @group GpnUtility
 * @description Utility class for functionality related to GPN.
 */
public with sharing class GpnUtility {

  // Keys for input map.
  public static final String INPUT_MAP_GPN_DETAILS_KEY = 'GPNDetails';
  public static final String INPUT_MAP_GPNS_ASSET_MODELS_KEY = 'gpnsAssetModels';
  public static final String INPUT_MAP_CHILD_SERIAL_NUMBERS_KEY = 'ChildSerialNumbers';
  public static final String INPUT_MAP_GPN_KEY = 'GPN';
  public static final String INPUT_MAP_NAME_KEY = 'name';
  public static final String INPUT_MAP_CHILD_SERIAL_NODES_KEY = 'childSerialNodes';
  public static final String INPUT_MAP_ORDERED_EQUIPMENT_KEY = 'orderedEquipment';
  public static final String INPUT_SUB_TYPE_KEY = 'subType';
  public static final String INPUT_CPE_TYPE_KEY = 'cpeType';

  // Keys for output map.
  public static final String OUTPUT_MAP_MODEL_KEY = 'Model';
  public static final String OUTPUT_MAP_GPN_DETAILS_KEY = 'GPNDetails';
  public static final String OUTPUT_SERIAL_NUMBER_KEY = 'SerialNumber';

  /**
   * @description This method merges the model name from gpnsAssetModels
   * json in GPNDetails json.
   * @param inputMap
   * @param outMap
   * @param options
   */
  public static void mergeModelName(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    List<Object> gpnDetails = (List<Object>)inputMap.get(
        INPUT_MAP_GPN_DETAILS_KEY);
    Map<String, Object> gpnsAssetModels =
        (Map<String, Object>)inputMap.get(
            INPUT_MAP_GPNS_ASSET_MODELS_KEY);
    for(Object gpnDetailObject: gpnDetails) {
      Map<String, Object> gpnDetail =
          (Map<String, Object>)gpnDetailObject;
      for(Object childSerialObject:
          (List<Object>)gpnDetail.get(
              INPUT_MAP_CHILD_SERIAL_NUMBERS_KEY)) {
        Map<String, Object> childSerial =
            (Map<String, Object>)childSerialObject;
        String gpn = String.valueOf(childSerial.get(
            INPUT_MAP_GPN_KEY));
        if(gpnsAssetModels.containsKey(gpn)) {
          Map<String, Object> assetModel =
              (Map<String, Object>)gpnsAssetModels.get(gpn);
          String model = String.valueOf(
              assetModel.get(INPUT_MAP_NAME_KEY));
          childSerial.put(OUTPUT_MAP_MODEL_KEY, model);
        }
      }
    }
    outMap.put(OUTPUT_MAP_GPN_DETAILS_KEY, gpnDetails);
  }

  /**
   * @description This method merges the serial number from childSerialNodes
   * json to orderedEquipments json.
   * @param inputMap
   * @param outMap
   * @param options
   */
  public static void mergeSerialNumber(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    List<Object> childSerialNodes = (List<Object>)inputMap.get(
        INPUT_MAP_CHILD_SERIAL_NODES_KEY);
    List<Object> orderedEquipments =
        (List<Object>)inputMap.get(
            INPUT_MAP_ORDERED_EQUIPMENT_KEY);
    Map<String, String> mapOfUniqueKeyWithSerial =
        new Map<String, String> ();
    Map<String, String> mapOfUniqueKeyWithModel =
        new Map<String, String> ();
    for(Object childSerialNode : childSerialNodes) {
      Map<String, Object> childSerial =
          (Map<String, Object>)childSerialNode;
      if (childSerial.get(INPUT_SUB_TYPE_KEY) != null
         && childSerial.get(INPUT_CPE_TYPE_KEY) != null
         && childSerial.get(OUTPUT_SERIAL_NUMBER_KEY) != null
         && childSerial.get(OUTPUT_MAP_MODEL_KEY) != null) {
          String uniqueKey = childSerial.get(INPUT_SUB_TYPE_KEY)+
              '_' + childSerial.get(INPUT_CPE_TYPE_KEY);
          String serialNumber = (String)childSerial.get(OUTPUT_SERIAL_NUMBER_KEY);
          String model = (String)childSerial.get(OUTPUT_MAP_MODEL_KEY);
          mapOfUniqueKeyWithSerial.put(uniqueKey, serialNumber);
          mapOfUniqueKeyWithModel.put(uniqueKey, model);
      }
    }
    for(Object orderedEquipment : orderedEquipments) {
      Map<String, Object> orderedEquip =
          (Map<String, Object>)orderedEquipment;
      if (orderedEquip.get(INPUT_SUB_TYPE_KEY) != null
         && orderedEquip.get(INPUT_CPE_TYPE_KEY) != null) {
          String uniqueKey = orderedEquip.get(INPUT_SUB_TYPE_KEY)+
              '_' + orderedEquip.get(INPUT_CPE_TYPE_KEY);
          String serialNumber = mapOfUniqueKeyWithSerial.get(uniqueKey);
          String model = mapOfUniqueKeyWithModel.get(uniqueKey);
          orderedEquip.put(OUTPUT_SERIAL_NUMBER_KEY, serialNumber);
          orderedEquip.put(OUTPUT_MAP_MODEL_KEY, model);
      }
    }
    outMap.putAll(inputMap);
  }

}