/**
 * @group DeviceWrapper
 * @description The Device wrapper to wrap the device values and sort the device list
 */
public with sharing class DeviceWrapper implements Comparable{
  public String serial{get;set;}
  public String gpn{get;set;}
  public String description{get;set;}
  public String userMessage{get;set;}

  //Method for sorting the device list.
  public Integer compareTo(Object otherObjectInstance){
    DeviceWrapper otherDeviceWrapperInstance = (DeviceWrapper)otherObjectInstance;
    if (this.serial<otherDeviceWrapperInstance.serial){
      return -1;
    } else {
      return 1;
    }
  }
}