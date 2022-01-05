/**
 * @group CSR Console
 * @description Will show the available appointment slots in an Omniscript.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const AVAILABLE_SLOT_ERROR_MESSAGE = 'Please select any of the following available slot.';
const COLUMNS = [
  {
    label: 'Start Time',
    fieldName: 'appointmentStartTime',
    type: 'text',
    hideDefaultActions: true
  },
  {
    label: 'End Time',
    fieldName: 'appointmentEndTime',
    type: 'text',
    hideDefaultActions: true
  },
  {
    label: 'Duration',
    fieldName: 'appointmentDuration',
    type: 'text',
    hideDefaultActions: true
  }
];
const DAY_DISPLAY_FORMAT = '2-digit';
const HOUR_DISPLAY_FORMAT = '2-digit';
const MONTH_DISPLAY_FORMAT = 'short';
const MINUTE_DISPLAY_FORMAT = '2-digit';
const NO_MORE_APPOINTMENTS = 'There is no more schedule an appointment to show.'
const YEAR_DISPLAY_FORMAT = 'numeric';
const NO_APPOINTMENT_SELECTED = 'No appointment selected';

export default class ScheduleAppointment extends OmniscriptBaseMixin(LightningElement){

  @api appointments;

  _accountId;
  _appointmentType;
  _appointmentSubType;
  _duration;
  _timeZone;
  appointmentDetails = [];
  columns = COLUMNS;
  errorMessage;
  noMoreAppointments;
  selectedAppointment = {};
  noAppointmentSelected = NO_APPOINTMENT_SELECTED;

 /**
  * @description Getting value of accountId set in the OmniScript
  *     as a LWC property and setting it to the decorator _accountId.
  * @param data Value to be set in the decorator _accountId.
  */
  @api
  set accountId(data) {
    if (data) {
      this._accountId = data;
    }
  }

 /**
  * @description Getter to return decorator _omniJsonData
  * @return _accountId
  */
  get accountId() {
    return this._accountId;
  }

 /**
  * @description Getting value of appointmentType set in the OmniScript
  *     as a LWC property and setting it to the decorator _appointmentType.
  * @param data Value to be set in the decorator _appointmentType.
  */
  @api
  set appointmentType(data) {
    if (data) {
      this._appointmentType = data;
    }
  }

 /**
  * @description Getter to return decorator _omniJsonData
  * @return _appointmentType
  */
  get appointmentType() {
    return this._appointmentType;
  }

 /**
  * @description Getting value of appointmentSubType set in the OmniScript
  *     as a LWC property and setting it to the decorator _appointmentSubType.
  * @param data Value to be set in the decorator _appointmentSubType.
  */
  @api
  set appointmentSubType(data) {
    if (data) {
      this._appointmentSubType = data;
    }
  }

 /**
  * @description Getter to return decorator _omniJsonData
  * @return _appointmentSubType
  */
  get appointmentSubType() {
    return this._appointmentSubType;
  }

 /**
  * @description Getting value of duration set in the OmniScript
  *     as a LWC property and setting it to the decorator _duration.
  * @param data Value to be set in the decorator _duration.
  */
  @api
  set duration(data) {
    if (data) {
      this._duration = parseInt(data);
    }
  }

 /**
  * @description Getter to return decorator _omniJsonData
  * @return _duration
  */
  get duration() {
    return this._duration;
  }

  get isAppointments() {
    return this.appointmentDetails.length > 0 ? true : false;
  }

 /**
  * @description Getting value of timeZone set in the OmniScript
  *     as a LWC property and setting it to the decorator _timeZone.
  * @param data Value to be set in the decorator _timeZone.
  */
  @api
  set timeZone(data) {
    if (data) {
      this._timeZone = data;
    }
  }

 /**
  * @description Getter to return decorator _omniJsonData
  * @return _timeZone
  */
  get timeZone() {
    return this._timeZone;
  }

 /**
  * @description Call manipulateAppointmentsData method on Page/Tab load.
  */
  connectedCallback() {
    this.manipulateAppointmentsData(this.appointments);
  }

 /**
  * @description To sort the available appointments based on Start Date.
  * @param appointmentDetails List of appointments.
  * @return Sorted Array
  */
  sortAppointmentByStartTime(appointmentDetails) {
    appointmentDetails.sort(function(a, b) {
      var keyA = new Date(a.appointmentStartTime),
        keyB = new Date(b.appointmentStartTime);
      // Compare the 2 dates
      if (keyA < keyB) return -1;
      if (keyA > keyB) return 1;
      return 0;
    });
    return appointmentDetails;
  }

 /**
  * @description To format Invoice items.
  * @param dateTimeString Unformatted available start time and end time.
  * @return Formatted dateTime.
  */
  getFormatDateTime(dateTimeString) {
    if (dateTimeString) {
      const dateTimeFormat = {
        year : YEAR_DISPLAY_FORMAT,
        month : MONTH_DISPLAY_FORMAT,
        day : DAY_DISPLAY_FORMAT,
        timeZone : this._timeZone,
        hour : HOUR_DISPLAY_FORMAT,
        minute : MINUTE_DISPLAY_FORMAT,
        hour12 : true
      };

      const dateTime = new Date(dateTimeString).toLocaleString('en-US', dateTimeFormat);
      return dateTime;
    }
    else {
      return '';
    }
  }

 /**
  * @description Method to manipulate appointment slots.
  */
  manipulateAppointmentsData(data) {
    let appointmentDetails = [];
    data.forEach(item => {
      let appointmentOptionsArr = {
        appointmentStartTime:this.getFormatDateTime(item.startTime),
        appointmentEndTime:this.getFormatDateTime(item.endTime),
        ...item
      }
      appointmentOptionsArr.appointmentDuration = this.getDuration(item.endTime, item.startTime);
      appointmentDetails.push(appointmentOptionsArr);
    });
    let sortedAppointments = this.sortAppointmentByStartTime(appointmentDetails);
    this.appointmentDetails = [...new Set([...this.appointmentDetails,...sortedAppointments])];
    this.loadStyles();
  }

 /**
  * @description To get duration of the appointment.
  * @param endTime appointment end time.
  * @param startTime appointment start time.
  * @return duration
  */
  getDuration(endTime, startTime) {
    const timeInMillisec = (new Date(endTime).getTime()) - (new Date(startTime).getTime());
    return new Date(timeInMillisec).toISOString().split('T')[1].replace(':00.000Z', '');
  }

 /**
 * @description Method to get appointment start and end time when selected any row.
 * @param event onclick event.
 */
  getSelectedRow(event) {
    let selectedRows;
    let selectedAppointment = {};
    if (event.target.label && event.target.label === this.noAppointmentSelected) {
      selectedRows = false;
      selectedAppointment.selectedRows = selectedRows;
    } else {
      selectedRows = event.detail.selectedRows[0];
      this.appointmentDetails.forEach(item => {
        if (item.appointmentStartTime == selectedRows.appointmentStartTime) {
          selectedAppointment.selectedStartTime = item.startTime;
          selectedAppointment.selectedEndTime = item.endTime;
          selectedAppointment.resourceId = item.resourceId;
          selectedAppointment.appointmentTypeAndSubType = item.appointmentType;
          selectedAppointment.selectedRows = true;
        }
      });
    }
    this.selectedAppointment = selectedAppointment;
  }

 /**
  * @description Method to update the Omni JSON data when appointment is selected.
  */
  bookAppointment() {
    if (Object.keys(this.selectedAppointment).length !== 0 &&
        this.selectedAppointment.constructor === Object) {
      this.omniApplyCallResp(this.selectedAppointment);
      this.omniNextStep();
    } else {
      this.errorMessage = AVAILABLE_SLOT_ERROR_MESSAGE;
    }
  }

 /**
  * @description Method to load more appointment slots in the OmniScript.
  */
  loadMoreRecords() {
    const lastAppointment = this.appointmentDetails[this.appointmentDetails.length - 1];
    const lastAppointmentDate = lastAppointment.appointmentEndTime.split('T')[0];
    const nextDay = this.getFutureDate(lastAppointmentDate, 2);
    const nextTenDays = this.getFutureDate(lastAppointmentDate, this._duration);

    this.callToGetAvailableAppointmentIP(nextDay, nextTenDays);
  }

 /**
  * @description Method to calculate future date for load more appointments.
  * @param date appointment end date of previous record.
  * @param numOfDays appointment slots need to be loaded for number of days.
  * @return futureDate
  */
  getFutureDate(date, numOfDays) {
    const d = new Date(date);
    const futureDate = new Date(d.setDate(d.getDate() + numOfDays));
    return futureDate.toISOString();
  }

 /**
  * @description Method to calculate future date for load more appointments.
  * @param date appointment end date of previous record.
  * @param numOfDays appointment slots need to be loaded for number of days.
  * @return futureDate
  */
  callToGetAvailableAppointmentIP(startDate, endDate) {

    let requestObject = {};
    requestObject.externalServiceAccountId = this._accountId;
    requestObject.startTime = startDate;
    requestObject.endTime = endDate;
    requestObject.appointmentType = this._appointmentType;
    requestObject.appointmentSubType = this._appointmentSubType;

    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_GetAvailableAppointments',
      options: '{}'
    };

    this.omniRemoteCall(params, true).then(response => {
      if (response.result.IPResult.appointments &&
          Array.isArray(response.result.IPResult.appointments) &&
          response.result.IPResult.appointments.length > 0) {
        this.manipulateAppointmentsData(response.result.IPResult.appointments);
      } else {
        this.errorMessage = NO_MORE_APPOINTMENTS;
      }
    }).catch (error => {
      this.errorMessage = error.message;
    });
  }

  /**
   * @description Method to set the style for lightning-input component.
   */
   loadStyles() {
    const style = document.createElement('style');
    style.innerText = `.custom-radio-style .slds-form-element__label {
        color: var(--sds-c-card-text-color);}`;

    setTimeout(() => {
      this.template.querySelector('lightning-input').appendChild(style);
    }, 100);
  }
}