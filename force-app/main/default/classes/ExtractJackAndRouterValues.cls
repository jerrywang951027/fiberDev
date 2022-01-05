public class ExtractJackAndRouterValues {

  Public static History_Event__c NewHE (String mail){
      History_Event__c historyEventRecord =
          new History_Event__c(Phone__c = '988998898', Email__c =mail);
      insert historyEventRecord;
        return historyEventRecord;
    }
}//ExtractJackAndRouterValues.NewHE('sipatel@google.com');