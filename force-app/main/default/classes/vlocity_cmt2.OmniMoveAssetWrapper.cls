global inherited sharing class OmniMoveAssetWrapper implements VlocityOpenInterface2, Callable
{
    
    public Object call(String action, Map<String, Object> args) 
    {
        Map<String,Object> inputMap = (Map<String,Object>)args.get('input');
        Map<String,Object> outputMap = (Map<String,Object>)args.get('output');
        Map<String,Object> options = (Map<String,Object>)args.get('options');
        
        return invokeMethod(action, inputMap, outputMap, options);
    }
    
	global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)	{

		if (methodName.equals('getAssets')) {
			getSelectedAssets(input, output, options);
		}

		if (methodName.equals('getAccountIds')) {
			getAccountIds(input, output, options);
		}

		if (methodName.equals('moveAssets')) {
			moveAssets(input, output, options);
		}

		if (methodName.equals('moveNewAssets'))
		{
			moveNewAssets(input, output, options);
		}

		if (methodName.equals('checkAvailableAssets')) {
			checkAvailableAssets(input, output, options);

		}

		if (methodName.equals('createOrder')) {
			createOrder(input, output, options);
		}

		if (methodName.equals('validateSelectedAsset')) {
			validateSelectedAsset(input, output, options);
		}

		return false;
	}

	private void getAccountIds(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		try{
			Logger.err('Inside getAccountIds');
			String contextId = (String)inputMap.get('ContextId');
			Id moveOutId, moveInId;
			if(contextId.contains('+')){
				List<String> idList = contextId.split('\\+');
				moveOutId = Id.valueOf(idList[0]);
				moveInId = Id.valueOf(idList[1]);
				if(moveOutId.getSObjectType() == Asset.SObjectType) {
					outputMap.put('showAssetList', true);
					outputMap.put('assetId', moveOutId);
					Id moveOutAccountId = [SELECT ServiceAccountId__c FROM Asset WHERE Id = :moveOutId].ServiceAccountId__c;
					outputMap.put('moveOutAccountId', moveOutAccountId);
				}else{
					outputMap.put('moveOutAccountId', moveOutId);
				}
				outputMap.put('moveInAccountId', moveInId);
				outputMap.put('ContextId', moveInId);
				System.debug('outputMap is :: '+outputMap);
			}
		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}

	private void createOrder(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		try{
			Logger.err('Inside createOrder'+inputMap);
			Id moveInId  = (Id)inputMap.get('moveInAccountId');
			Id parentAccId = [SELECT parentId FROM Account WHERE Id = :moveInId].parentId;
			if(parentAccId != null)
				inputMap.put('ContextId', parentAccId);
			else
				inputMap.put('ContextId', moveInId);
			inputMap.put('parAccountId', parentAccId);
			OmniCPQServiceWrapper omniCpqWrap = new OmniCPQServiceWrapper();
			Logger.err('Before createOrder'+inputMap);
			omniCpqWrap.invokeMethod('createOrder',inputMap,outputMap,options);
		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}

	private void checkAvailableAssets(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		try{
			Logger.err('Inside checkAvailableAssets');
			String moveAsset = CustomSettingsUtilities.getCustomClassImplemenationName('AvailableAsset');
	        Type t = Type.forName(moveAsset);
	        VlocityOpenInterface moveAssetImp = (VlocityOpenInterface)t.newInstance();
	        String methodName = 'checkAvailableAssets';
	        moveAssetImp.invokeMethod(methodName,inputMap, outputMap, options);
		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}

	private void getSelectedAssets(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		try{
			Logger.error('Inside getSelectedAssets');
			String moveAsset = CustomSettingsUtilities.getCustomClassImplemenationName('RetrieveAsset');
	        Type t = Type.forName(moveAsset);
	        VlocityOpenInterface moveAssetImp = (VlocityOpenInterface)t.newInstance();
	        String methodName = 'getAssets';
	        moveAssetImp.invokeMethod(methodName,inputMap, outputMap, options);
	        String localeCode = UserInfo.getLocale();
	        List<String> assetList = new List<String>();
	        List<Object> assetObjectList = (List<Object>)outputMap.get('AllAssets');
	        List<Map<String, Object>> assetsMapList = new List<Map<String, Object>>();
	        Map<String, String> fieldIdToLabel = getAssetFldIdToLabel();
	        String nsPrefix = ApplicationUtilities.getNameSpacePrefix();
	        String assetNameFldLabel = fieldIdToLabel.get('Name');
	        String quantityFldLabel = fieldIdToLabel.get('Quantity');
	        String oneTimeTotalFldLabel = fieldIdToLabel.get(nsPrefix + 'OneTimeTotal__c');
	        String recurringTotalFldLabel = fieldIdToLabel.get(nsPrefix + 'RecurringTotal__c');
	        String provStatusFldLabel = fieldIdToLabel.get(nsPrefix + 'ProvisioningStatus__c');
	        for (Object o : assetObjectList){
				Map<String, Object> aMap = (Map<String, Object>)o;
				assetsMapList.add(aMap);
				String assetName = (String)aMap.get(assetNameFldLabel);
				// If Quantity is not returend, it means the field is stored under its translated label name.
				// So, store it under 'Quantity' field so UI can identify and display the field.
				if (!aMap.containsKey('Quantity')) {
					aMap.put('Quantity', aMap.get(quantityFldLabel));
				}
				if (!aMap.containsKey('Recurring Total')) {
					aMap.put('Recurring Total', aMap.get(recurringTotalFldLabel));
				}
				if (!aMap.containsKey('One Time Total')) {
					aMap.put('One Time Total', aMap.get(oneTimeTotalFldLabel));
				}
				if (!aMap.containsKey('Provisioning Status')) {
					aMap.put('Provisioning Status', aMap.get(provStatusFldLabel));
				}
				assetList.add(assetName);
	        }
	        Boolean isMLSEnabled = TranslationUtility.isMLSFeatureEnabled();
			if (isMLSEnabled){
				Map<String, String> transMap = getAssetNameTranslations(localeCode, assetList);
				for (Map<String, Object> aMap : assetsMapList){
					String translation = transMap.get((String)aMap.get(assetNameFldLabel));
					if (!String.isEmpty(translation)){
						aMap.put('Asset Name', (Object)translation);
					}
				}
				outputMap.put('AllAssets', (Object)assetsMapList);
			}
		}catch(Exception e)
	    {
			Logger.error(e);
    		throw e;
	    }
	}

	private void validateSelectedAsset(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		try{
			Logger.err('Inside validateSelectedAsset');
			String moveAsset = CustomSettingsUtilities.getCustomClassImplemenationName('ValidateAsset');
	        Type t = Type.forName(moveAsset);
	        VlocityOpenInterface moveAssetImp = (VlocityOpenInterface)t.newInstance();
	        String methodName = 'validateSelectedAsset';
	        moveAssetImp.invokeMethod(methodName,inputMap, outputMap, options);
		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}



	private void moveAssets(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		try{
			String moveAsset = CustomSettingsUtilities.getCustomClassImplemenationName('MoveAsset');
	        Type t = Type.forName(moveAsset);
	        VlocityOpenInterface moveAssetImp = (VlocityOpenInterface)t.newInstance();
	        String methodName = 'moveAssets';
	        //CMT-1162, fill the root acc id for the moveIdAccountId as this is the accountId of the asset being copied for the orderItem
	        Id moveInId  = (Id)inputMap.get('moveInAccountId');
	        Id parentAccId = [SELECT RootAccountId__c FROM Account WHERE Id = :moveInId].RootAccountId__c;
	        inputMap.put('parAccountId', parentAccId);
	        moveAssetImp.invokeMethod(methodName,inputMap, outputMap, options);
		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}

	private void moveNewAssets(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
		try{
			String moveAsset = CustomSettingsUtilities.getCustomClassImplemenationName('MoveAsset');
	        Type t = Type.forName(moveAsset);
	        VlocityOpenInterface moveAssetImp = (VlocityOpenInterface)t.newInstance();
	        String methodName = 'moveNewAssets';
	        //CMT-1162, fill the root acc id for the moveIdAccountId as this is the accountId of the asset being copied for the orderItem
	        Id moveInId  = (Id)inputMap.get('moveInAccountId');
	        Id parentAccId = [SELECT RootAccountId__c FROM Account WHERE Id = :moveInId].RootAccountId__c;
	        inputMap.put('parAccountId', parentAccId);
	        moveAssetImp.invokeMethod(methodName,inputMap, outputMap, options);
		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}

	private Map<String, String> getAssetNameTranslations(String localeCode, List<String> assetNames){
		List<String> assetNameHash = new List<String>();
		List<String> assetNameList = new List<String>();
		List<StringTranslation__c> translationList = new List<StringTranslation__c>();
		Map<String, String> assetNameTranslationMap = new Map<String, String>();
		for (String s : assetNames){
			if (s.length() > 80){
				assetNameHash.add(TranslationUtility.getMD5HashOfString(s));
			}
			else{
				assetNameList.add(s);
			}
		}
		Logger.debug('assetNameHash : ' + assetNameHash);
		translationList = [Select Translation__c, StringId__r.BaseString__c
                           From StringTranslation__c Where (StringId__r.BaseStringHash__c in: assetNameHash or StringId__r.Name in: assetNameList)
                           and LocaleCode__c =: localeCode
                           and IsTranslated__c = true];

        for (StringTranslation__c st : translationList){
            String baseString = st.StringId__r.BaseString__c;
            String translatedString  = st.Translation__c;
            assetNameTranslationMap.put(baseString, translatedString);
        }
        // If translation is not found for the asset, use the same name.
        for (String oneAsset : assetNames) {
        	if (!assetNameTranslationMap.containsKey(oneAsset)) {
        		assetNameTranslationMap.put(oneAsset, oneAsset);
        	}
        }
        return assetNameTranslationMap;
	}

	/**
	* Gets Asset object's field name to Label map.
	*
	**/
	private Map<String, String> getAssetFldIdToLabel() {
		Map<String, String> fieldInfoMap = FieldSetService.getNameLabelPair(null, Asset.SObjectType);
		return fieldInfoMap;
	}
}