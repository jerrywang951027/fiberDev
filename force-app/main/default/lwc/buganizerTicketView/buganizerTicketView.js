import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
const COMMENTS_COLUMNS = [
  { 
    label: 'Comment Number',
    fieldName: 'commentNumber',
    type: 'number',
    sortable: true,
    searchable: true
  },
  { 
    label: 'Editor Email Id',
    fieldName: 'lastEditorEmailAddress',
    type: 'text',
    sortable: true,
    searchable: true
  },
  { 
    label: 'Comment',
    fieldName: 'comment',
    type: 'text',
    sortable: true,
    searchable: true
  },
  { 
    label: 'Last Modified',
    fieldName: 'modifiedTime',
    type: 'date',
    sortable: true,
    searchable: true
  }
];
export default class buganizerTicketView 
    extends OmniscriptBaseMixin(LightningElement) {
  @api initialData;
  bugafiberTicketId;
  bugafiberTicketDetails = [];
  bugafiberTicketComments = [];
  commentsColumns = COMMENTS_COLUMNS;
  errorMessage;
  isDataFetched = false;
  timeZone;
  /**
  * @description Will fire everytime document is added
  */
  connectedCallback() {
    var parsedData = JSON.parse(this.initialData);
    this.bugafiberTicketId = parsedData.bugafiberTicketId;
    this.timeZone = parsedData.timeZone;
    this.callToGetBuganizerticketDetailsIP();
  }
  /**
  * @description Handler method to call IP for fetching Buganizer ticket details
  */
  callToGetBuganizerticketDetailsIP() {
    const errorMessage = 'No details fetched';
    let requestObject = {};
    requestObject.bugafiberTicketId = this.bugafiberTicketId;
    requestObject.timeZone = this.timeZone;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_ExtractBuganizerDetails',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      if (response.result.IPResult.bugafiberTicketDetails) {
        this.bugafiberTicketDetails = 
            response.result.IPResult.bugafiberTicketDetails;
        if(this.bugafiberTicketDetails.bugafiberTicketComments) {
          this.bugafiberTicketComments =
              this.bugafiberTicketDetails.bugafiberTicketComments;
        }
        console.log('etr in lwc -->',this.bugafiberTicketDetails.etr);
        this.isDataFetched = true;
      } else {
        this.errorMessage = errorMessage;
      }
    }).catch(error => {
      this.errorMessage = error.message;
    });
  }
}