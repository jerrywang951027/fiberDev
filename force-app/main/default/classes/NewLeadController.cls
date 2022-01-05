public class NewLeadController {
  @AuraEnabled
  public static Id getMxuRecordTypeId () {
    return RecordTypeUtils.LEAD_MXU;
  }

  @AuraEnabled
  public static Id getDefaultRecordTypeId() {
    Schema.DescribeSObjectResult dsr = Lead.SObjectType.getDescribe();
    for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
      if (rti.isDefaultRecordTypeMapping()) {
        return rti.getRecordTypeId();
      }
    }
    return null;
  }
}