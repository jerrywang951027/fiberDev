/**
 * @group CSR Console
 * @description Will show the details of Order in a Order Card.
 */

import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const DAYS_ADDED_IN_PROJECTED_DATE_FOR_EXPECTED_DATE = 1;
const DAYS_ADDED_IN_REQUESTED_DUE_DATE_FOR_RETURN_BY_DATE = 60;
const DAY_DISPLAY_FORMAT = 'numeric';

const DISCONNECTED_FLAG = 'isDisconnect';
const DISCONNECTED_ICON = 'standard:first_non_empty';
const DISCONNECTED_TITLE = 'Disconnect';
const DISCONNECTED_TYPE = 'Disconnect';

const ERROR_MESSAGE_ERROR_ON_FETCHING_DETAILS = 'Error occured while fetching order details.';
const ERROR_MESSAGE_NO_DETAILS = 'No details to show.';

const HOUR_DISPLAY_FORMAT = '2-digit';
const MINUTE_DISPLAY_FORMAT = '2-digit';
const MONTH_DISPLAY_FORMAT = 'long';
const ORDER = 'order'

const PAUSE_ICON = 'utility:pause';
const PAUSE_RESUME_FLAG = 'isPauseResume';
const PAUSE_TITLE = 'Pause';
const PAUSE_TYPE = 'Pause';

const PRO_INSTALL_FLAG = 'isProInstall';
const PRO_INSTALL_ICON = 'standard:visits';
const PRO_INSTALL_PRODUCT_CODE = 'OFR_INSTL_PRO';
const PRO_INSTALL_TITLE = 'Professional Install';

const RESULT = 'result';
const RESUME_ICON = 'utility:play';
const RESUME_TITLE = 'Resume';
const RESUME_TYPE = 'Resume';

const SELF_INSTALL_PICKUP_DELIVERY_OPTION = 'Customer Pickup';
const SELF_INSTALL_PICKUP_FLAG = 'isCustomerPickUp';
const SELF_INSTALL_PICKUP_ICON = 'standard:proposition';
const SELF_INSTALL_PICKUP_TITLE = 'Customer Pick Up';
const SELF_INSTALL_PRODUCT_CODE = 'OFR_INSTL_SIK';
const SELF_INSTALL_SHIP_TO_CUSTOMER_DELIVERY_OPTION = 'Ship to Customer';
const SELF_INSTALL_SHIP_TO_CUSTOMER_FLAG = 'isShippedToCustomer';
const SELF_INSTALL_SHIP_TO_CUSTOMER_ICON = 'standard:shipment';
const SELF_INSTALL_SHIP_TO_CUSTOMER_TITLE = 'Ship to Customer';

const SUCCESS = 'success';

const STATUS_CHARGED = 'Charged';
const STATUS_OUTSTANDING = 'Outstanding';
const STATUS_RETURNED = 'Returned';

const TIME_ZONE = 'UTC';
const YEAR_DISPLAY_FORMAT = 'numeric';

export default class OrderDetails extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {

  error;
  isShowExpectedResumeDate = true;
  isSpinnerLoaded = true;
  orderDetails;
  orderId;
  noOrderItemsError;
  
/**
 * @description Will fire everytime when User selects an Order from Order Dropdown
 *     in Order tab to get the selected Order's Id.
 */
  @api get orderData() {
    return this.orderId;
  }

/**
 * @description Will fire everytime when User selects an Order from Order Dropdown
 *     in Order tab to set the selected Order's Id in orderId variable.
 * @param value Value to be set
 */
  set orderData(value) {
    this.setAttribute('orderData', value);
    this.orderId = value;
    this.getOrderDetails(this.orderId);
  }

/**
 * @description getOrderDetails To get details of selected Order.
 * @param orderId Selected Order ID.
 */
  getOrderDetails(orderId) {
    this.isSpinnerLoaded = true;
    this.error = undefined;
    this.noOrderItemsError = undefined;
    this.orderDetails = undefined;

    let inputParams = {
      orderId : orderId
    }
    let params = {
      input: JSON.stringify(inputParams),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_GetOrderDetails',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      if (response && Object.keys(response.result.IPResult).length !== 0
            && !response.result.IPResult.hasOwnProperty(SUCCESS)) {
          let orderDetails = {};

          if (response.result.IPResult.productCode) {
            if (response.result.IPResult.productCode == PRO_INSTALL_PRODUCT_CODE) {
              orderDetails = this.formatOrderDetails(PRO_INSTALL_ICON, PRO_INSTALL_FLAG,
                  response.result.IPResult, PRO_INSTALL_TITLE);
              orderDetails.order.orderNumber = response.result.IPResult.order.orderNumber;
            } else if (response.result.IPResult.productCode == SELF_INSTALL_PRODUCT_CODE) {
              if (response.result.IPResult.deliveryOption ==
                  SELF_INSTALL_PICKUP_DELIVERY_OPTION) {
                orderDetails = this.formatOrderDetails(SELF_INSTALL_PICKUP_ICON,
                    SELF_INSTALL_PICKUP_FLAG, response.result.IPResult, SELF_INSTALL_PICKUP_TITLE);
                orderDetails.pickUpDate =
                    this.getFormatDateTime(response.result.IPResult.pickUpDate, false);
              } else if (response.result.IPResult.deliveryOption ==
                  SELF_INSTALL_SHIP_TO_CUSTOMER_DELIVERY_OPTION) {
                orderDetails = this.formatOrderDetails(SELF_INSTALL_SHIP_TO_CUSTOMER_ICON,
                    SELF_INSTALL_SHIP_TO_CUSTOMER_FLAG, response.result.IPResult,
                    SELF_INSTALL_SHIP_TO_CUSTOMER_TITLE);
                orderDetails.order.shippingAddress =
                    (response.result.IPResult.order.shippingStreet != undefined ?
                    response.result.IPResult.order.shippingStreet + ', ' : '') +
                    (response.result.IPResult.order.shippingCity != undefined ?
                    response.result.IPResult.order.shippingCity + ', ' : '') +
                    (response.result.IPResult.order.shippingCountry != undefined ?
                    response.result.IPResult.order.shippingCountry + ', ' : '') +
                    (response.result.IPResult.order.shippingPostalCode != undefined ?
                    response.result.IPResult.order.shippingPostalCode : '');
                orderDetails.arriveByDate =
                    this.getFormatDateTime(response.result.IPResult.arriveByDate, false);
                let expectedDate = (response.result.IPResult.projectedDate != undefined
                    && response.result.IPResult.projectedDate != '') ?
                    this.addDays(response.result.IPResult.projectedDate,
                    DAYS_ADDED_IN_PROJECTED_DATE_FOR_EXPECTED_DATE) : '';
                orderDetails.expectedDate = this.getFormatDateTime(expectedDate, false);
              }
            }
          } else if (response.result.IPResult.order.type === DISCONNECTED_TYPE) {
            orderDetails = this.formatOrderDetails(DISCONNECTED_ICON, DISCONNECTED_FLAG,
                response.result.IPResult, DISCONNECTED_TITLE);
            orderDetails.order.requestedDueDate =
                this.getFormatDateTime(response.result.IPResult.order.requestedDueDate, false);
            let returnByDate = (response.result.IPResult.order.requestedDueDate != undefined
                && response.result.IPResult.order.requestedDueDate != '') ?
                this.addDays(response.result.IPResult.order.requestedDueDate,
                DAYS_ADDED_IN_REQUESTED_DUE_DATE_FOR_RETURN_BY_DATE) : '';
            orderDetails.returnByDate = this.getFormatDateTime(returnByDate, false);
            if (response.result.IPResult.devicesToReturn != null) {
              if (Array.isArray(response.result.IPResult.devicesToReturn)) {
                orderDetails.orderItems = response.result.IPResult.devicesToReturn;
              } else if (!Array.isArray(response.result.IPResult.devicesToReturn)) {
                orderDetails.orderItems = [];
                orderDetails.orderItems.push(response.result.IPResult.devicesToReturn);
              }
              orderDetails.orderItems.forEach(orderItem => {
                orderItem.status = this.getEquipmentReturnStatus(orderItem.isEquipmentReturned,
                    orderItem.isReturnDayReached);
              });
            } else {
                this.noOrderItemsError = 'No equipments to return.';
            }

          } else if (response.result.IPResult.order.type == PAUSE_TYPE) {
            orderDetails = this.formatOrderDetails(PAUSE_ICON, PAUSE_RESUME_FLAG,
                response.result.IPResult, PAUSE_TITLE);
            orderDetails.pauseStartDate =
                this.getFormatDateTime(response.result.IPResult.pauseStartDate, true);
            orderDetails.expectedResumeDate =
                this.getFormatDateTime(response.result.IPResult.expectedResumeDate, true);
            orderDetails.actualResumeDate =
                this.getFormatDateTime(response.result.IPResult.actualResumeDate, true);
            if (orderDetails.orderStatus == 'Activated' &&
                (orderDetails.actualResumeDate != undefined &&
                orderDetails.actualResumeDate != '')) {
              orderDetails.expectedResumeDate = orderDetails.actualResumeDate;
              this.isShowExpectedResumeDate = false;
            }
          } else if (response.result.IPResult.order.type == RESUME_TYPE) {
            orderDetails = this.formatOrderDetails(RESUME_ICON, PAUSE_RESUME_FLAG,
                response.result.IPResult, RESUME_TITLE);
            orderDetails.pauseStartDate =
                this.getFormatDateTime(response.result.IPResult.pauseStartDate, true);
            orderDetails.expectedResumeDate =
                this.getFormatDateTime(response.result.IPResult.expectedResumeDate, true);
            orderDetails.actualResumeDate =
                this.getFormatDateTime(response.result.IPResult.actualResumeDate, true);
            if (orderDetails.orderStatus == 'Activated'
                && orderDetails.actualResumeDate != undefined
                && orderDetails.actualResumeDate != '') {
              orderDetails.expectedResumeDate = orderDetails.actualResumeDate;
              this.isShowExpectedResumeDate = false;
            }
          }
          this.orderDetails = orderDetails;
          this.isSpinnerLoaded = false;
      } else {
        if (response.result.IPResult.hasOwnProperty(RESULT)) {
          this.error = response.result.IPResult.result.error.message;
        } else {
          this.error = ERROR_MESSAGE_NO_DETAILS;
        }
        this.orderDetails = undefined;
        this.isSpinnerLoaded = false;
      }
    }).catch (error => {
      this.isSpinnerLoaded = false;
      this.error = ERROR_MESSAGE_ERROR_ON_FETCHING_DETAILS;
    });
  }

/**
 * @description Method to add days to a date.
 * @param dateString Date string.
 * @param daysToBeAdded Days to be added to date.
 * @return DateTime
 */
  addDays(dateString, daysToBeAdded) {
    let dueDate = new Date(dateString);
    dueDate.setDate(dueDate.getDate() + daysToBeAdded);
    return dueDate.toISOString();
  }

/**
 * @description Method to format the Order details.
 * @param iconName Icon of the card.
 * @param orderType Type of the Order.
 * @param response Data node of response from CON_GetOrderDetails
 *      Integration Procedure.
 * @param title Title of the card.
 * @return Object
 */
  formatOrderDetails(iconName, orderType, response, title) {
    let orderDetail = {};

    orderDetail = response;
    if (orderDetail.hasOwnProperty(ORDER)) {
      orderDetail.order.creationDate = this.getFormatDateTime(response.order.creationDate, true);
    } else {
      orderDetail.order = {};
      orderDetail.order.creationDate = this.getFormatDateTime(response.creationDate, true);
    }
    orderDetail.icon = iconName;
    orderDetail[orderType] = true;
    orderDetail.title = title;
    return orderDetail;
  }

/**
 * @description Method to get return status of Equipment.
 * @param isReturned True: if equipment is returned. False: if equipment is not returned.
 * @param isReturnDayReached True: if equipments are not returned in 60 days.
 *     False: if equipments are returned in 60 days.
 * @return String
 */
  getEquipmentReturnStatus(isReturned, isReturnDayReached) {
    let status = '';
    if (isReturned) {
      status = STATUS_RETURNED;
    } else if (!isReturned) {
      status = STATUS_OUTSTANDING;
    } else if (isReturnDayReached) {
      status = STATUS_CHARGED;
    }
    return status;
  }

/**
 * @description Method to format date time in MMMM DD, YYYY hh:mm tt format.
 * Converting date to string because <lightning-formatted-date-time> is converting
 * time zone of date W.R.T. to user's device time zone.
 * @param dateTimeString date time string.
 * @param isTimeStampNeeded True: if date with time stamp is required
 *     False: if only date is required.
 * @return String
 */
  getFormatDateTime(dateTimeString, isTimeStampNeeded) {
    if (dateTimeString) {
      const dateTimeFormat = {
        year : YEAR_DISPLAY_FORMAT, month : MONTH_DISPLAY_FORMAT, day : DAY_DISPLAY_FORMAT,
        timeZone : TIME_ZONE
      };

      if (isTimeStampNeeded) {
        dateTimeFormat.hour = HOUR_DISPLAY_FORMAT;
        dateTimeFormat.minute = MINUTE_DISPLAY_FORMAT;
        dateTimeFormat.hour12 = true;
      }

      const dateTime = new Date(dateTimeString).toLocaleString('en-US', dateTimeFormat);
      return dateTime;
    } else {
      return '';
    }
  }

/**
 * @description Method to navigate to the Operation Ticket record page.
 * @param event Details of event fired on click of Ticket Id.
 */
  loadRecord(event) {
    const recordId = event.target.value;

    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
          recordId: recordId,
          actionName: 'view'
      },
    });
  }
}