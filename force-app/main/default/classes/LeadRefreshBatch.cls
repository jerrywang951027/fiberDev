/**
 * @group LeadRefreshBatch
 * @description This class is used for refreshing of disqualified lead.
 */
global with sharing class LeadRefreshBatch implements Database.Batchable<sObject>,
    Database.Stateful {

  public String query;
  /**
   * @description Paramterized Constructor holding the query.
   * @param query It is SOQL query which contains Lead information.
   */
  public LeadRefreshBatch(String query) {

    this.query = query;
  }

  /**
   * @description This method hold query of the disqualified Lead record.
   * @param batchContext It will hold the batch job Id.
   * @return Database.QueryLocator It rerurns list of Lead records.
   */
  global Database.QueryLocator start(Database.BatchableContext batchContext) {

    return Database.getQueryLocator(query);
  }

  /**
   * @description This method will update the status of disqualified Lead and recyle Lead record.
   * @param batchContext It will hold the batch job Id.
   * @param scope It is the list of Lead records.
   * @return null
   */
  global void execute(Database.BatchableContext batchContext, List<Lead> scope) {

    LeadRefreshBatchHelper.updateLeadStatus(scope);
  }

  /**
   * @description This method is used for post-activity purpose after the batch process.
   * @param batchContext It will hold the batch job Id.
   * @return null
   */
  global void finish(Database.BatchableContext batchContext) {
  }
}