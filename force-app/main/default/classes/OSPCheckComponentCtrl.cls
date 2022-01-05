public class OSPCheckComponentCtrl {

  @AuraEnabled
  public static List<OSP_Review__c> findRelatedOSP(Id recId) {
    if (recId != null) {
      List<OSP_Review__c> ospList = [
          SELECT
            Id, Name,
            TechOps_Serviceability_Form_Status__c
          FROM
            OSP_Review__c
          WHERE
            Property__c = :recId
          ORDER BY
            CreatedDate DESC
          LIMIT 1];
      if (!ospList.isEmpty()) {
        if (ospList[0].TechOps_Serviceability_Form_Status__c ==
            'Reviewed') {
          ospList.add(createOSP(recId));
          return ospList;
        } else {
          return ospList;
        }
      } else {
        return (new List<OSP_Review__c>{createOSP(recId)});
      }
    }
    return null;
  }

  private static OSP_Review__c createOSP(Id recId) {
    List<Property__c> propertyObj = [
        SELECT Id, Name,
          Primary_Street_Address__c,
          Primary_City__c,
          Primary_State__c,
          Primary_Zip_Code__c,
          Primary_Country__c,
          Build_Type__c,
          Geocodes__Latitude__s,
          Geocodes__Longitude__s,
          Market__c,
          Property_owner__c,
          Property_Manager__c,
          Property_Developer__c,
          PRID__c,
          Property_Classification_v2__c,
          Total_Number_of_Units__c,
          Walls_Close_Date__c
        FROM
          Property__c
        WHERE
          Id = :recId];
    OSP_Review__c newOSP = new OSP_Review__c();
    newOSP.Address__c =
        + propertyObj[0].Primary_Street_Address__c + '\n'
        + propertyObj[0].Primary_City__c + ', '
        + propertyObj[0].Primary_State__c + ' '
        + propertyObj[0].Primary_Zip_Code__c + '\n'
        + propertyObj[0].Primary_Country__c;
    newOSP.Build_Method__c = propertyObj[0].Build_Type__c;
    newOSP.Latitude__c = propertyObj[0].Geocodes__Latitude__s;
    newOSP.Longitude__c = propertyObj[0].Geocodes__Longitude__s;
    newOSP.Property_Market__c = propertyObj[0].Market__c;
    newOSP.POC_Type__c =
        propertyObj[0].Property_owner__c != null ? 'Property Owner'
        : (propertyObj[0].Property_Manager__c != null ? 'Property Manager'
        : (propertyObj[0].Property_Developer__c != null ? 'Property Developer'
        : null));
    newOSP.PRID__c = propertyObj[0].PRID__c;
    newOSP.Property_Classification__c =
        propertyObj[0].Property_Classification_v2__c;
    newOSP.Property_Name__c = propertyObj[0].Name;
    newOSP.Total_Number_Of_Units__c = propertyObj[0].Total_Number_of_Units__c;
    newOSP.Walls_Closing_Date__c = propertyObj[0].Walls_Close_Date__c;
    newOSP.Property__c = propertyObj[0].Id;
    return newOSP;
  }

  @AuraEnabled
  public static OSP_Review__c insertOSP(OSP_Review__c ospRecord) {
    if (ospRecord != null) {
      insert ospRecord;
      List<OSP_Review__c> newOSPRecord = [
          SELECT
            Id, Name
          FROM
            OSP_Review__c
          WHERE
            Id = :ospRecord.Id];
      return newOSPRecord[0];
    }
    return null;
  }
}