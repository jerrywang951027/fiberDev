/**
 * Invocable class: invokeIntegrationProcedureFromFlow
 * Test class: invokeIntegrationProcedureFromFlow_Test
 * */

global with sharing class invokeIntegrationProcedureFromFlow {
 
   /**
    * Invokes by Flow to run the Integration Procedure
    *
    * @param input  The input data map (which is assumed to contain an 'Id' node)
    *
    * @return The output data map
    */
   @InvocableMethod(label = 'Integration Procedure')
   global static List <IntegrationProcedureOutput> runIntegrationServiceInvocable(List<IntegrationProcedureInput> input) {
      
       List<IntegrationProcedureOutput> results = new List<IntegrationProcedureOutput>();
 
       // Async (Queueable) Mode
       if (input[0].executionMode == 'Queueable') {
          
           System.debug(LoggingLevel.Info, 'Calling IP using Queueable -> ' + JSON.serialize(input));
          
           IntegrationProcedureOutput result = new IntegrationProcedureOutput();
          
           // Returns Job Id
           result.output = vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable(
                   input[0].procedureAPIName,
                   new Map <String, Object>{'Id' => input[0].input},
                   new Map <String, Object>()
           );
          
           results.add(result);
       }
       // Synchronous Mode
       else {
          
           System.debug(LoggingLevel.Info, 'Calling IP Synchronously -> ' + JSON.serialize(input));
          
           IntegrationProcedureOutput result = new IntegrationProcedureOutput();
          
           result.output = JSON.serialize(
               vlocity_cmt.IntegrationProcedureService.runIntegrationService(
                   input[0].procedureAPIName,
                   new Map <String, Object>{'Id' => input[0].input},
                   new Map <String, Object>()
               )
           );
          
           results.add(result);
       }
      
       System.debug(LoggingLevel.Info, JSON.serialize(results));
       return results;
   }
 
   /**
    * Input data map definition
    *
    */
   global class IntegrationProcedureInput {
      
       @InvocableVariable(label = 'Procedure Name')
       global String procedureAPIName;
      
       @InvocableVariable(label = 'Input')
       global String input;
              
       @InvocableVariable(label = 'Execution Mode')
       global String executionMode; // Future, Queueable, or Synchronous (default)
   }
  
   /**
    * Output data map definition
    */
   global class IntegrationProcedureOutput {
      
       @InvocableVariable(label = 'Output')
       global String output;
   }
}