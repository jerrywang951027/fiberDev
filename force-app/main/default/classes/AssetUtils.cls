/**
 * @group Asset
 * @description Returning Asset & calling LeadUtil class according to the inactive Asset.
 */
public class AssetUtils {

  /**
   * @description If there is a Premises related to Asset & Lead is present, return true.
   * @param premisesRecord a vlocity_cmt__Premises__c record
   * @return Boolean
   **/
  public static Boolean isPremisesDisconnected(vlocity_cmt__Premises__c premisesRecord) {

    // TODO(b/187399967) Check convert lead condition,leads are not
    // being converted as Salesforce standard functionality.
    if ((premisesRecord.vlocity_cmt__Assets__r == null ||
        premisesRecord.vlocity_cmt__Assets__r.isEmpty()) &&
        (premisesRecord.vlocity_cmt__Leads__r == null ||
        premisesRecord.vlocity_cmt__Leads__r.isEmpty())) {
      return true;
    }
    return false;
  }
    /**
   * @description If there is a Premises related to Asset & Lead is present, return true.
   * @param premisesRecord a vlocity_cmt__Premises__c record
   * @return Boolean
   **/
  public static Boolean isInactiveAssetsWithLead(vlocity_cmt__Premises__c premisesRecord) {
    if ((premisesRecord.vlocity_cmt__Assets__r == null ||
        premisesRecord.vlocity_cmt__Assets__r.isEmpty()) &&
        (premisesRecord.vlocity_cmt__Leads__r != null ||
        !premisesRecord.vlocity_cmt__Leads__r.isEmpty())) {
      return true;
    }
    return false;
  }

  /**
   * @description Returns a list of Premises that are disconnected.
   * @param premisesId Set of vlocity_cmt__Premises__c Ids
   * @return List of Premises that are disconnected
   **/
  public static List<vlocity_cmt__Premises__c> getDisconnectedPremises(Set<Id> premisesId) {
    List<vlocity_cmt__Premises__c> disconnectedPremises = new List<vlocity_cmt__Premises__c>();
    // Holding all Premises which are not inactive Assets & Leads associated to it.
    for (vlocity_cmt__Premises__c premisesRecord : [
        SELECT
          Id,
          vlocity_cmt__City__c,
          vlocity_cmt__Country__c,
          vlocity_cmt__Geolocation__Longitude__s,
          vlocity_cmt__Geolocation__Latitude__s,
          vlocity_cmt__StreetAddress__c,
          vlocity_cmt__PostalCode__c,
          vlocity_cmt__State__c,
          (SELECT Id
           FROM vlocity_cmt__Assets__r
           WHERE
             Status != :Constants.ASSET.STATUS.INACTIVE),
          (SELECT
             Id,
             Is_Converted__c,
             Status,
             Sub_Status__c
           FROM vlocity_cmt__Leads__r
           WHERE
             Is_Converted__c = false)
        FROM
          vlocity_cmt__Premises__c
        WHERE
          Id IN :premisesId]) {
      if (isPremisesDisconnected(premisesRecord)) {
        disconnectedPremises.add(premisesRecord);
      }
    }
    return disconnectedPremises;
  }
}