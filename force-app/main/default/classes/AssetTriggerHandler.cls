/**
 * @group Asset
 * @description Handler to support trigger events for asset object.
 */
public class AssetTriggerHandler {
  public static final String CLASS_NAME = 'AssetTriggerHandler';

  /**
   * @description afterUpdateHandler That takes care of after Update functionality
   * @param assetList New list of Asset records from trigger
   * @param oldAssetMap Accepts map of old version Asset records from trigger
   * @return null
   */
  public static void afterUpdateExecute(List<Asset> assetList, Map<Id, Asset> oldAssetMap) {

    createNewLeadForInactiveAsset(assetList, oldAssetMap);
    changeAccountStatus(assetList);
      updateLeadStatusAndSubStatusForAllInactiveAssets(assetList, oldAssetMap);
  }

  /**
   * @description afterInsertExecute That takes care of after Insert functionality
   * @param assetList New list of Asset records from trigger
   * @return null
   */
  public static void afterInsertExecute(List<Asset> assetList) {

    changeAccountStatus(assetList);
  }

  /**
   * @description This method checks if all Assets associated to a Premises are inactive.
   * If all the Assets are inactive, then it creates an anonymous Lead to that Premises.
   * @param assetList New list of Asset records from trigger
   * @param oldAssetMap Accepts map of old version Asset records from trigger
   * @return null
   */
  public static void createNewLeadForInactiveAsset(List<Asset> assetList,
      Map<Id, Asset> oldAssetMap) {

    final String METHOD_NAME = 'createNewLeadForInactiveAsset';
    List<Lead> leadList = new List<Lead>();
    Set<Id> premisesIds = new Set<Id>();
    List<Asset> assetsForLeadCreation = new List<Asset>();
    try {
      for (Asset assetRecord : assetList) {
        Asset oldAstRecord = oldAssetMap.get(assetRecord.Id);
        if (assetRecord.Status != oldAstRecord.Status &&
            (assetRecord.Status.equals(Constants.Asset.STATUS.INACTIVE)) &&
            assetRecord.vlocity_cmt__PremisesId__c != null) {
          premisesIds.add(assetRecord.vlocity_cmt__PremisesId__c);
        }
      }
      if (!premisesIds.isEmpty()) {
        List<vlocity_cmt__Premises__c> disconnectedPremises =
            AssetUtils.getDisconnectedPremises(premisesIds);
        for (vlocity_cmt__Premises__c  premises : disconnectedPremises) {
          leadList.add(LeadUtils.stampLeadDetails(
              premises, Constants.LEAD.DEFAULT_VALUES.ADDRESS_GENERATED));
        }
        if (!leadList.isEmpty()) {
          insert leadList;
        }
      }
    }
    catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          METHOD_NAME, exp);
      throw exp;
    }
  }
  public static void updateLeadStatusAndSubStatusForAllInactiveAssets(List<Asset> assetList,Map<Id, Asset> oldAssetMap) {
      Set<Id> premisesId = new Set<Id>();
      Map<Id,List<Asset>> inactiveAssetMap = new Map<Id,List<Asset>>();
      Map<Id,List<Asset>> assetMap = new Map<Id,List<Asset>>();
      list<Asset> allAsset = new list<Asset>();
      list<Lead> assetLead = new list<Lead>();
      for (Asset assetRecord : assetList) {
        Asset oldAstRecord = oldAssetMap.get(assetRecord.Id);
        if (assetRecord.Status != oldAstRecord.Status && assetRecord.vlocity_cmt__PremisesId__c != null) {
          premisesId.add(assetRecord.vlocity_cmt__PremisesId__c);
        }
      }
      
      List<vlocity_cmt__Premises__c> premisesRecord = [
          SELECT
          Id,
          (SELECT Id, vlocity_cmt__PremisesId__c,Status
           FROM vlocity_cmt__Assets__r WHERE
           vlocity_cmt__PremisesId__c IN : premisesId
          ),
          (SELECT
           Id,
           Status,
           Sub_Status__c,vlocity_cmt__PremisesId__c
           FROM vlocity_cmt__Leads__r  ORDER BY LastModifiedDate DESC Limit 1)
          FROM
          vlocity_cmt__Premises__c
          WHERE
          Id IN : premisesId]; 

      for (vlocity_cmt__Premises__c premises : premisesRecord) {
          for (Asset assetRecord : premises.vlocity_cmt__Assets__r) {
              if(assetRecord.vlocity_cmt__PremisesId__c != null && assetRecord.Status == Constants.Asset.STATUS.INACTIVE){
                  premisesId.add(assetRecord.vlocity_cmt__PremisesId__c);
                  List<Asset> asset1stList = inactiveAssetMap.get(assetRecord.vlocity_cmt__PremisesId__c);
                  if(asset1stList == null)
                      asset1stList = new List<Asset>();
                  asset1stList.add(assetRecord);
                  inactiveAssetMap.put(assetRecord.vlocity_cmt__PremisesId__c,asset1stList); 
              }
              if(assetRecord.vlocity_cmt__PremisesId__c != null) {
                  premisesId.add(assetRecord.vlocity_cmt__PremisesId__c);
                  List<Asset> asset1stList = assetMap.get(assetRecord.vlocity_cmt__PremisesId__c);
                  if(asset1stList == null)
                      asset1stList = new List<Asset>();
                  asset1stList.add(assetRecord);
                  assetMap.put(assetRecord.vlocity_cmt__PremisesId__c,asset1stList); 
              } 
          }
      }
      
      for (vlocity_cmt__Premises__c premises : premisesRecord )  {
          for (Lead leads : premises.vlocity_cmt__Leads__r) {
              if(leads.Status == Constants.LEAD.STATUS.ON_HOLD &&
                 leads.Sub_Status__c == Constants.LEAD.SUB_STATUS.PENDING_PROOF_OF_RESIDENCE &&
                 leads.vlocity_cmt__PremisesId__c	== premises.Id && inactiveAssetMap.size() > 0 &&
                 inactiveAssetMap.get(premises.Id).size() == assetMap.get(premises.Id).size()
                ) {
                    leads.Status = Constants.LEAD.STATUS.IN_PROGRESS;
                    System.debug('Lead status is changed'+leads.Status);
                    leads.Sub_Status__c = Constants.LEAD.SUB_STATUS.NEEDS_FOLLOW_UP;
                    assetLead.add(leads);
                }
          }
      }
      if(assetLead.size() > 0){
          update assetLead;
      }
  }
 
  public static void changeAccountStatus(List<Asset> assetList) {

    List<Account> accountList =new List<Account>();
    Map<id, String> accountIdForStatus = new Map<id, String>();
    for(Asset assetData :assetList) {
      accountIdForStatus.put(assetData.accountId, assetData.vlocity_cmt__ProvisioningStatus__c);
    }
    for(Account accountdata : [SELECT Id, vlocity_cmt__Status__c FROM Account WHERE Id = :accountIdForStatus.keyset()]) {
      accountdata.vlocity_cmt__Status__c = accountIdForStatus.get(accountdata.Id);
      accountList.add(accountdata);
    }
    Upsert accountList;
  }
}