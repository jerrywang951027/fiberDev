List<vlocity_cmt__PriceListEntry__c> ple = [Select Id,name,vlocity_cmt__ProductId__c FROM vlocity_cmt__PriceListEntry__c where Id='a4J8G000000blcTUAQ'];

System.debug('name is'+ple[0].name);
ple[0].vlocity_cmt__ProductId__c = null;
update ple;