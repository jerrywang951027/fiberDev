/**
 * @group Lead Layout
 * @description will return the details of Premises associated to a Lead
 */
import { LightningElement, track, api } from 'lwc';
import getLeadWithPremises from '@salesforce/apex/PremisesController.getLeadWithPremises';
import { NavigationMixin } from 'lightning/navigation';

export default class PremisesDetails extends NavigationMixin(LightningElement) {

  @api recordId;
  @track error;
  @track premisesName;
  @track premisesRecordId;

  /*
   * @description Method that calls on load of component to fetch Premises record related to Lead.
   */
  connectedCallback() {
    getLeadWithPremises({leadId:this.recordId})
      .then (result => {
        this.premisesRecordId = result.vlocity_cmt__PremisesId__c;
        this.premisesName = result.vlocity_cmt__PremisesId__r.Name;
        this.error = undefined;
      })
      .catch (error => {
        this.error = error;
        this.premisesRecordId = undefined;
      });
  }
 /*
  * @description Method to navigate to premises record when clicked on Premises name.
  * @params event Fire event data
  */
  navigateToPremisesRecord(event) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.premisesRecordId,
        objectApiName: 'vlocity_cmt__Premises__c',
        actionName: 'view',
      },
    });
  }
}