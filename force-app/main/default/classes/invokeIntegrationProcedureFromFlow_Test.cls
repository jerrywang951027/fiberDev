/**
 * Invocable class: invokeIntegrationProcedureFromFlow
 * Test class: invokeIntegrationProcedureFromFlow_Test
 * */

@isTest
global class invokeIntegrationProcedureFromFlow_Test {
    @isTest
    global static void invokeQueueable() {   
        List<invokeIntegrationProcedureFromFlow.IntegrationProcedureInput> ipiList = new List<invokeIntegrationProcedureFromFlow.IntegrationProcedureInput>();
        invokeIntegrationProcedureFromFlow.IntegrationProcedureInput ipi = new invokeIntegrationProcedureFromFlow.IntegrationProcedureInput();
        ipi.executionMode = 'Queueable';
        
        ipiList.add(ipi);
        
        invokeIntegrationProcedureFromFlow.runIntegrationServiceInvocable(ipiList);
    }
    
    @isTest
    global static void invokeDefault() {
        List<invokeIntegrationProcedureFromFlow.IntegrationProcedureInput> ipiList = new List<invokeIntegrationProcedureFromFlow.IntegrationProcedureInput>();
        invokeIntegrationProcedureFromFlow.IntegrationProcedureInput ipi = new invokeIntegrationProcedureFromFlow.IntegrationProcedureInput();
        ipi.executionMode = 'Synchronous';
        
        ipiList.add(ipi);
        
        invokeIntegrationProcedureFromFlow.runIntegrationServiceInvocable(ipiList);
    }
    
}