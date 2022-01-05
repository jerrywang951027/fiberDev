/**
 * @group CSR Console.
 * @description Displays radio button with mobile numbers as labels.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class authenticationRadioButtonSMS extends OmniscriptBaseMixin(LightningElement) {
  @api contactDetails;

  /**
   * @description Handler to set the options.
   */
  get options() {
    return [
      { label: `${this.contactDetails.otherPhone}`, value: `${this.contactDetails.otherPhone}`},
      { label: `${this.contactDetails.primaryPhone}`, value: `${this.contactDetails.primaryPhone}`}
    ];
  }

  /**
   * @description Handler to update the Omniscript JSON.
   */
  handleChange(event) {
    const selectedOption = event.detail.value;
    this.omniApplyCallResp({"smsAuthentication": selectedOption});
  }
}