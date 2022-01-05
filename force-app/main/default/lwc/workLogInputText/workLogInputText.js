import {
  LightningElement,
  track,
  api
} from 'lwc';
import {
  register,
  unregister
} from 'vlocity_cmt/pubsub';
import {
  fire
} from 'vlocity_cmt/pubsub';

export default class WorkLogInputText extends LightningElement {
  @api recordId;
  @track boolAddCommentToTicketIP = false;
  SaveUpdateWorklog(event) {
    try {
      let commentElement = this.template.querySelector('lightning-textarea');
      let comment = commentElement.value;
      let ipInp = {};
      ipInp.ticketId = this.recordId;
      ipInp.commentText = comment;
      this.ipInput = JSON.stringify(ipInp);
      this.boolAddCommentToTicketIP = true;
      this.callbackObj = {
          result: this.processResponse.bind(this),
          error: this.onError.bind(this)
      }
      register('addCommentToTicket', this.callbackObj);

      } catch(error) {
          this.isWorkLog = true;
        }
    }

  processResponse(response) {
    let respObj = JSON.parse(response);
    let ticketSuccessData = {
      'success': 'success'
    }
    this.template.querySelector('lightning-textarea').value = '';
    fire('ticketWorklogChannel', 'ticket_worklog_channel', ticketSuccessData);
    unregister('addCommentToTicket', this.callbackObj);
    this.boolAddCommentToTicketIP = false;
  }
  onError(error) {
    this.isWorkLog = true;
  }
}