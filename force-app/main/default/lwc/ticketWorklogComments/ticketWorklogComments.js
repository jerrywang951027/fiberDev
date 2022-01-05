import { api, LightningElement, track, wire } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { register, unregister } from 'vlocity_cmt/pubsub';

const columns = [
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

export default class ticketWorklogComments extends OmniscriptBaseMixin(LightningElement) {
  @api recordId;
  records;
  error;
  columns = columns;

  connectedCallback() {
    this.fetchTicketComments();
    register('ticketWorklogChannel', {
      ticket_worklog_channel : this.fetchTicketCommentsData.bind(this)
    });
  }

  fetchTicketCommentsData(messageFromEvent) {
    this.fetchTicketComments();
  }

  fetchTicketComments() {
    let recordId = this.recordId;
    let requestObject = {};
    requestObject.ticketId = recordId;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'TCK_TicketComments',
      options: '{}'
    };

    this.omniRemoteCall(params, true).then(response => {
      this.error = undefined;
      let ticketComment = [];
      let ticketCommentArr = {};
      if (response && response.result && response.result.IPResult) {
        if (response.result.IPResult.ticketComments &&
            !response.result.IPResult.ticketComments.hasOwnProperty('error')) {
          ticketComment = response.result.IPResult.ticketComments;
          this.records = ticketComment;
          this.sortRecords();
        } else if (!response.result.IPResult.success &&
            response.result.IPResult.result.hasOwnProperty('error')) {
          this.error = response.result.IPResult.result.error.message;
        }
      } else {
        this.error = 'No response';
      }
    }).catch (error => {
      this.error = 'Error occured while fetching Bugafiber Ticket comments.';
    });
  }

  sortRecords(){
    this.records.sort((a, b) => {
      if (a.modifiedTime > b.modifiedTime) {
        return -1;
      }
      if (a.modifiedTime < b.modifiedTime) {
        return 1;
      }
      return 0;
    });
  }
}