List<Id> productIds = new List<Id>();

for (Product2 prod : [ Select Id from Product2 where vlocity_cmt__ObjectTypeId__c != null AND Id='01t5f000003LDZcAAO'])
{
      productIds.add(prod.Id);
}
Database.executeBatch(new vlocity_cmt.EPCProductAttribJSONBatchJob(productIds), 1);