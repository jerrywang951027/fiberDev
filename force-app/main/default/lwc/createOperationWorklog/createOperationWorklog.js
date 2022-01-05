import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { register, unregister, fire} from'vlocity_cmt/pubsub';

export default class CreateOperationWorklog extends OmniscriptBaseMixin(LightningElement) {
  @api recordId;
  @track addCommentToTicketIP = false;
  @track showLoading = true;
  @track labelName = '';
  @track searchKey;
  @track type;
  @track worklogRecords;

  connectedCallback() {
    this.populateTemplates();
    this.fetchWorklogTemplate('', this.recordId);
  }

  /**
   * calling Apex method
   */
  populateTemplates() {
    let result;
    let params = {
      input: '{}',
      sClassName: 'TicketingUtils',
      sMethodName: 'populateTemplates',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      console.log(JSON.stringify(response));
      result = (typeof response.result.options === 'string') ?
          JSON.parse(response.result.options) : response.result.options;
      this.onResponseSuccess(result);
    }).catch (error => {
         this.searchMessage = false;
    });
  }
  onResponseSuccess(result) {
    this.options = result;
  }

  changeWorklog(event) {
   this.searchKey =  event.target.value;
   this.fetchWorklogTemplate(this.searchKey, '');
  }

  fetchWorklogTemplate(templateName, ticketRecordId) {
    try {
      let params = {
        input: {},
        sClassName: 'TicketingUtils',
        sMethodName: 'getWorklogTemplate',
        options: '{}'
      };
      let inputObject = {};
      if(ticketRecordId) {
        inputObject.ticketId = ticketRecordId;
      } else {
        inputObject.labelName = templateName;
      }
      let inputMap = JSON.stringify(inputObject);
      params.input = inputMap;
      this.omniRemoteCall(params, true).then(response => {
        this.worklogRecords = (typeof response.result.options === 'string') ?
            JSON.parse(response.result.options) : response.result.options;
        this.type = response.result.type;
        this.searchKey = this.type;
        this.showLoading = false;
      }).catch (error => {
        console.log(error);
      });
    } catch(e) {
      console.log('changeWorklog : ' + e);
    }
  }

  saveUpdateWorklog(event) {
    try {
      let commentElement = this.template.querySelector('lightning-textarea');
      let comment = commentElement.value;
      this.ipInput = JSON.stringify({
        ticketId: this.recordId,
        commentText: comment
      });
      this.addCommentToTicketIP = true;
      this.callbackObj = {
        result: this.processResponse.bind(this),
        error: this.onError.bind(this)
    }
      register('addCommentToTicket', this.callbackObj);
    } catch(e) {
     console.log('SaveUpdateWorklog : ' + JSON.stringify(e));
    }
  }

  processResponse(response) {
    try {
      let respObj = JSON.parse(response);
    } catch(objError) {
      console.error(objError.message);
    }
    let ticketSuccessData = {
      'success': 'success'
    }
    this.template.querySelector('lightning-textarea').value = '';
    fire('operationWorklogHistoryChannel',
        'operation_ticket_worklog_channel',
        ticketSuccessData);
     unregister('addCommentToTicket', this.callbackObj);
     this.addCommentToTicketIP = false;
  }

  onError(errorResponse) {
    unregister('addCommentToTicket', this.callbackObj);
    this.addCommentToTicketIP = false;
  }
}