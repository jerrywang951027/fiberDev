/**
 * @group UpdateRequest
 * @description The Update request will get the device ownership and update mask.
 */
public class UpdateRequest {
    public DeviceOwnershipChangeRequestOwnership  deviceOwnership{get;set;}
    public String updateMask{get;set;}
}