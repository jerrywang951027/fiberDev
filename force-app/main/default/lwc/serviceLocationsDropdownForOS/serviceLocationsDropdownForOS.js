/**
 * @group CSR Console
 * @description It Will display Premises in CON_CustomNotifications OmniScript as a dropdown.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class ServiceLocationsDropdownForOS extends OmniscriptBaseMixin(LightningElement) {

  _premisesList;
  selectedServiceAccount = '';

  /**
   * @description Getting values of premisesList, set in the OmniScript as a LWC property
   *     and setting it to the decorator _premisesList.
   * @param data value to be set in the decorator _premisesList.
   */
  @api
  set premisesList(data) {
    if (data) {
      this._premisesList = data;
    }
  }

  /**
   * @description Getter to set the decorator formattedPremisesList with associated Premises
   * of Consumer Account.
   * @return premisesList
   */
  get premisesList() {
    let formattedPremisesList = [{'label': 'Select a Service Location', value: ''}];

    if (this._premisesList && this._premisesList != '') {

      if (Array.isArray(this._premisesList) && this._premisesList.length > 0) {
        this._premisesList.forEach(premisesData => {
          formattedPremisesList.push({ 'label': premisesData.premisesStreetAddress,
              'value': premisesData.id });
        });

      } else if (this._premisesList.constructor === Object) {
        formattedPremisesList.push({ 'label': this._premisesList.premisesStreetAddress,
            'value': this._premisesList.id });
      }

    }

    return formattedPremisesList;
  }

  /**
   * @description Method to get the selected Service Location and update it to Omni JSON Data.
   * @param event - Fired event data.
   */
  getServiceLocation(event) {
    this.selectedServiceAccount = event.detail.value;

    const dataToUpdate = {
      'serviceAccountId': this.selectedServiceAccount
    };

    this.omniUpdateDataJson(dataToUpdate);
  }
}