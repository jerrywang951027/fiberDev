/**
 * @group CSR Console.
 * @description Will show the Devices Return. 
 */

import { api, LightningElement } from 'lwc';

const INITIAL_DEVICE_COUNT = 5;
const NO_RECORDS_FOUND_MESSAGE = 'There is no devices associated with the location.';
const ZERO = 0;

export default class ServiceConsoleDevice extends LightningElement {
  @api devices;
  deviecRecords;
  devicesPaginationCounter = ZERO;
  isDevices = false;
  isPrevButton = false;
  isNextButton = false;
  noRecordsFoundMessage = NO_RECORDS_FOUND_MESSAGE;

  /**
   * @description To get the next 5 devices.
   */
  connectedCallback() {
    if (this.devices && this.devices.length > 0 && !this.checkAllDevicesForId()) {
      this.isDevices = true;
      this.devicesPaginationCounter += INITIAL_DEVICE_COUNT;
      this.deviecRecords = this.devices.slice(ZERO, this.devicesPaginationCounter);
      if (this.devices.length <= INITIAL_DEVICE_COUNT) {
        this.isNextButton = false;
      } else {
        this.isNextButton = true;
      }
    } else {
      this.isDevices = false;
    }
  }

  /**
   * @description To get the next 5 devices.
   */
  loadNextDevices() {
    if (this.devicesPaginationCounter < this.devices.length) {
      this.devicesPaginationCounter += INITIAL_DEVICE_COUNT;
      this.deviecRecords = this.devices.slice(ZERO, this.devicesPaginationCounter);
      this.isPrevButton = true;
      if (this.devicesPaginationCounter >= this.devices.length) {
        this.isNextButton = false;
      }
    }
  }

  /**
   * @description To get the previous 5 devices.
   */
  loadPreviousDevices() {
    if (this.devicesPaginationCounter !== INITIAL_DEVICE_COUNT) {
      this.devicesPaginationCounter -= INITIAL_DEVICE_COUNT;
      this.deviecRecords = this.devices.slice(ZERO, this.devicesPaginationCounter);
      this.isNextButton = true;
      if (this.devicesPaginationCounter === INITIAL_DEVICE_COUNT) {
        this.isPrevButton = false;
      }
    }
  }

  /**
   * @description To get the next 5 devices.
   */
  checkAllDevicesForId(){
    let isAllDevices = false;
    if (this.devices && this.devices.length > 0) {
      isAllDevices = this.devices.every(device => !device.hasOwnProperty('id') || device.id === "" );
    }
    return isAllDevices;
  }
}