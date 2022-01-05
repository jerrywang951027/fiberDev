import { api,LightningElement,track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class appointmentDetails extends OmniscriptBaseMixin(LightningElement) {
  _appointmentDetails;
  @track appointmentsAvailable;
  @track appointmentOptions = [];
  @track selectedAppointmentDetails;

  connectedCallback() {
    this.appointmentDetails ? (this.appointmentsAvailable = true):
        (this.appointmentsAvailable = false);
    if(this.appointmentsAvailable === true) {
      this.appointmentDetails.forEach(item => {
        let appointmentOptionsArr = {};
        appointmentOptionsArr.label = item.appointmentStartTime;
        appointmentOptionsArr.value = item.appointmentStartTime;
        this.appointmentOptions.push(appointmentOptionsArr);
      });
    }
  }
  /**
   * @description Getting value of _appointmentDetails set in the OmniScript
   * as a LWC property and setting it to the decorator _appointmentDetails.
   * @param data value to be set in the decorator _appointmentDetails
   */
  @api
  set appointmentDetails(data) {
    if (data) {
      this._appointmentDetails = data;
    }
  }

  /**
   * @description Getter to return decorator _appointmentDetails.
   * @return _appointmentDetails
   */
  get appointmentDetails() {
    return this._appointmentDetails;
  }

  onRadioSelection(event) {
    this.selectedAppointment = event.detail.value;
    this.appointmentDetails.forEach(item => {
      if(item.appointmentStartTime === this.selectedAppointment) {
        this.omniApplyCallResp({selectedStartTime : item.appointmentStartTime,
            selectedEndTime: item.appointmentEndTime, selectedTime: item.startTimeDetails});
      }
    });
  }
}