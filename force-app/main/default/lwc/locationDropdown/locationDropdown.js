/**
 * @group LocationDropDown
 * @description Will show Location details in dropdown.
 *     Fetch serviceAccount and order details on selection.
 */
import { api, LightningElement, track } from 'lwc';
import { fire, register } from 'vlocity_cmt/pubsub';

export default class locationDropdown extends LightningElement {

  @api locationList;
  @api recordId;

  @track isVisible = false;
  @track locationValue;
  @track premisesList = [];

  tabName = 'Overview';

  /**
   * @description Will be fired when a component is inserted into the DOM.
   *     This method will fetch Premises based on Account.
   *     If Premises List has value, then it will fire the event.
   */
  connectedCallback() {
    try {
      register('tabLabelChannel', {
        publish_tab_label: this.fetchTabName.bind(this)
      });

      if (Array.isArray(this.locationList) && this.locationList.length > 0 &&
          this.locationList[0].hasOwnProperty('serviceAccount')) {

        let serviceAccountList = this.locationList[0].serviceAccount
        let premises = [];

        if (Array.isArray(serviceAccountList)) {
          serviceAccountList.forEach((serviceAccount) => {
            premises.push(this.formatAddress(serviceAccount));
          });
        } else {
          premises.push(this.formatAddress(serviceAccountList));
        }
        if (premises.length > 0) {
          premises.sort(function (a, b) {
            return a.label.localeCompare(b.label, undefined, {
                numeric: true,
                sensitivity: 'base'
            });
          });

          this.locationValue = premises[0].value;
          this.firePubSub(premises[0].premisesId, this.locationValue, this.tabName);
          this.premisesList = premises;
          this.isVisible = true;
        } else {
          console.log('No locations to display.');
        }
      } else {
        console.log('No service account associated with the customer.');
      }
    } catch (error) {
      console.log(error);
    }
  }

  /**
   * @description This method will trigger when location value changes.
   */
  onLocationChange(event) {
    this.locationValue = event.detail.value;

    let premises = this.premisesList.find(premises => premises.value == this.locationValue);

    this.firePubSub(premises.premisesId, this.locationValue, this.tabName);
  }

  /**
   * @description Method to format address using data from serviceAccount.
   * @param serviceAccount Selected service account details.
   * @returns premises
   */
  formatAddress(serviceAccount) {
    let premises = {};

    if (serviceAccount.hasOwnProperty('premisesId')) {
      let completeAddress;
      completeAddress = ` ${serviceAccount.premisesStreetAddress}`;
      completeAddress += ` ${serviceAccount.premisesCity}` +
          ` ${serviceAccount.premisesState}`;
      completeAddress += ` ${serviceAccount.premisesPostalCode}`;

      if(serviceAccount.premisesUnitNumber != undefined) {
        completeAddress += ` Unit ${serviceAccount.premisesUnitNumber}`;
        premises.premisesUnitNumber = parseInt(serviceAccount.premisesUnitNumber);
      }
      if (serviceAccount.status != null) {
        completeAddress += ` -- ` + `${serviceAccount.status}`;
      }

      premises.label = completeAddress;
      premises.premisesId = serviceAccount.premisesId;
      premises.value = serviceAccount.id;
    }
    return premises;
  }

  /**
   * @description Method to fire pubsub.
   * @param premisesId Premises Id of the selected location.
   * @param serviceAccountId Service Account Id of selected location.
   * @param tabName Active tab name.
   */
  firePubSub(premisesId, serviceAccountId, tabName) {
    let serviceAccountData = {
      'premisesId': premisesId,
      'serviceAccountId': serviceAccountId,
      'tabName': tabName
    }
    fire('serviceAccountChannel', 'service_account_channel', serviceAccountData);
  }

  /**
   * @description Will be fired when the service console tab component will fire the pub/sub on
   *     tab change.
   * @param tab Tab name of selected tab.
   */
  fetchTabName(tab) {
    this.tabName = tab.tabLabel;
  }
}