trigger cloudNewPlatformEventHandler  on Cloud_News__e (after insert) {
    // Iterate through each notification.
    for (Cloud_News__e event : Trigger.New) {
       System.debug('received platform event at location: '+event.Location__c);
       System.debug('current executing user is: '+UserInfo.getUserName());
       System.debug('current executing user type is: '+UserInfo.getUserType());
   }
}