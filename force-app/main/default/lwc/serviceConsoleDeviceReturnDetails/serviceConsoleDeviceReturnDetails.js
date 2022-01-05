/**
 * @group CSR Console.
 * @description Will show the Device return details flyout.
 */
import { api, LightningElement} from 'lwc';

export default class ServiceConsoleDevicesReturnDetails extends LightningElement {
  @api deviceDetails;

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