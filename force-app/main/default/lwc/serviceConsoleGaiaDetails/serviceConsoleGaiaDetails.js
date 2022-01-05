/**
 * @group CSR Console.
 * @description Will show the GAIA details when disabled.
 */

import { api, LightningElement } from 'lwc';

export default class serviceConsoleGaiaDetails extends LightningElement {
  @api gaiaDetails;
  isAccordionOpened = false;

  /**
   * @description To set the GAIA details.
   */
  connectedCallback() {
    if (this.gaiaDetails) {
      if (this.gaiaDetails.creationTime) {
        this.gaiaDetails.creationTime = new Date(this.gaiaDetails.creationTime * 1000);
      }
      this.gaiaDetails.verified = this.setYesOrNo(this.gaiaDetails.verified);
      this.gaiaDetails.disabled = this.setYesOrNo(this.gaiaDetails.disabled);
    }
  }
  /**
   * @description To set the Yes/No based on value.
   * @param value - boolean value
   * @return string
   */
  setYesOrNo(value) {
    if (value) {
      return 'Yes';
    } else {
      return 'No';
    }
  }

  /**
   * @description To handle the header click.
   */
  toggleAccordion(){
    this.isAccordionOpened = !this.isAccordionOpened;
  }
}