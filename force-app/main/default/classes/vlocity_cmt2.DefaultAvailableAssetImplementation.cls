public inherited sharing class DefaultAvailableAssetImplementation implements VlocityOpenInterface, Callable
{

    public Object call(String action, Map<String, Object> args) 
    {
        Map<String,Object> inputMap = (Map<String,Object>)args.get('input');
        Map<String,Object> outputMap = (Map<String,Object>)args.get('output');
        Map<String,Object> options = (Map<String,Object>)args.get('options');
        
        return invokeMethod(action, inputMap, outputMap, options);
    }
    
	public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)	{

		if (methodName.equals('checkAvailableAssets')) {
			checkAvailableAssets(input, output, options);
		}

		return false;
	}

	private void checkAvailableAssets(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
		try{
			Logger.err('Inside checkAvailableAssets');
			String elemName  = (String)options.get('JSON Node'); // Json Node
			String allAssets = (String)options.get('Elem Name');
      		if ((allAssets == null) || String.isEmpty(allAssets))
       			 throw new OmniCPQServiceException(Label.MACDMoveElemError);
       		if ((elemName == null) || String.isEmpty(elemName))
       			 throw new OmniCPQServiceException(Label.MACDMoveJSONError);
			List<Object> assetList = (List<Object>)inputMap.get(allAssets);
			Id orderId = (Id)inputMap.get('OrderId');
			if ((orderId == null))
       			 throw new OmniCPQServiceException(Label.MACDMoveOrderError);
			List<Id> assetIdList = new List<Id>();
			if(assetList != null) {
				for(Object obj : assetList){
					Map<String, Object> asst = (Map<String, Object>)obj;
					assetIdList.add((Id)asst.get('Id'));
				}
			}
			Sobject parentItem = getParentItem(orderId);
			List<Asset> astList  = [SELECT Id, PricebookEntryId__c FROM Asset WHERE Id IN :assetIdList];
			List<Id> pbeList = new List<Id>();
			Map<Id, Set<Id>> assetIdToPbeMap = new Map<Id, Set<Id>>();
			if(astList.size() == 0)
			{
				throw new OmniCPQServiceException(Label.MACDMoveAssetError);
			}
			for(Asset ast : astList) {
				Id pbeIdAst = (Id)ast.get('PricebookEntryId__c');
				pbeList.add(pbeIdAst);
				Set<Id> astIdSet;
				if(assetIdToPbeMap.keySet().contains(pbeIdAst))
					astIdSet = assetIdToPbeMap.get(pbeIdAst);
				else
					astIdSet = new Set<Id>();
				astIdSet.add((Id)ast.get('Id'));
				assetIdToPbeMap.put((Id)ast.get('PricebookEntryId__c'), astIdSet);
			}
			if(pbeList.size() == 0)
				throw new OmniCPQServiceException(Label.MACDMovePricebookEntryError);
			List<PricebookEntry> pricebookEntryList = getAllPricebookEntries(pbeList);
			String productAvil = CustomSettingsUtilities.getCustomClassImplemenationName('ProductAvailability');
	        Type t = Type.forName(productAvil);
	        Logger.dbg('T value:'+t);
	        GlobalInterfaces.ProductAvailabilityInterface pai = (GlobalInterfaces.ProductAvailabilityInterface)t.newInstance();
	        pricebookEntryList = pai.getAvailableProducts(parentItem,pricebookEntryList);

			//Run the eligibility fitlers for the parent object
	       	String productElig = CustomSettingsUtilities.getCustomClassImplemenationName('ProductEligibility');
	        Type et = Type.forName(productElig);
	        Logger.dbg('Finished Available products query');
	        GlobalInterfaces.ProductEligibilityInterface pei = (GlobalInterfaces.ProductEligibilityInterface)et.newInstance();
	        priceBookEntryList = pei.getEligibleProducts(parentItem, pricebookEntryList);
	        Set<Id> pbeIdList = new Set<Id>();
	        for(PricebookEntry pbe : pricebookEntryList) {
	        	pbeIdList.add((Id)pbe.get('Id'));
	        }

	        Set<Id> availableAssetIds = new Set<Id>();
	        for(Id pbeId : assetIdToPbeMap.keySet()){
	        	if(pbeIdList.contains(pbeId))
	        		availableAssetIds.addAll((Set<Id>)assetIdToPbeMap.get(pbeId));
	        }

	        Set<String> lineNumString = new Set<String>();
	        for(Object obj : assetList){
				Map<String, Object> asst = (Map<String, Object>)obj;
				if(!availableAssetIds.contains((Id)asst.get('Id'))) {
					asst.put('Availability', 'Not Available');
					lineNumString.add((String)asst.get('LineNumber'));
				}
				else
					asst.put('Availability', 'Available');
			}

			for(Object obj : assetList){
				Map<String, Object> asst = (Map<String, Object>)obj;
				for(String lineNum : lineNumString) {
					if(((String)asst.get('LineNumber')).startsWith(lineNum)) {
						asst.put('Availability', 'Not Available');
					}
				}
			}

			outputMap.put(elemName, assetList);
		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}

	private SObject getParentItem(Id objId)
    {
        Logger.err('getParentItem');
        SObjectType objectType = objId.getSobjectType();
        Set<String> ignoredColumns = new Set<String>{ 'IsDeleted','CreatedDate','CreatedById','LastModifiedDate','LastModifiedById','SystemModstamp','LastActivityDate','CleanStatus' };

        String query = 'Select ';
        Boolean firstField = true;
        for (Schema.SObjectField field : ObjectDescriber.getDescribe(objectType).getFields().values())
        {
            if (!ignoredColumns.contains(String.valueOf(field)))
            {
                if (!firstField)
                {
                    query += ',';
                }

                query += String.valueOf(field);

                firstField = false;
            }
        }

        query += ' FROM ' + objectType;
        query += ' WHERE Id = \'' + objId + '\'';
        query += ' LIMIT ' + 1;

        return Database.query(query);
    }

    private List<PricebookEntry> getAllPricebookEntries(List<Id> pbeList){
		String query = 'Select Id, Pricebook2Id, Product2Id, ProductCode,Product2.Description, UnitPrice,Name,Product2.Name, Product2.JSONAttribute__c,Product2.IsConfigurable__c,Product2.Type__c,Product2.SubType__c,RecurringPrice__c,IsActive from PricebookEntry where  (IsActive = true) AND (Product2.recordTypeId = null OR Product2.recordType.DeveloperName = \'Product\')';
		if(pbeList != null && pbeList.size() > 0) {
			query += ' AND Id IN :pbeList';
		}
		List<PricebookEntry> pbList = Database.query(query);
		return pbList;
	}


}