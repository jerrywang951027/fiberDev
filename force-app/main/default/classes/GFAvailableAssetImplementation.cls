public with sharing class GFAvailableAssetImplementation implements vlocity_cmt.VlocityOpenInterface, Callable {

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
			System.debug('Inside checkAvailableAssets');
			String elemName  = (String)options.get('JSON Node'); // Json Node
			String allAssets = (String)options.get('Elem Name');
      		if ((allAssets == null) || String.isEmpty(allAssets))
       			 throw new MyException('vlocity_cmt.Label.MACDMoveElemError');
       		if ((elemName == null) || String.isEmpty(elemName))
       			 throw new MyException('vlocity_cmt.Label.MACDMoveJSONError');
			List<Object> assetList = (List<Object>)inputMap.get(allAssets);
			Id orderId = (Id)inputMap.get('OrderId');
			if ((orderId == null))
       			 throw new MyException('Label.MACDMoveOrderError');
			List<Id> assetIdList = new List<Id>();
			if(assetList != null) {
				for(Object obj : assetList){
					Map<String, Object> asst = (Map<String, Object>)obj;
					assetIdList.add((Id)asst.get('Id'));
				}
			}
			Sobject parentItem = getParentItem(orderId);
			List<Asset> astList  = [SELECT Id, vlocity_cmt__PricebookEntryId__c FROM Asset WHERE Id IN :assetIdList];
			List<Id> pbeList = new List<Id>();
			Map<Id, Set<Id>> assetIdToPbeMap = new Map<Id, Set<Id>>();
			if(astList.size() == 0)
			{
				throw new MyException('Label.MACDMoveAssetError');
			}
			for(Asset ast : astList) {
				Id pbeIdAst = (Id)ast.get('vlocity_cmt__PricebookEntryId__c');
				pbeList.add(pbeIdAst);
				Set<Id> astIdSet;
				if(assetIdToPbeMap.keySet().contains(pbeIdAst))
					astIdSet = assetIdToPbeMap.get(pbeIdAst);
				else
					astIdSet = new Set<Id>();
				astIdSet.add((Id)ast.get('Id'));
				assetIdToPbeMap.put((Id)ast.get('vlocity_cmt__PricebookEntryId__c'), astIdSet);
			}
			if(pbeList.size() == 0)
				throw new MyException('Label.MACDMovePricebookEntryError');
			List<PricebookEntry> pricebookEntryList = getAllPricebookEntries(pbeList);
			//String productAvil = vlocity_cmt.CustomSettingsUtilities.getCustomClassImplemenationName('ProductAvailability');
            String productAvil = 'vlocity_cmt2.DefaultProductAvailabilityImplementation';
	        Type t = Type.forName(productAvil);
	        System.debug('T value:'+t);
	        vlocity_cmt.GlobalInterfaces.ProductAvailabilityInterface pai = (vlocity_cmt.GlobalInterfaces.ProductAvailabilityInterface)t.newInstance();
	        pricebookEntryList = pai.getAvailableProducts(parentItem,pricebookEntryList);

			//Run the eligibility fitlers for the parent object
	       	//String productElig = CustomSettingsUtilities.getCustomClassImplemenationName('ProductEligibility');
               String productElig = 'vlocity_cmt2.DefaultProductEligibilityImplementation';
	        Type et = Type.forName(productElig);
	        System.debug('Finished Available products query');
	        vlocity_cmt.GlobalInterfaces.ProductEligibilityInterface pei = (vlocity_cmt.GlobalInterfaces.ProductEligibilityInterface)et.newInstance();
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
					asst.put('Available', 'Not Available');
					lineNumString.add((String)asst.get('LineNumber'));
				}
				else
					asst.put('Available', 'Available');
			}

			for(Object obj : assetList){
				Map<String, Object> asst = (Map<String, Object>)obj;
				for(String lineNum : lineNumString) {
					if(((String)asst.get('LineNumber')).startsWith(lineNum)) {
						asst.put('Available', 'Not Available');
					}
				}
			}

			outputMap.put(elemName, assetList);
		}catch(Exception e)
	    {
        	System.debug(e);
    		throw e;
	    }
	}

	private SObject getParentItem(Id objId)
    {
        System.debug('getParentItem');
        SObjectType objectType = objId.getSobjectType();
        Set<String> ignoredColumns = new Set<String>{ 'IsDeleted','CreatedDate','CreatedById','LastModifiedDate','LastModifiedById','SystemModstamp','LastActivityDate','CleanStatus' };

        String query = 'Select ';
        Boolean firstField = true;
        //for (Schema.SObjectField field : vlocity_cmt.ObjectDescriber.getDescribe(objectType).getFields().values())
        for (Schema.SObjectField field : objectType.getDescribe().fields.getMap().values())
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

    public class MyException extends Exception {}

}