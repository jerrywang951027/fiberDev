/**
 * @group SparesFulfillmentController
 * @description A Action SparesFulfillment that use for assign spare devices to
 * Selected Technician.
 */
public class SparesFulfillmentController {

  /**
   * @description Create a Map.
   */
  private static Map<String,String> serialKeyGpnMap = new Map<String,String>();
  public static Map<String, String> serialkeyLocationMap = new Map<String, String>();
  public static Map<String, String> serialKeyAssignmentMap = new Map<String, String>();

  /**
   * @description Method for checking technician is assign to technician group.
   * @param userEmail The technician email address to be pass.
   */
  @AuraEnabled
  public static boolean checkIfLdapExists(String userEmail){
    List<User> userList=[
        SELECT Id
        FROM User
        WHERE
          email=:userEmail];
    if (null != userList && userList.size() > 0){
      List<GroupMember> memberList=[
          select id,
          groupId
          from GroupMember
          where
            UserOrGroupId=:userList[0].id
            and group.name='Technician'];
        if ( null != memberList && memberList.size()>0 && memberList.get(0).Id != null){
            return true;
    }
  }
  return false;
}

  /**
   * @description Method for searching Teachnician list.
   */
  @AuraEnabled
  public static String searchSpareparts(List<String> sparePartList){
    try {
       return null;
    }
    catch (Exception exceptionObject){
      return null;
    }
  }

  /**
   * @description Method for Searching a Technician using technician LDAP and PRE_ASSIGNED_SPARE 
   * devices to the technician.
   * @param argUserName The technician name to be pass.
   * @return List of device for selected technician.
   */
  @AuraEnabled
  public static String searchSparepartsForUser(String argUserName){
    try {
          DeviceOwnershipCriteria deviceOwnershipCriteria = new DeviceOwnershipCriteria();
          List<DeviceWrapper> deviceWrapperList = new List<DeviceWrapper>();
          DeviceWrapper deviceWrapperInstance;
          deviceOwnershipCriteria.newOwners = new List<String>();
          deviceOwnershipCriteria.newOwners.add(argUserName);
          deviceOwnershipCriteria.ownershipStatuses =new List<String>();
          deviceOwnershipCriteria.ownershipStatuses.add('PRE_ASSIGNED_SPARE');
          Criteria criteria = new Criteria();
          criteria.deviceOwnershipCriteria = deviceOwnershipCriteria;

          FindSerialsRequestWrapper findSerialsRequestWrapper = new FindSerialsRequestWrapper();
          findSerialsRequestWrapper.criteria = criteria;
          FindSerialsAPI findSerialsAPI = new FindSerialsAPI();
          FindSerialsResponseWrapper findSerialsResponseWrapper =
              findSerialsAPI.callFindSerialAPI(findSerialsRequestWrapper);
          if (null != findSerialsResponseWrapper.serials){
            for (Serial currentSerial :findSerialsResponseWrapper.serials){
                deviceWrapperInstance = new DeviceWrapper();
                  deviceWrapperInstance.serial = currentSerial.serialKey.serialNumber;
                  deviceWrapperInstance.gpn = currentSerial.serialKey.gpn;
                  i2ms_Model_Description__c i2msModelDescriptionRecord =
                      i2ms_Model_Description__c.getValues(currentSerial.serialKey.gpn);
                  if(null != i2msModelDescriptionRecord){
                    deviceWrapperInstance.description
                        = i2msModelDescriptionRecord.Description__c;
                    }
                  deviceWrapperList.add(deviceWrapperInstance);
            }
          }
          String deviceWrapperListSerialized = JSON.serialize(deviceWrapperList);
          return deviceWrapperListSerialized;
        }
    catch (Exception exceptionObject){
      return null;
    }
  }

  /**
   * @description Method for retrieving the GPN for Serial Number.
   * @return The GPN for Serialnumber.
   */
  @AuraEnabled
  public static Map<String, String> findGpn(List<String> serialNumberList){
    try {
      List<SerialKey> serialKeyList = new List<SerialKey>();
      Criteria criteria = new Criteria();
      SerialKey serialKeyInstance;

      for (String serialNumber : serialNumberList){
          serialKeyInstance = new SerialKey();
          serialKeyInstance.serialNumber = serialNumber;
          serialKeyList.add(serialKeyInstance);
      }
      criteria.serialKeys = serialKeyList;
      FindSerialsRequestWrapper findSerialsRequestWrapper = new FindSerialsRequestWrapper();
      findSerialsRequestWrapper.criteria = criteria;
      FindSerialsAPI findSerialsAPI = new FindSerialsAPI();
      FindSerialsResponseWrapper findSerialsResponseWrapper =
          findSerialsAPI.callFindSerialAPI(findSerialsRequestWrapper);
      for (Serial currentSerial :findSerialsResponseWrapper.serials){
          serialKeyGpnMap.put(currentSerial.serialKey.serialNumber,
              currentSerial.serialKey.gpn);
          serialkeyLocationMap.put(currentSerial.serialKey.serialNumber,
              currentSerial.lastKnownGoogleLocationCode);
          if (currentSerial.currentStatus == 'ON_HAND' &&
              currentSerial.deviceOwnership.currentAttribute.newOwner == null){
                serialKeyAssignmentMap.put(currentSerial.serialKey.serialNumber, 'Not Assigned');
          } else {
            serialKeyAssignmentMap.put(currentSerial.serialKey.serialNumber, 'Device : '
                + currentSerial.serialKey.serialNumber +'  is already owned by '
                + currentSerial.deviceOwnership.currentAttribute.newOwner);
          }
      }
      return serialKeyGpnMap;
    }
      catch(Exception exceptionObject){
        return null;
    }
  }

  /**
   * @description Method for Assigning the Device to User
   * @param argUserName The Technician name to be pass
   * @param argSerialnumber1, .. The serial number to be pass
   * @param argWarehouse The selected Warehouse to be pass.
   * @return responseString.
   */
  @AuraEnabled
  public static String assignSerialsToUser(String argUserName
      , String argSerialNumber1
      , String argSerialNumber2
      , String argSerialNumber3
      , String argSerialNumber4
      , String argSerialNumber5
      , String argWarehouse){
        try{
          List<String> serialNumberList = new List<String>();
          List<DeviceWrapper> deviceWrapperList = new List<DeviceWrapper>();
          DeviceWrapper deviceWrapperInstance;
          String responseString;
          String currentSerialWarehouse;
          Boolean isSerialInvalid = false;
          if(String.isNotBlank(argSerialNumber1)){
            serialNumberList.add(argSerialNumber1);
          }
          if(String.isNotBlank(argSerialNumber2)){
            serialNumberList.add(argSerialNumber2);
          }
          if(String.isNotBlank(argSerialNumber3)){
            serialNumberList.add(argSerialNumber3);
          }
          if(String.isNotBlank(argSerialNumber4)){
            serialNumberList.add(argSerialNumber4);
          }
          if(String.isNotBlank(argSerialNumber5)){
            serialNumberList.add(argSerialNumber5);
          }
          Map<String, String> serialNumberGpnMap = findGpn(serialNumberList);
          for (String serialnumber : serialNumberList){
            Warehouse_Location__c warehouseLocationRecord
                = Warehouse_Location__c.getValues(serialkeyLocationMap.get(serialNumber));
              if (null != warehouseLocationRecord){
                currentSerialWarehouse = warehouseLocationRecord.Description__c;
              }
              if (currentSerialWarehouse != argWarehouse){
                deviceWrapperInstance = new DeviceWrapper();
                deviceWrapperInstance.userMessage = 'Could not find device with serial number '
                    + serialNumber +' at this location ';
                  isSerialInvalid = true;
                  break;
              }
              if (serialKeyAssignmentMap.get(serialNumber) != 'Not Assigned'){
                deviceWrapperInstance = new DeviceWrapper();
                deviceWrapperInstance.userMessage = serialKeyAssignmentMap.get(serialNumber);
                isSerialInvalid = true;
                break;
              }
          }
        if (isSerialInvalid){
          responseString = JSON.serialize(deviceWrapperInstance);
        }
        else {
          List<UpdateRequest> updateRequestList;
          serialNumberList = getAllSerialNumbersToAssign(serialNumberList);
          for (String serialNumber: serialNumberList){
            updateRequestList = new List<UpdateRequest>();
            DeviceOwnershipChangeRequestAttribute deviceOwnershipChangeRequestAttribute
                = new DeviceOwnershipChangeRequestAttribute();
              deviceOwnershipChangeRequestAttribute.newOwner = argUserName;
              deviceOwnershipChangeRequestAttribute.user = argUserName;
              UpdateRequest updateRequestInstance = new UpdateRequest();
              DeviceOwnershipChangeRequestOwnership OwnershipInstance
                  = new DeviceOwnershipChangeRequestOwnership ();
              DeviceOwnershipChangeRequestAttribute.ownershipStatus = 'PRE_ASSIGNED_SPARE';
              OwnershipInstance.currentAttribute = deviceOwnershipChangeRequestAttribute;
              DeviceOwnershipChangeRequestSerialKey deviceOwnershipChangeRequestSerialKey
                  = new DeviceOwnershipChangeRequestSerialKey();
              deviceOwnershipChangeRequestSerialKey.serialNumber = serialNumber;
              deviceOwnershipChangeRequestSerialKey.gpn
                  = serialNumberGpnMap.get(serialNumber);
              OwnershipInstance.serialKey = deviceOwnershipChangeRequestSerialKey;
              updateRequestInstance.deviceOwnership = OwnershipInstance;
              String updateMask =  String.join
                  (new List <String> {'deviceOwnership.currentAttribute.versionNumber',
                  'deviceOwnership.currentAttribute.ownershipStatus',
                  'deviceOwnership.currentAttribute.transactionType',
                  'deviceOwnership.currentAttribute.commitTime',
                  'deviceOwnership.currentAttribute.user',
                  'deviceOwnership.currentAttribute.currentOwner',
                  'deviceOwnership.currentAttribute.newOwner',
                  'deviceOwnership.currentAttribute.googleLocationCode',
                  'deviceOwnership.currentAttribute.assignedToAccount',
                  'deviceOwnership.currentAttribute.externalReferences',
                  'deviceOwnership.currentAttribute.defectReason',
                  'deviceOwnership.currentAttribute.comments',
                  'deviceOwnership.currentAttribute.deviceStatuse'}, ',');  
              updateRequestInstance.updateMask= updateMask;
              updateRequestList.add(updateRequestInstance);
              DeviceOwnershipBatchChangeRequestWrapper
                  deviceOwnershipBatchChangeRequestWrapperInstance
                      = new DeviceOwnershipBatchChangeRequestWrapper();
              deviceOwnershipBatchChangeRequestWrapperInstance.updateRequest = updateRequestList;
              DeviceOwnershipBatchChangeResWrapper deviceOwnershipBatchChangeResWrapperInstance
                  = DeviceOwnershipBatchChangeAPI.updateOwner(
                    deviceOwnershipBatchChangeRequestWrapperInstance);
              for (DeviceOwnershipChangeResponseOwnership
                  deviceOwnershipChangeResponseOwnershipInstance
                      : deviceOwnershipBatchChangeResWrapperInstance.deviceOwnership){
                    deviceWrapperInstance = new DeviceWrapper();
                    deviceWrapperInstance.serial
                        = deviceOwnershipChangeResponseOwnershipInstance.serialKey.serialNumber;
                    deviceWrapperInstance.gpn
                        = deviceOwnershipChangeResponseOwnershipInstance.serialKey.gpn;
                    i2ms_Model_Description__c i2msModelDescriptionRecord
                        = i2ms_Model_Description__c.getValues(
                          deviceOwnershipChangeResponseOwnershipInstance.serialKey.gpn);
                    if (null != i2msModelDescriptionRecord){
                      deviceWrapperInstance.description
                          = i2msModelDescriptionRecord.Description__c;
                    }
              deviceWrapperList.add(deviceWrapperInstance);
            }
          }
            deviceWrapperList.sort();
            responseString = JSON.serialize(deviceWrapperList);
        }
        return responseString;
      }
      catch (Exception exceptionObject){
        return null;
      }
  }

  /**
   * @description Method getAllSerialNumbersToAssign to be use for assign the child of
   * the parent serial number.
   * @return serialNumberListWithAllSerials.
   */
  private static List<String> getAllSerialNumbersToAssign(List<String> argSerialNumberList){
    List<String> serialNumberListWithAllSerials = new List<String>();
    for (String serialNumber: argSerialNumberList){
      serialNumberListWithAllSerials.add(serialNumber);
      FindChildSerialsRequestWrapper findChildSerialsRequestWrapperInstance =
          new FindChildSerialsRequestWrapper();
      FindChildReqParentSerialKey findChildReqParentSerialKeyIntance =
          new FindChildReqParentSerialKey();
      findChildReqParentSerialKeyIntance.serialNumber = serialNumber;
      findChildReqParentSerialKeyIntance.gpn = serialKeyGpnMap.get(serialNumber);
      findChildSerialsRequestWrapperInstance.parentSerialKey
          = findChildReqParentSerialKeyIntance;
      FindChildSerialsResponseWrapper findChildSerialsResponseWrapperInstance
          = FindChildSerialsAPI.callFindChildSerialsAPI(findChildSerialsRequestWrapperInstance);
      for (FindChildResSerial findChildResSerialCurrentInstance
          : findChildSerialsResponseWrapperInstance.serials){
            if (null
                == serialKeyGpnMap.get(findChildResSerialCurrentInstance.serialKey.serialNumber)){
                  serialKeyGpnMap.put(findChildResSerialCurrentInstance.serialKey.serialNumber
                      ,findChildResSerialCurrentInstance.serialKey.gpn);
              serialNumberListWithAllSerials.add(
                  findChildResSerialCurrentInstance.serialKey.serialNumber);
          }
      }
    }
    return serialNumberListWithAllSerials;
  }
}