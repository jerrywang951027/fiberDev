/**
 * @group CSR Console.
 * @description Will show the Device return details.
 */

import { api, LightningElement } from 'lwc';

const EXTENDER = "Extender";
const EXTENDER_ICON = "utility:broadcast";

const ONT = "ONT";
const ONT_ICON = "utility:connected_apps";

const PHONE_BOX = "Phone Box";
const PHONE_BOX_ICON = "utility:desktop_and_phone";

const POWER_ADAPTER = "Power Adapter";
const POWER_ADAPTER_ICON = "utility:apex_plugin";

const ROUTER = "Router";
const ROUTER_ICON = "utility:events";

const STATUS_NEW = "New";
const STATUS_ACTIVE = "Active";
const STATUS_SUSPENDED = "Suspended";
const STATUS_DELETED = "Deleted";
const STATUS_NEW_CLASS = "device-return-status-new";
const STATUS_ACTIVE_CLASS = "device-return-status-active";
const STATUS_SUSPENDED_CLASS = "device-return-status-suspended";
const STATUS_DELETED_CLASS = "device-return-status-deleted";

const OLI_ID_PREFIX = "802";
const ACTIVE_ASSET_ID_PREFIX = "02i";

export default class ServiceConsoleDevicesReturn extends LightningElement {
  @api device;

  contextIdForLostOrStolenDevice = '';
  isRestoreLostOrStolenSelected = false;

  /**
  * @description Get the icon based on the device product subtype.
  */
  get deviceIcon() {
    let icon = '';
    switch (this.device.productSubType) {
      case ROUTER:
        icon = ROUTER_ICON;
        break;
      case ONT:
        icon = ONT_ICON;
        break;
      case EXTENDER:
        icon = EXTENDER_ICON;
        break;
      case PHONE_BOX:
        icon = PHONE_BOX_ICON;
        break;
      case POWER_ADAPTER:
        icon = POWER_ADAPTER_ICON;
        break;
      default:
        icon = ROUTER_ICON
    }
    return icon;
  }

  /**
  * @description Method to set the details sent to the Omniscript.
  * @return boolean.
  */
  get hasDeviceId() {
    if (this.device.id && this.device.id.length > 0) {
      console.log("device details==>",this.device);
      return true;
    } else {
      return false;
    }
  }

  /**
  * @description Get the status class based on the device provisioning status.
  */
  get deviceProvisioningStatusColor() {
    let provsioningStatusClassName = '';
    switch (this.device.provisioningStatus) {
      case STATUS_NEW:
        provsioningStatusClassName = STATUS_NEW_CLASS;
        break;
      case STATUS_ACTIVE:
        provsioningStatusClassName = STATUS_ACTIVE_CLASS
        break;
      case STATUS_SUSPENDED:
        provsioningStatusClassName = STATUS_SUSPENDED_CLASS;
        break;
      case STATUS_DELETED:
        provsioningStatusClassName = STATUS_DELETED_CLASS;
        break;
      default:
        provsioningStatusClassName = STATUS_NEW_CLASS;
    }
    return provsioningStatusClassName;
  }

  /**
  * @description Shows the Device Return Details component.
  */
  openDeviceDetailsModal() {
    this.template.querySelector('c-service-console-device-return-details').openModal();
  }

  /**
  * @description Shows the Device Return Flyout component.
  */
  openDeviceReturnFlyout() {
    this.template.querySelector('c-service-console-device-return-flyout').openModal();
  }

  /**
  * @description Shows the Device Swap component.
  */
  openDeviceSwap() {
    this.template.querySelector('c-service-console-device-swap').openModal();
  }

  /**
  * @description Method to check if its an OLI.
  * @return boolean.
  */
  get isOrderLineItem() {
    const id = this.device.id;
    return id.startsWith(OLI_ID_PREFIX);
  }

/**
  * @description Method to check if its an Asset.
  * @return boolean.
  */
  get isActiveAsset() {
    const id = this.device.id;
    return id.startsWith(ACTIVE_ASSET_ID_PREFIX);
  }

  /**
  * @description Method to check if its an Asset.
  * @return boolean.
  */
  get isDisableReportLostOrStolenButton() {
    const id = this.device.id;
    return !id.startsWith(ACTIVE_ASSET_ID_PREFIX);
  }

  /**
  * @description Method to enable the return button.
  * @return boolean.
  */
  get disableReturnButton() {
    if (!this.device.showReturnButton) {
      return true;
    } else {
      return false;
    }
  }

  /**
  * @description Method set the options for Swap?Return combobox.
  * @return options.
  */
    get comboBoxOptions() {
        return [
            { label: 'Return', value: 'return' },
            { label: 'Swap', value: 'swap' },
            { label: 'Report Lost/Stolen', value: 'reportLostOrStolen' }
        ];
    }

  /**
  * @description Method to handle the combobox selection.
  */
    handleComboboxSelection(event){
        const selectedItemValue = event.detail.value;
        console.log("selectedItemValue",selectedItemValue);
      if (selectedItemValue === 'return') {
          this.openDeviceDetailsModal();
      } else if (selectedItemValue === 'reportLostOrStolen') {
        this.isRestoreLostOrStolenSelected = true;
        this.contextIdForLostOrStolenDevice = {'ContextId': this.device.id};
        console.log("isRestoreLostOrStolenSelected",this.isRestoreLostOrStolenSelected);
        console.log("contextIdForLostOrStolenDevice",this.contextIdForLostOrStolenDevice);
        this.openModal();
      } else {
          this.openDeviceSwap();
      }
    }

  /**
   * @description Method to launch vlocity modal.
   */
  openModal(){
    Promise.resolve().then(() => {
      let modal = this.template.querySelector('vlocity_cmt-modal') ?
          this.template.querySelector('vlocity_cmt-modal') :
          this.template.querySelector('c-modal');
      if (modal) {
        modal.openModal();
      } else {
        console.log('modal is undefined');
      }
    }).catch(error => console.log(error.message));
  }

  /**
   * @description Method to close vlocity modal.
   */
  closeModal() {
    Promise.resolve().then(() => {
      let modal = this.template.querySelector('vlocity_cmt-modal') ?
          this.template.querySelector('vlocity_cmt-modal') :
          this.template.querySelector('c-modal');
      if (modal) {
        modal.closeModal();
      } else {
        console.log('modal is undefined');
      }
    }).catch(error => console.log(error.message));
  }
}