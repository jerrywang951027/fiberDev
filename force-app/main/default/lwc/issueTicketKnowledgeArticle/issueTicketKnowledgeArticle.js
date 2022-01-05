/**
* @group CSR Console
* @description Displays Knowledge article related to Issue Ticket.
*/
import {api, LightningElement, track} from 'lwc';
import {OmniscriptBaseMixin} from 'vlocity_cmt/omniscriptBaseMixin';
import {fetchCustomLabels} from'vlocity_cmt/utility';

const NO_RECORDS_FOUND_MESSAGE = 'There is no linked article associated with Issue Ticket found';

export default class IssueTicketKnowledgeArticle extends OmniscriptBaseMixin(LightningElement) {
  @api recordId;
  @track articles = [];
  @track googleSupportUrl;
  error;
  isSpinnerLoaded = false;
  noRecordsFoundMessage = NO_RECORDS_FOUND_MESSAGE;

  /**
   * @description ConnectedCallback method to load the spinner and to call handleLoad method to
   * get knowledge articles.
   */
  connectedCallback() {
    this.invokeIssueTicketKBArticleIP();
    this.getGoogleSupportUrl();
  }

  /**
   * @description Method to invoke Issue Ticket knowledge article from IP.
   */
  invokeIssueTicketKBArticleIP() {
    this.isSpinnerLoaded = true;
    this.error = undefined;
    let requestObject = {};
    requestObject.ticketId = this.recordId;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'TCK_IssueTicketKnowledgeArticles',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      this.isSpinnerLoaded = false;
      if (response && Array.isArray(response.result.IPResult.extractIssueTicketKnowledgeArticle) &&
          response.result.IPResult.extractIssueTicketKnowledgeArticle.length > 0) {
          this.articleDetails = response.result.IPResult.extractIssueTicketKnowledgeArticle;
          this.getIssueTicketKBArticles(this.articleDetails);
      } else {
        this.error = 'No knowledge articles available';
      }
    }).catch (error => {
      this.isSpinnerLoaded = false;
      this.error = 'Error occured while fetching knowledge bases.';
    });
  }

  /**
   * @description Method to iterative over each article.
   * @param articleDetails Holds article details.
   */
  getIssueTicketKBArticles(articleDetails) {
    articleDetails.forEach(items => {
      this.getArticle(items);
    });
  }

  /**
   * @description Method to show urls of knowledge article.
   * @param issueTicketArticle Holds an article.
   */
  getArticle(issueTicketArticle) {
    let issueTicketArticleArr = {};
    let url;
    url = this.googleSupportUrl + issueTicketArticle.Url__c;
    issueTicketArticleArr['url'] = encodeURI(url);
    issueTicketArticleArr['isData'] = true;
    issueTicketArticleArr['title'] = issueTicketArticle.Title__c;
    this.articles.push(issueTicketArticleArr);
  }
  /**
   * @description Method to fetch google support url from custom label.
   */
  getGoogleSupportUrl() {
    fetchCustomLabels(['googleSupportUrl'], "en-US").then(label => {
      this.googleSupportUrl = label.googleSupportUrl;
    })
  }
}