/***
*
*Context rules for products
*
*/
global inherited sharing class CtxRulesProductsOpenImplementation implements VlocityOpenInterface
{

    global CtxRulesProductsOpenImplementation()
    {

    }
    /**
    * @description  entry method to interface based on methodName. <br>
    *return Boolean
    */
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outputMap, Map<String,Object> options)
    {
        Boolean success = true;
        try
        {
            if (outputMap == null)
            {
                outputMap = new Map<String, Object>();
            }
            if (methodName == 'getAvailableProducts')
            {
                doEligibleProducts(inputMap, outputMap, options);
            }
        }
        catch(Exception e)
        {
            success = false;
            outputMap.put('error', e.getMessage());
        }
        return success;
    }

    @TestVisible
    global void doEligibleProducts(Map<String,Object> inputMap, Map<String,Object> outputMap, Map<String,Object> optionsMap)
    {

        //introduce setting the context of the user here:
        Map<String, Object> ctxSvcinput = new Map<String,Object>();
        Map<String, Object> ctxSvcoption = new Map<String,Object>();
        Map<String, Object> ctxSvcoutput = new Map<String,Object>();
        Logger.dbg('Setting  params for context service');
        String sUserId = UserInfo.getUserId();
        Logger.dbg('User Id is '+ sUserId);

        List<SObject> unqualList = new List<SObject>();

        String mthName = 'handleMessage';
        String orderId = (String)inputMap.get('ObjectId');
        ctxSvcinput.put('OrderId', orderId);

        ctxSvcinput.put('UserId', sUserId);

        ctxSvcoption.put(EventMessage.EVENT_NAME, 'pushevent'); //   eventname : "Pop"

        ctxSvcoption.put(EventMessage.EVENT_TYPE, 'Context');


        Map<String,Object>   eventArgs = new Map<String,Object> ();


        eventArgs.put(EventMessage.EVENT_CTX_KEY , sUserId); // set CtxKeyId to identify the appContext. this could be Userid or interactionId

        eventArgs.put(EventMessage.EVENT_SCOPE, 'Login'); // scope :  Login

        eventArgs.put(EventMessage.EVENT_STAGE, 'PriceList');
        eventArgs.put('ObjectId', orderId);

        ctxSvcinput.put(EventMessage.EVENT_ARGS, eventArgs);

        ContextService ctxSvc = new ContextService();
        Boolean res = ctxSvc.invokeMethod(EventService.HANDLE_EVENT_METHODNAME,ctxSvcinput,ctxSvcoutput, ctxSvcoption);
        Logger.dbg('the result from Context Service is '+ res);
        List<PriceBookEntry> prodList = (List<PriceBookEntry>)inputMap.get('ObjectList');
        List<PriceBookEntry> passList = prodList.clone();
        Map<ID, PriceBookEntry> IdObjectMap = new  Map<ID, PriceBookEntry>();
        List<Id> idList = new List<Id>();
        for(PriceBookEntry prod : prodList)
        {
            idList.add(prod.Product2Id);
            IdObjectMap.put(prod.Product2Id, prod);
        }

        String val;
        AppContext appCtx = AppContext.get(sUserId);
        //ContextRuleService ctxRuleSvc = new ContextRuleService();
        Map<String, Object> inputs = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> outputs = new Map<String,Object>();
        String NSP  = ApplicationUtilities.getNameSpacePrefix();
        inputs.put('ContextKey', sUserId);
        inputs.put('ObjectList', idList);
        inputs.put('enableRuleMessageService', inputMap.get('enableRuleMessageService'));
        options.put('orderBy', 'Name');
        options.put('whereClause', NSP+'IsActive__c = true');
        if(optionsMap != null && optionsMap.containsKey('RuleType'))
        {
            options.put('RuleType', optionsMap.get('RuleType'));
        }
        //Boolean ruleRes = ctxRuleSvc.getQualified(inputs, outputs, options);
        InvokeService.invokeOpenImplementation( 'ContextRuleService', 'getQualified', inputs, outputs, options   )  ;
        List<ID> qualList = (List<ID>)outputs.get('PassIdList');
        Set<ID>  qualSet = new Set<ID>(qualList);
        Logger.dbg('Qualified List is ' + qualList);
        Map<Id, Boolean> ObjRuleMap =  (Map<Id, Boolean>)outputs.get('RuleExistsMap');


        for (Integer i = passList.size() - 1; i >= 0 ; --i)
        {     //disqualify the object only if ruleset exists for it
            if (!qualSet.contains(passList.get(i).Product2Id) && ObjRuleMap.containsKey(passList.get(i).Product2Id) && ObjRuleMap.get(passList.get(i).Product2Id))
            {
                passList.remove(i);
            }
        }

        Logger.dbg('the pass list is now '+ passList);
        List<Map<String,Object>> passObjectList = new List<Map<String,Object>>();
        for(PriceBookEntry pass : passList)
        {
            Map<String, Object> passObject = new Map<String, Object>();
            passObject.put('PriceBookEntry', pass);
            passObjectList.add(passObject);
        }
        outputMap.put('PassList', passObjectList);

        List<Map<String,Object>> hardFailList = (List<Map<String,Object>>)outputs.get('HardFailList');
        List<Map<String,Object>> hardFailObjectList = new List<Map<String,Object>>();
        for(Map<String, Object> hardFail : hardFailList)
        {
            Id prodId = (Id)hardFail.get('objectId');
            Map<String, Object> hardFailObject = new Map<String, Object>();
            hardFailObject.put('PriceBookEntry', IdObjectMap.get(prodId));
            hardFailObject.put('Message', hardFail.get('Message'));
            hardFailObject.put('messageList', hardFail.get('messageList'));
            hardFailObject.put('failType', hardFail.get('failType'));
            hardFailObject.put('rulesetIdList',hardFail.get('rulesetIdList'));
            hardFailObject.put('rulesetMessages',hardFail.get('rulesetMessages'));
            hardFailObjectList.add(hardFailObject);
        }
        outputMap.put('HardFailList', hardFailObjectList);

        List<Map<String,Object>> softFailList = (List<Map<String,Object>>)outputs.get('SoftFailList');
        List<Map<String,Object>> softFailObjectList = new List<Map<String,Object>>();
        for(Map<String, Object> softFail : softFailList)
        {
            Id prodId = (Id) softFail.get('objectId');
            Map<String, Object> softFailObject = new Map<String, Object>();
            softFailObject.put('PriceBookEntry', IdObjectMap.get(prodId));
            softFailObject.put('Message', softFail.get('Message'));
            softFailObject.put('messageList', softFail.get('messageList'));
            softFailObject.put('failType', softFail.get('failType'));
            softFailObject.put('rulesetIdList',softFail.get('rulesetIdList'));
            softFailObject.put('rulesetMessages',softFail.get('rulesetMessages'));
            softFailObjectList.add(softFailObject);
        }
        outputMap.put('SoftFailList', softFailObjectList);


        List<Map<String,Object>> softPassList = (List<Map<String,Object>>)outputs.get('SoftPassList');
        List<Map<String,Object>> softPassObjectList = new List<Map<String,Object>>();
        for(Map<String, Object> softPass : softPassList)
        {
            Id prodId = (Id)softPass.get('objectId');
            Map<String, Object> softPassObject = new Map<String, Object>();
            softPassObject.put('PriceBookEntry', IdObjectMap.get(prodId));
            softPassObject.put('Message', softPass.get('Message'));
            softPassObject.put('messageList', softPass.get('messageList'));
            softPassObject.put('failType', softPass.get('failType'));
            softPassObject.put('rulesetIdList',softPass.get('rulesetIdList'));
            softPassObject.put('rulesetMessages',softPass.get('rulesetMessages'));
            softPassObjectList.add(softPassObject);
        }
        outputMap.put('SoftPassList', softPassObjectList);
    }
}