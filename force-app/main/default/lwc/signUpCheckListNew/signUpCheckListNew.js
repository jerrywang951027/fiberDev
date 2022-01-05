import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createHistoryEvent from '@salesforce/apex/SignUpChecklistController.createHistoryEvent';
import isContactTicket from '@salesforce/apex/SignUpChecklistController.isContactTicket';
import stampLeadDetailsForSignUp from
    '@salesforce/apex/SignUpChecklistController.stampLeadDetailsForSignUp';

export default class SignUpChecklistNew extends LightningElement {

  @api recordId;

  @track checkListFields = ['FirstName', 'LastName', 'Email', 'Phone', 'Pilot__c',
      'Customer_Consent_to_3rd_Party_Delivery__c', 'Campaign__c', 'Sign_up_Insights__c',
      'Interaction_Notes__c', 'Objection_Reason__c', 'Interaction_Type__c', 'Interaction_Result__c',
      'Third_Party_Delivery__c'];
  @track firstNameLastNameUnknownCheck;
  @track historyRecord;
  @track interactionType;
  @track isHistoryEvent = false;
  @track isFormLoaded = false;
  @track leadRecord = {};
  @track note;
  @track objectionReason;
  @track signUpInsight;
  @track signUpState;

  get getFirstNameIcon() {
    return (this.leadRecord && this.leadRecord.FirstName !== '' &&
        this.leadRecord.FirstName !== 'Unknown') ? 'standard:task2' : 'standard:question_feed';
  }

  get getLastNameIcon() {
    return (this.leadRecord && this.leadRecord.LastName !== '' &&
        this.leadRecord.LastName !== 'Unknown') ? 'standard:task2' : 'standard:question_feed';
  }

  get getEmailIcon() {
    return (this.leadRecord && this.leadRecord.Email !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getPhoneIcon() {
    return (this.leadRecord && this.leadRecord.Phone !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getPilot__cIcon() {
    return (this.leadRecord && this.leadRecord.Pilot__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getCustomer_Consent_to_3rd_Party_Delivery__cIcon() {
    return (this.leadRecord && (this.leadRecord.Customer_Consent_to_3rd_Party_Delivery__c === false
        || this.leadRecord.Customer_Consent_to_3rd_Party_Delivery__c === '')) ?
        'standard:question_feed' : 'standard:task2';
  }

  get getCampaign__cIcon() {
    return (this.leadRecord && this.leadRecord.Campaign__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getSign_up_Insights__cIcon() {
    return (this.leadRecord && this.leadRecord.Sign_up_Insights__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getObjection_Reason__cIcon() {
    return (this.leadRecord && this.leadRecord.Objection_Reason__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getInteraction_Notes__cIcon() {
    return (this.leadRecord && this.leadRecord.Interaction_Notes__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getInteraction_Type__cIcon() {
    return (this.leadRecord && this.leadRecord.Interaction_Type__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getInteraction_Result__cIcon() {
    return (this.leadRecord && this.leadRecord.Interaction_Result__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  get getThird_Party_Delivery__cIcon() {
    return (this.leadRecord && this.leadRecord.Third_Party_Delivery__c !== '') ?
        'standard:task2' : 'standard:question_feed';
  }

  connectedCallback() {
    isContactTicket({leadId:this.recordId})
        .then(result => {
          this.isHistoryEvent = result;
          console.log('isHistoryEvent'+this.isHistoryEvent);
        })
        .catch(error => {
          this.isHistoryEvent = error;
    });
  }

  handleOnLoad(event) {
    let record = event.detail.records;
    let fields = record[this.recordId].fields;
    Object.keys(fields).map(field => {
      if (this.checkListFields.indexOf(field) !== -1) {
        this.leadRecord[field] = fields[field].value ? fields[field].value :
        (field === 'Customer_Consent_to_3rd_Party_Delivery__c' ? false : '');
      }
    });
    this.note = fields.Interaction_Notes__c ? fields.Interaction_Notes__c.value : '';
    this.objectionReason = fields.Objection_Reason__c.value ? fields.Objection_Reason__c.value : '';
    this.interactionType = fields.Interaction_Type__c ? fields.Interaction_Type__c.value : '';
    this.signUpInsight = fields.Sign_up_Insights__c.value ? fields.Sign_up_Insights__c.value : '';
    if (fields.FirstName.value === null || fields.FirstName.value === "Unknown" ||
      fields.LastName.value === null || fields.LastName.value === "Unknown") {
      this.firstNameLastNameUnknownCheck = false;
    }
    this.isFormLoaded = true;
  }

  handleFieldChange(event) {
    this.leadRecord[event.currentTarget.fieldName] = event.currentTarget.value;
    if (event.currentTarget.fieldName === "Objection_Reason__c"
        && this.template.querySelector('.objectionReason').value !== '') {
      this.template.querySelector('.signUpInsights').value = '';
    } else if (event.currentTarget.fieldName === "Sign_up_Insights__c"
          && this.template.querySelector('.signUpInsights').value !== '') {
      this.template.querySelector('.objectionReason').value = '';
    }
    if (this.leadRecord["FirstName"] === '' || this.leadRecord["FirstName"] === 'Unknown' ||
      this.leadRecord["LastName"] === '' || this.leadRecord["LastName"] === 'Unknown') {
      this.firstNameLastNameUnknownCheck = false;
    } else {
       this.firstNameLastNameUnknownCheck = true;
    }
  }

  calloutToSignUpcontroller() {
    if ((this.note !== this.leadRecord["Interaction_Notes__c"]) 
        && this.leadRecord["Interaction_Notes__c"] 
        && this.leadRecord["Interaction_Notes__c"].length > 0) {
      if (this.leadRecord["Sign_up_Insights__c"]
          && (this.signUpInsight !== this.leadRecord["Sign_up_Insights__c"])) {
        this.signUpState = true;
      } else {
        this.signUpState = false;
      }
      this.leadRecord["Id"] = this.recordId;
      if (this.leadRecord["Sign_up_Insights__c"]) {
        this.Type = 'Pending Signup';
      } else {
        this.Type = 'Customer Interaction';
      }
      createHistoryEvent({
          type: this.Type,
          leadData: this.leadRecord,
          signUpState: this.signUpState
        })
        .then (result => {
        })
        .catch (error => {
           console.log("Error==>" + JSON.stringify(error));
        });
      }
  }

  stampLeadDetails() {
    if (this.leadRecord["Sign_up_Insights__c"]
        && (this.signUpInsight !== this.leadRecord["Sign_up_Insights__c"])) {
      this.signUpState = true;
    } else {
      this.signUpState = false;
    }
    stampLeadDetailsForSignUp({
      leadId: this.recordId,
      signUpState: this.signUpState
    });
  }

  onSave() {
    let fieldValidation = true;
    this.template.querySelectorAll('lightning-input-field').forEach(element => {
      element.reportValidity();
      if (element.reportValidity() === false) {
        fieldValidation = false;
      }
    });
    if (!fieldValidation) {} else if (this.firstNameLastNameUnknownCheck === false) {
      this.showErrorEvent('Firstname and LastName must not be Unknown');
    } else if (this.leadRecord['FirstName'] === '' || this.leadRecord['FirstName'] === 'Unknown') {
      this.showErrorEvent('First Name is required and should not be Unknown')
    } else if (this.leadRecord['LastName'] === '' || this.leadRecord['LastName'] === 'Unknown') {
      this.showErrorEvent('Last Name is required and should not be Unknown')
    } else if (!this.leadRecord["Email"] && !this.leadRecord["Phone"]) {
      this.showErrorEvent('Enter email or phone');
    } /*else if (!this.leadRecord["Sign_up_Insights__c"] && !this.leadRecord["Objection_Reason__c"]) {
      this.showErrorEvent('Enter Signup Insight or Objection reason');
    }*/ else {
      this.calloutToSignUpcontroller();
      this.stampLeadDetails();
      this.template.querySelector('lightning-record-edit-form').submit();
    }
  }

  handleSuccess(event) {
    this.showToastEvent();
  }

  showToastEvent() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: 'Record saved successfully',
        variant: 'success'
      })
    );
  }

  showErrorEvent(errMsg) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Error!',
        duration: 5000,
        message: errMsg,
        variant: 'error'
      })
    );
  }
}