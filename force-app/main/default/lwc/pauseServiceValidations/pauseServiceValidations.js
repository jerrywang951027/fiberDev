/**
 * @group CSR Console
 * @description Will validate Pause and Reschedule flow for 120 days of Pause duration.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const IMMEDIATELY = 'Immediately';
const LEGAL_ERROR_MESSAGE = 'Confirm that you have reviewed legal talking points with customer.';
const NEXT = 'Next';
const PAUSE = 'Pause';
const PAUSE_DAYS_ERROR_MESSAGE = 'Number of requested pause days exceeds 120 day limit.';
const RESCHEDULE_PAUSE = 'Reschedule Pause';
const SUBMIT = 'Submit';
const MINIMUM_PAUSE_DURATION = 30;

export default class PauseServiceValidations extends OmniscriptBaseMixin(LightningElement) {

  _flowName;
  _maxPauseBalance;
  _omniJsonData;
  _pauseTime;
  _resumeTime;
  daysDifferenceErrorMessage = 'You may not choose a date less than ' +
      MINIMUM_PAUSE_DURATION + ' days in total.';
  isValid = true;
  newPauseDaysAvailable;
  validationErrorMessage;

  get americaLosAngelesOffsetInMinutes() {
    return this.isDSTApplied() ? 25200000 : 28800000;
  }

  /**
  * @description To get tomorrow's date, future date based on dateRange and
  *     call to prepopulateFieldValues method.
  */
  @api
  set omniJsonData(omniData) {
    if (omniData) {
      this._omniJsonData = omniData;
    }
  }

  /**
  * @description Getter to return decorator _omniJsonData.
  * @return _omniJsonData
  */
  get omniJsonData() {
    return this._omniJsonData;
  }

  /**
  * @description Getting value of maxPauseBalance (120 days) set in the OmniScript
  *     as a LWC property and setting it to the decorator _maxPauseBalance.
  * @param data Value to be set in the decorator _maxPauseBalance.
  */
  @api
  set maxPauseBalance(data) {
    if (data) {
      this._maxPauseBalance = parseInt(data);
    }
  }

  /**
  * @description Getter to return decorator _maxPauseBalance.
  * @return _maxPauseBalance
  */
  get maxPauseBalance() {
    return this._maxPauseBalance;
  }

  /**
  * @description Getting value of pauseTime (T23:59:00.000Z) set in the OmniScript
  *     as a LWC property and setting it to the decorator _pauseTime.
  * @param data Value to be set in the decorator _pauseTime.
  */
  @api
  set pauseTime(data) {
    if (data) {
      this._pauseTime = data;
    }
  }

  /**
  * @description Getter to return decorator _pauseTime.
  * @return _pauseTime
  */
  get pauseTime() {
    return this._pauseTime;
  }

  /**
  * @description Getting value of resumeTime (T00:01:00.000Z) set in the OmniScript
  *     as a LWC property and setting it to the decorator _resumeTime.
  * @param data Value to be set in the decorator _resumeTime.
  */
  @api
  set resumeTime(data) {
    if (data) {
      this._resumeTime = data;
    }
  }

  /**
  * @description Getter to return decorator _resumeTime.
  * @return _resumeTime
  */
  get resumeTime() {
    return this._resumeTime;
  }

  /**
  * @description Getting value of flowName (Pause or Reschedule Pause) set in the OmniScript
  *     as a LWC property and setting it to the decorator _flowName.
  * @param data Value to be set in the decorator _flowName.
  */
  @api
  set flowName(data) {
    if (data) {
      this._flowName = data;
    }
  }

  /**
  * @description Getter to return decorator _flowName.
  * @return _resumeTime
  */
  get flowName() {
    return this._flowName;
  }

  /**
  * @description Getter to return label of the button based on guided flow,
  *     if we're launching Pause Guided Flow, label of the button would be Next,
  *     if we are launching Reschedule Pause Flow, label of the button would be Submit.
  * @return buttonLabel
  */
  get buttonLabel() {
    if (this._flowName === PAUSE) {
      return NEXT;
    } else if(this._flowName === RESCHEDULE_PAUSE) {
      return SUBMIT;
    }
  }

  /**
  * @description Getter to return currentYearBalance from decorator this._omniJsonData.
  * @return currentYearBalance
  */
  get pauseDaysAvailable() {
    if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.premisesAddressBlock &&
        this._omniJsonData.scheduleLocationService.premisesAddressBlock
            .currentYearBalance !== null) {
      return this._omniJsonData.scheduleLocationService.premisesAddressBlock.currentYearBalance;
    }
  }

  /**
  * @description Getter to return pauseReason from decorator this._omniJsonData.
  * @return pauseReason
  */
  get pauseReason() {
    if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.pauseReasonBlock &&
        this._omniJsonData.scheduleLocationService.pauseReasonBlock.pauseReason) {
      return this._omniJsonData.scheduleLocationService.pauseReasonBlock.pauseReason;
    }
  }

  /**
  * @description Getter to return pauseReasonOther from decorator this._omniJsonData.
  * @return pauseReasonOther
  */
  get pauseReasonDescription() {
    if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.pauseReasonBlock &&
        this._omniJsonData.scheduleLocationService.pauseReasonBlock.pauseReasonOther) {
      return this._omniJsonData.scheduleLocationService.pauseReasonBlock.pauseReasonOther;
    }
  }

  /**
  * @description Getter to return pauseStart from decorator this._omniJsonData.
  * @return pauseStart
  */
  get pauseStart() {
    if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.pauseStartBlock &&
        this._omniJsonData.scheduleLocationService.pauseStartBlock.pauseStart) {
      return this._omniJsonData.scheduleLocationService.pauseStartBlock.pauseStart;
    }
  }

  /**
  * @description Getter to return pauseStartSelectedDateTime or pauseStartOtherDateTime or
  *     pauseStartNowSelectedDateTime from decorator this._omniJsonData based on conditions
  *     in the OmniScript.
  * @return pauseStartDate
  */
  get pauseStartDate() {
    if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.pauseStartBlock &&
        this._omniJsonData.scheduleLocationService.pauseStartBlock.pauseStartSelectedDateTime) {
      return this._omniJsonData.scheduleLocationService.pauseStartBlock
          .pauseStartSelectedDateTime.split('T')[0];
    } else if (this._omniJsonData.scheduleLocationService &&
          this._omniJsonData.scheduleLocationService.pauseStartBlock &&
          this._omniJsonData.scheduleLocationService.pauseStartBlock.pauseStartOtherDateTime) {
        return this._omniJsonData.scheduleLocationService.pauseStartBlock.pauseStartOtherDateTime;
    } else if (this._omniJsonData.scheduleLocationService &&
          this._omniJsonData.scheduleLocationService.pauseStartBlock &&
          this._omniJsonData.scheduleLocationService.pauseStartBlock
              .pauseStartNowSelectedDateTime) {
        return this._omniJsonData.scheduleLocationService.pauseStartBlock
            .pauseStartNowSelectedDateTime;
    }
  }

  /**
  * @description Getter to return pauseStopSelectedDateTime or pauseStopOtherDateTime from
  *     decorator this._omniJsonData based on conditions in the OmniScript.
  * @return pauseStopDate
  */
  get pauseStopDate() {
    if ((this._omniJsonData.scheduleLocationService &&
      this._omniJsonData.scheduleLocationService.pauseStartBlock &&
      this._omniJsonData.scheduleLocationService.pauseStartBlock.pauseStart === 'Other')
      && (this._omniJsonData.scheduleLocationService &&
      this._omniJsonData.scheduleLocationService.pauseStopBlock &&
      this._omniJsonData.scheduleLocationService.pauseStopBlock.pauseStop !== 'Other')) {
      const pauseStartDate = new Date(
          this._omniJsonData.scheduleLocationService.pauseStartBlock.pauseStartOtherDateTime);
      const pauseStopDate = new Date(pauseStartDate.setDate(pauseStartDate.getDate() +
          parseInt(this._omniJsonData.scheduleLocationService.pauseStopBlock.pauseStop)));
      return pauseStopDate.toISOString().split('T')[0];
    } else {
      if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.pauseStopBlock &&
        this._omniJsonData.scheduleLocationService.pauseStopBlock.pauseStopSelectedDateTime) {
        return this._omniJsonData.scheduleLocationService.pauseStopBlock
            .pauseStopSelectedDateTime.split('T')[0];
      } else if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.pauseStopBlock &&
        this._omniJsonData.scheduleLocationService.pauseStopBlock.pauseStopOtherDateTime) {
        return this._omniJsonData.scheduleLocationService.pauseStopBlock.pauseStopOtherDateTime;
      }
    } 
  }

  /**
  * @description Getter to return legal from decorator this._omniJsonData.
  * @return isLegal, Boolean true or false
  */
  get isLegal() {
    if (this._omniJsonData.scheduleLocationService &&
        this._omniJsonData.scheduleLocationService.legalBlock &&
        this._omniJsonData.scheduleLocationService.legalBlock.legal) {
      return this._omniJsonData.scheduleLocationService.legalBlock.legal;
    }
  }

  /**
  * @description Getter to return pauseStartDate based on condition.
  * @return pauseStartDateAndTime
  */
  get pauseStartDateAndTime() {
    if (this.pauseStartDate && this.pauseStart !== IMMEDIATELY) {
      const startDateTime = new Date(this.pauseStartDate + this._pauseTime);
      // As per the requirement this should always be in America/Los_Angeles
      return this.addOffset(startDateTime, this.americaLosAngelesOffsetInMinutes);
    } else {
      return this.pauseStartDate;
    }
  }

  /**
  * @description Getter to return pauseStopDateAndTime.
  * @return pauseStopDateAndTime
  */
  get pauseStopDateAndTime() {
    if (this.pauseStopDate) {
      const stopDateTime = new Date(this.pauseStopDate + this._resumeTime);
      // As per the requirement this should always be in America/Los_Angeles
      return this.addOffset(stopDateTime, this.americaLosAngelesOffsetInMinutes);
    }
  }

  /**
  * @description Getter to return daysLeftInCurrentFY.
  * @return daysLeftInCurrentFY
  */
  get daysLeftInCurrentFY() {
    const referenceDate = new Date(this.pauseStartDate);
    const endOfYear = new Date(referenceDate.getFullYear(), 11, 31);
    return this.dateDiffInDays(endOfYear, referenceDate);
  }

  /**
  * @description Getter to return pauseDuration.
  * @return pauseDuration
  */
  get pauseDuration() {
    return this.dateDiffInDays(this.pauseStopDate, this.pauseStartDate);
  }

  /**
  * @description Getter to return isCurrentYear.
  * @return isCurrentYear, Boolean true or false
  */
  get isCurrentYear() {
    const currentYear = (new Date()).getFullYear();
    const referenceDate = new Date(this.pauseStartDate);
    const futureDate = new Date(referenceDate).setDate(referenceDate
        .getDate() + this.pauseDuration);
    const futureDateYear = (new Date(futureDate)).getFullYear();

    if (currentYear === futureDateYear) {
      return true;
    } else {
      return false;
    }
  }

  /**
  * @description Getter to return startOfNewYear.
  * @return startOfNewYear
  */
  get startOfNewYear() {
    return new Date((new Date()).getFullYear()+1, 0, 1);
  }

  /**
  * @description Getter to return pauseStopDaysInNextYear.
  * @return pauseStopDaysInNextYear
  */
  get pauseStopDaysInNextYear() {
    return this.dateDiffInDays(this.pauseStopDate, this.startOfNewYear);
  }

  /**
  * @description Getter to return currentYearPauseDaysBal based on condition.
  * @return currentYearPauseDaysBal
  */
  get currentYearPauseDaysBal() {
    if (!this.isCurrentYear) {
      if (this.pauseDaysAvailable >= this.pauseDuration) {
        return this.pauseDaysAvailable - this.daysLeftInCurrentFY;
      }
    }
  }

  /**
  * @description Method to add one day in the date passed as parameter in date format.
  * @param date Date to which we need to add one day.
  * @return addOneDayToDate
  */
  addOneDayToDate(date) {
    const referenceDate = new Date(date);
    const dayPlusOne = new Date(referenceDate.setDate(referenceDate.getDate() + 1));
    return dayPlusOne.toISOString().split('T')[0];
  }

  /**
  * @description Method to return difference between two date in days.
  * @param startDate
  * @param endDate
  * @return dateDiffInDays
  */
  dateDiffInDays(startDate, endDate) {
    return Math.ceil((new Date(startDate).getTime() - new Date(endDate)
        .getTime()) / (1000 * 3600 * 24));
  }

  /**
  * @description Method to return date in January 06, 2019 format.
  * @param date Date to be formatted.
  * @return dateFormatRequiredForGamma
  */
  dateFormatRequiredForGamma(date) {
    return new Date(date)
        .toLocaleString('en-US',
            {
              month: 'long',
              day: '2-digit',
              year: 'numeric',
              timeZone: 'UTC'
            }
        );
  }

  /**
  * @description Method to validate Pause and Reschedule flow for 120 days of Pause duration.
  * @return isValid, Boolean true or false
  */
  validatePause() {
    this.isValid = true;
    this.validationErrorMessage;

    if (this.pauseDaysAvailable != null && this.pauseDaysAvailable === 0) {
      this.isValid = false;
      this.validationErrorMessage = PAUSE_DAYS_ERROR_MESSAGE;
    } else if (this.pauseDaysAvailable && this.pauseStartDate && this.pauseStopDate) {
      if (this.pauseDuration < MINIMUM_PAUSE_DURATION) {
        this.isValid = false;
        this.validationErrorMessage = this.daysDifferenceErrorMessage;
      } else {
        if (this.isCurrentYear) {
          if (this.pauseDaysAvailable >= this.pauseDuration) {
            this.newPauseDaysAvailable = this.pauseDaysAvailable - this.pauseDuration;
          } else {
            this.isValid = false;
            this.validationErrorMessage = PAUSE_DAYS_ERROR_MESSAGE;
          }
        } else {
          if (this.pauseDaysAvailable >= this.pauseDuration) {
            if (this.pauseStopDaysInNextYear <= this._maxPauseBalance) {
              this.newPauseDaysAvailable = this._maxPauseBalance - this.pauseStopDaysInNextYear;
            } else {
              this.isValid = false;
              this.validationErrorMessage = PAUSE_DAYS_ERROR_MESSAGE;
            }
          } else {
            this.isValid = false;
            this.validationErrorMessage = PAUSE_DAYS_ERROR_MESSAGE;
          }
        }
      }

      if (this.isValid && !this.isLegal) {
        this.isValid = false;
        this.validationErrorMessage = LEGAL_ERROR_MESSAGE;
      }
    }

    return this.isValid;
  }

  /**
  * @description Method to update the Omni JSON data in the OmniScript.
  */
  updateDataToOmni() {

    const dataToUpdate = {
      'currentYearPauseDaysBal': this.currentYearPauseDaysBal,
      'legal': this.isLegal,
      'newPauseDaysAvailable': this.newPauseDaysAvailable,
      'pauseDaysAvailable': this.pauseDaysAvailable,
      'pauseDuration': this.pauseDuration,
      'pauseStart': this.pauseStart,
      'pauseReason': this.pauseReason,
      'pauseReasonOther': this.pauseReasonDescription,
      'pauseStartDateTime': this.pauseStartDateAndTime,
      'pauseStopDateTime': this.pauseStopDateAndTime,
      'resumeServiceDate': this.pauseStopDateAndTime,
      'pauseStartDate':this.pauseStartDate,
      'pauseStartDateTimeForGamma': this.dateFormatRequiredForGamma(this.pauseStartDate),
      'pauseStopDateTimeForGamma': this.dateFormatRequiredForGamma(this.pauseStopDateAndTime),
      'resumeServiceDateForGamma': this.dateFormatRequiredForGamma(this.pauseStopDateAndTime)
    };

    this.omniUpdateDataJson(dataToUpdate);
  }

  /**
  * @description Method to go to add offset to the date.
  * @param date date to which offset has to be added.
  * @param offset date to which offset has to be added.
  */
  addOffset(date, offsetInMiliSeconds) {
    return new Date(date.getTime() + offsetInMiliSeconds);
  }

  /**
  * @description Method to go to Next step after validating 120 days Pause service and updating
  *     Omni JSON data to OmniScript.
  */
  validatePauseService() {
    if (this.validatePause()) {
      this.updateDataToOmni();
      this.omniNextStep();
    }
  }

  /**
  * @description Method determine if Daylight Saving Time is applied or not.
  * @returns true: If Daylight Saving Time is applied.
  *     false: If Daylight Saving Time is not applied.
  */
  isDSTApplied() {
    const januaryDate = new Date(new Date().getFullYear(), 0, 1).getTimezoneOffset();
    const julyDate = new Date(new Date().getFullYear(), 6, 1).getTimezoneOffset();
    return Math.max(januaryDate, julyDate) != new Date().getTimezoneOffset();
  }
}