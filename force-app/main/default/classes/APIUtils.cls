/*
 * @group APIUtils
 * @description Utility methods for API details.
 */
public class APIUtils {

  /*
   * @description Get custom metadata for API calls.
   * @param masterLabel Will differentiate metadata record
   * @return API_Base_Info__mdt
   */
  public static API_Base_Info__mdt getCustomMetadataRecords(String masterLabel) {

    API_Base_Info__mdt metadataList = [
        SELECT Id, Api_Password__c, Api_Username__c, Base_URL__c, Content_Type__c, (
            SELECT Id, Base_Api__c, Endpoint__c, Method__c
            FROM API_Utils__r
            WHERE MasterLabel = :masterLabel
            )
        FROM API_Base_Info__mdt
        WHERE Id IN (
            SELECT Base_Api__c
            FROM API_Info__mdt
            WHERE MasterLabel = :masterLabel
            )
    ];
    return metadataList;
  }
}