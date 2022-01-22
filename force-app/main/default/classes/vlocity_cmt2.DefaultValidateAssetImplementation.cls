public inherited sharing class DefaultValidateAssetImplementation implements VlocityOpenInterface, Callable
{
	static final String selectedAssetsDelem = ':';
  	public static final String selectedAssetsKey = 'jsonPath';
	    
    public Object call(String action, Map<String, Object> args) 
    {
        Map<String,Object> inputMap = (Map<String,Object>)args.get('input');
        Map<String,Object> outputMap = (Map<String,Object>)args.get('output');
        Map<String,Object> options = (Map<String,Object>)args.get('options');
        
        return invokeMethod(action, inputMap, outputMap, options);
    }
    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)	{

		if (methodName.equals('validateSelectedAsset')) {
			validateSelectedAsset(input, output, options);
		}

		return false;
	}

	private void validateSelectedAsset(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
		try{
			Logger.err('Inside validateSelectedAsset');
			String elemName  = (String)options.get('JSON Node'); // Json Node
			String allAssets = (String)options.get('Elem Name');
			if ((allAssets == null) || String.isEmpty(allAssets))
       			 throw new OmniCPQServiceException('getAssets method call should have an option Elem Name');
       		if ((elemName == null) || String.isEmpty(elemName))
       			 throw new OmniCPQServiceException('getAssets method call should have an option JSON Node');
			Object tempPath = options.get(selectedAssetsKey);
      		if(tempPath == null)
        		throw new OmniCPQServiceException('Invalid key given for Asset Selection');

		    List<String> selectedAssetsPath = ((String) tempPath).split(selectedAssetsDelem);
		    Map<String, Object> obMap = (Map<String, Object>)inputMap.get(selectedAssetsPath[0].trim());
		    List<Object> selectedAssets = (List<Object>)obMap.get(selectedAssetsPath[1].trim());
		    List<String> notAvailableList = new List<String>();
		    List<LineItemWrapper> lineItems = new List<LineItemWrapper>();
		    Boolean allAvailable = true;
			for(Object obj : selectedAssets) {
				Map<String, Object> objMap = (Map<String, Object>)obj;
				if(objMap != null) {
					String availCheck = (String)objMap.get('Available');
					if(availCheck == null || !availCheck.equals('Not Available')) {
						LineItemWrapper lw = new LineItemWrapper(obj, 'Ascending');
						lineItems.add(lw);
					}else{
						if(availCheck != null && availCheck.equals('Not Available')) {
							allAvailable = false;
							String lineNum = (String)objMap.get('LineNumber');
							notAvailableList.add(lineNum);
						}
					}
				}
			}

			lineItems.sort();
			selectedAssets.clear();

			//Removing children for all products which are not available
			for(LineItemWrapper lw : lineItems) {
				Boolean flag = false;
				Object obj = lw.objItem;
				Map<String, Object> objMap = (Map<String, Object>)obj;
				String lineNum = (String)objMap.get('LineNumber');
				for(String str : notAvailableList){
					if(lineNum.startsWith(str)) {
						flag = true;
						break;
					}
				}
				if(!flag)
					selectedAssets.add(obj);
			}
			outputMap.put(elemName,selectedAssets);
			outputMap.put('allAvailable', allAvailable);
			outputMap.put('showAssetList', true);

		}catch(Exception e)
	    {
        	Logger.err(e);
    		throw e;
	    }
	}

}