Id myId = '01t18000002JbiUAAS';  
String sObjName = myId.getSObjectType().getDescribe().getName();  
system.debug('Object Name for '+myId+' is ' + sObjName);

myId = 'a1u18000000kZ6PAAU';  
 sObjName = myId.getSObjectType().getDescribe().getName();  
system.debug('Object Name for '+myId+' is ' + sObjName);


myId = 'a1v18000003FVC5AAO';  
 sObjName = myId.getSObjectType().getDescribe().getName();  
system.debug('Object Name for '+myId+' is ' + sObjName);

myId = 'a2e18000000C1ZaAAK';  
 sObjName = myId.getSObjectType().getDescribe().getName();  
system.debug('Object Name for '+myId+' is ' + sObjName);