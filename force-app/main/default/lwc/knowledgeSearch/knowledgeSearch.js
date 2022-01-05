/**
* @group CSR Console
* @description Will display knowledge articles from help center.
*/
import { api, LightningElement, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getUserProfile } from "vlocity_cmt/utility";

export default class KnowledgeSearch extends
    OmniscriptBaseMixin(NavigationMixin(LightningElement)) {

  @api objectApiName;
  @api recordId;
  @track isSearchResults = false;
  @track searchKey;
  isDisableExpandBtn = true;
  isTechnician = false;
  profileName = '';

  /**
  * @description getter for isTicket.
  */
  get isTicket() {
    return (this.objectApiName === 'Ticket__c') ? true : false;
  }
  /**
   * @description Will be fired when a component is inserted into the DOM.
   * This method will call getProfileName() to get current logged in user profile
   */
  connectedCallback() {
    this.getProfileName();
  }

  /**
   * @description getProfileName method to get current logged in user profile and also
   * checks if logged in user is Technicain.
   */
  getProfileName() {
    getUserProfile()
    .then(result => {
      if (result) {
        if (result.hasOwnProperty('profilename')) {
          this.profileName = result.profilename;
          if (this.profileName === 'Technician') {
            this.isTechnician = true;
          }
        }
      }
    });
  }

  /**
   * @description handleChange method to get search key from input field.
   * @param event - Details of the event fired.
   */
  handleChange(event) {
    this.isDisableExpandBtn = true;
    this.isSearchResults = false;
    this.searchKey = event.target.value;
  }

  /**
   * @description handleSubmit method to initiate search by inserting knowledgeSearchResults LWC
   * in the DOM.
   * @param event - Details of the event fired.
   */
  handleSubmit(event) {
    if (this.searchKey.length > 0) {
      this.isSearchResults = true;
    }
  }

  /**
   * @description expandArticles method to change the layout of knowledge base from vertical
   * to horizontal. This method will launch an Aura component which contains knowledgeSearch
   * Result LWC.
   */
  expandArticles() {
    this[NavigationMixin.Navigate]({
      "type": "standard__component",
      "attributes": {
        "componentName": "c__knowledgeSearchResultsWrapper"
      },
      state: {
        c__isExpandView : true,
        c__profileName : this.profileName,
        c__searchKey : this.searchKey
      }
    });
  }

  /**
   * @description toggleExpand method to disable expand button.
   */
  toggleExpand() {
    this.isDisableExpandBtn = false;
  }
}