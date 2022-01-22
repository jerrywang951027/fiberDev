// Create an instance of the event and store it in the newsEvent variable
Cloud_News__e newsEvent = new Cloud_News__e(
           Location__c='Toronto');
// Call method to publish events
Database.SaveResult sr = EventBus.publish(newsEvent);
// Inspect publishing result
if (sr.isSuccess()) {
    System.debug('Successfully published event.');
} else {
    for(Database.Error err : sr.getErrors()) {
        System.debug('Error returned: ' +
                     err.getStatusCode() +
                     ' - ' +
                     err.getMessage());
    }
}