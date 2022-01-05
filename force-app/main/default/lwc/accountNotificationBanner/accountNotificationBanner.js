/**
 * @group CSR Console
 * @description It Will display notifications for each Consumer Account and it's associated
 *     Service Accounts in the Service Console.
 */
 import { api, LightningElement, track } from 'lwc';
 import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
 import { NavigationMixin } from 'lightning/navigation';
 
 const CUSTOM_NOTIFICATION_NOT_FOUND_MSG = 'No cutom/system generated notifications found.';
 const SERVICE_OUTAGE_NOTIFICATION_NOT_FOUND_MSG = 'No service outage notifications found.';
 
 export default class AccountNotificationBanner extends OmniscriptBaseMixin
     (NavigationMixin(LightningElement)) {
 
   @track notificationList = [];
   @track serviceAccountId;
 
   /**
   * @description Getter to set the decorator serviceAccountId with account Id.
   * @return accountId
   */
   @api get accountId() {
     return this.serviceAccountId;
   }
 
   /**
   * @description Will fire everytime when Location changes from Customer Details FlexCard
   *     and get the Service Account Id.
   * @param inputData Data to be set.
   */
   set accountId(data) {
     this.setAttribute('serviceAccountId', data);
     if (data) {
       this.serviceAccountId = data;
       this.getNotifications();
     }
   }
 
   /**
   * @description Method to call Integration Procedure CON_FetchNotifications to get Custom/System
   *     generated notifications and display it in Service Console.
   */
   getNotifications(){
     this.notificationList = [];
 
     const requestObject = {};
     requestObject.serviceAccountId = this.serviceAccountId;
 
     const params = {
       input: JSON.stringify(requestObject),
       sClassName: 'vlocity_cmt.IntegrationProcedureService',
       sMethodName: 'CON_FetchNotifications',
       options: '{}'
     };
 
     this.omniRemoteCall(params, true).then(response => {
       console.log('response == '+JSON.stringify(response));
       if (response.result.IPResult.fetchServiceOutage.hasOwnProperty('outages')) {
         if (response.result.IPResult.fetchServiceOutage.serviceDetails
           .internetAssetStatus === 'Active') {
         let outageNotificationsObj = {};
         const parsedOutageNotifications = response.result.IPResult.fetchServiceOutage.outages;
         if (Array.isArray(parsedOutageNotifications) && parsedOutageNotifications.length > 0) {
           parsedOutageNotifications.filter(item => {
             outageNotificationsObj = {};
             if ((item.status).toLowerCase() !== 'completed') {
               if (response.result.IPResult.fetchServiceOutage.serviceDetails
                   .phoneAssetStatus === 'Active' && (item
                   .serviceAffected).toLowerCase() === 'voice') {
                 outageNotificationsObj.id = item.ticketId;
                 outageNotificationsObj.isTicketId = true;
                 outageNotificationsObj.message = response.result.IPResult.setMessage.messsage;
                 outageNotificationsObj.message += this.getFormattedDate(item.estimatedEndTime);
                 outageNotificationsObj.variant = response.result.IPResult.setMessage.variant;
                 outageNotificationsObj.icon = response.result.IPResult.setMessage.icon;
                 outageNotificationsObj.styleClass = 'outage-notification';
                 this.notificationList.push(outageNotificationsObj);
               } else if ((item.serviceAffected).toLowerCase() !== 'voice') {
                 outageNotificationsObj.id = item.ticketId;
                 outageNotificationsObj.isTicketId = true;
                 outageNotificationsObj.message = response.result.IPResult.setMessage.messsage;
                 outageNotificationsObj.message += this.getFormattedDate(item.estimatedEndTime);
                 outageNotificationsObj.variant = response.result.IPResult.setMessage.variant;
                 outageNotificationsObj.icon = response.result.IPResult.setMessage.icon;
                 outageNotificationsObj.styleClass = 'outage-notification';
                 this.notificationList.push(outageNotificationsObj);
               }
             }
           });
         }
         else if (parsedOutageNotifications.constructor === Object) {
           if ((parsedOutageNotifications.status).toLowerCase() !== 'completed') {
             if (response.result.IPResult.fetchServiceOutage.serviceDetails
                 .phoneAssetStatus === 'Active' && (parsedOutageNotifications
                 .serviceAffected).toLowerCase() === 'voice') {
               outageNotificationsObj.id = parsedOutageNotifications.ticketId;
               outageNotificationsObj.isTicketId = true;
               outageNotificationsObj.message = response.result.IPResult.setMessage.messsage;
               outageNotificationsObj.message += this.getFormattedDate(parsedOutageNotifications
                   .estimatedEndTime);
               outageNotificationsObj.variant = response.result.IPResult.setMessage.variant;
               outageNotificationsObj.icon = response.result.IPResult.setMessage.icon;
               outageNotificationsObj.styleClass = 'outage-notification';
               this.notificationList.push(outageNotificationsObj);
             } else if ((parsedOutageNotifications.serviceAffected).toLowerCase() !== 'voice'){
               outageNotificationsObj.id = parsedOutageNotifications.ticketId;
               outageNotificationsObj.isTicketId = true;
               outageNotificationsObj.message = response.result.IPResult.setMessage.messsage;
               outageNotificationsObj.message += this.getFormattedDate(parsedOutageNotifications
                   .estimatedEndTime);
               outageNotificationsObj.variant = response.result.IPResult.setMessage.variant;
               outageNotificationsObj.icon = response.result.IPResult.setMessage.icon;
               outageNotificationsObj.styleClass = 'outage-notification';
               this.notificationList.push(outageNotificationsObj);
             }
           }
         }
         else {
           console.log(SERVICE_OUTAGE_NOTIFICATION_NOT_FOUND_MSG);
         }
       }
       else {
         console.log(SERVICE_OUTAGE_NOTIFICATION_NOT_FOUND_MSG);
       }
     }
 
     if (response.result.IPResult.fetchNotification.hasOwnProperty('notification')) {
       const parsedNotifications = response.result.IPResult.fetchNotification.notification;
       if (Array.isArray(parsedNotifications) && parsedNotifications.length > 0) {
         this.notificationList = [...new Set([...this.notificationList,...parsedNotifications])];
       }
       else if (parsedNotifications.constructor === Object &&
         parsedNotifications.hasOwnProperty('id')) {
         this.notificationList.push(parsedNotifications);
       }
       else {
         console.log(CUSTOM_NOTIFICATION_NOT_FOUND_MSG);
       }
     }
     else {
       console.log(CUSTOM_NOTIFICATION_NOT_FOUND_MSG);
     }
 
     if (this.notificationList.length > 0) {
       this.loadStyles();
     }
 
     }).catch (error => {
       console.log('Error: '+JSON.stringify(error));
     });
   }
 
   /**
   * @description Method to format date in toLocaleDateString.
   * @param dateTime
   */
   getFormattedDate(dateTime) {
     return new Date(dateTime).toLocaleDateString();
   }
 
   /**
   * @description Method to set the style for vlocity_cmt-alert component, aligning the
   *     text to the left side and changing the color of the button.
   */
   loadStyles() {
     const vlocityAlertCustomStyle = document.createElement('style');
     vlocityAlertCustomStyle.innerText = `.slds-notify_alert {justify-content:left; text-align:left;}
         .custom-notification .slds-notify_alert.slds-theme_warning {background-color:#f8e38e;
         color:#080707;} .custom-notification .slds-notify_alert.slds-theme_warning
         .slds-icon {fill:#514f4d} .outage-notification button {line-height: normal;}
         .outage-notification button, .outage-notification button:hover,
         .outage-notification button:focus, .outage-notification button:active {color: #000;}`;
 
     setTimeout(() => {
       this.template.querySelector('vlocity_cmt-alert').appendChild(vlocityAlertCustomStyle);
     }, 100);
   }
 
   /**
    * @description Method to load Ticket details in a sub tab by navigating it to
    *     genericAuraWrapperForConsoleLWC Aura component and by passing Ticket Id.
    * @param  event - Fired event data
    */
   loadTicketDetails(event) {
     const data = {'bugafiberTicketId': event.target.value}
     this[NavigationMixin.Navigate]({
       'type': 'standard__component',
       'attributes': {
         'componentName': 'c__genericAuraWrapperForConsoleLWC'
       },
       state: {
         c__initialData: JSON.stringify(data),
         c__isExpandView: true,
         c__lwcComponentName: 'c:buganizerTicketView',
         c__tabIcon: 'utility:bug',
         c__tabLabel: event.target.value
       }
     });
   }
 }