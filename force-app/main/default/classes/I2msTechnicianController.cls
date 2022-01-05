/**
 * @group I2msTechnicianController
 * @description This class is used for Select Tech, Unassign the PreAssigned devices and
 * Confirm the lost devices.
 */
 public with sharing class I2msTechnicianController {
   public static final String CLASS_NAME = 'I2msTechnicianController';
   private static String technician = 'Technician';
   private static String preAssigned ='PRE_ASSIGNED_SPARE';
   private static String confirmLost ='LOST_PENDING_RECEIPT';
   private static String mask = String.join
     (new List <String> {'deviceOwnership.currentAttribute.versionNumber',
     'deviceOwnership.currentAttribute.ownershipStatus',
     'deviceOwnership.currentAttribute.transactionType',
     'deviceOwnership.currentAttribute.commitTime','deviceOwnership.currentAttribute.user',
     'deviceOwnership.currentAttribute.currentOwner',
     'deviceOwnership.currentAttribute.newOwner',
     'deviceOwnership.currentAttribute.googleLocationCode',
     'deviceOwnership.currentAttribute.assignedToAccount',
     'deviceOwnership.currentAttribute.externalReferences',
     'deviceOwnership.currentAttribute.defectReason',
     'deviceOwnership.currentAttribute.comments',
     'deviceOwnership.currentAttribute.deviceStatuse'}, ',');

  // Checks if the user is part of Technician public group
  @AuraEnabled
  public static Boolean checkIfLdapExists(String userEmail) {
    List <GroupMember> memberList;
    List <User> userDetails = new List <User> ([SELECT Id FROM User WHERE email = :userEmail ]);
      if (userDetails!= null && !userDetails.isEmpty()) {
        memberList = new List <GroupMember> ([SELECT Id,
        groupId FROM GroupMember WHERE UserOrGroupId = :userDetails[0].Id AND
        group.name = :technician]);
      }
      if (memberList!= null && !memberList.isEmpty()) {
        return true;
      }
    return false;
  }
  // Makes a call to findSerials API and returns the list of devices assigned
  @AuraEnabled
  public static String extractJsonData(String searchKey, String status) {
    final String METHOD_NAME = 'extractJsonData';
    Map <String, Object> inputBody = new Map <String, Object> ();
    Map <String, Object> criteriaNode = new Map <String, Object> ();
    Map <String, Object> deviceOwnershipNode = new Map <String, Object> ();
    Map <String, Object> findSerialsMap;
    List <String> owners = new List <String> ();
    owners.add(searchKey);
    List <String> ownershipStatuses = new List <String> ();
    ownershipStatuses.add(status);
      if (status == preAssigned) {
      deviceOwnershipNode.put('newOwners', owners);
      } else if (status == confirmLost) {
        deviceOwnershipNode.put('currentOwners', owners);
      }
    deviceOwnershipNode.put('ownershipStatuses', ownershipStatuses);
    criteriaNode.put('deviceOwnershipCriteria', deviceOwnershipNode);
    inputBody.put('criteria', criteriaNode);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:FindSerials');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
    req.setBody(JSON.serialize(inputBody));
    Http http = new Http();
    try {
      HTTPResponse res = http.send(req);
        if (!String.isBlank(res.getBody())) {
          findSerialsMap = (Map <String, Object> )JSON.deserializeUntyped(res.getBody());
          if (findSerialsMap != null) {
            List <object> ldapList = (List <Object> ) findSerialsMap.get('serials');
            Map <String, Object> serialKey;
            Map <String, Object> ldapMap;
            String description;
            List <object> finalList = new List <object> ();
              if (ldapList != null && !ldapList.isEmpty()) {
                for (Object ldap: ldapList) {
                  ldapMap = (Map <String, Object> ) ldap;
                  serialKey = (Map <String, Object> ) ldapMap.get('serialKey');
                  // Gets ldaps description from custom settings and put it in the JSON list
                  i2ms_Model_Description__c i2msModelDescriptionRecord =
                    i2ms_Model_Description__c.getValues((String) serialKey.get('gpn'));
                  if (i2msModelDescriptionRecord != null) {
                    description = i2msModelDescriptionRecord.Description__c;
                    ldapMap.put('description', description);
                  }
                  finalList.add(ldapMap);
                }
              return JSON.serialize(finalList);
              }
          }
      }
    } catch (Exception exp) {
        LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
        throw exp;
    }
  return null;
  }
  // Method is used for unassign the selected device
  @AuraEnabled
  public static String updateDeviceOwnership(String inputData, string userLdap) {
    final String METHOD_NAME = 'updateDeviceOwnership';
    List <Object> inputList = (List <Object> ) JSON.deserializeUntyped(inputData);
    List <Object> updateRequestList = new List <Object> ();
    Map <String, Object> inputBody = new Map <String, Object> ();
    Map <String, Object> inputMap;
    String serialNo;
    String gpn;
    for (Object input: inputList) {
      inputMap = (Map <String, Object> ) input;
      serialNo = (String) inputMap.get('serialNo');
      gpn = (String) inputMap.get('gpn');
      updateRequestList.add(new Map<String, Object> {
        'updateMask' => mask,
        'deviceOwnership' => new Map<String, Object> {
        'serialKey'=> new Map<String, Object> {
        'serialNumber' => serialNo,
        'gpn' => gpn },
        'currentAttribute' => new Map<String, Object>{
        'transactionType'=> 'UNASSIGN ',
        'user'=> userLdap }
        }
      });
    }
    inputBody.put('updateRequest', updateRequestList);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:BatchUpdateDevice');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
    req.setBody(JSON.serialize(inputBody));
    Http http = new Http();
  try {
    HTTPResponse res = http.send(req);
      Map <String, Object> updateDeviceResponse = (Map <String, Object> )
      JSON.deserializeUntyped(res.getBody());
        if (!String.isBlank(res.getBody())) {
          return res.getBody();
        }
  }catch (Exception exp) {
    LoggingUtility.insertExceptionLog(CLASS_NAME,
      METHOD_NAME, exp);
    throw exp;
  }
  return null;
  }
  // Method used to confirm lost for selected devices.
  @AuraEnabled
  public static String confirmLost(String inputData, String userLdap) {
    final String METHOD_NAME = 'confirmLost';
    List <Object> inputList = (List <Object> ) JSON.deserializeUntyped(inputData);
    List <Object> updateRequestList = new List <Object> ();
    Map <String, Object> inputBody = new Map <String, Object> ();
    Map <String, Object> serialNode;
    Map <String, Object> inputMap = new Map <String, Object> ();
    String serialNo;
    String gpn;
      for (Object input: inputList) {
        inputMap = (Map <String, Object> ) input;
        serialNo = (String) inputMap.get('serialNo');
        gpn = (String) inputMap.get('gpn');
        updateRequestList.add(new Map<String, Object> {
          'updateMask' =>mask,
          'deviceOwnership' => new Map<String, Object> {
          'serialKey'=> new Map<String, Object> {
          'serialNumber' => serialNo,
          'gpn' => gpn },
          'currentAttribute' => new Map<String, Object>{
          'transactionType'=> 'CONFIRMED_LOST',
          'user'=> userLdap,
          'ownershipStatus'=> 'CONFIRMED_LOST',
          'currentOwner'=> 'WAREHOUSE',
          'googleLocationCode'=> 'NITTX01FS' }
          }
        });
    }
    inputBody.put('updateRequest', updateRequestList);
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:BatchUpdateDevice');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
    req.setBody(JSON.serialize(inputBody));
    Http http = new Http();
    try {
      HTTPResponse res = http.send(req);
      Map <String, Object> updateDeviceResponse = (Map <String, Object> )
      JSON.deserializeUntyped(res.getBody());
        if ( updateDeviceResponse != null ) {
          return 'success';
        }
    }catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
        METHOD_NAME, exp);
      throw exp;
    }
    return null;
  }
}