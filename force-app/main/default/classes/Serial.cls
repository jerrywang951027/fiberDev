/**
 * @group Serial
 * @description The serial to get the criteria of parent device.
 */
public class Serial {
  public SerialKey serialKey{get;set;}
  public ParentSerialKey parentSerialKey{get;set;}
  public String lastKnownGoogleLocationCode{get;set;}
  public DeviceOwnershipResponse deviceOwnership{get;set;}
  public String lastUpdatedTime{get;set;}
  public String currentStatus{get;set;}
}