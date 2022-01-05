public class RelatedAccountHelper {
  private static final String PRIMARY_DELETION_ERROR =
      'Primary Related Account deletion is not allowed';

  public static void primaryFieldUpdateLogic(
      List<GFB_Related_Account__c> newList,
      Map<Id, GFB_Related_Account__c> oldMap) {
    Set<Id> propertyIdSet = new Set<Id>();
    Map<Id, List<Id>> propIdToAccIdMap = new Map<Id, List<Id>>();
    Map<Id, List<String>> propIdToTypeMap = new Map<Id, List<String>>();
    List<GFB_Related_Account__c> relAccListToUpdate = new
        List<GFB_Related_Account__c>();

    for (GFB_Related_Account__c relAccObj : newList) {
      if (relAccObj.GFB_Primary__c
          && (relAccObj.GFB_Type__c ==
              MxUConstants.MxURelatedAcctType.PROPERTY_OWNER
          || relAccObj.GFB_Type__c ==
              MxUConstants.MxURelatedAcctType.PROPERTY_MANAGER
          || relAccObj.GFB_Type__c ==
              MxUConstants.MxURelatedAcctType.LAND_DEVELOPER
          || relAccObj.GFB_Type__c ==
              MxUConstants.MxURelatedAcctType.EQUITY_BACKER)) {
        if (oldMap != null) {
          GFB_Related_Account__c oldObj = oldMap.containsKey(relAccObj.Id) ?
              oldMap.get(relAccObj.Id) : null;
          if (oldObj != null
              && (relAccObj.GFB_Primary__c != oldObj.GFB_Primary__c
              || relAccObj.GFB_Type__c != oldObj.GFB_Type__c)) {
            propertyIdSet.add(relAccObj.Property__c);
          }
        } else {
          propertyIdSet.add(relAccObj.Property__c);
        }
        populatePropMap(propIdToAccIdMap, propIdToTypeMap, relAccObj);
      }
    }
    if (!propertyIdSet.isEmpty()) {
      for (GFB_Related_Account__c relAccRec : [
          SELECT Id, Name, GFB_Primary__c, GFB_Type__c, Property__c
          FROM GFB_Related_Account__c
          WHERE GFB_Primary__c = true AND Property__c IN : propertyIdSet
          AND Id NOT IN : newList]) {
        List<String> typeList = propIdToTypeMap.get(relAccRec.Property__c);
        if (typeList.contains(relAccRec.GFB_Type__c)) {
          relAccRec.GFB_Primary__c = false;
          relAccListToUpdate.add(relAccRec);
        }
      }
      if (!relAccListToUpdate.isEmpty()) {
        update relAccListToUpdate;
      }
      if (!propIdToAccIdMap.isEmpty() && !propIdToTypeMap.isEmpty()) {
        updatePropertyAccountLookup(
            propertyIdSet, propIdToAccIdMap, propIdToTypeMap);
      }
    }
  }

  private static void populatePropMap(
      Map<Id, List<Id>> propIdToAccIdMap,
      Map<Id, List<String>> propIdToTypeMap,
      GFB_Related_Account__c relatedAcc) {
    List<Id> accIds = new List<Id>();
    List<String> typeList = new List<String>();
    if (propIdToAccIdMap.containsKey(relatedAcc.Property__c)
        && propIdToTypeMap.containsKey(relatedAcc.Property__c)) {
      accIds = propIdToAccIdMap.get(relatedAcc.Property__c);
      typeList = propIdToTypeMap.get(relatedAcc.Property__c);
    }
    accIds.add(relatedAcc.Account__c);
    propIdToAccIdMap.put(relatedAcc.Property__c, accIds);
    typeList.add(relatedAcc.GFB_Type__c);
    propIdToTypeMap.put(relatedAcc.Property__c, typeList);
  }

  private static void updatePropertyAccountLookup(
      Set<Id> propertyIdSet,
      Map<Id, List<Id>> propIdToAccIdMap,
      Map<Id, List<String>> propIdToTypeMap) {
    Property__c propertyObj;
    List<Property__c> propertyListToUpdate = new List<Property__c>();

    for (Id propId : propertyIdSet) {
      if (propIdToAccIdMap.containsKey(propId)
          && propIdToTypeMap.containsKey(propId)) {
        propertyObj = new Property__c(Id = propId);
        List<String> typeValueList = propIdToTypeMap.get(propId);
        if (typeValueList.contains(
            MxUConstants.MxURelatedAcctType.PROPERTY_OWNER)) {
          Integer index = typeValueList.indexOf(
              MxUConstants.MxURelatedAcctType.PROPERTY_OWNER);
          propertyObj.Property_owner__c =
              propIdToAccIdMap.get(propId).get(index);
        }
        if (typeValueList.contains(
            MxUConstants.MxURelatedAcctType.PROPERTY_MANAGER)) {
          Integer index = typeValueList.indexOf(
              MxUConstants.MxURelatedAcctType.PROPERTY_MANAGER);
          propertyObj.Property_Manager__c =
              propIdToAccIdMap.get(propId).get(index);
        }
        if (typeValueList.contains(
            MxUConstants.MxURelatedAcctType.LAND_DEVELOPER)) {
          Integer index = typeValueList.indexOf(
              MxUConstants.MxURelatedAcctType.LAND_DEVELOPER);
          propertyObj.Property_Developer__c =
              propIdToAccIdMap.get(propId).get(index);
        }
        if (typeValueList.contains(
            MxUConstants.MxURelatedAcctType.EQUITY_BACKER)) {
          Integer index = typeValueList.indexOf(
              MxUConstants.MxURelatedAcctType.EQUITY_BACKER);
          propertyObj.Property_Equity__c =
              propIdToAccIdMap.get(propId).get(index);
        }
        propertyListToUpdate.add(propertyObj);
      }
    }
    if (!propertyListToUpdate.isEmpty()) {
      update propertyListToUpdate;
    }
  }

  public static void restrictDeletePrimaryAccount(
      List<GFB_Related_Account__c> relatedAccounts) {
    for (GFB_Related_Account__c relatedAccount :  relatedAccounts) {
      if (relatedAccount.GFB_Primary__c == true) {
        relatedAccount.addError(PRIMARY_DELETION_ERROR);
      }
    }
  }
}