/**
 * @group LeadCreationFlow
 * @description To call AddressServiceability LWC and use this in the Flow screen.
 */
import { LightningElement, api } from 'lwc';
import pubsub from 'c/pubsub';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class LeadCreationFlow extends LightningElement {

  // Declare and Initialize Decorators
  @api addressId = "";
  @api checkAddress = "";
  @api city = "";
  @api eligibility = "";
  @api isAccountVerified = false;
  @api isAddressId = false;
  @api isServiceable = false;
  @api latitude = "";
  @api longitude = "";
  @api radioSelection = "";
  @api state = "";
  @api status = "";
  @api serviceability = "";
  @api street = "";
  @api unitNumber = "";
  @api zip = "";

  /**
   * @description Register pubsub callback for an event.
   */
  connectedCallback() {
    pubsub.register('notifyparent', this.handleEvent.bind(this));
  }

  /**
   * @description Unregister pubsub callback for an event.
   */
  disconnectedCallback() {
    pubsub.unregisterAll(this);
  }

  /**
   * @description To share the details of addressServicability LWC to the Flow
   * @param messageFromEvt Details of addressServicability LWC
   */
  handleEvent(messageFromEvt) {
    if (messageFromEvt !== undefined) {
      if (messageFromEvt.hasOwnProperty('radioSelection')) {
        this.radioSelection = messageFromEvt.radioSelection;
      }
      if (messageFromEvt.hasOwnProperty('accountVerify')) {
        this.isAccountVerified = messageFromEvt.accountVerify;
      }
      if (messageFromEvt.hasOwnProperty('addressId')) {
        this.addressId = messageFromEvt.addressId;
      }
      if (messageFromEvt.hasOwnProperty('serviceability')) {
        this.serviceability = messageFromEvt.serviceability;
      }
      if (messageFromEvt.hasOwnProperty('eligibility')) {
        this.eligibility = messageFromEvt.eligibility;
      }
      if (messageFromEvt.hasOwnProperty('unitNumber')) {
        this.unitNumber = messageFromEvt.unitNumber;
      }
      if (messageFromEvt.hasOwnProperty('street')) {
        this.street = messageFromEvt.street;
      }
      if (messageFromEvt.hasOwnProperty('city')) {
        this.city = messageFromEvt.city;
      }
      if (messageFromEvt.hasOwnProperty('state')) {
        this.state = messageFromEvt.state;
      }
      if (messageFromEvt.hasOwnProperty('zip5')) {
        this.zip = messageFromEvt.zip5;
      }
      if (messageFromEvt.hasOwnProperty('latitude')) {
        this.latitude = messageFromEvt.latitude;
      }
      if (messageFromEvt.hasOwnProperty('longitude')) {
        this.longitude = messageFromEvt.longitude;
      }
      if (messageFromEvt.hasOwnProperty('checkAddress')) {
        this.checkAddress = messageFromEvt.checkAddress;
      }
      if (messageFromEvt.hasOwnProperty('status')) {
        this.status = messageFromEvt.status;
      }
      if (this.addressId) {
        this.isAddressId = false;
      } else {
        this.isAddressId = true;
      }
      if (this.serviceability === "SERVICEABLE") {
        this.isServiceable = false;
      } else {
        this.isServiceable = true;
      }
    }
  }
}