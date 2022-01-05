import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class KnowledgeSearchResults extends OmniscriptBaseMixin(LightningElement) {

  @api isExpandView;
  @api profileName;
  @api searchKey;

  @track articles = [];

  error;
  helpCenterDetails = [];
  isSpinnerLoaded = false;

  /**
   * @description Getter to get the view type(Horizontal/Vertical).
   */
  get listClassName() {
    if (this.isExpandView === true) {
      return 'slds-list_horizontal';
    } else {
      return '';
    }
  }

  /**
   * @description Getter to get the width of the column.
   */
  get listItemClassName() {
    if (this.isExpandView === true) {
      return 'slds-size_1-of-' + this.articles.length;
    } else {
      return 'slds-size_1-of-1';
    }
  }

  /**
   * @description Getter to get the CSS class on case of change of view.
   */
  get listItemDivClassName() {
    if (this.isExpandView === true) {
      return 'slds-border_left slds-border_right slds-border_top '
          + 'slds-border_bottom slds-m-horizontal_x-small';
    } else {
      return 'slds-border_left slds-border_right slds-border_top slds-border_bottom '
          + 'slds-m-vertical_medium';
    }
  }

  /**
   * @description Will be fired when a component is inserted into the DOM.
   * This method will call getHelpCenterKB(profileName) to fetch help center knowledge base
   * custom metadata details.
   */
  connectedCallback() {
    if (this.searchKey) {
      this.getHelpCenterKB(this.profileName);
    }
  }

  /**
   * @description getHelpCenterKB method to get the help center details from
   * custom metadata on the basis of profile name of current logged in user.
   * @param profileName - current logged in user profile.
   */
  getHelpCenterKB(profileName) {
    this.isSpinnerLoaded = true;
    this.error = undefined;
    let requestObject = {};
    requestObject.profileName = profileName;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_GetHelpCenterKBFromMetadata',
      options: '{}'
    };

    this.omniRemoteCall(params, true).then(response => {
      this.isSpinnerLoaded = false;
      if (response && Array.isArray(response.result.IPResult.helpCenter) &&
          response.result.IPResult.helpCenter.length > 0) {
        this.helpCenterDetails = response.result.IPResult.helpCenter;
        this.invokeHelpCenterIP(this.helpCenterDetails);
      } else {
        this.error = 'No knowlege bases available to fetch articles.';
      }
    }).catch (error => {
      this.isSpinnerLoaded = false;
      this.error = 'Error occured while fetching knowledge bases.';
      console.log(error);
    });
  }

  /**
   * @description invokeHelpCenterIP method loop on the help center details returned
   * from custom metadata.
   * @param helpCenterDetails - details of helpcenters fetched from custom metadata
   */
  invokeHelpCenterIP(helpCenterDetails) {
    helpCenterDetails.forEach(items => {
      this.getKBArticles(items);
    });
  }

  /**
   * @description getKBArticles method to get the knowledge articles based on search key
   * and help centers fetched from custom metadata and display it in UI.
   * @param helpCenter - details of help center passed in the
   * invokeHelpCenterIP(helpCenterDetails) method
   */
  getKBArticles(helpCenter) {
    this.isSpinnerLoaded = true;

    let requestObject = {};
    requestObject.query = this.searchKey;

    if (this.isExpandView === true) {
      requestObject.recordCount = helpCenter.Record_Count_In_Expanded_View__c;
    } else {
      requestObject.recordCount = helpCenter.Record_Count__c;
    }

    requestObject.helpCenter = helpCenter.Label;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_GetHelpCenterKBFromApi',
      options: '{}'
    };

    this.omniRemoteCall(params, true).then(response => {
      this.error = undefined;
      let articlesArr = {};
      if (response && !Array.isArray(response.result.IPResult)) {
        if (response.result.IPResult.result !== undefined &&
            !response.result.IPResult.result.hasOwnProperty('error')) {
          let url;
          url = helpCenter.URL__c + this.searchKey;

          articlesArr['url'] = encodeURI(url);
          articlesArr['isData'] = true;
          articlesArr['kBTitle'] = helpCenter.Title__c;
          articlesArr['helpCenterName'] = response.result.IPResult.helpCenterName;
          articlesArr['result'] = response.result.IPResult.result;
          articlesArr['recordLength'] = response.result.IPResult.result.length;
          articlesArr['totalResults'] = response.result.IPResult.totalResults;
          articlesArr['order'] = helpCenter.Order__c;

          this.articles.push(articlesArr);
          this.enableExpand();
          this.sortHelpCenterKB();
        } else if (!response.result.IPResult.success &&
            response.result.IPResult.result.hasOwnProperty('error')) {
          this.isSpinnerLoaded = false;
          this.error = response.result.IPResult.result.error.message;
        }
      } else {
        articlesArr['isData'] = true;
        articlesArr['error'] = 'No articles found.';
        articlesArr['kBTitle'] = helpCenter.Title__c;
        articlesArr['order'] = helpCenter.Order__c;

        this.articles.push(articlesArr);
        this.sortHelpCenterKB();
      }
      this.isSpinnerLoaded = false;
    }).catch (error => {
      this.isSpinnerLoaded = false;
      console.log(error);
      this.error = 'Error occured while fetching knowlege base articles.';
    });
  }

  /**
   * @description sortHelpCenterKB method to sort the help center knowledge base on the basis
   * of Order.
   */
  sortHelpCenterKB() {
    this.articles.sort((a, b) => {
      if (a.order < b.order) {
        return -1;
      }
      if (a.order > b.order) {
        return 1;
      }
      return 0;
    });
  }

  /**
   * @description enableExpand method to enable the expand button.
   * This method will fire a custom event to enable expand button which is in knowledgeSearch LWC.
   */
  enableExpand() {
    const evt = new CustomEvent('toggle_expand_button', {});
    this.dispatchEvent(evt);
  }
}