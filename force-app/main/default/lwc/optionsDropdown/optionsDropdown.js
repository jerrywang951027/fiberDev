/**
 * @group CSR Console
 * @description It Will display list of Order actions on overview tab of service console
 *     based on Order type, subtype and delivery method.
 */
import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const OPTIONS = {
  CANCEL : 'Cancel',
  CONFIGURE : 'Configure',
  RESCHEDULE : 'Reschedule',
  RESCHEDULE_APPOINTMENT : 'Reschedule Appointment',
  RETURN_DEVICES : 'Return Devices',
  SIK_PICK_UP : 'SIK Pick Up'
};
const ORDER_TYPE = {
  SUSPEND : 'Suspend',
  DISCONNECT : 'Disconnect',
  PAUSE : 'Pause',
  MOVE : 'Move',
  CHANGE_SERVICES : 'Change Services',
  ACCOUNT_TRANSFER : 'Account Transfer',
  NEW_INSTALL : 'New Install'
};
const INSTALLATION_TYPES = {
  SELF_INSTALLATION : 'Self Installation',
  PROFESSIONAL_INSTALLATION : 'Professional Installation'
}
const OPTION_VALUES = {
  RETURN_DEVICES : 'ReturnDevices',
  RESCHEDULE_APPOINTMENT : 'RescheduleAppointment'
}

export default class OverviewOptionsDropdown extends OmniscriptBaseMixin(LightningElement) {

  @api orderDetails;

  @track option = OPTIONS;
  @track optionValue = OPTION_VALUES;

  contextId = {};
  contextIdForSIKPickup = {};
  seletedOption = '';

  /**
   * @description Method to call loadStyles.
   */
  connectedCallback(){
    this.loadStyles();
  }

  /**
   * @description Method to get boolean value for opening cancel omniscript.
   */
  get isCancelSelected(){
    return this.seletedOption === OPTIONS.CANCEL ? true : false;
  }

  /**
   * @description Method to get boolean value for opening configure omniscript.
   */
  get isConfigureSelected(){
    return this.seletedOption === OPTIONS.CONFIGURE ? true : false;
  }

  /**
   * @description Method to get boolean value for opening SIKPickup omniscript.
   */
   get isSIKPickUpSelected(){
    return this.seletedOption === OPTIONS.SIK_PICK_UP ? true : false;
  }

  /**
   * @description Method to get boolean value for enable/disable cancel button.
   */
  get isShowCancel(){
    if (this.orderDetails && (this.orderDetails[0].order.type == ORDER_TYPE.SUSPEND ||
        this.orderDetails[0].order.type == ORDER_TYPE.DISCONNECT ||
        this.orderDetails[0].order.isChangesAllowed == false)) {
      return true;
    }
    else {
      return false;
    }
  }

  /**
   * @description Method to get boolean value for enable/disable configure button.
   */
  get isShowConfigure(){
    if (this.orderDetails && (this.orderDetails[0].order.type == ORDER_TYPE.SUSPEND ||
        this.orderDetails[0].order.type == ORDER_TYPE.PAUSE ||
        this.orderDetails[0].order.type == ORDER_TYPE.MOVE ||
        this.orderDetails[0].order.type == ORDER_TYPE.ACCOUNT_TRANSFER ||
        this.orderDetails[0].order.isChangesAllowed == false )) {
      return true;
    }
    else {
      return false;
    }
  }

  /**
   * @description Method to get boolean value for enable/disable reschedule button.
   */
  get isShowReschdule(){
    if (this.orderDetails && (this.orderDetails[0].order.type == ORDER_TYPE.PAUSE ||
        this.orderDetails[0].order.type == ORDER_TYPE.DISCONNECT ||
        this.orderDetails[0].order.type == ORDER_TYPE.CHANGE_SERVICES ||
        this.orderDetails[0].order.type == ORDER_TYPE.NEW_INSTALL ||
        this.orderDetails[0].order.isChangesAllowed == true )) {
      return false;
    }
    else {
      return true;
    }
  }

  /**
   * @description Method to get boolean value for enable/disable return device button.
   */
  get isShowReturnDevices(){
    if (this.orderDetails && (this.orderDetails[0].order.type == ORDER_TYPE.DISCONNECT ||
        this.orderDetails[0].order.type == ORDER_TYPE.CHANGE_SERVICES)) {
      return false;
    }
    else {
      return true;
    }
  }

  /**
   * @description Method to get boolean value for enable/disable SIKPickup button.
   */
  get isShowSIKPickup(){
    if (this.orderDetails && (this.orderDetails[0].order.type == ORDER_TYPE.NEW_INSTALL ||
        this.orderDetails[0].order.type == ORDER_TYPE.CHANGE_SERVICES) &&
        (this.orderDetails[0].orderDetails.productSubType ==
        INSTALLATION_TYPES.SELF_INSTALLATION)) {
      return false;
    }
    else {
      return true;
    }
  }

  /**
   * @description Method to get boolean value for enable/disable reschedule appointment button.
   */
  get isShowReschduleAppointment(){
    if (this.orderDetails && (this.orderDetails[0].orderDetails.productSubType ==
      INSTALLATION_TYPES.PROFESSIONAL_INSTALLATION)) {
      return false;
    }
    else {
      return true;
    }
  }

  /**
   * @description Will fire when option clicks on dropdown
   *     sets contextId as input for omniscripts.
   */
  onOptionClick(event) {
    this.seletedOption = event.detail.value;
    this.contextId = {'orderId': this.orderDetails[0].order.id};
    this.contextIdForSIKPickup = {'ContextId': this.orderDetails[0].order.id};
    this.openModal();
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

  /**
   * @description Method to style button.
   */
  loadStyles() {
    const style = document.createElement('style');
    style.innerText = `.button-menu-styling .slds-dropdown__item>a {display:block;text-align:right;}
        .button-menu-styling .slds-dropdown__item>a[aria-disabled=false] {color: #0176d3;}`;
    setTimeout(() => {
      this.template.querySelector('lightning-button-menu').appendChild(style);
    }, 100);
  }
}