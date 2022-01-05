global class XOMAutoTask_InvokeIntegrationProcedure implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    
    /***************************************************************************************************************
    * @description Executes auto-task business logic 
    * @param List of orchestration items (auto-tasks)
    * @return Nothing, business logic is executed
    * @example
    *
    * Not invoked directly but rather called by Vlocity XOM orchestration engine
    */

    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {

        //retrieve additional information for orchestration items: order Id, account Id
        List <vlocity_cmt__OrchestrationItem__c> itemsExt = [SELECT Id,vlocity_cmt__AutoTaskParameters__c,vlocity_cmt__State__c,
                                                             vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c
                                                             FROM vlocity_cmt__OrchestrationItem__c 
                                                             WHERE Id in :items];
        
        //iterate list to loop through orchestration item
        for (vlocity_cmt__OrchestrationItem__c item : itemsExt) {        
            
            /* Initialize variables */
            String autotaskParametersString = item.vlocity_cmt__AutoTaskParameters__c;
            Map <String, Object> autotaskParametersMap = (Map <String, Object>) JSON.deserializeUntyped(autotaskParametersString);
            String procedureName = (String) autotaskParametersMap.get('procedureName');
            
            Map <String, Object> ipInput = new Map <String, Object> ();
            Map <String, Object> ipOutput = new Map <String, Object> ();
            Map <String, Object> ipOptions = new Map <String, Object> ();
            
            if (String.isBlank(procedureName)) {
                SObjectException e = new SObjectException();
                e.setMessage('Procedure name (procedureName) is not defined for the auto-task. Verify that the Auto Task Parameters field is properly populated');
                throw e;
            }

            /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
            /* If you need more input information for VIP, you can extend the code here. Alternatively, you can use dataraptors within your VIP to collect such information */
            ipInput.put('orchItemId', item.Id);
            ipInput.put('orderId', item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c);
            
             List <Order> OrderDetails = [SELECT vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c, 
                                                vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                                vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                                vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c,
                                                vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                CompanyAuthorizedById,CompanyAuthorizedBy.Name,CompanyAuthorizedBy.Email,CompanyAuthorizedBy.Phone,
                                                CompanyAuthorizedBy.MobilePhone
                                                FROM Order
                                                WHERE Id = :item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c];
                                                            
           for (Order order: OrderDetails)
           {
                 ipInput.put('dsUserId',order.CompanyAuthorizedById);
                 ipInput.put('dsUserName',order.CompanyAuthorizedBy.Name);
                 ipInput.put('dsUserEmail',order.CompanyAuthorizedBy.Email);
                 ipInput.put('dsUserPhone',(order.CompanyAuthorizedBy.Phone !=null?order.CompanyAuthorizedBy.Phone : order.CompanyAuthorizedBy.MobilePhone));
                 ipInput.put('SiteAddress',(order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+(order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c !=null ?' Unit/Apt '+order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c+', ':', ')+order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c+', '+order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c+', '+order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c));
                 /*ApplicationLog.logMessage('Info', 'XOMAutoTask_InvokeIntegrationProcedure', 'ExecuteUserQuery', OrderDetails.toString(), '', 'this log is to capture the output of the autotask', String.valueOf(ipInput), null, 0);*/
                 
           }
            System.debug('Custom > DEBUG > XOMAutoTask_InvokeIntegrationProcedure: ipInput= ' + ipInput);
            /* Call the IP via runIntegrationService, and save the output to ipOutput */
            ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.
            runIntegrationService(procedureName, ipInput, ipOptions);

            
            if(ipOutput.containskey('success') && !Boolean.valueOf(ipOutput.get('success')) && ipOutput.containskey('result'))
            {
                Map<String, Object> res = (Map<String, Object>)ipOutput.get('result');
                if(res.containskey('Error'))
                {
                    DMLException e = new DMLException();
                    e.setMessage((String)res.get('Error'));
                    throw e;
                }
            }
            
            //Capture debug log and application log for error handling
            System.debug('Custom > DEBUG > XOMAutoTask_InvokeIntegrationProcedure: ipOutput = ' + ipOutput);
            ApplicationLog.logMessage('Info', 'XOMAutoTask_InvokeIntegrationProcedure', 'executeBatch', item.Id, '', 'this log is to capture the output of the autotask', String.valueOf(ipOutput), null, 0);
        }
    }
    
    public void finish(vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask info){   
    system.debug('Inside');  
   } 
}