public class RefreshSimbaDetailsController {
  private final static String EMPTY_SIMBA_ID = 'Unable to Sync. Please update the Simba Deal ID on the Opportunity and try again.';

  @AuraEnabled
  public static void refreshOpportunity(Id recordId) {
    Opportunity opp = [SELECT Id,
                              Pending_Simba_Refresh__c,
                              Simba_Deal_ID__c
                       FROM Opportunity
                       WHERE Id =: recordId LIMIT 1];
    if (opp != null && opp.Simba_Deal_ID__c == null) {
       throw new AuraHandledException(EMPTY_SIMBA_ID);
    }
    if (opp != null && opp.Pending_Simba_Refresh__c == false) {
      opp.Pending_Simba_Refresh__c = true;
      try {
        update opp;
      }
      catch(Exception e) {
        ErrorUtils.createExceptionLog(e);
      }
    }
  }
}