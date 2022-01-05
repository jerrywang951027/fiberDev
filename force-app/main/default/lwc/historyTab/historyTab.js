import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
const COLUMNS = [
  { 
    label: 'Date',
    fieldName: 'createdDate',
    type: "date",
    typeAttributes:{
      day: "2-digit",
      month: "short",
      year: "2-digit"
    }
  },
  { 
    label: 'Type',
    fieldName: 'iconName'
  },
  { 
    label: 'Summary',
    fieldName: 'eventType' 
  },
  { 
    label: 'Id',
    fieldName: 'displayLabel'
  }
];
const TYPES = [
  // {label: 'All', value: 'All'},
  {label: 'Email', value: 'Email', level: 'parent'},
  {label: 'Chat', value: 'Chat', level: 'parent'},
  {label: 'Phone Call', value: 'Phone Call', level: 'parent'},
  {label: 'Fiber Space', value: 'Fiber Space', level: 'parent'},
  {label: 'Outbound', value: 'Outbound', level: 'parent'},
  {label: 'Social', value: 'Social', level: 'parent'},
  {label: 'No Channel', value: 'No Channel', level: 'parent'},
  {label: 'Sign Up', value: 'Sign Up', level: 'parent'},
  {label: 'Billing Event', value: 'Billing Event', level: 'parent'},
  {label: 'Eligible Uptime/Downtime', value: 'Eligible Uptime/Downtime', level: 'parent'},
  {label: 'Google Account Transfer', value: 'Google Account Transfer', level: 'parent'},
  {label: 'Installation Event', value: 'Installation Event', level: 'parent'},
  {label: 'Internal Issue', value: 'Internal Issue', level: 'parent'},
  {label: 'Move', value: 'Move', level: 'parent'},
  {label: 'NIU Installation', value: 'NIU Installation', level: 'parent'},
  {label: 'One Time Transaction', value: 'One Time Transaction', level: 'parent'},
  {label: 'Outage', value: 'Outage', level: 'parent'},
  {label: 'Plan Change', value: 'Plan Change', level: 'parent'},
  {label: 'Planned Maintenance', value: 'Planned Maintenance', level: 'parent'},
  {label: 'Service Visit', value: 'Service Visit', level: 'parent'},
  {label: 'Suspension Event', value: 'Suspension Event', level: 'parent'},
  {label: 'Touchpoint', value: 'Touchpoint', level: 'parent'}
];

export default class HistoryTab extends OmniscriptBaseMixin(LightningElement) {
  selectedType = "All";
  types = TYPES;
  serviceAccountId;
  isSpinnerLoaded = true;
  columns = COLUMNS;
  eventTypeAndIconMapping;
  // eventTypeAndIconMapping;
  
  @track historyDetails = [];
  @track selectedFilters = ['All'];
  /**
   * @description Will fire everytime when Premises Id is changed. to get the Premises Id.
   * @return this.serviceAccountId Returns the serviceAccountId
   */
   @api get serviceAccountData() {
    return this.serviceAccountId;
  }

  /**
   * @description Will fire everytime when Premise Id is changed. to set the Premises Id.
   * @param  value - Value to be set
   */
  set serviceAccountData(value) {
    this.setAttribute('serviceAccountData', value);
    this.serviceAccountId = value;
    this.getHistoryTabDetails();
  }
  get iconByEventType() {
    return eventTypeAndIconMapping;
  }
  set iconByEventType(value){
    const iconByEventTypeMap = new Map();
    value.forEach(iconData => {
      iconByEventTypeMap.set(iconData.eventType, iconData.iconName);
    });
    this.eventTypeAndIconMapping = iconByEventTypeMap;
  }

  getHistoryTabDetails() {
    this.isSpinnerLoaded = true;
    this.historyDetails = undefined;
    console.log('getHistoryTabDetails :: serviceAccountId '+this.serviceAccountId);
    let inputParams = {
      serviceAccountId : this.serviceAccountId,
      eventTypeSelected : this.selectedFilters
    }
    console.log('getHistoryTabDetails :: selectedFilters '+this.selectedFilters);
    let params = {
      input: JSON.stringify(inputParams),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_FetchHistoricalDetailsForServiceAccount',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      console.log('getHistoryTabDetails :: response = '+JSON.stringify(response.result.IPResult));
      this.iconByEventType = response.result.IPResult.iconMapping;
      if (response && response.result.IPResult.finalData.length !== 0) {
        let dataFromIP = response.result.IPResult.finalData;
        dataFromIP.forEach(events => {
          events.iconName = events.eventType != '' ?
              this.eventTypeAndIconMapping.get(events.eventType) :
              this.eventTypeAndIconMapping.get('Default Icon');
          events.summaryData = events.summaryData.split('\\n').join(' <br>');
        });

        this.historyDetails = dataFromIP;
        this.isSpinnerLoaded = false;
        console.log('this.data = '+JSON.stringify(this.historyDetails));
      }
    }).catch (error => {
      console.log('getHistoryTabDetails :: error = '+JSON.stringify(error));
      this.isSpinnerLoaded = false;
    });
  }
  // getIconName(eventType) {
  //   let iconName = '';
  //   this.eventTypeAndIconMapping.forEach(icon => {
  //     if (icon.eventType == eventType){
  //       iconName = icon.iconName;
  //     }
  //   });
  //   return iconName;
  // }
  getFilterData() {
    const listComp = this.template.querySelector('lightning-dual-listbox');
    let filterValues = [];
    if (listComp && listComp.value && listComp.value.length > 0) {
      this.selectedFilters = listComp.value;
      filterValues = listComp.value;
    } else if (this.selectedFilters) {
      filterValues = this.selectedFilters;
    }
    if (filterValues && filterValues.length > 0) {
      let typeFilters = [];
      filterValues.forEach(
          item => (typeFilters.push(this.types.find(elem => (elem.value === item)))));
      return typeFilters;
    }
    return [];
  }
  filterByTypes(event) {
    console.log('filterByTypes : event.detail ' +JSON.stringify(event.detail));
    console.log('filterByTypes : event.detail len' +event.detail.length);
    this.selectedFilters = event.detail.length != 0 ? event.detail : ['All'];
    console.log('filterByTypes : this.selectedFilters ' +this.selectedFilters);
    this.getHistoryTabDetails();
  }
}