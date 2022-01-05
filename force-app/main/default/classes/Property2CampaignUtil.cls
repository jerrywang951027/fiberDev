public without sharing class Property2CampaignUtil {

  public static Map<String, Set<Property2Campaign__c>> getJunctionRecords(
      Map<String, List<Sobject>> mapPRIDToLstSObject) {
    Map<String, Set<Property2Campaign__c>> mapOptToJunctionRec =
        new Map<String, Set<Property2Campaign__c>>();
    if (mapPRIDToLstSObject.values()[0].getSObjectType() ==
        Schema.Property__c.getSObjectType()) {
      List<vlocity_cmt__Premises__c> lstAddresses =
          [SELECT Id, Project_ID__c,
            (SELECT Campaign__c, Campaign__r.Name FROM Leads__r),
            (SELECT CampaignId, Campaign.Name FROM Opportunities__r)
        FROM vlocity_cmt__Premises__c
        WHERE Project_ID__c IN :mapPRIDToLstSObject.keyset()];
      if (!lstAddresses.isEmpty()) {
        mapOptToJunctionRec.put(MxUConstants.Operation.OPT.OPT_INSERT,
            getRelatedCampaigns(mapPRIDToLstSObject, lstAddresses));
      }
      else {
        Set<Property2Campaign__c> setDeleteJuncRecs =
            new Set<Property2Campaign__c>();
        for (List<Property__c> lstProperties :
             mapPRIDToLstSObject.values()) {
          for (Property__c objProp : lstProperties) {
            setDeleteJuncRecs.addAll(objProp.Related_Properties__r);
          }
        }
        if (!setDeleteJuncRecs.isEmpty()) {
          mapOptToJunctionRec.put(MxUConstants.Operation.OPT.OPT_DELETE,
              setDeleteJuncRecs);
        }
      }
    }
    else if (mapPRIDToLstSObject.values()[0].getSObjectType() ==
        Schema.vlocity_cmt__Premises__c.getSObjectType()) {
      List<Property__c> lstProperties = [
          SELECT Id, PRID__c,
              (SELECT Campaign__c, Name FROM Related_Properties__r)
          FROM Property__c
          WHERE PRID__c IN :mapPRIDToLstSObject.keyset()];
      mapOptToJunctionRec.put(MxUConstants.Operation.OPT.OPT_INSERT,
          getRelatedCampaigns(mapPRIDToLstSObject, lstProperties));
    }
    return mapOptToJunctionRec;
  }

  public static void createRelatedCampaignsForLeadsAndOppty(
      Set<String> setProjectIds) {
    Map<String, List<vlocity_cmt__Premises__c>> mapPRIDToLstProperty =
        new Map<String, List<vlocity_cmt__Premises__c>>();
    for (vlocity_cmt__Premises__c objAddress : [
        SELECT Id, Project_Id__c,
            (SELECT Campaign__c, Campaign__r.Name FROM Leads__r),
            (SELECT CampaignId, Campaign.Name FROM Opportunities__r)
        FROM vlocity_cmt__Premises__c
        WHERE Project_Id__c IN :setProjectIds]) {
      if (!mapPRIDToLstProperty.containsKey(objAddress.Project_Id__c)) {
        mapPRIDToLstProperty.put(objAddress.Project_Id__c,
            new List<vlocity_cmt__Premises__c>{objAddress});
      }
      else {
        mapPRIDToLstProperty.get(objAddress.Project_Id__c)
            .add(objAddress);
      }
    }
    if (!mapPRIDToLstProperty.isEmpty()) {
      Map<String, Set<Property2Campaign__c>> mapOptToJunctionRec =
          Property2CampaignUtil.getJunctionRecords(mapPRIDToLstProperty);
      if (mapOptToJunctionRec != null
          && !mapOptToJunctionRec.isEmpty()
          && mapOptToJunctionRec.containsKey(
              MxUConstants.Operation.OPT.OPT_INSERT)) {
        insert new List<Property2Campaign__c>(mapOptToJunctionRec.get(
            MxUConstants.Operation.OPT.OPT_INSERT));
      }
    }
  }

  private static Set<Property2Campaign__c> getRelatedCampaigns(
      Map<String, List<SObject>> mapPRIDToLstSObject,
          List<SObject> lstRecords) {
    Set<Property2Campaign__c> setJunctionRecords =
        new Set<Property2Campaign__c>();
    Map<String, Property2Campaign__c> mapCampaignId2Property =
        new Map<String, Property2Campaign__c>();
    Set<Property2Campaign__c> setAllJuncRecs =
        new Set<Property2Campaign__c>();
    Set<Property2Campaign__c> setExistingJuncRecs =
        new Set<Property2Campaign__c>();
    if (!lstRecords.isEmpty()
        && lstRecords[0].getSObjectType() ==
           Schema.vlocity_cmt__Premises__c.getSObjectType()) {
      for (vlocity_cmt__Premises__c objAddress : (List<vlocity_cmt__Premises__c>)lstRecords) {
        for (Property__c objProp: (List<PRoperty__c>)
            mapPRIDToLstSObject.get(objAddress.Project_ID__c)) {
          setAllJuncRecs.addAll(objProp.Related_Properties__r);
          for (Property2Campaign__c objJuncRec : objProp.Related_Properties__r) {
            mapCampaignId2Property.put(
                objJuncRec.Campaign__c + objProp.PRID__c, objJuncRec);
          }
          setJunctionRecords.addAll(iterateLeads(
              objAddress.Leads__r, mapCampaignId2Property,
              objProp, setExistingJuncRecs));
          setJunctionRecords.addAll(iterateOpportunities(
              objAddress.Opportunities__r, mapCampaignId2Property,
             objProp, setExistingJuncRecs));
        }
      }
    }
    else if (!lstRecords.isEmpty()
             && lstRecords[0].getSObjectType() ==
                Schema.Property__c.getSObjectType()) {
      for (Property__c objProp : (List<Property__c>)lstRecords) {
        setAllJuncRecs.addAll(objProp.Related_Properties__r);
      for (Property2Campaign__c objJuncRec : objProp.Related_Properties__r) {
        mapCampaignId2Property.put(
            objJuncRec.Campaign__c + objProp.PRID__c, objJuncRec);
      }
      for (vlocity_cmt__Premises__c objAddress: (List<vlocity_cmt__Premises__c>)
          mapPRIDToLstSObject.get(objProp.PRID__c)) {
        setJunctionRecords.addAll(iterateLeads(
            objAddress.Leads__r, mapCampaignId2Property,
            objProp, setExistingJuncRecs));
        setJunctionRecords.addAll(iterateOpportunities(
            objAddress.Opportunities__r, mapCampaignId2Property,
            objProp, setExistingJuncRecs));
        }
      }
    }
    if (!setExistingJuncRecs.isEmpty()) {
       setAllJuncRecs.removeAll(setExistingJuncRecs);
    }
    if(!setAllJuncRecs.isEmpty()) {
      delete new List<Property2Campaign__c>(setAllJuncRecs);
    }
    return setJunctionRecords;
  }

  private static Set<Property2Campaign__c> iterateLeads(
      List<Lead> lstLeads, Map<String, Property2Campaign__c> mapCampaignId2Property,
          Property__c objProp, Set<Property2Campaign__c> setExistingJuncRecs) {
    Set<Property2Campaign__c> setJunctionRecords =
        new Set<Property2Campaign__c>();
    for (Lead objLead: lstLeads) {
      if (objLead.Campaign__c != null) {
        String sMapKey = objLead.Campaign__c + objProp.PRID__c;
        if (!mapCampaignId2Property.containsKey(sMapKey)) {
          Property2Campaign__c objRec = new Property2Campaign__c(
              Name = objLead.Campaign__r.Name,
              Campaign__c = objLead.Campaign__c,
              Property__c = objProp.Id);
          setJunctionRecords.add(objRec);
        }
        else {
          setExistingJuncRecs.add(mapCampaignId2Property.get(sMapKey));
        }
      }
    }
    return setJunctionRecords;
  }

  private static Set<Property2Campaign__c> iterateOpportunities(
      List<Opportunity> lstOpptys, Map<String, Property2Campaign__c>
          mapCampaignId2Property, Property__c objProp,
              Set<Property2Campaign__c> setExistingJuncRecs) {
    Set<Property2Campaign__c> setJunctionRecords =
        new Set<Property2Campaign__c>();
    for (Opportunity objOppty: lstOpptys) {
      if (objOppty.CampaignId != null) {
        String sMapKey = objOppty.CampaignId + objProp.PRID__c;
        if (!mapCampaignId2Property.containsKey(sMapKey)) {
          Property2Campaign__c objRec = new Property2Campaign__c(
              Name = objOppty.Campaign.Name,
              Campaign__c = objOppty.CampaignId,
              Property__c = objProp.Id);
          setJunctionRecords.add(objRec);
        }
        else {
          setExistingJuncRecs.add(mapCampaignId2Property.get(sMapKey));
        }
      }
    }
    return setJunctionRecords;
  }
}