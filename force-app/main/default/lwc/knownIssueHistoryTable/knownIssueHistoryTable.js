import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import pubsub from 'vlocity_cmt/pubsub';

const COLUMNS = [
  {
    fieldName: "title",
    label: "Title",
    searchable: "false",
    sortable: true,
    type: "text",
    wrapText : true
  },
  {
    fieldName: "nocTicketCreatedTime",
    label: "Noc Ticket Created Date",
    searchable: false,
    sortable: true,
    type: "text"
  },
  {
    fieldName: "ticketId",
    label: "Ticket Id",
    searchable: false,
    sortable: true,
    type: "text"
  },
  {
    fieldName: "etr",
    label: "ETR",
    searchable: false,
    sortable: true,
    type: "text",
  }
];

export default class knownIssueHistoryTable extends OmniscriptBaseMixin(LightningElement) {
  @api consumerAccountData;
  columns = COLUMNS;
  isError = false;
  isSpinnerLoaded = false;
  serviceOutageList = [];
  timeZone;

  /**
   * @description connected callback for LWC
   */
  connectedCallback() {
    this.register();
  }

  /**
   * @description pubsub registery
   */
  register() {
    pubsub.register('onclosemodal', { closeModal: this.handleDataFromChildCmp.bind(this) });
  }

  /**
   * @description Method to close modal using pubsub
   */
  handleDataFromChildCmp(data) {
    if (data) {
      this.closeModal();
    }
  }

  /**
   * @description Button action to open modal and fetch known issue
   */
  loadKnownIssues() {
    this.openModal();
    if (this.consumerAccountData && Array.isArray(this.consumerAccountData) &&
        this.consumerAccountData[0].hasOwnProperty('id')) {
      this.getKnownIssues();
    }
  }

  /**
   * @description Method to close vlocity modal.
   */
  closeModal() {
    Promise.resolve().then(() => {
      let modal = this.template.querySelector("vlocity_cmt-modal") ?
        this.template.querySelector("vlocity_cmt-modal") :
        this.template.querySelector("c-modal");
      if (modal) {
        modal.closeModal();
      } else {
        console.log("modal is undefined");
      }
    }).catch(error => console.log(error.message));
  }

  /**
   * @description Method to fetch Known Issue using IP
   */
  getKnownIssues() {
    this.isSpinnerLoaded = true;
    this.isError = false;
    this.knownIssueList = [];
    let params = {
      input: JSON.stringify({'serviceAccountId': this.consumerAccountData[0].id}),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_FetchKnownIssue',
      options: '{}'
    };

    // Get the data from Integration procedure to serviceOutageList
    this.omniRemoteCall(params, true).then(response => {
      if (response.result.IPResult.hasOwnProperty('knownIssue')) {
        const knownIssue = response.result.IPResult.knownIssue;
        this.timeZone = response.result.IPResult.timeZone;
        console.log('timeZone-->',this.timeZone);
        if(Array.isArray(knownIssue)) {
          this.knownIssueList = knownIssue;
          this.loadStyles();
        } else if (knownIssue.constructor === Object) {
          this.knownIssueList.push(knownIssue);
          this.loadStyles();
        } else {
          this.isError = true;
          this.validationErrorMessage = 'No Known Issue to display.';
        }
      } else if (response.result.IPResult.hasOwnProperty('error')) {
        this.isError = true;
        let ipError = response.result.IPResult.error;
        this.validationErrorMessage = ipError;
      } else {
        this.isError = true;
        let ipError = response.result.IPResult.result.error;
        this.validationErrorMessage = `${ipError.code +' - '+ ipError.message}`;
      }
      this.isSpinnerLoaded = false;
    }).catch (error => {
      this.isError = true;
      this.validationErrorMessage = error.message;
      this.isSpinnerLoaded = false;
    });
  }

  /**
   * @description Method to launch omniscript in vlocity modal.
   */
  openModal(){
    Promise.resolve().then(() => {
      let modal = this.template.querySelector("vlocity_cmt-modal") ?
          this.template.querySelector("vlocity_cmt-modal") :
      this.template.querySelector("c-modal");
      if (modal) {
        modal.openModal();
      } else {
        console.log("modal is undefined");
      }
    }).catch(error => console.log(error.message));
  }

  /**
   * @description Method to set the style for vlocity_cmt-data-table.
   */
  loadStyles() {
    const style = document.createElement('style');
    style.innerText = `.known-issue-list .style-summary .tableRowCell
        {white-space: initial}`;
    setTimeout(() => {
      this.template.querySelector('vlocity_cmt-data-table').appendChild(style);
    }, 100);
  }
}