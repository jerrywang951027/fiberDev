/**
 * @group CSR Console
 * @description This is created in place of all the out of the box Tab Component.
 *     This will have all the Tabs and will publish Label of the Active Tab to the required
 *     components.
 */
import { api, LightningElement } from 'lwc';
import pubsub from 'vlocity_cmt/pubsub';

export default class ServiceConsoleCustomTabs extends LightningElement {

  @api recordId;

  premisesData;
  serviceAccountId;
  tabLabel = 'Overview';

  /**
   * @description Will be fired when a component is inserted into the DOM.
   *     This will register the pub/sub fired from the locationDropdown component
   *     to get the selected Location Details.
   *     This will also publish the name of the Active Tab to the required components.
   */
  connectedCallback() {
    pubsub.register('serviceAccountChannel',
        {service_account_channel : this.fetchServiceAccountData.bind(this)});
    let tabData = {
      'tabLabel' : this.tabLabel
    }
    pubsub.fire('tabLabelChannel', 'publish_tab_label', tabData);
  }

  /**
   * @description Will be fired when the locationDropdown component will fire the pub/sub on
   *     Location Change and also fire a pubsub to update the Devices.
   * @param messageFromEvent - Id of selected Location along with its Service Account Id
   *     recieved from pub/sub.
   */
  fetchServiceAccountData(messageFromEvent) {
    this.premisesData = messageFromEvent.premisesId;
    this.serviceAccountId = messageFromEvent.serviceAccountId;
    pubsub.fire('serviceDeviceChannel', 'service_device_channel', messageFromEvent);
  }

  /**
   * @description Will be fired when Tab is changed. This will publish the Name of the Active Tab
   *     to the required components.
   * @param event - Details of event.
   */
  handleActiveTab(event) {
    this.tabLabel = event.target.label;
    let tabData = {
      'tabLabel' : this.tabLabel,
      'premisesId' : this.premisesData
    }
    pubsub.fire('tabLabelChannel', 'publish_tab_label', tabData);
  }
}