/**
 * @group Tickets
 * @description This is used to fetch all issue tickets with open status
 */
import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation';

export default class populateOpenIssueTickets extends
    OmniscriptBaseMixin(NavigationMixin(LightningElement)) {

  @api accountId;
  @api leadId;
  @api historyId;
  @track showIssueList = false;
  @track showEndMessage = false;
  @track openIssueTicketList = [];

  /**
   * @description On Load Chages
   */
  connectedCallback() {
    if(this.accountId || this.leadId || this.historyId) {
      this.fetchOpenIssueTickets();
    } else {
      this.showEndMessage = true;
      this.showIssueList = false;
    }
  }
  /**
   * @description Used to call OpenIssueTicketsController (Fetch Issue Ticket with open status)
   */
  fetchOpenIssueTickets() {
    let inputObject = {};
    let methodName ='';
    if (this.accountId) {
      inputObject.accountId = this.accountId;
      methodName = 'getOpenIssueTickets';
    } else if (this.leadId) {
        inputObject.leadId = this.leadId;
        methodName = 'getOpenIssueTicketsForLead';
    } else if (this.historyId) {
        inputObject.historyId = this.historyId;
        methodName = 'getOpenIssueTicketsForHistoryEvent';
    }
    this.inputMap = JSON.stringify(inputObject);
    let params = {
      input: this.inputMap,
      sClassName: 'OpenIssueTicketsController',
      sMethodName: methodName,
      options: '{}',
    };
    this.omniRemoteCall(params, true).then(response => {
      let result = (typeof response.result.options === 'string')
          ? JSON.parse(response.result.options) : response.result.options;
      this.onResponseSuccess(result);
    }).catch (error => {
      this.searchMessage = false;
    });
  }

  /**
   * @description Issue ticket records exist then record will be visibility.
   */
  onResponseSuccess(response) {
    if(response && Array.isArray(response) && response.length > 0) {
      this.openIssueTicketList = response;
      this.showIssueList = true;
      this.showEndMessage = false;
    } else {
      this.showEndMessage = true;
      this.showIssueList = false;
    }
  }

  /**
   * @description Issue ticket records (status open) not exist then
   * it will show end interaction screen.
   */
  onEndInteraction() {
    this.omniApplyCallResp({'endThisInteractionSetValue': 'Yes'});
    this.omniNextStep();
  }

  /**
   * @description Navigate Record
   */
  openTicketDetails(event) {
    const config = {
      type: 'standard__recordPage',
      attributes: {
        recordId: event.target.name,
        actionName: 'view'
      }
    };
    this[NavigationMixin.Navigate](config);
  }
}