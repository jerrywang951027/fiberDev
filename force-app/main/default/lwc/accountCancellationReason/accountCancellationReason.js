/**
 * @group CSR Console
 * @description Will show the Cancellation Reason and Cancellation Date to Disconnect Order OS Flow
 */

import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class AccountCancellationReason extends OmniscriptBaseMixin(LightningElement) {

  _dateRange;
  _omniJsonData;
  cancellationDate = '';
  cancellationReason = '';
  date = '';
  isCancellationReason = false;
  returnByDate;

  /**
   * @description To get tomorrow's date, future date based on dateRange and
   *     call to prepopulateFieldValues method
   */
  renderedCallback() {
    this.prepopulateFieldValues();
  }

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
   * @description Getting value of dateRange (29 days) set in the OmniScript as a LWC property
   *     and setting it to the decorator _dateRange
   * @param data value to be set in the decorator _dateRange
   */
  @api
  set dateRange(data) {
    if (data) {
      this._dateRange = parseInt(data);
    }
  }

  /**
   * @description Getter to return decorator _dateRange
   * @return _dateRange
   */
  get dateRange() {
    return this._dateRange;
  }

  /**
   * @description Getting value of note, set in the OmniScript as a LWC property
   *     and setting it to the decorator _note
   * @param data value to be set in the decorator _note
   */
  @api
  set note(data) {
    if (data) {
      this._note = data;
    }
  }

  /**
  * @description Getter to return decorator _note
  * @return note
  */
  get note() {
    return this._note;
  }

  /**
   * @description Getter to get tomorrow's date in YMD format.
   * @return this.getTomorrowsDateInYMDFormat()
   */
  get tomorrowsDate () {
    return this.getTomorrowsDateInYMDFormat();
  }

  /**
   * @description Getter to get future date by passing date range in YMD format.
   * @return future date
   */
  get futureDate () {
    return this.getFutureDateInYMDFormat(this._dateRange);
  }

  /**
   * @description Getter to get isImmediately as Boolean value.
   * @return true/false
   */
  get isImmediately() {
    return this.cancellationDate === 'Immediately';
  }

  /**
   * @description Getter to get isOther as Boolean value.
   * @return true/false
   */
  get isOther() {
    return this.cancellationDate === 'Other';
  }

  /**
   * @description To pre populate fields value (Cancellation Reason, Cancellation Date and Other)
   *     when coming back to the calling LWC (Step 1) in the guided flow
   */
  prepopulateFieldValues() {
    if (this._omniJsonData.accountCancellation &&
        this._omniJsonData.accountCancellation.accountCancellationReason &&
        this._omniJsonData.accountCancellation.accountCancellationReason
            .cancellationDate) {
      this.cancellationDate = this._omniJsonData
          .accountCancellation.accountCancellationReason.cancellationDate;
    }

    if (this._omniJsonData.accountCancellation &&
        this._omniJsonData.accountCancellation.accountCancellationReason &&
        this._omniJsonData.accountCancellation.accountCancellationReason
            .date) {
      this.date = this._omniJsonData.accountCancellation.accountCancellationReason
          .date;
    }

    if (this._omniJsonData.accountCancellation &&
        this._omniJsonData.accountCancellation.accountCancellationReason &&
        this._omniJsonData.accountCancellation.accountCancellationReason
            .cancellationReason) {
      this.cancellationReason = this._omniJsonData
          .accountCancellation.accountCancellationReason.cancellationReason;
      let radioButtons = this.template.querySelectorAll('.type-radio');
      radioButtons.forEach((entry) => {
        if (entry.value === this._omniJsonData.accountCancellation.accountCancellationReason
            .cancellationReason) {
          entry.checked = true;
        } else {
          entry.checked = false;
        }
      });
    }
  }

  /**
   * @description Getter to create options for Cancellation Date in a combobox field
   * @return cancellationOptions
   */
  get cancellationOptions() {
    return [
      {
        label: 'Please select a cancellation date',
        value: ''
      },
      {
        label: 'End of today',
        value: 'End of today'
      },
      {
        label: 'End of bill cycle date' + this.getSubscriptionEndDateFormatted(),
        value: 'End of bill cycle date'
      },
      {
        label: 'Immediately',
        value: 'Immediately'
      },
      {
        label: 'Other',
        value: 'Other'
      }
    ];
  }

  /**
   * @description Method to handle Cancellation Reason radio buttons onchange event and
   *     finally update the values from LWC to OmniScript JSON data
   * @param event onchange event.
   */
  handleCancellationReason(event) {
    const cancellationTitle = event.target.dataset.title;

    this.cancellationReason = event.target.value;
    this.date = '';

    if (cancellationTitle && cancellationTitle === 'Forced Cancellation') {
      this.cancellationDate = 'Immediately';
      this.returnByDate = this.getCurrentDateTime();
    } else {
      this.cancellationDate = '';
      this.returnByDate = '';
    }

    const dataToUpdate = {
      'cancellationDate': this.cancellationDate,
      'cancellationReason': this.cancellationReason,
      'cancellationTitle': cancellationTitle,
      'date': this.date,
      'isImmediately': this.isImmediately,
      'returnByDate': this.returnByDate
    };

    this.omniUpdateDataJson(dataToUpdate);
  }

  /**
   * @description Method to handle Cancellation Date dropdown value onchange event and
   *     finally update the values from LWC to OmniScript JSON data
   * @param event onchange event.
   */
  onDurationChange(event) {
    this.cancellationDate = event.detail.value;
    this.date = '';
    this.returnByDate = '';

    switch (this.cancellationDate) {
      case 'End of today':
        this.returnByDate = this.setCurrentDateTimeByTime(22, 0, 0);
        break;
      case 'End of bill cycle date':
        this.returnByDate = this.getSubscriptionEndDate();
        break;
      case 'Immediately':
        this.returnByDate = this.getCurrentDateTime();
        break;
      case 'Other':
        this.returnByDate = this.date;
        break;
    }

    const dataToUpdate = {
      'cancellationDate': this.cancellationDate,
      'date': this.date,
      'isImmediately': this.isImmediately,
      'returnByDate': this.returnByDate
    }

    this.omniUpdateDataJson(dataToUpdate);
  }

  /**
   * @description Method to handle Select a Date datepicker field value onchange event and
   *     finally update the values from LWC to OmniScript JSON data
   * @param event onchange event.
   */
  onDateChange(event) {
    if (event.target.value) {
      this.date = event.target.value;
      this.returnByDate = this.date;
    } else {
      this.date = '';
      this.returnByDate = this.date;
    }

    const dataToUpdate = {
      'date': this.date,
      'returnByDate': this.returnByDate
    }

    this.omniUpdateDataJson(dataToUpdate);
  }

  /**
   * @description Method to return current date and time in 2021-08-06 10:24:38 format
   * @return current datetime
   */
   getCurrentDateTime() {
    const now = new Date();
    return now.toISOString().split('.')[0].replace('T', ' ');
  }

  /**
   * @description Method to return current date and time in 2021-08-06 22:00:00 format by passing
   *     hour, minutes and seconds as parameter
   * @param hour hours of the day.
   * @param min minutes of the day.
   * @param sec seconds of the day.
   * @return set datetime
  */
   setCurrentDateTimeByTime(hour, min, sec) {
    const now = new Date();
    const newDateTime = new Date(now.setHours(hour, min, sec));
    return newDateTime.toISOString().split('.')[0].replace('T', ' ');
  }

  /**
   * @description Method to return today's date in 2021-08-06 (YYYY-MM-DD) format
   * @return this.formatDateInYYYYMMDD(today) today's date in 2021-08-06 (YYYY-MM-DD) format
   */
  getTodaysDateInYMDFormat() {
    const today = new Date();
    return this.formatDateInYYYYMMDD(today);
  }

  /**
   * @description Method to return tomorrow's date in 2021-08-07 (YYYY-MM-DD) format
   * @return this.formatDateInYYYYMMDD(tomorrowsDate) tomorrow's date in 2021-08-07 (YYYY-MM-DD)
   *     format
   */
  getTomorrowsDateInYMDFormat() {
    const currentDate = new Date();
    const tomorrowsDate = new Date(currentDate.setDate(currentDate.getDate() + 1));
    return this.formatDateInYYYYMMDD(tomorrowsDate);
  }

  /**
   * @description Method to return future date considering numOfDays as 29 days in 2021-09-04
   *     (YYYY-MM-DD) format
   * @param numOfDays number of days in future from the current date
   * @return this.formatDateInYYYYMMDD(futureDate) future date in 2021-09-04 (YYYY-MM-DD)
   *     format
   */
  getFutureDateInYMDFormat(numOfDays) {
    const today = new Date();
    const futureDate = new Date().setDate(today.getDate() + numOfDays);
    return this.formatDateInYYYYMMDD(futureDate);
  }

  /**
   * @description Method to return date passed in the method in 2021-09-04 (YYYY-MM-DD) format
   * @param date date to be formatted
   * @return formmated date ex. 2021-09-04 (YYYY-MM-DD)
   */
  formatDateInYYYYMMDD(date) {
    return (new Date(date)).toISOString().split('T')[0];
  }

  /**
   * @description Method to return Subscription End Date (End of bill cycle date) from
   *     Omni JSON Data
   * @return subscriptionEndDate
   */
  getSubscriptionEndDate() {
    let subscriptionEndDate = '';
    if (this._omniJsonData.subscription && this._omniJsonData.subscription.endDate) {
      subscriptionEndDate = this._omniJsonData.subscription.endDate;
    }
    return subscriptionEndDate;
  }

  /**
   * @description Method to format the subscription end date.
   *     Omni JSON Data
   * @return subscriptionEndDate
   */
  getSubscriptionEndDateFormatted() {
    let subscriptionEndDate = '';
    if (this._omniJsonData.subscription && this._omniJsonData.subscription.endDate) {
      subscriptionEndDate = ' - ' + new Date(this._omniJsonData.subscription.endDate)
          .toLocaleDateString('en-US', {
        month: '2-digit',
        day: '2-digit',
        year: 'numeric',
        timeZone: 'UTC'
      });
    }
    return subscriptionEndDate;
  }

  /**
   * @description Method to handle Next button in the guided flow on click of it.
   *     if this.handleValidate() method return true then move the flow to the next step
   *     using this.omniNextStep() method otherwise display error message
   */
  handleNext() {
    if (this.handleValidate()) {
      this.omniNextStep();
    }
  }

  /**
   * @description Method to validate fields by checking field's validity, if the validation
   *     on the fields return true and if this.cancellationReason field's value is not empty
   *     then method with return true else false
   * @return true/false
   */
  handleValidate() {
    this.isCancellationReason = false;

    const allValid = [...this.template.querySelectorAll('.validation-required')]
        .reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    this.isCancellationReason = this.cancellationReason ? false : true;
    return (allValid && !this.isCancellationReason ? true : false);
  }

  /**
   * @description Method to format and return premises address by concatenating unitNumber,
   *     streetAddress, city, state and postalCode from account property of OmniScript JSON data
   *     otherwise display 'No premises address found.'
   * @return completeAddress
   */
  get premisesAddress() {
    let completeAddress = '';

    if (this._omniJsonData.account) {
      completeAddress = this._omniJsonData.account.unitNumber != undefined ?
          `${this._omniJsonData.account.unitNumber} ` : '';
      completeAddress += `${this._omniJsonData.account.streetAddress} `;
      completeAddress += `${this._omniJsonData.account.city} `;
      completeAddress += `${this._omniJsonData.account.state} `;
      completeAddress += `${this._omniJsonData.account.postalCode}`;
    } else {
      completeAddress = 'No premises address found.'
    }

    return completeAddress;
  }
}