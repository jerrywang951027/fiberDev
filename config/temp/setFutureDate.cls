
vlocity_cmt__OrchestrationItem__c orchestrationItem = <find the required orchestration item>;
orchestrationItem.vlocity_cmt__ProcessAfter__c = datetime.now()+7;
update orchestrationItem;