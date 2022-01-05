import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class serviceConsoleDeviceSwap extends OmniscriptBaseMixin(LightningElement) {
  
  @api device;

 /**
   * @description Method to set the details sent to the Omniscript.
   * @return deviceDetails
   */
  get deviceDetails() {
    const deviceDetails = new Object();
    deviceDetails['ContextId'] = this.device.id;
    return deviceDetails;
  }
   /**
   * @description Opens the modal.
   */
  @api
  openModal() {
    Promise.resolve().then(() => {
      const modal = this.template.querySelector("vlocity_cmt-modal") ?
        this.template.querySelector("vlocity_cmt-modal") :
        this.template.querySelector("c-modal");
      if (modal) {
        modal.openModal();
      } else {
        console.log("modal is undefined");
      }
    }).catch(error => console.log(error.message));
  }

  /**
   * @description Method to close the modal on click of a Cancel button.
   */
  closeModal() {
    Promise.resolve().then(() => {
      const modal = this.template.querySelector("vlocity_cmt-modal") ?
          this.template.querySelector("vlocity_cmt-modal") :
          this.template.querySelector("c-modal");
      if (modal) {
        modal.closeModal();
      } else {
        console.log("modal is undefined");
    }
    }).catch(error => console.log(error.message));
  } 
}