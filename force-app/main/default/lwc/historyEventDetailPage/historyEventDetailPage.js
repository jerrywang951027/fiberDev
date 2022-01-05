/**
 * @description  This LWC component is used on History_Event__c Details page to replace the standard
 * view.
 * @group History_Event__c details page
 */
import {api, LightningElement, track} from 'lwc';
import {OmniscriptBaseMixin} from 'vlocity_cmt/omniscriptBaseMixin';

const CHEVRON_OPEN_ICON = 'utility:chevrondown';
const CHEVRON_CLOSE_ICON = 'utility:chevronright';

export default class HistoryEventDetailPage extends OmniscriptBaseMixin
(LightningElement) {
  @api
  recordId;
  @track
  accountDetailsCollapsed = false;
  @track
  ticketDetails = {};
  @track
  ticketDetailsCollapsed = false;

  /**
   * @description Connected callback to fetch data
   */
  connectedCallback() {
    this.fetchTicketDetails();
  }

  /**
   * Returns the icon to display based on ticket details collapse state
   */
  get ticketDetailsHeaderIcon() {
    return this.ticketDetailsCollapsed ? CHEVRON_CLOSE_ICON : CHEVRON_OPEN_ICON;
  }

  /**
   * Returns the icon to display based on account details collapse state
   */
  get accountDetailsHeaderIcon() {
    return this.accountDetailsCollapsed ? CHEVRON_CLOSE_ICON : CHEVRON_OPEN_ICON;
  }

  /**
   * @description This method calls Integrated Procedure to fetch the record details and its related
   * record's details.
   */
  fetchTicketDetails() {
    let recordId = this.recordId;
    let requestObject = {};
    requestObject.historyEventId = recordId;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'TCK_ExtractContactTicketDetails',
      options: '{}'
    };
    this.omniRemoteCall(params, true)
        .then((response) => {
          this.error = '';
          if (response && response.result && response.result.IPResult) {
            if (response.result.IPResult.contactTicketDetails) {
              this.ticketDetails = response.result.IPResult.contactTicketDetails;
            }
          } else {
            this.error = 'No response';
          }
        })
        .catch((error) => {
          this.error = 'Error occured while fetching Ticket details.';
        });
  }

  /**
   * @description Collapse or open the Ticket details header handler.
   */
  onTicketDetailsHeaderClick() {
    this.ticketDetailsCollapsed = !this.ticketDetailsCollapsed;
  }

  /**
   * @description Collapse or open the Account details header handler.
   */
  onAccountDetailsHeaderClick() {
    this.accountDetailsCollapsed = !this.accountDetailsCollapsed;
  }
}