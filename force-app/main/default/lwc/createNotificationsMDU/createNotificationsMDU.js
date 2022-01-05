/**
 * @group CSR Console
 * @description It Will launch CON_CreateNotifications omniscirpt when 
 * Create Notification button is clicked.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class CreateNotificationsMDU extends OmniscriptBaseMixin(LightningElement) {
  @api recordId;

  /**
   * @description Method to get premises record Id.
   */
  get premisesRecordId(){
    return {"premisesId": this.recordId};
  }
}