/**
* @group ServiceVisits-installerService
* @description to return the records of the TicketDataWrapper.
*/
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllTickets from '@salesforce/apex/OperationTicketData.getAllTickets';
import getSalesforceId from '@salesforce/apex/OperationTicketData.getSalesforceId';

const actions = [
    { label: 'Download', name: 'download' }
];
var COLUMNSMANAGER =[{
    label: 'Vendor',
    fieldName: 'vendor',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Fiber Market',
    fieldName: 'googleFiberMarket',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 80
  },
  {
    label: 'Technician',
    fieldName: 'technicianName',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
  },
  { type: 'button', 
    label: 'Ticket Id',
    fieldName: 'ticketUrl',
	 initialWidth: 100,
	 typeAttributes: {
        label: {
			  fieldName: 'ticketId'
			},
			title: {
			  fieldName: 'ticketId'
			},
        name: 'download',  
        variant: 'Base',
        alternativeText: 'download',        
        disabled: false
    }
  },
  {
    label: 'Account',
    fieldName: 'accountId',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true
  },
  {
    label: 'Order Id',
    fieldName: 'orderId',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
  },
  {
    label: 'Appointment Date',
    fieldName: 'appointmentDate',
    initialWidth: 100,
    wrapText: true,
    hideDefaultActions: true,
    sortable: true,
    type: 'date',
    typeAttributes: {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit"
    }
  },
  {
    label: 'Account Status',
    fieldName: 'accountStatus',
    initialWidth: 100,
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Appointment Type',
    fieldName: 'appointmentType',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 180
  },
  {
    label: 'Sub-Type',
    fieldName: 'Sub',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 180
  },
  {
    label: 'Current Plan',
    fieldName: 'servicePlan',
    initialWidth: 130,
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Customer Name',
    fieldName: 'customerName',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 80
  },
  {
    label: 'Customer Email',
    fieldName: 'customerEmail',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 80
  },
  {
    label: 'Customer Phone',
    fieldName: 'customerPhone',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 80
  },
  {
    label: 'Address',
    fieldName: 'address',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 180
  },
  {
    label: 'ONT',
    fieldName: 'ONT',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Router',
    fieldName: 'router',
    wrapText: true,
    hideDefaultActions: true,
    type: 'number',
    cellAttributes: {
      alignment: 'left'
    }
  }];
var COLUMNSBASIC =[
  { type: 'button', 
    label: 'Ticket Id',
    fieldName: 'ticketUrl',
	 initialWidth: 100,
	 typeAttributes: {
        label: {
			  fieldName: 'ticketId'
			},
			title: {
			  fieldName: 'ticketId'
			},
        name: 'download',  
        variant: 'Base',
        alternativeText: 'download',        
        disabled: false
    }
  },
  {
    label: 'Account',
    fieldName: 'accountId',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true
  },
  {
    label: 'Order Id',
    fieldName: 'orderId',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
  },
  {
    label: 'Appointment Date',
    fieldName: 'appointmentDate',
    initialWidth: 100,
    wrapText: true,
    hideDefaultActions: true,
    sortable: true,
    type: 'date',
    typeAttributes: {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit"
    }
  },
  {
    label: 'Account Status',
    fieldName: 'accountStatus',
    initialWidth: 100,
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Appointment Type',
    fieldName: 'appointmentType',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 180
  },
  {
    label: 'Current Plan',
    fieldName: 'servicePlan',
    initialWidth: 130,
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Customer Name',
    fieldName: 'customerName',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 80
  },
  {
    label: 'Customer Email',
    fieldName: 'customerEmail',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 80
  },
  {
    label: 'Customer Phone',
    fieldName: 'customerPhone',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 80
  },
  {
    label: 'Address',
    fieldName: 'address',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 180
  },
  {
    label: 'ONT',
    fieldName: 'ONT',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Router',
    fieldName: 'router',
    wrapText: true,
    hideDefaultActions: true,
    type: 'number',
    cellAttributes: {
      alignment: 'left'
    }
  }];
export default class InstallerService extends NavigationMixin(LightningElement) {
  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy;
  columns = COLUMNSMANAGER;//COLUMNS;
  columnsBasic = COLUMNSBASIC;
  showSpinner = true;
  filterValues;
  recordResult;
  @track error;
  @track serviceList;
  @track marketValue;
  @track isVendorUserPermissionSet = false;
  @track isBasicUserPermissionSet = false;
  get options() {
    return [
      { label: 'Select', value: '' },
      { label: 'Raleigh/Durham, NC', value: 'Raleigh/Durham, NC' },
      { label: 'Atlanta, GA', value: 'Atlanta, GA' },
      { label: 'West Des Moines, IA', value: 'West Des Moines, IA' },
      { label: 'Austin, TX', value: 'Austin, TX' },
      { label: 'Charlotte, NC', value: 'Charlotte, NC' },
      { label: 'Nashville, TN', value: 'Nashville, TN' },
      { label: 'San Antonio, TX', value: 'San Antonio, TX' },
      { label: 'Salt Lake City, UT', value: 'Salt Lake City, UT' },
      { label: 'Provo, UT', value: 'Provo, UT' },
      { label: 'Orange County, CA', value: 'Orange County, CA' },
      { label: 'Kansas City, KS', value: 'Kansas City, KS' },
      { label: 'Kansas City, MO', value: 'Kansas City, MO' },
      { label: 'Huntsville, AL', value: 'Huntsville, AL' }
    ];
  }
  connectedCallback() {
		this.getRecords();
  }
  handleChange(event) {
  	 this.showSpinner = true;
    this.marketValue = event.detail.value;
    this.getRecords();

  }
  getRecords() {
	let result;
	getAllTickets({strMarket: this.marketValue,strSort: ""})
     .then(result => {
        this.formatData(result);
        this.recordResult = result;
		  this.showSpinner = false;
      })
      .catch(error => {
        this.error = error;
		  this.showSpinner = false;
      });
    }
  
  formatData(data) {
    this.serviceList = data;
    var tempServiceList = [];
    var emails;
    var technicianName;
    data.forEach (( record ) => {
        let tempRecord = Object.assign( {}, record );
        tempRecord.ticketUrl = '/' + record.operationId;
        if (record.technician != null) {
        emails = record.technician.split('@');
        tempRecord.technicianName = emails[0];
        } else {
          tempRecord.technicianName = 'Not Assigned';
        }
        this.isVendorUserPermissionSet = (tempRecord.userType == 'Vendor') ? true :false;
        this.isBasicUserPermissionSet = (tempRecord.userType == 'Basic') ? true :false;
        if(this.marketValue == ''||this.marketValue ==undefined || this.marketValue == tempRecord.googleFiberMarket) {
          tempServiceList.push( tempRecord );
        }
       
    });
    this.serviceList = tempServiceList;
    this.error = undefined;
    this.showSpinner = false;
  }

  /**
   * @group sortBy
   * @description to return the sorting parameter for each columns
   */
  sortBy ( field, reverse, primer ) {
    const key = primer 
    ? function ( x ) {
      return primer( x[field] );
    }
    : function ( x ) {
      return x[field];
    };
    return function ( a, b ) {
      a = key( a );
      b = key( b );
      return reverse * ( (a > b) - (b > a) );
    };
  }
  
  handleRowAction(event) {
        let OperationTicketId;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
		  if (row.operationId) {
		    this.navigateToRecordPage(row.operationId);
		  } else {
            getSalesforceId({ticketId: row.ticketId})
                .then(result => {
              OperationTicketId = result;
               
		      this.showSpinner = false;
              this.navigateToRecordPage(OperationTicketId);
              })
                .catch(error => {
       
		      this.showSpinner = false;
              });
		  }
    }
  navigateToRecordPage(recordId) {
     this[NavigationMixin.Navigate]({
       type: 'standard__recordPage',
       attributes: {
         objectApiName: 'Operation_Ticket__x',
         recordId: recordId,
         actionName: 'view'
       }
     });
   }
  /**
   * @group onHandleSort
   * @description to return the sorting direction
   */
  onHandleSort( event ) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.serviceList];
    cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
    this.serviceList = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }
  /**
   * @group getFilterValues
   * @description to get the ticket data based on filter values
   */
  getFilterValues( event ) {
    this.filterValues = event.detail;
  }
  rowSelected(event) {
      console.log(event.value);
  }
}