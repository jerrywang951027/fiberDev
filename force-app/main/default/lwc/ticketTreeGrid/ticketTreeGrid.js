/** 
 * @description This class is the main container for History Actions tree view
 */
import {
  api,
  LightningElement,
  track
} from 'lwc';
import {
  OmniscriptBaseMixin
} from 'vlocity_cmt/omniscriptBaseMixin';

/**
 * Columns definition
 */
const COLUMNS = [{
    type: 'text',
    fieldName: 'createdDate',
    label: 'Created Date',
    initialWidth: 200,
    cellAttributes: {
      alignment: 'left'
    }
  },
  {
    type: 'text',
    fieldName: 'typeSymptom',
    label: 'Type',
    wrapText: true,
    cellAttributes: {
      alignment: 'left'
    }
  },
  {
    type: 'url',
    fieldName: 'ticketUrl',
    label: 'Ticket Id',
    typeAttributes: {
      label: {
        fieldName: 'urlDisplay'
      }
    },
    cellAttributes: {
      alignment: 'left'
    }
  },
  {
    type: 'text',
    fieldName: 'summary',
    label: 'Summary',
    wrapText: true,
    cellAttributes: {
      alignment: 'left'
    }
  }
];
// Filter Types
const TYPES = [{
    label: 'Phone',
    value: 'Phone',
    level: 'parent'
  },
  {
    label: 'Chat',
    value: 'Chat',
    level: 'parent'
  },
  {
    label: 'Door to Door',
    value: 'Door to Door',
    level: 'parent'
  },
  {
    label: 'Email',
    value: 'Email',
    level: 'parent'
  },
  {
    label: 'Inbound',
    value: 'Inbound',
    level: 'parent'
  },
  {
    label: 'Outbound',
    value: 'Outbound',
    level: 'parent'
  },
  {
    label: 'Sign Up',
    value: 'Sign Up',
    level: 'parent'
  },
  {
    label: 'Social',
    value: 'Social',
    level: 'parent'
  },
  {
    label: 'SMS',
    value: 'SMS',
    level: 'parent'
  },
  {
    label: 'Internal Issue',
    value: 'Internal Issue',
    level: 'parent'
  },
  {
    label: 'Billing Event',
    value: 'Billing Event',
    level: 'parent'
  },
  {
    label: 'Google Account Transfer',
    value: 'Google Account Transfer',
    level: 'child'
  },
  {
    label: 'Installation Event',
    value: 'Installation Event',
    level: 'child'
  },
  {
    label: 'Move',
    value: 'Move',
    level: 'child'
  },
  {
    label: 'NIU Installation',
    value: 'NIU Installation',
    level: 'parent'
  },
  {
    label: 'One Time Transaction',
    value: 'One Time Transaction',
    level: 'child'
  },
  {
    label: 'Outage',
    value: 'Outage',
    level: 'parent'
  },
  {
    label: 'Plan Change',
    value: 'Plan Change',
    level: 'parent'
  },
  {
    label: 'Service Visit',
    value: 'Service Visit',
    level: 'parent'
  },
  {
    label: 'Suspension',
    value: 'Suspension',
    level: 'child'
  }
];

const COLUMNS_WORKLOG = [
 {
   label: 'Comments',
   fieldName: 'comment',
   type: 'text',
   wrapText: true
 },
 {
   label: 'Author',
   fieldName: 'emailAddress',
   type: 'text',
   wrapText: true,
   initialWidth: 250
 },
 {
   label: "Timestamp",
   fieldName: "modifiedTime",
   type: "date",
   wrapText: true,
   initialWidth: 200,
   typeAttributes:{
     year: "numeric",
     month: "long",
     day: "2-digit",
     hour: "2-digit",
     minute: "2-digit"
   }
 }
];
 

const ACCOUNT = 'Account';
const OPERATION_TICKET = 'Operation Ticket';
const LEAD = 'Lead';
const EN_US = 'en-US';

export default class TicketTreeGrid extends OmniscriptBaseMixin
  (LightningElement) {
    @api recordId;
    @api objectName;
    @track buganizerTicketObj = {};
    @track emailTimeStamp;
    @track gridData = [];
    @track historyEventObj = {};
    @track isBuganizerServiceVisit = false;
    @track isKnownIssue = {};
    @track isOutageIssue = {};
    @track isCustomerSignUp = false;
    @track isIssue = false;
    @track isInternalIssue = false;
    @track isBuganizerTicket = false;
    @track isOrderTicket = false;
    @track isEventServiceVisit = false;
    @track isChildEmail = false;
    @track isParentEmail = false;
    @track isNIUInstallation = false;
    @track latestCommentObj = {};
    @track isMove = false;
    @track oldResult;
    @track orderObj = {};
    @track selectedItem;
    @track selectedFilters = [];
    @track showSpinner = false;
    @track selectedRows = [];
    @track types = TYPES;
    @track timeStamp;
    @track planType;
    @track customerSignUp;
    @track signUpInsights;
    @track pilot;
    @track leadObjection;
    @track interactionResult;
    @track thirdPartyDelivery;
    @track isD2D = false;
    @track isPlanChange = false;
    @track direction;
    @track doorOpen;
    @track eventEndDate;
    @track eventDate;
    @track campaign;
    COLUMNS_WORKLOG = COLUMNS_WORKLOG;
    @track moveCreatedDate;
    @track moveOldAddress;
    @track moveNewAddress;
    
    @track oldAccountNumber;
    @track newAccountNumber;

    @track newPlan;
    @track oldPlan;

    @track isNewInstall = false;

    @track isPause = false;

    @track pauseStartDate;
    @track pauseEndDate;
    @track reason;
    @track linkToContactTicket;
    @track disconnectDate;
    @track isAccountTransfer = false;
    @track isDisconnect = false;

    @track isBillingEvent = false;
    @track completedTransaction;
    @track futureDatedTransaction;
    @track createdDate;
    @track allCommentsList = [];
	 @track showWorklog = false;
    currentResult;
    // definition of columns for the tree grid
    gridColumns = COLUMNS;
    nextPageToken = '';
    pageSize;
    previousSelection;
    totalPageSize;

    /**
     * @description Connected callback to fetch data.
     */
    connectedCallback() {
      this.fetchTreeData(false);
    }

    /**
     * @description This method calls Integrated Procedure to fetch the tree data.
     */
    fetchTreeData(nextButtonClick) {
      this.selectedRows = [];
      this.previousSelection = null;
      this.showSpinner = true;
      let recordId = this.recordId;
      let requestObject = {};
      switch (this.objectName) {
      case ACCOUNT:
        requestObject.accountId = recordId;
        break;
      case OPERATION_TICKET:
        requestObject.operationTicketId = recordId;
        break;
      case LEAD:
        requestObject.leadId = recordId;
        break;
      }
      requestObject.type = this.getFilterData();
      if (nextButtonClick) {
        requestObject.pageToken = this.nextPageToken;
        if (this.nextPageToken) {
          this.oldResult = this.currentResult;
        }
      }
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'TCK_ExtractHistory',
        options: '{}'
      };
      this.omniRemoteCall(params, true)
        .then((response) => {
          this.showSpinner = false;
          this.error = '';
          if (response && response.result && response.result.IPResult) {
            if (response.result.IPResult && response.result.IPResult.hasOwnProperty('error')) {
              this.error = response.result.IPResult.error;
            } else if (response.result.IPResult.returnValue &&
              (response.result.IPResult.returnValue.ticketResponse
              ||response.result.IPResult.returnValue.pageSize)) {
              const resultObj = response.result.IPResult.returnValue;
              // const resultObj = TEST_DATA.returnValue;
              this.currentResult = resultObj;
              this.updateTreeData(resultObj);
            } 
          } else {
            this.error = 'Error occured while fetching History details.';
          }
        })
        .catch((error) => {
          this.showSpinner = false;
          this.error = 'Error occured while fetching History details.';
        });
    }

    /**
     * @description This method is used to handle selection on the grid to override the default LWC's
     * tree grid functionality. We will always override the current selection with previous
     * selections.
     */
    handleRowSelection(event) {
      const selectedRows = event.detail.selectedRows;
      let self = this;
      const selectedRow = selectedRows.find(
        element =>
        (self.previousSelection ? element.uniqueId != self.previousSelection.uniqueId : true));
      this.previousSelection = selectedRow;
      let currentSelections = [];
      this.selectedItem = selectedRow;
      if (selectedRow) {
        currentSelections.push(selectedRow.uniqueId);
        this.updateDetailsView();
      }
      this.selectedRows = currentSelections;
		this.showWorklog = false;
    }

    /**
     * @description Event handle method when show Filter button is clicked
     */
    onFilterEventsClick() {
      this.selectedRows = [];
      this.selectedItem = null;
    }

    /**
     * @description Event handle method when next button is clicked
     */
    onNextClick() {
      this.fetchTreeData(true);
    }

    /**
     * @description Event handle method when previous button is clicked
     */
    onPreviousClick() {
      this.updateTreeData(this.oldResult);
      this.oldResult = null;
    }

    /**
     * @description this method is called when save button is clicked after filter selections
     */
    getFilterData() {
      if (this.selectedFilters && this.selectedFilters.length > 0) {
        let typeFilters = [];
        this.selectedFilters.forEach(
          item => (typeFilters.push(this.types.find(elem => (elem.value === item)))));
        return typeFilters;
      }
      return [];
    }

    /**
     * @description This method is called after tree data is fetched using IP and is used to transform
     * some data to be specific to LWC's TreeGrid Component.
     */
    updateTreeData(resultObj) {
      const ticketResponse = resultObj.ticketResponse;
      if (resultObj.ticketResponse) {
        const treeDataArray = ticketResponse.map(item => {
        let uniqueId = item.bugafiberId ? item.bugafiberId : item.Id;
        const isEmail = (item.type === 'Email' && !item.bugafiberId);
        let parentObj = {
          type: item.type,
          uniqueId: uniqueId,
          bugafiberId: item.bugafiberId,
          createdDate: item.createdDate,
          id: item.Id,
          isChild: item.isChild,
          ticketUrl: isEmail ? '' : item.ticketUrl,
          summary: item.summary,
          urlDisplay: isEmail ? '' : uniqueId,
          isBuganizerTicket: item.isBuganizerTicket,
			 typeSymptom: item.type
        };
        if (item.children && item.children.length > 0) {
          const newChildArray = item.children.map(childItem => {
            let childUniqueId = childItem.bugafiberId ? childItem.bugafiberId : childItem.Id;
            const isEmailChild = (
              (childItem.type === 'Email' ||
                childItem.type === 'Proof of Residency Requested' ||
                childItem.type === 'Customer Follow up' ||
                childItem.type === 'Sign-Up Lead'
              ) &&
              !childItem.bugafiberId
            );
            //const isEmailChild = (childItem.type === 'Email' && !childItem.bugafiberId);
            let childObj = {
              type: childItem.type,
			     typeSymptom: childItem.typeSymptom,
              uniqueId: childUniqueId,
              bugafiberId: childItem.bugafiberId,
              createdDate: childItem.createdDate,
              id: childItem.Id,
              isChild: childItem.isChild,
              ticketUrl: isEmailChild ? '' : childItem.ticketUrl,
              summary: childItem.summary,
              urlDisplay: isEmailChild ? '' : childUniqueId,
              isBuganizerTicket: childItem.isBuganizerTicket
            };
            return childObj;
          });
          parentObj['_children'] = newChildArray;
        }
        return parentObj;
      });
      this.pageSize = resultObj.pageSize;
      this.nextPageToken = resultObj.pageToken;
      this.totalPageSize = resultObj.totalSize;
      this.gridData = treeDataArray;
      } else {
        this.gridData = resultObj;
      }
    }

    /**
     * @description This method is used to call separate Ips to fetch Detail views and conditions by
     * data type is determined in this function
     */
    updateDetailsView() {
      this.isOrderTicket = false;
      this.isChildEmail = false;
      this.isParentEmail = false;
      this.isServiceVisit = false;
      this.isIssue = false;
      this.isInternalIssue = false;
      this.isBuganizerTicket = false;
      this.isKnownIssue = false;
      this.isOutageIssue = false;
      this.isNIUInstallation = false;
      this.isEventServiceVisit = false;
      this.isBuganizerServiceVisit = false;
      this.isCustomerSignUp = false;
      this.isD2D = false;
      this.isMove = false;
      this.isPause = false;
      this.isPlanChange = false;
      this.isNewInstall = false;
      this.isDisconnect = false;
      this.isBillingEvent = false;
      this.isAccountTransfer = false;
      if (this.selectedItem) {
        if (this.selectedItem.isChild) {
          //alert('id--->'+this.selectedItem.id);
          if (this.selectedItem.bugafiberId && this.selectedItem.type === 'Issue') {
            this.fetchBuganizerTicketDetails();
            this.isIssue = true;
          } else if (!this.selectedItem.bugafiberId &&
            ((this.selectedItem.type.indexOf('Email') != -1) || this.selectedItem.type === 'Email' ||
              this.selectedItem.type === 'Proof of Residency Requested')) {
            this.fetchHistoryEventDetails();
            this.isChildEmail = true;
          } else if (this.selectedItem.id && this.selectedItem.id.startsWith('801')) {
            this.fetchOrderDetails();
            this.isOrderTicket = true;
          } else if (!this.selectedItem.bugafiberId && (this.selectedItem.type === 'Customer Follow up' ||
              this.selectedItem.type === 'Sign-Up Lead')) {
            this.fetchHistoryEventDetails();
            this.isCustomerSignUp = true;
          }
        } else {
          if (this.selectedItem.type === 'Move') {
            this.fetchOrderDetails();
            this.isMove = true;
          } else if (this.selectedItem.type === 'Plan change') {
            this.fetchOrderDetails();
            this.isPlanChange = true;
          } else if (this.selectedItem.type === 'New Install') {
            this.fetchOrderDetails();
            this.isNewInstall = true;
          } else if (this.selectedItem.type === 'Pause') {
            this.fetchOrderDetails();
            this.isPause = true;
          } else if (this.selectedItem.type === 'Disconnect') {
            this.fetchOrderDetails();
            this.isDisconnect = true;
          } else if (this.selectedItem.type === 'Billing' || this.selectedItem.type === 'Suspension') {
            this.billientEventDetails();
            this.isBillingEvent = true;
          } else if (this.selectedItem.type === 'Account Transfer') {
            this.fetchOrderDetails();
            this.isAccountTransfer = true;
          } else if (this.selectedItem.bugafiberId) {
            // 'NIU Intsallation', 'Known Issue',
            switch (this.selectedItem.type) {
            case 'Chat':
            case 'Email':
            case 'Inbound Phone':
            case 'Inbound Chat':
            case 'Inbound Email':
            case 'Inbound Social':
            case 'Inbound SMS':
            case 'Inbound Phone':
            case 'NOC':
            case 'Outbound Chat':
            case 'Outbound Email':
            case 'Outbound Social':
            case 'Outbound Sign Up':
            case 'Outbound SMS':
            case 'Outbound Phone':
            case 'Outbound':
            case 'Phone':
            case 'Social':
            case 'SMS':
              this.fetchBuganizerTicketDetails();
              this.isBuganizerTicket = true;
              break;
            case 'Internal Issue':
              this.fetchBuganizerTicketDetails();
              this.isIssue = true;
              this.isInternalIssue = true;
              break;
            case 'Service Visit':
              if (this.selectedItem.isBuganizerServiceVisit) {
                this.fetchBuganizerTicketDetails();
                this.isBuganizerServiceVisit = true;
              } else {
                this.fetchHistoryEventDetails();
                this.isEventServiceVisit = true;
              }
              break;
            case 'known Issue':
              this.isKnownIssue = true;
              this.fetchBuganizerTicketDetails();
              break;
            case 'Outage':
              this.isOutageIssue = true;
              this.fetchBuganizerTicketDetails();
              break;
            case 'NIU Intsallation':
              this.isNIUInstallation = true;
              break;
            default:
              this.isBuganizerTicket = true;
              this.buganizerTicketObj = {};
              break;
            }
          } else {
            if (this.selectedItem.type === 'Move') {
              this.fetchOrderDetails();
              this.isMove = true;
            }

            if (this.selectedItem.type === 'Email' ||
              this.selectedItem.type === 'Sign Up') {
              this.isParentEmail = true;
              this.fetchHistoryEventDetails();
            }

            if (this.selectedItem.type === 'Outbound Door to Door') {
              this.fetchHistoryEventDetails();
              this.isD2D = true;

            }
          }
        }
      }
    }

    /**
     * @description This method calls Integrated Procedure to fetch buganizer ticket details by
     * calling out a bugafiber api and get details and latest comments
     */
    fetchBuganizerTicketDetails() {
      let requestObject = {};
      let marketTimeZone = {};
      this.latestCommentObj = {};
      this.buganizerTicketObj = {};
      requestObject.bugafiberTicketId = this.selectedItem.bugafiberId;
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'TCK_ExtractBuganizerDetails',
        options: '{}'
      };

      this.omniRemoteCall(params, true)
        .then((response) => {
          this.error = '';
          if (response && response.result && response.result.IPResult) {
            if (response.result.IPResult.ticketDetails) {
              this.buganizerTicketObj = response.result.IPResult.ticketDetails;
              marketTimeZone = response.result.IPResult.timeZoneInfo.TimeZone;
              const dateTimeFormat = {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: 'numeric',
                minute: 'numeric',
                second: 'numeric',
                weekday: 'long',
                hour12: true,
                timeZone: marketTimeZone
              };
              if (marketTimeZone != null) {
                this.timeStamp =
                  new Date(response.result.IPResult.ticketDetails.createdTime).toLocaleString(
                    'en-US', dateTimeFormat);
                response.result.IPResult.ticketDetails.createdTime =
                  new Date(response.result.IPResult.ticketDetails.createdTime).toLocaleString(
                    'en-US', dateTimeFormat);
                response.result.IPResult.ticketDetails.modifiedTime =
                  new Date(response.result.IPResult.ticketDetails.modifiedTime).toLocaleString(
                    'en-US', dateTimeFormat);
              } else {
                this.timeStamp = response.result.IPResult.historyEventOrder.TimeStamp;
              }
              this.planType = response.result.IPResult.historyEventOrder.Type;
            /*  if (response.result.IPResult.latestComment) {
                this.latestCommentObj = response.result.IPResult.latestComment;
              }
              if (response.result.IPResult.allComments) {
                this.allCommentsList = response.result.IPResult.allComments;
              } */
            if (response.result.IPResult.latestComment) {
            this.latestCommentObj = response.result.IPResult.latestComment;
            }
            if (response.result.IPResult.allComments) {
            this.allCommentsList = response.result.IPResult.allComments;
            }
            }

          } else {
            this.error = 'Error occured while fetching Ticket details.';
          }
        })
        .catch((error) => {
          this.error = 'Error occured while fetching Ticket details.';
        });
    }
	
	/**
     * @description This method call is used to toggle showWorklog flag
     */
	updateWorklogFlag(){
		this.showWorklog = !this.showWorklog;
	}

    /**
     * @description This method calls Integrated Procedure to fetch Order details
     */
    fetchOrderDetails() {
      let requestObject = {};
      this.orderObj = {};
      requestObject.orderId = this.selectedItem.id;
      requestObject.type = this.selectedItem.type;
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'ORD_ExtractOrderDetails',
        options: '{}'
      };
      this.omniRemoteCall(params, true)
        .then((response) => {
          this.error = '';
          if (response && response.result && response.result.IPResult) {
            this.orderObj = response.result.IPResult;
            this.moveCreatedDate = this.orderObj.createdDate;
            this.moveOldAddress = this.orderObj.oldAddress;
            this.moveNewAddress = this.orderObj.newAddress;
            this.oldAccountNumber = this.orderObj.oldAccountNumber;
            this.newAccountNumber = this.orderObj.newAccountNumber;

            this.newPlan = JSON.stringify(this.orderObj.newPlan);
            this.oldPlan = this.orderObj.oldPlan;

            this.pauseStartDate = this.orderObj.pauseStartDate;
            this.pauseEndDate = this.orderObj.pauseEndDate;
            this.reason = this.orderObj.reason;
            this.linkToContactTicket = this.orderObj.linkToContactTicket;
            this.disconnectDate = this.orderObj.disconnectDate;

          } else {
            this.error = 'Error occured while fetching Order details.';
          }
        })
        .catch((error) => {
          this.error = 'Error occured while fetching Order details.';
        });
    }

    /**
     * @description This method calls Integrated Procedure to fetch Order details
     */
    fetchHistoryEventDetails() {
      let requestObject = {};
      this.historyEventObj = {};
      if (this.selectedItem.isChild && (this.selectedItem.type.indexOf('Email') != -1 || 
		    this.selectedItem.type === 'Email' ||
          this.selectedItem.type === 'Proof of Residency Requested' ||
          this.selectedItem.type === 'Customer Follow up' ||
          this.selectedItem.type === 'Sign-Up Lead'
        )) {
        requestObject.historyActionId = this.selectedItem.id;
        //alert(this.selectedItem.type);
      } else {
        requestObject.type = this.selectedItem.type;
        if (this.selectedItem.bugafiberId == null) {
          requestObject.historyEventKey = this.selectedItem.id;
        } else {
          requestObject.historyEventKey = this.selectedItem.bugafiberId;
        }
      }
      const dateTimeFormat = {
        year: 'numeric',
        month: 'short',
        day: '2-digit',
        hour: 'numeric',
        minute: 'numeric',
        second: 'numeric',
        weekday: 'long',
        hour12: true,
      };
      requestObject.type = this.selectedItem.type;

      requestObject.createdDate = new Date(requestObject.createdDate).toLocaleString(dateTimeFormat);
      requestObject.createdDate = requestObject.createdDate
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'TCK_ExtractEventDetails',
        options: '{}'
      };
      this.omniRemoteCall(params, true)
        .then((response) => {
          this.error = '';
          if (response && response.result && response.result.IPResult) {
            this.historyEventObj = response.result.IPResult;
            this.marketTimeZone = this.historyEventObj.timeZone.TimeZone;

            if (requestObject.type === 'Outbound Door to Door') {
              this.direction = this.historyEventObj.outboundDetails.direction;
              this.doorOpen = this.historyEventObj.outboundDetails.doorOpen;
              this.eventEndDate = this.historyEventObj.outboundDetails.eventEndDate;
              this.eventDate = this.historyEventObj.outboundDetails.eventDate;
            }

            if (this.historyEventObj.customerFollowUp.type === 'Customer Follow up' ||
              this.historyEventObj.customerFollowUp.type === 'Sign-Up Lead') {
              this.isCustomerSignUp = true;
              this.signUpInsights = this.historyEventObj.customerFollowUp.signUpInsights;
              this.pilot = this.historyEventObj.customerFollowUp.pilot;
              this.leadObjection = this.historyEventObj.customerFollowUp.leadObjection;
              this.interactionResult = this.historyEventObj.customerFollowUp.interactionResult;
              this.thirdPartyDelivery = this.historyEventObj.customerFollowUp.thirdPartyDelivery;
              this.campaign = this.historyEventObj.customerFollowUp.name;
            } else {
              // this.isCustomerSignUp = false;
            }

            const dateTimeFormat = {
              year: 'numeric',
              month: 'short',
              day: '2-digit',
              hour: 'numeric',
              minute: 'numeric',
              second: 'numeric',
              weekday: 'long',
              hour12: true,
              timeZone: this.marketTimeZone
            };
            if (this.marketTimeZone != null) {
              this.historyEventObj.dateAndTime =
                new Date(this.historyEventObj.dateAndTime).toLocaleString('en-US', dateTimeFormat);
              this.timeStamp =
                new Date(response.result.IPResult.historyEventOrder.CreatedDate).toLocaleString(
                  'en-US', dateTimeFormat
                );
              this.emailTimeStamp =
                new Date(this.historyEventObj.timeStamp).toLocaleString('en-US', dateTimeFormat);
            } else {
              this.emailTimeStamp = this.historyEventObj.timeStamp;
              this.timeStamp = response.result.IPResult.historyEventOrder.CreatedDate;
            }
            this.planType =
              response.result.IPResult.historyEventOrder.productName + ' , ' +
              response.result.IPResult.historyEventOrder.Name;

            if ((this.planType).includes("undefined")) {
              this.planType = '';
            }

          } else {
            this.error = 'Error occured while fetching Event details.';
          }
        })
        .catch((error) => {
          this.error = 'Error occured while fetching Event details.';
        });
    }

    onMultiSelectChange(event) {
      this.selectedFilters = event.detail;
    }

    /**
     * @description Event handle method when save button is clicked
     */
    filterByTypes() {
      this.fetchTreeData(false);
    }

    /**
     * @description This method calls Integrated Procedure to billing event details
     */
    billientEventDetails() {
      let requestObject = {};
      this.orderObj = {};
      requestObject.billingEventId = this.selectedItem.id;
      requestObject.type = this.selectedItem.type;
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'TCK_ExtractBillingEventDetail',
        options: '{}'
      };
      this.omniRemoteCall(params, true)
        .then((response) => {
          this.error = '';
          if (response && response.result && response.result.IPResult) {
            alert(response);
            console.log("checklog802");
            this.orderObj = response.result.IPResult;
            //alert(JSON.stringify(this.orderObj));
            this.completedTransaction = this.orderObj.completedTransactions;
            this.futureDatedTransaction = this.orderObj.futureDatedTransactions;
            this.createdDate = this.orderObj.createdDate;
          } else {
            this.error = 'Error occured while fetching Order details.';
          }
        })
        .catch((error) => {
          this.error = 'Error occured while fetching Order details.';
        });
    }
  }