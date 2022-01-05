/**
 * @group Tickets
 * @description This is used to fetch Type, Subtype and Symptom from issue ticket metadata
 */
import {
  api,LightningElement,track
} from 'lwc';
import {
  OmniscriptBaseMixin
} from 'vlocity_cmt/omniscriptBaseMixin';

export default class logIssue extends OmniscriptBaseMixin(LightningElement) {

  _issueTicketMetadata;
  _isSearchKey;
  @track items = [];
  @track showMessage = true;
  @track isSearch = false;
  connectedCallback() {
    try {
      this.issueTicketData = this.issueTicketMetadata;
      this.formatIssueTicketRecords('');
      this.isSearch = this.isSearchKey === 'true' ? true : false;
    } catch (e) {
      console.log("Error" + JSON.stringify(e));
    }
  }

  /**
   * @description Getting value of issueTicketMetadata set in the OmniScript
   * as a LWC property and setting it to the decorator _issueTicketMetadata.
   * @param data value to be set in the decorator _issueTicketMetadata
   */
  @api
  set issueTicketMetadata(data) {
    if (data) {
      this._issueTicketMetadata = data;
    }
  }

  /**
   * @description Getter to return decorator _issueTicketMetadata.
   * @return _issueTicketMetadata
   */
  get issueTicketMetadata() {
    return this._issueTicketMetadata;
  }

  /**
   * @description Getting value of isSearchKey set in the OmniScript
   * as a LWC property and setting it to the decorator _isSearchKey.
   * @param data value to be set in the decorator _isSearchKey
   */
   @api
   set isSearchKey(data) {
     if (data) {
       this._isSearchKey = data;
     }
   }

  /**
   * @description Getter to return decorator _isSearchKey.
   * @return _isSearchKey
   */
   get isSearchKey() {
     return this._isSearchKey;
   }

  formatIssueTicketRecords(filterText) {
    try {
      this.items = [];
      let issueType = {};
      let issueSubType = {};
      let issueSymptom = {};
      let issueTicketData = this.issueTicketMetadata;
      if (this.issueTicketMetadata) {
        issueTicketData.forEach(record => {
          if (record.symptom && (record.symptom.toLowerCase()).includes(filterText.toLowerCase())) {
            if (!issueSymptom[record.symptom]) {
              issueSymptom[record.symptom] = [];
            }
            let issueEntry = {};
            issueEntry.label = record.resolutioncode;
            issueEntry.name = record.resolutioncode;
            issueEntry.resolutioncode = record.resolutioncode;
            issueEntry.subType = record.subType;
            issueEntry.type = record.type;
            issueEntry.symptom = record.symptom;
            issueEntry.expanded = filterText ? true : false;
            issueEntry.items = [];
            issueSymptom[record.symptom].push(issueEntry);
            if (record.subType && !issueSubType[record.subType]) {
              issueSubType[record.subType] = [];
              let issueEntrySubType = {};
              issueEntrySubType.label = record.subType;
              issueEntrySubType.name = record.subType;
              issueEntrySubType.subType = record.subType;
              issueEntrySubType.type = record.type;
              issueEntrySubType.expanded = filterText ? true : false;
              issueEntrySubType.items = [];
              issueSubType[record.subType].push(issueEntrySubType);
            }
            if (record.type && !issueType[record.type]) {
              issueType[record.type] = [];
              let issueEntryType = {};
              issueEntryType.label = record.type;
              issueEntryType.name = record.type;
              issueEntryType.type = record.type;
              issueEntryType.expanded = filterText ? true : false;
              issueEntryType.items = [];
              issueType[record.type].push(issueEntryType);
            }
          }
          else {
            return false;
          }
        });
        for (const property in issueSymptom) {
          let subTypeText = issueSymptom[property][0].subType;
          let symptomObject = {};
          symptomObject.label = property;
          symptomObject.name = property;
          symptomObject.expanded = filterText ? true : false;
          symptomObject.items = [];
          issueSubType[subTypeText][0].items.push(symptomObject);
        }
        for (const property in issueSubType) {
          issueType[issueSubType[property][0].type][0].items.push(issueSubType[property][0]);
        }
        for (const property in issueType) {
          this.items.push(issueType[property][0]);
        }
        this.issueType = issueType;
        this.issueSubType = issueSubType;
        this.issueSymptom = issueSymptom;
      }
    } catch (error) {
      console.log(error);
    }
  }

  handleChange(event) {
    this.formatIssueTicketRecords(event.target.value);
  }

  handleOnselect(event) {
    this.selectedItemValue = event.detail.name;
    if (this.issueSymptom[event.detail.name]) {
      this.showMessage = false;
      let selectedType = this.issueSymptom[event.detail.name][0].type;
      let selectedSubType = this.issueSymptom[event.detail.name][0].subType;
      let selectedSymptom = event.detail.name;
      this.omniApplyCallResp({
        'selectedType': selectedType,
        'selectedSubType': selectedSubType,
        'selectedSymptom': selectedSymptom
      });
    } else {
      this.showMessage = true;
    }
  }
}