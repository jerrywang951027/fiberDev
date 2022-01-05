/**
 * @description  This LWC component is used on Ticket__c Details page to replace the standard view.
 * @group Ticket__c
 */
import {api, LightningElement, track} from 'lwc';
import {OmniscriptBaseMixin} from 'vlocity_cmt/omniscriptBaseMixin';

const CHEVRON_OPEN_ICON = 'utility:chevrondown';
const CHEVRON_CLOSE_ICON = 'utility:chevronright';

export default class TicketDetailsWithAccount extends OmniscriptBaseMixin
    (LightningElement) {
  @api recordId;

  @track accountDetailsCollapsed = false;
  @track booleanFlags = {};
  @track constructionDetailsCollapsed = false;
  @track constructionDetails = {};
  @track error;
  @track leadDetailsCollapsed = false;
  @track relatedDetails = {};
  @track ticketDetails = {};
  @track ticketDetailsCollapsed = false;

  /**
   * @description Connected callback to fetch data.
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
   * Returns the icon to display based on account details collapse state
   */
  get leadDetailsHeaderIcon() {
    return this.leadDetailsCollapsed ? CHEVRON_CLOSE_ICON : CHEVRON_OPEN_ICON;
  }

  /**
   * Returns the icon to display based on account details collapse state
   */
  get constructionDetailsHeaderIcon() {
    return this.constructionDetailsCollapsed ? CHEVRON_CLOSE_ICON : CHEVRON_OPEN_ICON;
  }

  /**
   * @description This method calls Integrated Procedure to fetch the record details.
   */
  fetchTicketDetails() {
    let ticketId = this.recordId;
    let requestObject = {};
    requestObject.ticketId = ticketId;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'TCK_ExtractIssueTicketDetails',
      options: '{}'
    };
    this.omniRemoteCall(params, true)
        .then((response) => {
          this.error = '';
          if (response && response.result && response.result.IPResult) {
            if (response.result.IPResult.result
                && response.result.IPResult.result.hasOwnProperty('error')) {
              this.error = response.result.IPResult.result.error.message;
            } else {
              if (response.result.IPResult.ticketDetails) {
                this.ticketDetails = response.result.IPResult.ticketDetails;
              }
              if (response.result.IPResult.leadAccountGroupFetch) {
                this.booleanFlags = response.result.IPResult.leadAccountGroupFetch;
              }
              if (response.result.IPResult.extractTicketRelatedAccountOrLead) {
                this.relatedDetails = response.result.IPResult.extractTicketRelatedAccountOrLead;
              }
              if (response.result.IPResult.transformBugafiberTicketDetails) {
                this.constructionDetails = response.result.IPResult.transformBugafiberTicketDetails;
              }
            }
          } else {
            this.error = 'No response';
          }
        })
        .catch((error) => {
          this.error = 'Error occured while fetching Ticket related record details.';
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

  /**
   * @description Collapse or open the Lead details header handler.
   */
  onLeadDetailsHeaderClick() {
    this.leadDetailsCollapsed = !this.leadDetailsCollapsed;
  }

  /**
   * @description Collapse or open the Account details header handler.
   */
  onConstructionDetailsHeaderClick() {
    this.constructionDetailsCollapsed = !this.constructionDetailsCollapsed;
  }
}