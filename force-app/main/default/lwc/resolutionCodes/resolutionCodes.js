/**
 * @group resolutioncodes
 * @description for showing resolution code according to
 * type,subtype and Symptom fields.
 */
import { api, LightningElement, track} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class resolutioncodes extends OmniscriptBaseMixin(LightningElement) {
  @track options;
  _ticketId;

  @api
  set ticketId(data) {
    if (data) {
      this._ticketId = data;
    }
  }
  get ticketId() {
    return this._ticketId;
  }

  /**
   * calling Apex method by getting contextId from Omniscript.
   */
  connectedCallback() {
    if (this.ticketId) {
      this.populateResolutionCodes();
    }
  }

  /**
   * calling Apex method
   */
  populateResolutionCodes() {
    let result;
    let inputMap = {'ticketId': this.ticketId};
    let params = {
      input: JSON.stringify(inputMap),
      sClassName: 'IssueTicket',
      sMethodName: 'populateResolutionCodes',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      result = (typeof response.result.options === 'string') ?
          JSON.parse(response.result.options) : response.result.options;
      this.onResponseSuccess(result);
    }).catch (error => {
         this.searchMessage = false;
    });
  }

  onResponseSuccess(result) {
    this.options = result;
  }

  /**
   * pass the resolutionCodes to OmniScript.
   */
  handleOnChange(event) {
    const selectedValue = event.target.value;
    this.omniApplyCallResp({'selectedResolutionCode': selectedValue});
  }

  /**
   * From the reolve button we are validating Resolutions Code.
   */
  onResolve(event) {
    if (this.handleValidate()) {
      this.omniNextStep();
    }
  }

  /**
   * This Method handle the validation for Resolutions Code.
   */
  handleValidate() {
    const allValid = [...this.template.querySelectorAll('.validation-required')]
        .reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    return allValid;
  }
}