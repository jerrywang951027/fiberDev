import {api, LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import extractLatestBugafiberTicketId from
    '@salesforce/apex/SignUpChecklistController.extractLatestBugafiberTicketId';
import hasOpenHistoryEvent from
    '@salesforce/apex/SignUpChecklistController.hasOpenHistoryEvent';
import isContactTicket from
    '@salesforce/apex/SignUpChecklistController.isContactTicket';
import stampLeadDetailsForSignUp from
    '@salesforce/apex/SignUpChecklistController.stampLeadDetailsForSignUp';
import updateBugafiberTicket from
    '@salesforce/apex/SignUpChecklistController.updateBugafiberTicket';

export default class SignUpChecklistNew extends LightningElement {
  @api recordId;
  @track bugafiberTicketId = '';
  @track changeLastNameIcon;
  @track changeEmailIcon;
  @track changePhoneIcon;
  @track changeFirstNameIcon;
  @track changePilot__cIcon;
  @track changeSign_up_Insights__cIcon;
  @track changeCampaign__cIcon;
  @track changeCustomer_Consent_to_3rd_Party_Delivery__cIcon;
  @track changeObjection_Reason__cIcon;
  @track Interaction_Notes__c;
  @track changeInteraction_Notes__cIcon;
  @track changeInteraction_Result__cIcon;
  @track firstNameLastNameUnknownCheck;
  @track historyRecord;
  @track interactionType;
  @track interactionTypeCapture;
  @track isHistoryEvent
  @track leadRecord = {};
  @track note;
  @track objectionReason;
  @track openHistoryEventcheck;
  @track signUpInsight;
  @track signUpState;
  @track changeThird_Party_Delivery__cIcon;

  connectedCallback() {
    isContactTicket({leadId:this.recordId})
        .then(result => {
          this.isHistoryEvent = result;
        })
        .catch(error => {
          this.isHistoryEvent = error;
    });
  }

  handleOnLoad(event) {
    this.getOpenHistoryEventStatus();
    this.extractLatestBugafiberTicketId();
    let record = event.detail.records;
    let fields = record[this.recordId].fields;
    Object.keys(fields).map(field => {
        this['change' + field + 'Icon'] = (fields[field].value === null
        || fields[field].value === "Unknown"
        || fields[field].value === false) ? 'standard:question_feed' : 'standard:task2';
      this.leadRecord[field] = fields[field].value ? fields[field].value : '';
    });
    this.changeObjection_Reason__cIcon = 'standard:question_feed';
    this.changeSign_up_Insights__cIcon = 'standard:question_feed';
    this.template.querySelector('.objectionReason').value = '';
    this.template.querySelector('.signUpInsights').value = '';
    this.note = fields.Interaction_Notes__c ? fields.Interaction_Notes__c.value : '';
    this.objectionReason = fields.Objection_Reason__c.value ? fields.Objection_Reason__c.value : '';
    this.interactionType = fields.Interaction_Type__c ? fields.Interaction_Type__c.value : '';
    this.signUpInsight = fields.Sign_up_Insights__c.value ? fields.Sign_up_Insights__c.value : '';
    if (fields.FirstName.value === null || fields.FirstName.value === "Unknown" ||
      fields.LastName.value === null || fields.LastName.value === "Unknown") {
      this.firstNameLastNameUnknownCheck = false;
    }
  }

  handleFieldChange(event) {
    this.leadRecord[event.currentTarget.fieldName] = event.currentTarget.value;
    if (event.currentTarget.fieldName === "FirstName"
        || event.currentTarget.fieldName === "LastName") {
      this['change' + event.currentTarget.fieldName + 'Icon'] =
          (this.leadRecord[event.currentTarget.fieldName] === ''
          || this.leadRecord[event.currentTarget.fieldName] === 'Unknown') ?
          'standard:question_feed' : 'standard:task2';
    } else if (event.currentTarget.fieldName === "Customer_Consent_to_3rd_Party_Delivery__c") {
      this['change' + event.currentTarget.fieldName + 'Icon'] =
          (this.leadRecord[event.currentTarget.fieldName] === false) ?
          'standard:question_feed' : 'standard:task2';
    } else if (event.currentTarget.fieldName) {
      this['change' + event.currentTarget.fieldName + 'Icon'] =
          (this.leadRecord[event.currentTarget.fieldName] === '') ?
          'standard:question_feed' : 'standard:task2';
    }

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

  stampLeadDetails() {
    if (this.leadRecord["Sign_up_Insights__c"] &&
      (this.signUpInsight !== this.leadRecord["Sign_up_Insights__c"])) {
      this.signUpState = true;
    } else {
      this.signUpState = false;
    }
    stampLeadDetailsForSignUp({
      leadId: this.recordId,
      signUpState: this.signUpState
    });
  }

  getOpenHistoryEventStatus() {
    hasOpenHistoryEvent({
        leadId: this.recordId
      })
      .then(result => {
        this.openHistoryEventcheck = result;
      })
      .catch(error => {});
  }

  updateBugafiberTicket() {
    if (this.bugafiberTicketId.length > 0) {
      updateBugafiberTicket({
          bugafiberTicketId: this.bugafiberTicketId,
          firstName: this.leadRecord['FirstName'],
          lastName: this.leadRecord['LastName'],
          email: this.leadRecord['Email'],
          phoneNumber: this.leadRecord['Phone']
        }).then(result => {})
        .catch(error => {
          console.log('Ticket update is not successful.');
        })
    }
  }

  extractLatestBugafiberTicketId() {
    extractLatestBugafiberTicketId({
        leadId: this.recordId
      }).then(result => {
        this.bugafiberTicketId = result;
      })
      .catch(error => {
        console.log('not fetching bugafiberId');
      })
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
      this.stampLeadDetails();
      this.template.querySelector('lightning-record-edit-form').submit();
      this.updateBugafiberTicket();
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