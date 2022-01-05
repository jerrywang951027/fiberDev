/**
 * Custom Callout Task that allows for use of Integration Producedures for pre and post processing.
 *
 * Configuration of this task is using the AutotaskParemeters field (re-purposed from AutoTask). This field contains
 * a JSON where the integration procedure names can be specified.
 *
 * The following parameters are passed to the IP as input: accountId, orderId, orchestrationItemId,
 * orchestrationItemName, orchestrationPlanId.
 *
 * Example 1: this will call IPs before and after the HTTP callout is executed.
 * <code>
 * {
 *   "preInvokeIP": "Type_Subtype",
 *   "postInvokeIP: "Type_Subtype"
 * }
 * </code>
 *
 * Example 2: this will call a single IP instead of the HTTP callout
 * <code>
 * {
 *   "integrationProcedureName": "Type_Subtype"
 * }
 * </code>
 * In this case, you can also process the output of the ip by implementing extending this class and implementing
 * processResponse(ipOutput) method.
 *
 * @author Cristian Duicu
 * @date Jan 28, 2021
 */
global class OMCalloutWithIP extends vlocity_cmt.DefaultSystemInterface {

    global class DefaultInterfaceUnrecoverableException extends Exception {
    }

    // Based on https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
    public static Set<Integer> successStatusCode = new Set<Integer>{
            200, 201, 202, 203, 204, 205, 206, 302, 304
    };

    public static Set<Integer> recoverableErrorStatusCodes = new Set<Integer>{
            408, 426 /* Upgrade is required */, 500, 502, 503, 504, 440, 444, 520, 522, 523, 524, 525
    };
    public static final Integer TIMEOUT_MAX = 120000;

    /**
    * This method is a part of ISystemInterface. It is invoked at the start of the batch
    * @param url base URL the batch is started for
    * @param path path this batch is started for
    */
    global virtual override void startBatch(String url, String path) {
        super.startBatch(url, path);
    }

    /**
     * This method is called at the end of the batch
     *
     * @param url base URL for the batch
     * @param path path for the batch
     * */
    global virtual override void endBatch(String url, String path) {
        super.endBatch(url, path);
    }

    /**
     * This method is called from executeItem to process response.
     *
     * @param url base URL for the batch
     * @param path path for the batch
     * @param res HttpResponse to process
     */
    global virtual override void processResponse(String url, String path, HttpResponse res) {
        System.debug('[BaseSystemInterfaceImpl] processResponse()');
        super.processResponse(url, path, res);
    }

    /**
     * Invoked when the callout is using an IP instead of the standard HTTP integration.
     *
     * @param ipOutput the output from the integration procedure
     */
    global void processIPResponse(Map<String, Object> ipOutput) {
        // check for error
        if (ipOutput != null) {
            Map<String,Object> apiResponse = (Map<String,Object>)ipOutput.get('APIResponse');
            if (apiResponse != null) {
                if (apiResponse.get('success') == false) {
                    System.debug('IP returned error.');
                    throw new DefaultInterfaceUnrecoverableException ('IP Error: ' + apiResponse.get('reasons'));
                }
            }
        } else {
            System.debug('IP invoked successfully.');
        }
        System.debug('[BaseSystemInterfaceImpl] processIPResponse()');
    }

    /**
    * Executes a Callout OrchestrationItem
    * @param url base URL to send the request to
    * @param path path to send the request to
    * @param item OrchestrationItem that needs to be executed
    */
    global virtual override void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        Map <String, Object> input = new Map <String, Object> ();
        Map <String, Object> output = new Map <String, Object> ();
        Map <String, Object> options = new Map <String, Object> ();

        // Get the Order SObject - the technique will differ depending on if this orchestration item is related to an Order Item or a Fulfillment Request Line
        vlocity_cmt.XOMOrderDomainObject orderObj = null;
        if (item.vlocity_cmt__OrderItemId__c != null) {
            Id orderId = item.vlocity_cmt__OrderItemId__r.OrderId;
            orderObj = ((vlocity_cmt.XOMOrderService) vlocity_cmt.XOMObjectFactory.getService(Order.SObjectType)).getObject(orderId, true);
            input.put('orderId', item.vlocity_cmt__OrderItemId__r.OrderId);
        } else {
            Set<Id> orderIds = new Set<Id>();
            orderIds.add(item.vlocity_cmt__fulfilmentRequestLineId__r.vlocity_cmt__fulfilmentRequestId__c);
            List<vlocity_cmt.XOMOrderDomainObject> orderObjs =
                    ((vlocity_cmt.XOMOrderService) vlocity_cmt.XOMObjectFactory.getService(Order.SObjectType)).getFulfilmentRequests(orderIds, true);
            if (orderObjs.size() > 0) orderObj = orderObjs.get(0); // there is always only one top level FRL
            input.put('fulfilmentRequestId', item.vlocity_cmt__fulfilmentRequestLineId__r.vlocity_cmt__fulfilmentRequestId__c);
        }
        System.debug('Order Object: ' + orderObj);


        //retrieve additional information for orchestration items: order Id, account Id
        Map<String, Object> autotaskParametersMap = new Map<String, Object>();
        String itemId = item.Id;
        vlocity_cmt__OrchestrationItem__c itemExt = [
                select Id, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId, vlocity_cmt__AutoTaskParameters__c
                from vlocity_cmt__OrchestrationItem__c
                where Id = :itemId
        ];
        String autotaskParametersString = itemExt.vlocity_cmt__AutoTaskParameters__c;
        System.debug('Parameters: ' + autotaskParametersString);
        if (autotaskParametersString != null) {
            autotaskParametersMap = (Map <String, Object>) JSON.deserializeUntyped(autotaskParametersString);
            System.debug('Parameters: ' + autotaskParametersMap);
        }

        Map <String, Object> ipInput = new Map <String, Object> ();
        Map <String, Object> ipOutput = new Map <String, Object> ();
        Map <String, Object> ipOptions = new Map <String, Object> ();
        /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
        /* If you need more input information for VIP, you can extend the code here. Alternatively, you can use dataraptors within your VIP to collect such information */
        ipInput.put('accountId', itemExt.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId);
        ipInput.put('orderId', item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c);
        ipInput.put('orchestrationItemId', item.Id);
        ipInput.put('orchestrationItemName', item.Name);
        ipInput.put('orchestrationPlanId', item.vlocity_cmt__OrchestrationPlanId__c);

        String ipName = (String)autotaskParametersMap.get('integrationProcedureName');
        if (ipName != null && !String.isBlank(ipName)) {
            // invoke the IP only
            invokeIntegrationProcedure(ipName, ipInput, ipOutput, ipOptions);
            processIPResponse(ipOutput);
        }
    }

    /**
     * @param procedureName
     * @param ipInput
     * @param ipOutput
     * @param ipOptions
     */
    public void invokeIntegrationProcedure(String procedureName, Map <String, Object> ipInput, Map <String, Object> ipOutput, Map <String, Object> ipOptions) {
        if (String.isBlank(procedureName)) {
            return;
        }
        System.debug('Invoking IP: ' + procedureName);

        /* Call the IP via runIntegrationService, and save the output to ipOutput */
        ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
        System.debug('ipOutput: ' + ipOutput);
    }

}