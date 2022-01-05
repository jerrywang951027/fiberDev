/**
 * @group CSR Console
 * @description class to filter and count order items based on CPE type.
 */
public with sharing class EquipmentUtils {

  /**
   * @description This method is to filter and count order items based on CPE type.
   * @param inputMap This will have orderItems.
   * @param outMap This will return the filtered orderItems with counted equipments.
   * @param options Any optional parameters
   * @return null
   */
  public void countEquipmentMethod(Map<String, Object> inputMap,
      Map<String, Object> outMap, Map<String, Object> options) {
    Map<String, List<Object>> outputMap = new Map<String, List<Object>>();
    String typeOfOrder = (String) inputMap.get('type');
    List<Object> orderItemList = (List<Object>)(inputMap.get('orderItems'));
    for (Integer i = 0; i < orderItemList.size(); i++) {
      Map<String, Object> equipmentDetailByKeys = (Map<String, Object>)(orderItemList[i]);
      if (!equipmentDetailByKeys.containsKey('parent')) {
        if (outputMap.containsKey('parent')) {
          outputMap.get('parent').add((orderItemList[i]));
        } else {
          List<Object> parentList = new List<Object>();
          parentList.add(orderItemList[i]);
          outputMap.put('parent', parentList);
        }
      } else if ((equipmentDetailByKeys.containsKey('parent') &&
          !equipmentDetailByKeys.containsKey('cloudStorage')) ||
          (typeOfOrder == 'Phone' && equipmentDetailByKeys.containsKey('parent') &&
          !equipmentDetailByKeys.containsKey('phoneNumber') &&
          !equipmentDetailByKeys.containsKey('phoneNumberType'))) {
        if (outputMap.containsKey('nonParent')) {
          outputMap.get('nonParent').add((orderItemList[i]));
        } else {
          List<Object> nonParentList = new List<Object>();
          nonParentList.add(orderItemList[i]);
          outputMap.put('nonParent', nonParentList);
        }
      } else{
        if (outputMap.containsKey('cloudStorage')) {
          outputMap.get('cloudStorage').add((orderItemList[i]));
        } else{
          List<Object> cloudStorageList = new List<Object>();
          cloudStorageList.add(orderItemList[i]);
          outputMap.put('cloudStorage', cloudStorageList);
        }
      }
    }
    List<Object> equipmentTypeList = new List<Object>();
    List<Object> nonParentEquipmentsList = outputMap.get('nonParent');

    Map<Object, Integer> equipmentCountByType = new Map<Object, Integer>();

    for (Integer i = 0; i < nonParentEquipmentsList.size(); i++) {
      Map<String, Object> equipmentDetailsByKey = (Map<String, Object>)(nonParentEquipmentsList[i]);
        if (equipmentDetailsByKey.containsKey('type')){
          equipmentTypeList.add(equipmentDetailsByKey.get('type'));
        } else {
          equipmentTypeList.add(equipmentDetailsByKey.get('childName'));
        }
    }
    for (Integer i = 0; i < equipmentTypeList.size(); i++){
      Integer itemCount = 0;
      if (equipmentCountByType.get(equipmentTypeList[i]) > 0){
        itemCount = equipmentCountByType.get(equipmentTypeList[i]);
      }
      itemCount++;
      equipmentCountByType.put(equipmentTypeList[i], itemCount);
    }
    List<Object> equipmentCountList = new List<Object>();
    for (Object equipmentType : equipmentCountByType.keySet()){
      Map<String, Object> equipmentTypeAndCountByKeys = new Map<String, Object>();
      equipmentTypeAndCountByKeys.put('childName', equipmentType);
      equipmentTypeAndCountByKeys.put('value', equipmentCountByType.get(equipmentType));
      equipmentCountList.add(equipmentTypeAndCountByKeys);
    }
    outMap.put('nonParent', equipmentCountList);
    outMap.put('parent', outputMap.get('parent'));
    outMap.put('cloudStorage', outputMap.get('cloudStorage'));
  }
}