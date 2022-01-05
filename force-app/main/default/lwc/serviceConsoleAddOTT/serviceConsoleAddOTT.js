/**
 * @group CSR Console.
 * @description Displays OTT credit and debit radio options for Add OTT omniscript.
 */
import { LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class serviceConsoleAddOTT extends OmniscriptBaseMixin(LightningElement) {
  ottTransactionOption;

  /**
   * @description Sets the radio option from the Omniscript JSON.
   */
  connectedCallback() {
    if (this.omniJsonData && this.omniJsonData.submitOneTimeTransaction) {
      this.ottTransactionOption = this.omniJsonData.submitOneTimeTransaction.ottTransactionOption;
    }
  }

  /**
   * @description Sets the radio options for credit OTT
   * @return returns array of options
   */
  get creditOptions() {
    return [
      { label: 'Appointment Related', value: 'Appointment Related' },
      { label: 'Contract Buyout', value: 'Contract Buyout' },
      { label: 'Failed Install', value: 'Failed Install' },
      { label: 'Fee Credit', value: 'Fee Credit' },
      { label: 'Individual OOS', value: 'Individual OOS Incident' },
      { label: 'Poor Support Experience', value: 'Poor Support Experience' },
      { label: 'Product Issue', value: 'Product Issue' },
      { label: 'Reconnect Fee Waiver', value: 'Reconnect Fee Waiver' }
    ];
  }

  /**
   * @description Sets the radio option for debit OTT
   * @return returns array of options
   */
  get debitOptions() {
    return [
      {
        label: 'Customer needs to be charged for lost/stolen/unreturned equipment',
        value: 'LOST/UNRETURNED EQUIPMENT'
      }
    ];
  }

  /**
   * @description Handler to update the Omniscript JSON.
   * @param event : radio option selected
   */
  handleChange(event) {
    const selectedOption = event.detail.value;
    this.omniApplyCallResp({ "ottTransactionOption": selectedOption });
  }
}