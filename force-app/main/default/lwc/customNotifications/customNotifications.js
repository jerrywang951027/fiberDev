/**
 * @group CSR Console
 * @description It Will display All the Notifications in a table and
 * Create Notification Form in CON_CustomNotifications OmniScript.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getDataHandler } from 'vlocity_cmt/utility';
import { cloneDeep } from 'vlocity_cmt/lodash';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const NOTIFICATION_ERROR_MSG = 'There is an issue in updating Notification.';
const NOTIFICATION_NOT_FOUND_MSG = 'No notifications are available for the associated Account.'
const NOTIFICATION_SUCCESS_MSG = 'Notification has been updated successfully.';

export default class CustomNotifications extends OmniscriptBaseMixin(LightningElement) {

  _notifications;
  allNotifications;
  isCreateNotificationForm = false;
  isSpinner = false;
  notificationErrorMessage = NOTIFICATION_NOT_FOUND_MSG;
  tableHeight = 'height:12rem';

 /**
  * @description Getting value of notifications, set in the OmniScript as a LWC property
  *     and setting it to the decorator _notifications.
  * @param data value to be set in the decorator _notifications.
  */
  @api
  set notifications(data) {
    if (data) {
      this._notifications = data;
    }
  }

 /**
  * @description Getter to return decorator _notifications.
  * @return notifications
  */
  get notifications() {
    return this._notifications;
  }

 /**
  * @description Set all the Notifications grouped by enabled notifications and then grouped by
  *     disabled notifications in a list and then set it in the decorator allNotifications to
  *     display it in the UI.
  */
  connectedCallback() {
    let enabledNotificationsArr = [];
    let disabledNotificationsArr = [];

    const today = new Date(new Date().toISOString().split('T')[0]).getTime();

    if (this._notifications) {
      const clonedRecords = cloneDeep(this._notifications);

      if (Array.isArray(clonedRecords) && clonedRecords.length > 0) {
        clonedRecords.filter((item) => {

          if (item.expirationDate && item.expirationDate !== '') {
            let expirationDate = item.expirationDate.split('T')[0];
            expirationDate = new Date(expirationDate).getTime();

            if (expirationDate >= today) {
              item.isDisabled = false;
              enabledNotificationsArr.push(item);

            } else {
              item.isDisabled = true;
              disabledNotificationsArr.push(item)
            }

          } else {
            item.isDisabled = false;
            enabledNotificationsArr.push(item);
          }
        });
        this.allNotifications = enabledNotificationsArr.concat(disabledNotificationsArr);

      } else if (clonedRecords.constructor === Object) {
        const clonedRecordArr = [];

        if (clonedRecords.expirationDate && clonedRecords.expirationDate !== '') {
          let expirationDate = clonedRecords.expirationDate.split('T')[0];
          expirationDate = new Date(expirationDate).getTime();

          if (expirationDate >= today) {
            clonedRecords.isDisabled = false;

          } else {
            clonedRecords.isDisabled = true;
          }

        } else {
          clonedRecords.isDisabled = false;
        }

        this.tableHeight = 'auto';
        clonedRecordArr.push(clonedRecords);
        this.allNotifications = clonedRecordArr;

      } else {
        this.allNotifications = undefined;
      }

    } else {
      this.allNotifications = undefined;
    }

  }

 /**
  * @description Method to toggle (hide/show) Notifications table and Create Notification Form.
  */
  showCreateNotificationForm() {
    this.isCreateNotificationForm = !this.isCreateNotificationForm;

    const dataToUpdate = {
      'showCreateNotificationForm': this.isCreateNotificationForm
    };

    this.omniUpdateDataJson(dataToUpdate);
  }

 /**
  * @description Method to check if check box is checked or not and based on that enable
  *     and disable the notification by updating expiration date field in the Notification record.
  * @param event - Fired event data.
  */
  updateNotification(event) {
    const isChecked = event.target.checked;
    const index = event.target.name;
    const selectedNotification = this.allNotifications[index];
    const notificationData = {};

    notificationData.isChecked = isChecked;
    notificationData.notificationId = selectedNotification.id;

    if (isChecked) {
      notificationData.expirationDate = this.getYesterDate();
    } else {
      notificationData.expirationDate = '';
    }

    this.updateNotificationRecord(notificationData);
  }

 /**
  * @description Method to call the DataRaptor CON_UpdateNotification
  *     to update (enable/disable) the Notification record.
  * @param data Data to be passed to DR.
  */
  async updateNotificationRecord(data) {
    this.isSpinner = true;

    const requestData = {};
    requestData.value = {};
    requestData.type = 'dataraptor';
    requestData.value.inputMap = JSON.stringify(data);
    requestData.value.bundleName = 'CON_UpdateNotification';

    await getDataHandler(JSON.stringify(requestData)).then(result => {
      this.isSpinner = false;
      this.showNotification('Success', NOTIFICATION_SUCCESS_MSG, 'success');
    }).catch(error => {
      this.isSpinner = false;
      this.showNotification('Error', NOTIFICATION_ERROR_MSG, 'error');
    });
  }

 /**
  * @description Method to get the yesterday's date.
  * @return getYesterDate
  */
  getYesterDate() {
    let today = new Date();
    today.setDate(today.getDate() - 1);
    return today.toISOString().split('T')[0];
  }

 /**
  * @description Method to show the Notification.
  * @param title Title of the Notification.
  * @param message Message to be displayed in the Notification.
  * @param variant Variant of Notification (success/error).
  */
  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}