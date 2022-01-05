/**
* @group ServiceVisits-installerService
* @description to return the records of the TicketDataWrapper.
*/
import { LightningElement, api, wire, track } from 'lwc';
//import getAllTickets from '@salesforce/apex/OperationTicketData.getAllTickets';
import getAllTickets from '@salesforce/apex/ServiceTicketData.getAllTickets';

var COLUMNS = [
  {
    label: 'Technician',
    fieldName: 'technicianName',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
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
    label: 'Ticket Id',
    fieldName: 'ticketUrl',
    initialWidth: 80,
    wrapText: true,
    hideDefaultActions: true,
    type: 'url',
    target: '_blank',
    typeAttributes: {
      label: {
        fieldName: 'ticketId'
      }
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
    label: 'Customer Account',
    fieldName: 'customerId',
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
    label: 'Address',
    fieldName: 'address',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 180
  },
  {
    label: 'Service Plan',
    fieldName: 'servicePlan',
    initialWidth: 130,
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
  },
  {
    label: 'Phone',
    fieldName: 'phone',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'ONT',
    fieldName: 'ONT',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Status',
    fieldName: 'status',
    initialWidth: 100,
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Vendor',
    fieldName: 'vendor',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  }
];

var COLUMNSVENDOR = [
  {
    label: 'Ticket Id',
    fieldName: 'ticketUrl',
    initialWidth: 80,
    wrapText: true,
    hideDefaultActions: true,
    type: 'url',
    target: '_blank',
    typeAttributes: {
      label: {
        fieldName: 'ticketId'
      }
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
    label: 'Customer Account',
    fieldName: 'customerId',
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
    label: 'Address',
    fieldName: 'address',
    type: 'text',
    wrapText: true,
    hideDefaultActions: true,
    initialWidth: 180
  },
  {
    label: 'Service Plan',
    fieldName: 'servicePlan',
    initialWidth: 130,
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
  },
  {
    label: 'Phone',
    fieldName: 'phone',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'ONT',
    fieldName: 'ONT',
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Status',
    fieldName: 'status',
    initialWidth: 100,
    wrapText: true,
    hideDefaultActions: true,
    type: 'text'
  }
];
export default class InstallerService extends LightningElement {
  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy;
  columns = COLUMNS;
  columnsVendor = COLUMNSVENDOR;
  showSpinner = true;
  filterValues;
  recordResult;
  @track error;
  @track serviceList;
  @track marketValue;
  @track isVendorUserPermissionSet = false;
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
    this.marketValue = event.detail.value;
    //this.formatData(this.recordResult);
    this.getRecords();
    console.log('::::'+this.marketValue);

  }
  getRecords() {
	let result;
	getAllTickets({strMarket: this.marketValue,strSort: ""})
     .then(result => {
        //result = JSON.stringify(result);
       // console.log(JSON.stringify(result));
        this.formatData(result);
        this.recordResult = result;
        //this.contData = result;
      })
      .catch(error => {
        this.error = error;
      });
    }
  
  /*@wire(getAllTickets)
  wiredTickets ({ error, data }) {
    if ( data ) {
      this.formatData(data);
    } else if ( error ) {
      this.error = error.body.message;
      this.showSpinner = false;
    }
  }*/
  formatData(data) {
    console.log('data == '+JSON.stringify(data));
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
        }
        this.isVendorUserPermissionSet = (tempRecord.userType == 'Vendor') ? true :false;
        console.log('tempRecord.googleFiberMarket::'+tempRecord.googleFiberMarket+':::this.marketValue:::'+this.marketValue);
        
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
    console.log('filter values == '+JSON.stringify(event.detail));
    this.filterValues = event.detail;
  }
}