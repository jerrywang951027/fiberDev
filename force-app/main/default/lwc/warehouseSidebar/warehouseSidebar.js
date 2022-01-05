/**
   * @group warehouseSidebar
   * @description Side-bar selection component, based on selected option,
   *     navigate to page.
   */
// Import Lightning decorator
import {
  api,
  LightningElement,
  track,
  wire
} from 'lwc';
// Check if user have access to this warehouse
import checkIfUserExists 
    from "@salesforce/apex/i2msFindSerialAPI.checkIfUserExists";
// Import GetRecord system API
import {
  getRecord
} from 'lightning/uiRecordApi';
// Get current user id
import Id from '@salesforce/user/Id';
// Get user name
import UserNameFld from '@salesforce/schema/User.Name';
// Get user Email
import userEmailFld from '@salesforce/schema/User.Email';
// Get user active status
import userIsActiveFld from '@salesforce/schema/User.IsActive';
// Get user alias
import userAliasFld from '@salesforce/schema/User.Alias';

export default class WarehouseSidebar extends LightningElement {

  // Define Scope of Global and Local Variables
  @api gpnSearch;
  @api statusSearch;
  @api serialnumberSearch;
  @api technameSearch;
  @api warehouseFromScreen = '';
  @api warehouseAccessFromPublicGroup = '';

  @track selectedStatus = '';
  @track selectedValue = '';
  
  error;
  onhandDevicesShow;
  resolveLostPendingShow;
  resolvePreAssignedShow;
  sparefulfillmentShow;
  technicianEndOfDayShow;
  warehouseSearchShow;

  // Get current user Email.
  @wire(getRecord, {
    recordId: Id,
    fields: [UserNameFld, userEmailFld, userIsActiveFld, userAliasFld]
  })
  wireuser({
    error,
    data
  }) {
    if (data) {
      this.currentUserEmailId = data.fields.Email.value;
    } else if (error) {
      this.error = error;
    }
  }

  // Get status for search component.
  get getStatusValue() {

    return [{
        label: 'ONHAND',
        value: 'ONHAND'
      },
      {
        label: 'PRE_ASSIGNED',
        value: 'PRE_ASSIGNED'
      },
      {
        label: 'PRE_ASSIGNED_SPARE',
        value: 'PRE_ASSIGNED_SPARE'
      },
      {
        label: 'ALL_PREASSIGNED',
        value: 'ALL_PREASSIGNED'
      },
      {
        label: 'PRE_TRANSFER',
        value: 'PRE_TRANSFER'
      },
      {
        label: 'ACKNOWLEDGED',
        value: 'ACKNOWLEDGED'
      },
      {
        label: 'LOST_PENDING_RECEIPT',
        value: 'LOST_PENDING_RECEIPT'
      },
      {
        label: 'DOA_PENDING_RECEIPT',
        value: 'DOA_PENDING_RECEIPT'
      },
      {
        label: 'SURPLUS_PENDING_RECEIPT',
        value: 'SURPLUS_PENDING_RECEIPT'
      },
      {
        label: 'RMA_PENDING_RECEIPT',
        value: 'RMA_PENDING_RECEIPT'
      },
      {
        label: 'LOST',
        value: 'LOST'
      },
      {
        label: 'FOUND',
        value: 'FOUND'
      },
    ];
  }

  constructor() {
    super();
    this.template.addEventListener('valueCheck', this.parenthandlerCheck.bind(this));
  }

  // Check user authority for the selected warehouse.
  async checkUser(warehouseName) {
    var validUsers = await checkIfUserExists({
      location: warehouseName
    })
    const checkUser = validUsers.find(Arr => Arr.Email === this.currentUserEmailId);
    // Return checkUser
    if (checkUser) {
      return true
    } else {
      return false
    }
  }

  // When any component selection was made on the screen.
  async handleSelect(event) {
    const selected = event.detail.name;

    // Switch off all components display.
    this.onhandDevicesShow = false;
    this.sparefulfillmentShow = false;
    this.resolvePreAssignedShow = false;
    this.technicianEndOfDayShow = false;
    this.resolveLostPendingShow = false;
    this.warehouseSearchShow = false;

    // Only show OnHand Devices, make all other flags OFF.
    if (selected === 'onhand_devices') {
      this.warehouseAccessFromPublicGroup = await this.checkUser(this.selectedValue)
      this.warehouseFromScreen = this.selectedValue;
      this.onhandDevicesShow = true
      const today = new Date();

      // Make the component available before it has been called on the screen.
      try {
        const objChild = this.template.querySelector("c-onhand-devices");
        objChild.fetchOnhand(this.warehouseFromScreen, this.warehouseAccessFromPublicGroup);
      } catch {
        this.template.querySelector("c-onhand-devices");
      }
    }

    // Only show Spare Fulfillment, make all other flags OFF.
    else if (selected === 'spares_fulfillment') {
      this.sparefulfillmentShow = true
      // Make the component available before it has been called on the screen.
      this.template.querySelector('c-warehouse-view');
    }
    // Only show Resolve Pre Assigned, make all other flags OFF.
    else if (selected === 'resolve_pre_assigned') {
      this.resolvePreAssignedShow = true
      // Make the component available before it has been called on the screen.
      this.template.querySelector('c-resolve-pre-assigned');
    }
    // Only show End of Day, make all other flags OFF.
    else if (selected === 'end_of_day') {
      this.technicianEndOfDayShow = true;
      // Make the component available before it has been called on the screen.
      this.template.querySelector('c-i2ms-warehouse-technician-end-of-day');
    }
    // Only show Resolve Lost, make all other flags OFF.
    else if (selected === 'resolve_lost') {
      this.resolveLostPendingShow = true;
      // Make the component available before it has been called on the screen.
      this.template.querySelector('c-resolve-lost-pending-receipt');
    }
  }

  // When search was made on the side bar.
  async handleSearch() {

    // Get search values from screen.
    this.serialnumberSearch = 
        this.template.querySelector('lightning-input[data-formfield="serialnumber"]').value;
    this.technameSearch = 
        this.template.querySelector('lightning-input[data-formfield="techname"]').value;
    this.gpnSearch = 
        this.template.querySelector('lightning-input[data-formfield="gpn"]').value;
    this.statusSearch = 
        this.template.querySelector('lightning-combobox[data-formfield="status"]').value;

    // Only show search warehouse component on screen, rest all flags should be OFF.
    this.resolveLostPendingShow = false;
    this.resolvePreAssignedShow = false;
    this.sparefulfillmentShow = false;
    this.onhandDevicesShow = false;
    this.technicianEndOfDayShow = false;
    this.warehouseSearchShow = true;

    // Make the component available before it has been called on the screen.
    try {
      const objChild = this.template.querySelector("c-warehouse-search-element");
      objChild.loadDataTable(this.selectedValue, this.serialnumberSearch,
          this.technameSearch, this.gpnSearch, this.statusSearch);

    } catch {
      this.template.querySelector("c-warehouse-search-element");
    }

    // Clear search fields on screen.
    this.template.querySelector('lightning-input[data-formfield="serialnumber"]').value = null;
    this.template.querySelector('lightning-input[data-formfield="techname"]').value = null;
    this.template.querySelector('lightning-input[data-formfield="gpn"]').value = null;
    this.template.querySelector('lightning-combobox[data-formfield="status"]').value = '';
  }

  // Get parent check value
  parenthandlerCheck(event) {
    this.selectedValue = event.detail;
  }

  // If status was changed, retrieve its value
  handleStatusChange(event) {
    this.statusSearch = event.detail.value;
  }
}