import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class contactTicketAssociatedWithTicket extends OmniscriptBaseMixin(LightningElement) {
  @api nextStep;
  @api ticketId;
  @track accError;
  @track conError;
  @track conItems = [];
  @track errorMessage = "";
  @track inputText;
  @track isTicketView = false;
  @track nextButtonClass =
      "slds-button slds-button_brand navigation-button-container disable-button";
  @track options = [];
  @track responseTicketView = [];
  @track selectedAccount;
  @track ticketColumns = [
    {
      label: 'Bugafiber Id',
      fieldName: 'BugafiberId',
      type: 'text'
    },
    {
      label: 'Date Modified',
      fieldName: 'DateModified',
      type: "date",
      typeAttributes:{
        year: "numeric",
        month: "long",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
      }
    },
    {
      label: 'Ldap',
      fieldName: 'Ldap',
      type: 'text'
    }
  ];
  _ticketId;
  inputDetails(event) {
    this.inputText=eventconsole.target.value;
  }
  set ticketId(data) {
    if (data) {
    this._ticketId = data;
    }
  }
  get ticketId() {
    return this._ticketId;
  }
  connectedCallback() {
    this.getListOfTickets();
  }
  onResponseSuccess(response) {
    this.selectedOption = this.value;
    this.omniApplyCallResp({'radioSelection': this.selectedOption});
    this.responseTicketView = [];
    this.responseTicketView.push({'BugafiberId': '','DateModified': '','Ldap':''});
    if (response && Array.isArray(response)) {
      response.forEach(record => {
        let recordObject = {};
        let optionObject = {};
        recordObject.BugafiberId = record.bugafiberId;
        recordObject.DateModified = record.lastModifiedDate;
        recordObject.Ldap = record.lastModifiedBy;
        this.responseTicketView.push(recordObject);
        optionObject.label = record.bugafiberId + '  :  '
            +new Date(record.lastModifiedDate).toDateString()+'  :  '+ record.lastModifiedBy;
        optionObject.value = record.historyEventId;
        this.options.push(optionObject);
      });
    }
    this.isTicketView = true;
  }

  getListOfTickets() {
    let requestObject = {};
    requestObject.ticketId = this._ticketId;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'TCK_ExtractHistoryEvents',
      options: '{}'
    };

    this.omniRemoteCall(params, true).then(response => {
      let result = (typeof response.result.IPResult ===
          'string') ? JSON.parse(response.result.IPResult) : response.result.IPResult;
	  this.bugafiberIssueTicketList = result.recentlyClosedHistoryEvents;
      this.onResponseSuccess(result.recentlyClosedHistoryEvents);
    }).catch (error => {
      this.error = 'Error occured while fetching existing Contact Tickets.';
    });
  }

  handleChange(event) {
    this.selectedOption = event.detail.value;
    console.log(JSON.stringify(this.selectedOption));
    this.omniApplyCallResp({'radioSelection': this.selectedOption});
    this.nextButtonClass = "slds-button slds-button_brand navigation-button-container";
  }
  onSelectRecord(event) {
    this.isTicketView = true;
  };

  save() {
    if(this.selectedOption && this.selectedOption !== 'New') {
      console.log(JSON.stringify(this.selectedOption));
      this.nextStep = 'upadteContactTicketForIssueTicket';
      this.omniNextStep();
    } else {
      this.errorMessage = "Please select a Contact Ticket to proceed."
    }
  }
}