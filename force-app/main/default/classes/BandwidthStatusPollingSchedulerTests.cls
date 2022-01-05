/**
 * @group TestClass-BandwidthStatusPollingScheduler
 * @description Test class for BandwidthStatusPollingScheduler to improve code coverage
 * and test functionality.
 */
@isTest
public with sharing class BandwidthStatusPollingSchedulerTests {
 public static final String CLASS_NAME = 'BandwidthStatusPollingScheduler';
 public static final String SCHEDULE_JOB_NAME = 'BandwidthStatusPollingScheduler Job';
 public static final String EXTRACT_FRL_FOR_POLLING = 'XOM_ExtractFrlForBandwidthStatusPolling';
 /**
 * @description This method sets the test data.
 * @param null
 */
  @testSetup
  private static void setupData() {
    vlocity_cmt__DRBundle__c bundle = new vlocity_cmt__DRBundle__c(
        Name = EXTRACT_FRL_FOR_POLLING,
        vlocity_cmt__DRMapName__c = EXTRACT_FRL_FOR_POLLING,
        vlocity_cmt__Type__c = 'Extract',
        vlocity_cmt__InterfaceObject__c = 'json',
        vlocity_cmt__InputType__c = 'JSON',
        vlocity_cmt__OutputType__c = 'JSON'
    );
    insert new List<vlocity_cmt__DRBundle__c> {bundle};
    List<Object> frlResponse = 
        (List<Object>)JSON.deserializeUntyped(
        '[{\"asyncTransactionStatus\":\"E911 In Progress\",'+
        '\"e911OrderId\":\"7401\",'+
        '\"e911OrderStatus\":\"In Progress\"},' +
        '{\"asyncTransactionStatus\":\"Port-in In Progress\",'+
        '\"portInOrderId\":\"7401\",'+
        '\"portInOrderStatus\":\"In Progress'
        +'\"}]');
    // Create dataraptor mappings.
    List<vlocity_cmt__DRMapItem__c> drMaps = new List<vlocity_cmt__DRMapItem__c>{
        new vlocity_cmt__DRMapItem__c(
          Name = EXTRACT_FRL_FOR_POLLING,
          vlocity_cmt__MapId__c = EXTRACT_FRL_FOR_POLLING,
          vlocity_cmt__DomainObjectCreationOrder__c = 1,
          vlocity_cmt__InterfaceFieldAPIName__c = 'frl', 
          vlocity_cmt__DomainObjectAPIName__c = 'json', 
          vlocity_cmt__DomainObjectFieldAPIName__c = 'frl',
          vlocity_cmt__DomainObjectFieldType__c = 'Object',
          vlocity_cmt__DefaultValue__c = JSON.serialize(frlResponse)
        )};
     insert drMaps;
  }

  @isTest
  private static void testBandwidthStatusPollingScheduler() {
    String jobId;
      
    Test.StartTest();
      BandwidthStatusPollingScheduler sch = new BandwidthStatusPollingScheduler();
      String cronExp = '0 0 23 * * ?';
      jobId = System.schedule(SCHEDULE_JOB_NAME, cronExp, sch);
    Test.StopTest();
     
    CronTrigger scheduleJob = [
      SELECT Id, 
        CronJobDetail.Id, 
        CronJobDetail.Name, 
        CronJobDetail.JobType 
      FROM CronTrigger 
      WHERE Id = :jobId];
    System.assertEquals(SCHEDULE_JOB_NAME, scheduleJob.CronJobDetail.Name, 'Job name should match.');
  }

}