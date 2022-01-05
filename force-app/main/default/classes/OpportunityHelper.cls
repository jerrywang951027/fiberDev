public class OpportunityHelper {
  private static final String NATIONAL_MXU_UPDATES_EMAIL = 'national-mxu-updates@google.com';
  private static final String DEAL_WON_EMAIL_TEMPLATE_DEVNAME = 'MXU_DealWon';
  private static final String TERMINATED_EMAIL_TEMPLATE_DEVNAME = 'AA_Termination_Review';
  private static final Integer WEEK_TO_DAYS = 7;

  public static void setEmailAlias(List<Opportunity> oppNewList) {
    for (Opportunity oppObj : oppNewList) {
      if (oppObj.RecordTypeId == RecordTypeUtils.OPPORTUNITY_MXU
          || oppObj.RecordTypeId == RecordTypeUtils.OPPORTUNITY_MXU_NON_AA) {
        oppObj.Market_MXU_Sales_Lead__c =
            CustomMetadataUtil.getSalesEmailByMxUMarket(oppObj.Market_Formula__c);
        oppObj.market_Tech_Ops_lead__c =
            CustomMetadataUtil.getTechOpsEmailByMxUMarket(oppObj.Market_Formula__c);
        // Commenting out constants and hard-coding it in program for v2 to v3 migration
        //if (UserInfo.getOrganizationId() == Constants.OrgIds.PROD) {
        if (UserInfo.getOrganizationId() == '00D1N0000017AdAUAU') {

          oppObj.National_Email_Alias__c = NATIONAL_MXU_UPDATES_EMAIL;
        }
      }
    }
  }

  public static void updateBuildMethod(List<Opportunity> oppNewList,
      Map<Id, Opportunity> oldOpportunityMap) {
    Set<Id> propertyIds = new Set<Id>();
    List<Opportunity> opptyToFillBuildMethod = new List<Opportunity>();
    Map<Id, Property__c> parentPropertyMap = new Map<Id, Property__c>();
    for (Opportunity oppObj : oppNewList) {
      if (oppObj.RecordTypeId == RecordTypeUtils.OPPORTUNITY_MXU &&
          oppObj.Property__c != null &&
          (oldOpportunityMap == null ||
           oldOpportunityMap.get(oppObj.Id).Property__c != oppObj.Property__c)) {
        propertyIds.add(oppObj.Property__c);
        opptyToFillBuildMethod.add(oppObj);
      }
    }

    if (!propertyIds.isEmpty()) {
      parentPropertyMap = new Map<Id, Property__c>(
        [SELECT
           Id,
           Build_Type__c
         FROM
           Property__c
         WHERE
           Id IN :propertyIds]
       );
    }

    if (!parentPropertyMap.isEmpty()) {
      for (Opportunity opptyObj : opptyToFillBuildMethod) {
        opptyObj.Build_Method__c =
            parentPropertyMap.get(opptyObj.Property__c).Build_Type__c;
      }
    }
  }

  public static void setIsWebpass(List<Opportunity> oppNewList) {
    for (Opportunity oppObj : oppNewList) {
      if ((oppObj.RecordTypeId == RecordTypeUtils.OPPORTUNITY_MXU ||
          oppObj.Converted_Lead_Record_Type__c == RecordTypeUtils.LEAD_MXU_DEV_NAME) &&
          oppObj.Build_Method__c == MxUConstants.Property.BUILD_TYPE.WEBPASS) {
        oppObj.Is_Webpass__c = true;
      }
    }
  }

  public static void setDealNames(List<Opportunity> oppList) {
    for (Opportunity opp : oppList) {
      if (opp.RecordTypeId == RecordTypeUtils.OPPORTUNITY_MXU) {
        opp.Deal_Name__c = opp.Name;
      }
    }
  }

  public static void fillRestrictedAccessOptions(List<Opportunity> oppNewList,
      Map<Id, Opportunity> oldOpportunityMap) {
    List<Property__c> propertiesToUpdate = new List<Property__c>();
    for (Opportunity opp : oppNewList) {
      if (opp.Marketing_Exclusivity__c !=
          oldOpportunityMap.get(opp.Id).Marketing_Exclusivity__c &&
         opp.Marketing_Exclusivity__c ==
             MxUConstants.Opportunity.MARKETING_EXCLUSIVITY.YES) {
        propertiesToUpdate.add(new Property__c(Id = opp.Property__c,
            Restricted_Access_Options__c =
            MxUConstants.Property.RESTRICTED_ACCESS_OPTIONS.NO_DOOR_HANGERS_ALLOWED +
            // Commenting out constants and hard-coding it in program for v2 to v3 migration
            //Constants.SEMICOLON +
            ';' +

            MxUConstants.Property.RESTRICTED_ACCESS_OPTIONS.NO_D2D_ALLOWED));
      }
    }

    if (!propertiesToUpdate.isEmpty()) {
      update propertiesToUpdate;
    }
  }

  public static void createNonAAIfDAF(List<Opportunity> oppNewList,
      Map<Id, Opportunity> oldOpportunityMap) {
    List<Opportunity> nonAaOppsToCreate = new List<Opportunity>();
    List<Opportunity> oppsToCheckDaf = new List<Opportunity>();
    Set<Id> propertyIdsToCheckExistingDafs = new Set<Id>();
    Set<String> dafNames = new Set<String>();
    for (Opportunity opp : oppNewList) {
      if (opp.StageName != oldOpportunityMap.get(opp.Id).StageName &&
          opp.StageName == MxUConstants.Opportunity.STAGE.DEAL_WON &&
          opp.DAF_Signed_Y_N__c == MxUConstants.Opportunity.DAF_SIGNED.NO &&
          opp.RecordTypeId != RecordTypeUtils.OPPORTUNITY_MXU_NON_AA &&
          opp.Contract_Type__c != MxUConstants.Opportunity.CONTRACT_TYPE.MDU_AA_SHORT_FORM &&
          opp.Contract_Type__c != MxUConstants.Opportunity.CONTRACT_TYPE.MTU_AA_SHORT_FORM &&
          opp.Property__r.Property_Type__c != MxUConstants.Property.PROPERTY_TYPE.PRIVATE_ROADS) {
        oppsToCheckDaf.add(opp);
        propertyIdsToCheckExistingDafs.add(opp.Property__c);
        dafNames.add(opp.Name + MxUConstants.Opportunity.NAME_SUFFIX.DAF);
      }
    }

    if(!oppsToCheckDaf.isEmpty()){
      Map<Id, List<Opportunity>> dafOppsByPropertyId =
          getExistingDafs(propertyIdsToCheckExistingDafs, dafNames);
      for(Opportunity opp : oppsToCheckDaf) {
        if(!isDafAlredyExist(opp.Name + MxUConstants.Opportunity.NAME_SUFFIX.DAF,
            dafOppsByPropertyId.get(opp.Property__c))){
           nonAaOppsToCreate.add(createNewNonAA(opp));
        }
      }

      if (!nonAaOppsToCreate.isEmpty()) {
        insert nonAaOppsToCreate;
      }
    }
  }

  public static void populateInactivityDate(
      List<Opportunity> lstOpptys,
      Map<Id, Opportunity> oldMap) {
    Date launchDate = Test.isRunningTest() ?
                      System.today() :
                      Date.valueOf(Label.Email_Expansion_Launch_Date);
    for (Opportunity oppty: lstOpptys) {
      if (oppty.RecordTypeId != RecordTypeUtils.OPPORTUNITY_CUSTOMER
          && oppty.createdDate >= launchDate) {
        Opportunity oldOppty = oldMap.get(oppty.Id);
        if (oppty.StageName != oldOppty.StageName) {
        String duration;
          if (oppty.StageName ==
              MxUConstants.Opportunity.STAGE.PITCH) {
            duration =
                CustomMetadataUtil.getStageOneInactivityDurationByMxUMarket(
                    oppty.Market_Formula__c);
          } else if (oppty.StageName ==
              MxUConstants.Opportunity.STAGE.PENDING_CONTRACT) {
            duration =
                CustomMetadataUtil.getStageThreeInactivityDurationByMxUMarket(
                    oppty.Market_Formula__c);
          }
          if (duration != null && oppty.LastActivityDate != null) {
            oppty.Follow_Up_Notification_Date__c =
              oppty.LastActivityDate.addDays(getDurationInDays(duration));
          }
        }
      }
    }
  }

  private static Integer getDurationInDays(String duration) {
    Integer durationInDays = Integer.valueOf(duration.substringBefore(' ').trim());
    return duration.containsIgnoreCase('week') ?
           durationInDays * WEEK_TO_DAYS : durationInDays;
  }
  private static Map<Id, List<Opportunity>> getExistingDafs(
      Set<Id> propertyIdsToCheckExistingDafs, Set<String> dafNames) {
    List<Opportunity> dafOpportunities = [
      SELECT
        Id,
        Property__c,
        Name
      FROM
        Opportunity
      WHERE
        Property__c IN :propertyIdsToCheckExistingDafs
        AND Name IN :dafNames
        AND StageName NOT IN : MxUConstants.Opportunity.STAGE.INACTIVE_STAGES
        AND Sub_Status__c != :MxUConstants.Opportunity.SUB_STATUS.PAUSED];

    Map<Id, List<Opportunity>> dafOppsByPropertyId =
        new Map<Id, List<Opportunity>>();
    for (Opportunity opp : dafOpportunities) {
      if (dafOppsByPropertyId.containsKey(opp.Property__c)) {
        dafOppsByPropertyId.get(opp.Property__c).add(opp);
      } else {
        dafOppsByPropertyId.put(opp.Property__c, new List<Opportunity>{opp});
      }
    }
    return dafOppsByPropertyId;
  }

  private static Boolean isDafAlredyExist(String dafOpportunityName,
      List<Opportunity> oppsToFindDaf) {
    if (oppsToFindDaf == null || oppsToFindDaf.isEmpty()) {
      return false;
    }
    for (Opportunity opp : oppsToFindDaf) {
      if (opp.Name == dafOpportunityName) {
        return true;
      }
    }
    return false;
  }

  private static Opportunity createNewNonAA(Opportunity aaOpportunity) {
    return new Opportunity(
        StageName = MxUConstants.Opportunity.STAGE.OPEN,
        RecordTypeId = RecordTypeUtils.OPPORTUNITY_MXU_NON_AA,
        Type = MxUConstants.Opportunity.TYPE.DAF,
        Contract_Type__c =
            MxUConstants.Opportunity.CONTRACT_TYPE.DAF,
        Property__c = aaOpportunity.Property__c,
        AccountId = aaOpportunity.AccountId,
        Build_Method__c = aaOpportunity.Build_Method__c,
        CloseDate = aaOpportunity.CloseDate,
        Name = aaOpportunity.Name + MxUConstants.Opportunity.NAME_SUFFIX.DAF,
        OwnerId = aaOpportunity.OwnerId,
        Total_Number_Of_Units__c = aaOpportunity.Total_Number_Of_Units__c);
  }
}