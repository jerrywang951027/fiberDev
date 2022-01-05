public class PropertyLightningMapController {
  @AuraEnabled
  public static List<Property__c> getProperties(ID recordId) {
    Decimal latitude;
    Decimal longitude;
    List< Property__c> propList =  [Select Id,
                                      Name,
                                      Property_Status__c,
                                      Primary_City__c,
                                      Primary_State__c,
                                      geocodes__latitude__s ,
                                      geocodes__longitude__s,
                                      Primary_Zip_Code__c,
                                      Primary_Street_Address__c,
                                      Primary_Country__c
                                    FROM property__c
                                    WHERE id =:recordid];


    for (Property__c prop: propList) {
      latitude = prop.Geocodes__Latitude__s;
      longitude = prop.Geocodes__Longitude__s;
    }



    List<Property__c> nearByProps =  [Select Id,
                                        Name,
                                        Primary_City__c,
                                        Primary_State__c,
                                        Opportunity_Stage__c ,
                                        Property_Status__c,
                                        geocodes__latitude__s ,
                                        geocodes__longitude__s,
                                        Primary_Zip_Code__c,
                                        Primary_Street_Address__c,
                                        Primary_Country__c
                                      From property__c
                                      WHERE Distance(Geocodes__c,
                                       geolocation(:latitude, :longitude),
                                       'mi') < 5 ];
    return nearByProps ;
  }
}