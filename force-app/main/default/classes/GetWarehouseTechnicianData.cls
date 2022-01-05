public class GetWarehouseTechnicianData {

    class DeviceModel
    {
        String serialNumber;
        String gpn;
        String owner;
    }   
    @AuraEnabled
    public static boolean checkIfLdapExists(String userEmail){

        if(userEmail == 'WAREHOUSE@google.com')
        {
            return true;
        }

        User[] userIds=[SELECT Id,email FROM User WHERE email=:userEmail limit 1];        
        if(userIds == null || userIds.size() <= 0)
        {
            return false;
        }

        User userId = userIds[0];      
        GroupMember[] members=[select id,groupId from GroupMember where UserOrGroupId=:userId.id
        and group.name='Technician' limit 1];          
        if (members != null && members.size()>0 && members[0].Id != null){
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static string 
getWarehouseData(String searchKey, Boolean inboundMode, List<String> statusList){
        Map<String, Object> inputBody = new Map<String, Object>();
        Map<String, Object> criteriaNode = new Map<String, Object>();
        Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
        List<String> owners = new List<String>();
        owners.add(searchKey);
        List<String> ownershipStatuses=new List<String>(statusList);       
        if(inboundMode && 
        (ownershipStatuses.contains('PRE_ASSIGNED_SPARE') 
        || ownershipStatuses.contains('PRE_TRANSFER'))){
            deviceOwnershipNode.put('newOwners',owners);
        }
        else{
            deviceOwnershipNode.put('currentOwners',owners);
        }

        deviceOwnershipNode.put('ownershipStatuses',ownershipStatuses);
        criteriaNode.put('deviceOwnershipCriteria',deviceOwnershipNode);
        inputBody.put('criteria',criteriaNode);        
        HttpResponse res = CreateAndSendPostRequest(
            'callout:FindSerials',JSON.serialize(inputBody));
        if(!String.isBlank(res.getBody())){
            Map<String,Object> findSerialsMap 
            = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            if(findSerialsMap!=null){
                list<object> ldapList = (List<Object>)findSerialsMap.get('serials');
                 Map<String,Object> serialKey;
                 Map<String,Object> ldapMap;
                string description;
                list<object>finalList=new List<object>();
                if(ldapList != null && !ldapList.isEmpty()){
                    for(object ldap:ldapList){
                        ldapMap = (Map<String,Object>) ldap;  
                        serialKey = (Map<String,Object>) ldapMap.get('serialKey'); 
                        i2ms_Model_Description__c i2msModelDescriptionRecord 
                        = i2ms_Model_Description__c.getValues((string)serialKey.get('gpn'));
                        if(i2msModelDescriptionRecord!=null){
                        description=i2msModelDescriptionRecord.Description__c; 
                         ldapMap.put('description',description);
                        }                       
                        finalList.add(ldapMap);
                    }                    
                    return JSON.serialize(finalList);
                }
            }            
        }        
        return null;
    }

    @AuraEnabled
    public static string receiveDevice(String serialNumber,String gpn){        
        Map<String, List<Object>> inputBody = new Map<String, List<Object>>();
        Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
        Map<String, Object> serialKey = new Map<String, Object>();
        Map<String, Object> currentAttribute = new Map<String, Object>();
        Map<String, Object> updateRequest = new Map<String, Object>();

        currentAttribute.put('transactionType', 'Receipt');
        serialKey.put('serialNumber',serialNumber);
        serialKey.put('gpn',gpn);
        deviceOwnershipNode.put('serialKey', serialKey);
        deviceOwnershipNode.put('currentAttribute', currentAttribute);

        List<Object> objList = new List<Object>();

        updateRequest.put('deviceOwnership', deviceOwnershipNode);
        updateRequest
        .put('updateMask', getUpdateMask());

        objList.add(updateRequest);

        inputBody.put('updateRequest', objList);

        HttpResponse res = CreateAndSendPostRequest(
            'callout:BatchUpdateDevice',JSON.serialize(inputBody));
        Map<String,Object> updateDeviceResponse = (Map<String,Object>) 
        JSON.deserializeUntyped(res.getBody());
        if(!String.isBlank(res.getBody())){
            return res.getBody();
        }
        return null;
    }
    @AuraEnabled
    public static string reportDOA(List<Map<String, String>> devices, 
    String deviceStatus, String defectReason, String comments){

        Map<String, List<Object>> inputBody = new Map<String, List<Object>>();
        List<Object> objList = new List<Object>();

        for(Integer i = 0; i < devices.size();i++)
        {
            Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
            Map<String, Object> serialKey = new Map<String, Object>();
            Map<String, Object> currentAttribute = new Map<String, Object>();
            Map<String, Object> updateRequest = new Map<String, Object>();

            currentAttribute.put('ownershipStatus', 'DOA_PENDING_RECEIPT');
            currentAttribute.put('currentOwner', devices[i].get('owner'));
            currentAttribute.put('comments', comments);
            currentAttribute.put('deviceStatus', deviceStatus);
            currentAttribute.put('defectReason', defectReason);
            currentAttribute.put('versionNumber', 1.0);

            serialKey.put('serialNumber',devices[i].get('serialNumber'));
            serialKey.put('gpn',devices[i].get('gpn'));
            deviceOwnershipNode.put('serialKey', serialKey);
            deviceOwnershipNode.put('currentAttribute', currentAttribute);


            updateRequest.put('deviceOwnership', deviceOwnershipNode);
            updateRequest.put('updateMask', getUpdateMask());

            objList.add(updateRequest);

        }

        inputBody.put('updateRequest', objList);

        HttpResponse res = CreateAndSendPostRequest(
            'callout:BatchUpdateDevice', 
            JSON.serialize(inputBody));
        Map<String,Object> updateDeviceResponse = 
        (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        if(!String.isBlank(res.getBody())){
            return res.getBody();
        }
        return null;
    }    
    @AuraEnabled
    public static string reportLost(List<Map<String, String>> devices, String comments){        
        Map<String, List<Object>> inputBody = new Map<String, List<Object>>();
        List<Object> objList = new List<Object>();        
        for(Integer i = 0; i < devices.size();i++)
        {
            Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
            Map<String, Object> serialKey = new Map<String, Object>();
            Map<String, Object> currentAttribute = new Map<String, Object>();
            Map<String, Object> updateRequest = new Map<String, Object>();

            currentAttribute.put('ownershipStatus', 'LOST_PENDING_RECEIPT');
            currentAttribute.put('currentOwner', devices[i].get('owner'));
            currentAttribute.put('comments', comments);
            currentAttribute.put('versionNumber',1.0);            
            serialKey.put('serialNumber',devices[i].get('serialNumber'));
            serialKey.put('gpn',devices[i].get('gpn'));
            deviceOwnershipNode.put('serialKey', serialKey);
            deviceOwnershipNode.put('currentAttribute', currentAttribute);

            updateRequest.put('deviceOwnership', deviceOwnershipNode);
            updateRequest.put('updateMask', getUpdateMask());

            objList.add(updateRequest);
        }

        inputBody.put('updateRequest', objList);

        HttpResponse res = CreateAndSendPostRequest(
            'callout:BatchUpdateDevice',JSON.serialize(inputBody));
        Map<String,Object> updateDeviceResponse = (Map<String,Object>) 
        JSON.deserializeUntyped(res.getBody());
        if(!String.isBlank(res.getBody())){
            return res.getBody();
        }
        return null;
    }

    @AuraEnabled
    public static string reportSurplus(List<Map<String, String>> devices){
        
        Map<String, List<Object>> inputBody = new Map<String, List<Object>>();
        List<Object> objList = new List<Object>();
        
        for(Integer i = 0; i < devices.size();i++)
        {
            Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
            Map<String, Object> serialKey = new Map<String, Object>();
            Map<String, Object> currentAttribute = new Map<String, Object>();
            Map<String, Object> updateRequest = new Map<String, Object>();

            currentAttribute.put('ownershipStatus', 'SURPLUS_PENDING_RECEIPT');
            currentAttribute.put('currentOwner', devices[i].get('owner'));
            currentAttribute.put('versionNumber',1.0);
            
            serialKey.put('serialNumber',devices[i].get('serialNumber'));
            serialKey.put('gpn',devices[i].get('gpn'));
            deviceOwnershipNode.put('serialKey', serialKey);
            deviceOwnershipNode.put('currentAttribute', currentAttribute);

            updateRequest.put('deviceOwnership', deviceOwnershipNode);
            updateRequest.put('updateMask', getUpdateMask());

            objList.add(updateRequest);
        }

        inputBody.put('updateRequest', objList);

        HttpResponse res = CreateAndSendPostRequest(
            'callout:BatchUpdateDevice', 
            JSON.serialize(inputBody));

        Map<String,Object> updateDeviceResponse = (Map<String,Object>) 
        JSON.deserializeUntyped(res.getBody());
        if(!String.isBlank(res.getBody())){
            return res.getBody();
        }
        return null;
    }
 
    //Technician Accepts devices
    @AuraEnabled
    public static string acceptDevices(List<Map<String, String>> devices){

        Map<String, List<Object>> inputBody = new Map<String, List<Object>>();
        List<Object> objList = new List<Object>();

        for(Integer i = 0; i < devices.size();i++)
        {
            Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
            Map<String, Object> serialKey = new Map<String, Object>();
            Map<String, Object> currentAttribute = new Map<String, Object>();
            Map<String, Object> updateRequest = new Map<String, Object>();
    
        
            currentAttribute.put('ownershipStatus', 'ACKNOWLEDGED');
            currentAttribute.put('currentOwner', devices[i].get('owner'));
            currentAttribute.put('versionNumber',1.0);
    
            currentAttribute.put('transactionType', 'ACCEPT_SPARE');
            serialKey.put('serialNumber',devices[i].get('serialNumber'));
            serialKey.put('gpn',devices[i].get('gpn'));
            deviceOwnershipNode.put('serialKey', serialKey);
            deviceOwnershipNode.put('currentAttribute', currentAttribute);
    
            updateRequest.put('deviceOwnership', deviceOwnershipNode);
            updateRequest.put('updateMask', getUpdateMask());
    
            objList.add(updateRequest);
        }
        
        inputBody.put('updateRequest', objList);

        HttpResponse res = CreateAndSendPostRequest(
            'callout:BatchUpdateDevice', 
            JSON.serialize(inputBody));
        Map<String,Object> updateDeviceResponse = (Map<String,Object>) 
        JSON.deserializeUntyped(res.getBody());
        if(!String.isBlank(res.getBody())){
            return res.getBody();
        }
        return null;
    }

    //Technician Rejects devices
    @AuraEnabled
    public static string rejectselectedDevices(List<Map<String, String>> devices){

        Map<String, List<Object>> inputBody = new Map<String, List<Object>>();
        List<Object> objList = new List<Object>();

        for(Integer i = 0; i < devices.size();i++)
        {
            Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
            Map<String, Object> serialKey = new Map<String, Object>();
            Map<String, Object> currentAttribute = new Map<String, Object>();
            Map<String, Object> updateRequest = new Map<String, Object>();
        
            currentAttribute.put('ownershipStatus', 'ACKNOWLEDGED');
            currentAttribute.put('currentOwner', devices[i].get('owner'));
            currentAttribute.put('versionNumber',1.0);

            currentAttribute.put('transactionType', 'TRANSFER_REJECT');
            serialKey.put('serialNumber',devices[i].get('serialNumber'));
            serialKey.put('gpn',devices[i].get('gpn'));
            deviceOwnershipNode.put('serialKey', serialKey);
            deviceOwnershipNode.put('currentAttribute', currentAttribute);
            updateRequest.put('deviceOwnership', deviceOwnershipNode);
            updateRequest.put('updateMask', getUpdateMask());

            objList.add(updateRequest);
        }
        
        inputBody.put('updateRequest', objList);

        HttpResponse res = CreateAndSendPostRequest(
            'callout:BatchUpdateDevice', 
            JSON.serialize(inputBody));

        Map<String,Object> updateDeviceResponse = (Map<String,Object>) 
        JSON.deserializeUntyped(res.getBody());
        if(!String.isBlank(res.getBody())){
            return res.getBody();
        }
        return null;
    }

    @AuraEnabled
    public static string techTransfer(List<Map<String, String>> devices, String newOwner){
        Map<String, List<Object>> inputBody = new Map<String, List<Object>>();
        List<Object> objList = new List<Object>();

        for(Integer i = 0; i < devices.size();i++)
        {
            Map<String, Object> deviceOwnershipNode = new Map<String, Object>();
            Map<String, Object> serialKey = new Map<String, Object>();
            Map<String, Object> currentAttribute = new Map<String, Object>();
            Map<String, Object> updateRequest = new Map<String, Object>();

            currentAttribute.put('ownershipStatus', 'PRE_TRANSFER');
            currentAttribute.put('newOwner',newOwner);
            currentAttribute.put('currentOwner', devices[i].get('owner'));
            currentAttribute.put('transactionType','TRANSFER');
            currentAttribute.put('versionNumber', 1.0);

            serialKey.put('serialNumber',devices[i].get('serialNumber'));
            serialKey.put('gpn',devices[i].get('gpn'));
            deviceOwnershipNode.put('serialKey', serialKey);
            deviceOwnershipNode.put('currentAttribute', currentAttribute);
            updateRequest.put('deviceOwnership', deviceOwnershipNode);
            updateRequest.put('updateMask', getUpdateMask());

            objList.add(updateRequest);
        }

        inputBody.put('updateRequest', objList);

        HttpResponse res = CreateAndSendPostRequest(
            'callout:BatchUpdateDevice', 
            JSON.serialize(inputBody));

        Map<String,Object> updateDeviceResponse = (Map<String,Object>) 
        JSON.deserializeUntyped(res.getBody());
        if(!String.isBlank(res.getBody())){
            return res.getBody();
        }
        return null;
    } 

    private static HttpResponse CreateAndSendPostRequest(string endpoint, string inputBody)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/JSON;charset=UTF-8');
        req.setBody(inputBody);
        
        Http http = new Http();
        return http.send(req);
    }

    private static string getUpdateMask()
    {
        return
        'deviceOwnership.currentAttribute.versionNumber,' +
        'deviceOwnership.currentAttribute.ownershipStatus,' +
        'deviceOwnership.currentAttribute.transactionType,' +
        'deviceOwnership.currentAttribute.commitTime,' +
        'deviceOwnership.currentAttribute.user,' +
        'deviceOwnership.currentAttribute.currentOwner,' +
        'deviceOwnership.currentAttribute.newOwner,' +
        'deviceOwnership.currentAttribute.googleLocationCode,' +
        'deviceOwnership.currentAttribute.assignedToAccount,' +
        'deviceOwnership.currentAttribute.externalReferences,' +
        'deviceOwnership.currentAttribute.defectReason,' +
        'deviceOwnership.currentAttribute.comments,' +
        'deviceOwnership.currentAttribute.deviceStatus';
    }
}