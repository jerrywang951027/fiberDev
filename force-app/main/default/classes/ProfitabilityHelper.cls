public class ProfitabilityHelper {

  public static void updateEstimatedSignups(
      List<Profitability__c> newList, Map<Id, Profitability__c> oldMap) {
    updateEstimatedSignups(newList, oldMap, 'Terminal_Take_Rate__c');
  }

  public static void updateEstimatedSignups(
      List<Property__c> newList, Map<Id, Property__c> oldMap) {
    updateEstimatedSignups(newList, oldMap, 'Total_Number_of_Units__c');
  }

  public static void updateEstimatedSignups(
      List<SObject> newList,
      Map<Id, SObject> oldMap,
      String fieldName) {
    Map<Id, SObject> profIdToSObjectMap = new Map<Id, SObject>();
    Schema.SObjectType objectName = newList.getSObjectType();
    for (SObject record : newList) {
      Id recordId = (Id) record.get('Id');
      if (record.get(fieldName) != null) {
        if (oldMap == null || (oldMap.containsKey(recordId)
            && record.get(fieldName) !=
            oldMap.get(recordId).get(fieldName))) {
          if (objectName == Schema.Property__c.getSObjectType()) {
            profIdToSObjectMap.put((Id) record.get('Profitability__c'), record);
          } else if (objectName == Schema.Profitability__c.getSObjectType()) {
            profIdToSObjectMap.put(recordId, record);
          }
        }
      } else {
        if (objectName == Schema.Profitability__c.getSObjectType()) {
          record.put('Estimated_Signups__c', null);
        }
      }
    }
    if (!profIdToSObjectMap.isEmpty()) {
      calculateSignups(objectName, profIdToSObjectMap);
    }
  }

  private static void calculateSignups(
      Schema.SObjectType objectName,
      Map<Id, SObject> profIdToSObjectMap) {
    if (objectName == Schema.Property__c.getSObjectType()) {
      List<Profitability__c> profitList = new List<Profitability__c>();
      Map<Id, Profitability__c> profitMap = new Map<Id, Profitability__c>([
          SELECT Estimated_Signups__c, Terminal_Take_Rate__c
          FROM Profitability__c
          WHERE Id IN :profIdToSObjectMap.keySet()]);
      for (Property__c propObj :
          (List<Property__c>) profIdToSObjectMap.values()) {
        if (profitMap.containsKey(propObj.Profitability__c)
            && profitMap.get(propObj.Profitability__c).Terminal_Take_Rate__c
            != null && propObj.Total_Number_of_Units__c != null) {
          Profitability__c profit = profitMap.get(propObj.Profitability__c);
          Decimal estimateValue = profit.Terminal_Take_Rate__c
              * propObj.Total_Number_of_Units__c / 100;
          if (profit.Estimated_Signups__c != estimateValue) {
            profit.Estimated_Signups__c = estimateValue;
            profitList.add(profit);
          }
        }
      }
      if (!profitList.isEmpty()) {
        update profitList;
      }
    } else if (objectName == Schema.Profitability__c.getSObjectType()) {
      Map<Id, Property__c> ProfIdToPropMap = new Map<Id, Property__c>();
      List<Property__c> PropertyList = [
          SELECT Profitability__c, Total_Number_of_Units__c
          FROM Property__c
          WHERE Profitability__c IN :profIdToSObjectMap.keySet()];
      for (Property__c propObj : PropertyList) {
        ProfIdToPropMap.put(propObj.Profitability__c, propObj);
      }
      for (Profitability__c profObj :
          (List<Profitability__c>) profIdToSObjectMap.values()) {
        if (ProfIdToPropMap.containsKey(profObj.Id)
            && ProfIdToPropMap.get(profObj.Id).Total_Number_of_Units__c
            != null) {
          profObj.Estimated_Signups__c = profObj.Terminal_Take_Rate__c
              * ProfIdToPropMap.get(profObj.Id).Total_Number_of_Units__c / 100;
        }
      }
    }
  }
}