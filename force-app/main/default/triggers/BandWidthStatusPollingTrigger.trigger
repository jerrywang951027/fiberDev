/**
 * @group BandWidth_Status_Polling__e
 * @description Trigger to handle events on BandWidth_Status_Polling__e event.
 */
trigger BandWidthStatusPollingTrigger on BandWidth_Status_Polling__e (
    after insert) {

  if(Trigger.isAfter) {
    if(Trigger.isInsert) {
      // Method that handles all after update logic.
      BandwidthStatusPollingTriggerHandler.afterInsertHandler(
        Trigger.new);
    }
  }

}