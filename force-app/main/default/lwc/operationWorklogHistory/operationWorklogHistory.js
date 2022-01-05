import { api, LightningElement, track, wire } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { register, unregister } from 'vlocity_cmt/pubsub';

const tableColumns = [
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
      sortable: true,
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

  export default class operationWorklogHistory extends OmniscriptBaseMixin(LightningElement) {

    @api recordId;
    columns = tableColumns;
    error;
    marketTimeZone
    records;

    connectedCallback() {
      this.fetchTicketComments();
      register('operationWorklogHistoryChannel', {
          operation_ticket_worklog_channel : this.fetchTicketCommentsData.bind(this)
      });
    }
    fetchTicketCommentsData(messageFromEvent) {
      console.log('Event Catched');
      this.fetchTicketComments();
    }
    fetchTicketComments() {
      let recordId = this.recordId;
      let requestObject = {};
      requestObject.ticketId = recordId;
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'TCK_ExtractOperationTicketComments',
        options: '{}'
      };

      this.omniRemoteCall(params, true).then(response => {
        this.error = undefined;
        let ticketComment = [];
        let ticketCommentsInMarketTimezone = [];
        let ticketCommentArr = {};
        if (response && response.result && response.result.IPResult) {
          if (response.result.IPResult.ticketComments &&
              !response.result.IPResult.ticketComments.hasOwnProperty('error')) {
            ticketComment = response.result.IPResult.ticketComments;
            this.marketTimeZone = response.result.IPResult.getZone.TimeZone;
            ticketComment.forEach((ticket) => {
              ticket.modifiedTime = new Date(ticket.modifiedTime).toLocaleString('en-US',{timeZone: this.marketTimeZone});
              ticketCommentsInMarketTimezone.push(ticket);
            });
            this.records = ticketCommentsInMarketTimezone;
            this.sortRecords();
          } else if (!response.result.IPResult.success &&
              response.result.IPResult.result.hasOwnProperty('error')) {
            this.error = response.result.IPResult.result.error.message;
          } else {
            this.error = 'Error occured while fetching bugafiber ticket comments.';
          }
        } else {
          this.error = 'No response';
        }
      }).catch (error => {
        console.log(error);
        this.error = 'Error occured while fetching bugafiber ticket comments.';
      });
    }
    sortRecords(){
      this.records.sort((a, b) => {
        if (a.modifiedTime > b.modifiedTime) {
          return -1;
        } else if (a.modifiedTime < b.modifiedTime) {
          return 1;
        } else {
          return 0;
        }
     });
  }
}