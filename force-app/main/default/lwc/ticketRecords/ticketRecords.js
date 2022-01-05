import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class ticketRecords extends OmniscriptBaseMixin(LightningElement) {
  _accountIdForTicket;
  _accountPremisesId;
  @api nextStep;
  @track accError;
  @track conError;
  @track conItems = [];
  @track errorMessage = "";
  @track inputText;
  @track isTicketView = false;
  @track nextButtonClass =
      "slds-button slds-button_brand navigation-button-container disable-button";
  @track selectedAccount;
  @track ticketColumns = [
    {
      label: 'Issue Symptom',
      fieldName: 'IssueSymptom',
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
      label: 'Status',
      fieldName: 'Status',
      type: 'text'
    }
  ];
  @track options = [];
  value = 'New';
  @track responseTicketView = [];
  inputDetails(event) {
    this.inputText=eventconsole.target.value;
  }
  @api
  set accountIdForTicket(data) {
    if (data) {
    this._accountIdForTicket = data;
    }
  }
  get accountIdForTicket() {
    return this._accountIdForTicket;
  }
  @api
  set accountPremisesId(data) {
    if (data) {
      this._accountPremisesId = data;
    }
  }
  get accountPremisesId() {
    return this._accountPremisesId;
  }
  connectedCallback() {
    this.getListOfTickets();
  }
  onResponseSuccess(response) {
    this.selectedOption = this.value;
    this.omniApplyCallResp({'radioSelection': this.selectedOption});
    this.responseTicketView = [];
    this.responseTicketView.push({'IssueSymptom': 'Create new issue', 'DateModified':'',
        'Status': ''});
    if (response && Array.isArray(response)) {
      response.forEach(record => {
        let recordObject = {};
        let optionObject = {};
        recordObject.IssueSymptom = record.symptom;
        recordObject.DateModified = record.modifiedTime;
        recordObject.Status = record.status;
        recordObject.type = record.type;
        recordObject.subType = record.subType;
        recordObject.ticketFlowDefType = record.ticketFlowDefType;
        this.responseTicketView.push(recordObject);
        optionObject.label = record.symptom + '  :  '
            +new Date(record.modifiedTime).toDateString()+'  :  '+ record.status;
        optionObject.value = record.ticketId;
        this.options.push(optionObject);
      });
    }
    this.isTicketView = true;
  }

  getListOfTickets() {
    let requestObject = {};
    requestObject.premisesId = this._accountPremisesId;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'TCK_ExtractIssueTickets',
      options: '{}'
    };

    this.omniRemoteCall(params, true).then(response => {
      let result = (typeof response.result.IPResult ===
          'string') ? JSON.parse(response.result.IPResult) : response.result.IPResult;
      this.bugafiberIssueTicketList = result;
      this.onResponseSuccess(result);
    }).catch (error => {
      this.error = 'Error occured while fetching existing Issue Tickets.';
    });
  }

  createNewIssue() {
    this.selectedOption =  'New';
    this.omniApplyCallResp({
        'radioSelection': this.selectedOption,
        'bugafiberTicketId': '',
        'bugafiberTicketSymptom': '',
        'bugafiberTicketSubType': '',
        'bugafiberTicketType': '',
        'bugafiberTicketStatus': ''
    });
    this.nextStep = 'notes';
    this.omniNextStep();
  }

  handleChange(event) {
    this.selectedOption = event.detail.value;
    this.omniApplyCallResp({'radioSelection': this.selectedOption});
    this.nextButtonClass = "slds-button slds-button_brand navigation-button-container";
    if(event.detail.value !== 'New') {
      this.bugafiberIssueTicketList.forEach(record => {
        if((typeof record.ticketId === 'string') ? record.ticketId :
            record.ticketId.toString() === event.detail.value) {
          this.omniApplyCallResp({
              'bugafiberTicketId': record.ticketId,
              'bugafiberTicketSymptom': record.symptom,
              'bugafiberTicketSubType': record.subType,
              'bugafiberTicketType': record.type,
              'bugafiberTicketStatus': record.status
          });
        }
      });
    } else {
      this.omniApplyCallResp({
          'bugafiberTicketId': '',
          'bugafiberTicketSymptom': '',
          'bugafiberTicketSubType': '',
          'bugafiberTicketType': '',
          'bugafiberTicketStatus': ''
      });
    }
  }
  onSelectRecord(event) {
    this.isTicketView = true;
  };

  navigateToIssue() {
    if(this.selectedOption && this.selectedOption !== 'New') {
      this.nextStep = 'confirmIssueDetails';
      this.omniNextStep();
    } else {
      this.errorMessage = "Please select an issue to proceed."
    }
  }
}