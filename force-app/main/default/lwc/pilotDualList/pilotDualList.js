/**
 * @group Geopointe
 * @description To display Pilot values.
 */
import { api, LightningElement, track } from "lwc";
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
export default class pilotDualList extends OmniscriptBaseMixin(
  LightningElement ) {

  @api options;
  @api pilot;
  @track listValues = [];

  /**
   * @description Onload fetches information from OmnisScript.
   */
  connectedCallback() {
    this.listValues = this.pilot
      ? this.pilot.split(";")
      : [];
    this.omniApplyCallResp({ selectedPilot: this.pilot });
  }

  /**
   * @description Selects the Pilot value and pass to OmniScript.
   */
  handleChange(event) {
    let selectedOptionsList = event.target.value;
    let selectedOptionAsString = selectedOptionsList.join(";");
    this.omniApplyCallResp({ selectedPilot: selectedOptionAsString });
  }
}