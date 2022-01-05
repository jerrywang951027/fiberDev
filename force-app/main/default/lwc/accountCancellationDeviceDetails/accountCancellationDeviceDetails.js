/**
 * @group CSR Console
 * @description Will show the devices information like Devices to Keep and Devices to Return
 *     in Disconnect Order OS Flow
 */

import { api, LightningElement } from 'lwc';
import { cloneDeep } from 'vlocity_cmt/lodash';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const DEVICES_TO_KEEP_MSG = 'No devices on account that user can keep.';
const DEVICES_TO_RET_MSG = 'No devices on account that user can return.';

export default class AccountCancellationDeviceDetails extends OmniscriptBaseMixin(
    LightningElement) {

  _deviceReturnInDays;
  _omniJsonData;
  devicesToKeepMsg = DEVICES_TO_KEEP_MSG;
  devicesToRetMsg = DEVICES_TO_RET_MSG;
  totalPrice;

  /**
   * @description Getting OmniScript JSON data in LWC and setting it to the decorator _omniJsonData
   * @param omniData value to be set in the decorator _omniJsonData
   */
  @api
  set omniJsonData(omniData) {
    if (omniData) {
      this._omniJsonData = omniData;
    }
  }

  /**
   * @description Getter to return decorator _omniJsonData
   * @return _omniJsonData
   */
  get omniJsonData() {
    return this._omniJsonData;
  }

  /**
   * @description Getting value of deviceReturnInDays (60 days) set in the OmniScript as a
   *     LWC property and setting it to the decorator _deviceReturnInDays
   * @param data value to be set in the decorator _deviceReturnInDays
   */
  @api
  set deviceReturnInDays(data) {
    if (data) {
      this._deviceReturnInDays = parseInt(data);
    }
  }

  /**
   * @description Getter to return decorator _deviceReturnInDays
   * @return _deviceReturnInDays
   */
  get deviceReturnInDays() {
    return this._deviceReturnInDays;
  }

  /**
   * @description Method to format and return devices to keep from devicesToKeep property of
   *     OmniScript JSON data otherwise set the variable devices to false and display message
   *     'No devices on account that user can keep.'
   * @return devices
   */
  get devicesToKeep() {
    let devices;

    if (this._omniJsonData.devicesToKeep) {
      let clonedRecords = cloneDeep(this._omniJsonData.devicesToKeep);
      devices = [];

      if (Array.isArray(clonedRecords)) {
        clonedRecords.filter(function (device) {
          device.formatString = `${device.serialNumber} (${device.name})`;
        });
        devices = clonedRecords;
      } else {
        clonedRecords.formatString =
            `${clonedRecords.serialNumber} (${clonedRecords.name})`;
        devices.push(clonedRecords);
      }
    } else {
      devices = false;
    }

    return devices;
  }

  /**
   * @description Method to format and return devices to return from devicesToReturn property of
   *     OmniScript JSON data otherwise set the variable devices to false and display message
   *     'No devices on account that user can return.'
   * @return devices
   */
  get devicesToReturn() {
    let devices;

    if (this._omniJsonData.devicesToReturn) {
      let clonedRecords = cloneDeep(this._omniJsonData.devicesToReturn);
      let totalPrice = 0;
      devices = [];
      if (Array.isArray(clonedRecords)) {
        clonedRecords.filter(function (device) {
          device.formatString = `${device.serialNumber} (${device.name})`;
          device.formatString += device.basePrice.includes('$') ? 
            ` -- If not returned: ${device.basePrice}` :
            ` -- If not returned: $${device.basePrice}`;
          totalPrice += parseFloat(device.basePrice.replace("$", ""));
        });
        devices = clonedRecords;
      } else {
        clonedRecords.formatString = `${clonedRecords.serialNumber} (${clonedRecords.name})`;
        clonedRecords.formatString += clonedRecords.basePrice.includes('$') ?
            ` -- If not returned: ${clonedRecords.basePrice}` :
            ` -- If not returned: $${clonedRecords.basePrice}`;
        totalPrice = parseFloat(clonedRecords.basePrice.replace("$", ""));
        devices.push(clonedRecords);
      }
      this.totalPrice = totalPrice;
    } else {
      devices = false;
    }

    return devices;
  }

  /**
   * @description Method to return date along with the message from
   *     returnByDate (YYYY/MM/DD format) property of OmniScript JSON data
   *     ex. Total device cost if not returned by 8/13/2021
   *     otherwise 'Total device cost'
   * @return returnByDateMsgs
   */
  get returnByDate() {
    let returnByDateMsg;

    if (this._omniJsonData.accountCancellation &&
        this._omniJsonData.accountCancellation.accountCancellationReason &&
        this._omniJsonData.accountCancellation.accountCancellationReason.returnByDate) {
      let returnByDateString = this._omniJsonData.accountCancellation
          .accountCancellationReason.returnByDate;
      let addDays;
      const timeZoneOffsetInMiliSeconds = (new Date().getTimezoneOffset())*(-1);
      if (returnByDateString.includes(' ')) {
        returnByDateString = returnByDateString.replace(' ','T');
        returnByDateString += '.000Z';
      
        const returnByDateObj = new Date(returnByDateString);
        const convertedDate = this.addOffsetInMiliSeconds(returnByDateObj, 
            timeZoneOffsetInMiliSeconds);

        addDays = this.addDaysToDate(convertedDate, this._deviceReturnInDays);
      } else if (returnByDateString.includes('T')) {
        const convertedDate = this.addOffsetInMiliSeconds(returnByDateString, 
            timeZoneOffsetInMiliSeconds);

        addDays = this.addDaysToDate(convertedDate, this._deviceReturnInDays);
      } else {
        addDays = this.addDaysToDate(new Date(returnByDateString), this._deviceReturnInDays);
      }
      returnByDateMsg = 'Total device cost if not returned by ';
      returnByDateMsg += new Date(addDays)
          .toLocaleDateString('en-US', {
              month: '2-digit',
              day: '2-digit',
              year: 'numeric',
              timeZone: 'UTC'
          });
    } else {
      returnByDateMsg = 'Total device cost';
    }
    return returnByDateMsg;
  }

  /**
   * @description Method to add offset to a date.
   * @return convertedDate
   */
  addOffsetInMiliSeconds(dateValue, offsetInMiliseconds) {
    const convertedDate = new Date(dateValue.getTime() +
        offsetInMiliseconds*60000);
    return convertedDate;
  }

  /**
   * @description Method to add days to a date.
   * @return convertedDate
   */
  addDaysToDate(dateValue, daysToAdd) {
    const convertedDate = new Date(dateValue).setDate(dateValue.getDate() + daysToAdd);
    return convertedDate;
  }
}