import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation';

const actions = [
  { label: 'Download', name: 'download' }
];

export default class ticketListView extends OmniscriptBaseMixin
    (NavigationMixin(LightningElement)) {

  @api kind;
  @track boolTicketData = false;
  @track columns = [];
  @track constructionColumns = ['ticketId', 'customerIssueStatus', 'subType', 'accountId',
      'createdTime', 'updated', 'requestedFollowUp', 'daysLeft', 'severity', 'assignee',
      'assignedGoogleGroup', 'fiberMarket', 'fiberSpaceCode'];
  @track csrColumns = ['ticketId', 'customerIssueStatus', 'schema', 'type', 'symptom',
      'accountId', 'createdTime', 'requestedFollowUp', 'assignee', 'assignedGoogleGroup',
      'fiberMarket', 'fiberSpaceCode', 'vendorGoogleGroup'];
  @track escalationsColumns = ['ticketId', 'customerIssueStatus', 'summary', 'accountId',
      'blockedByIssueId', 'createdTime', 'updated', 'severity', 'assignee',
      'assignedGoogleGroup', 'fiberMarket', 'fiberSpaceCode'];
  @track fiberSpaceEscalationsColumns = ['ticketId', 'customerIssueStatus', 'symptom',
      'originalVendorGroup', 'createdTime', 'daysLeft', 'severity', 'assignee',
      'assignedGoogleGroup', 'fiberMarket', 'fiberSpaceCode'];
  @track fiberSpaceFollowUpColumns = ['ticketId', 'customerIssueStatus', 'blockingIssueId',
      'createdTime', 'followUp', 'assignee', 'assignedGoogleGroup', 'fiberMarket',
      'fiberSpaceCode'];
  @track fiberSpaceWaitQueueColumns = ['ticketId', 'reasonForVisit', 'firstName',
      'partySize', 'customerDescription', 'language', 'queueTime', 'assignee',
      'assignedGoogleGroup', 'fiberMarket', 'fiberSpaceCode', 'vendorGoogleGroup'];
  @track group = '';
  @track sortBy;
  @track sortDirection;
  @track value = 'CSR';
  get options() {
    return [
      {label: 'CSR', value: 'CSR' },
      {label: 'CSR-T2', value: 'CSR_T2' },
      {label: 'Construction', value: 'Construction' },
      {label: 'Escalations (ICS)', value: 'Escalations_ICS' },
      {label: 'Escalations (IST)', value: 'Escalations_IST' },
      {label: 'Escalations (TCS)', value: 'Escalations_TCS' },
      {label: 'Fiber Space', value: 'Fiber_Space' },
      {label: 'Fiber Space Leads', value: 'Fiber_Space_Leads' },
      {label: 'Fiber Space Escalations', value: 'Fiber_Space_Escalations' },
      {label: 'Fiber Space Follow-up', value: 'Fiber_Space_Follow_up' },
      {label: 'Fiber Space Wait Queue', value: 'Fiber_Space_Wait_Queue' },
      {label: 'Inbound Sales', value: 'Inbound_Sales' },
      {label: 'Install Escalations', value: 'Install_Escalations' },
      {label: 'Address Wizards', value: 'Address_Wizards' },
      {label: 'Field Sales', value: 'Field_Sales' },
      {label: 'MDU Sales', value: 'MDU_Sales' },
      {label: 'MxU Account Managers', value: 'MxU_Account_Managers' },
      {label: 'MxU Construction Managers', value: 'MxU_Construction_Managers' },
      {label: 'MxU Field Design Managers', value: 'MxU_Field_Design_Managers' },
      {label: 'NIU Escalations', value: 'NIU_Escalations' },
      {label: 'Quality', value: 'Quality' }
    ];
  }
  @track allColumns = [
    {
      type: 'button',
      label: 'Ticket Id',
      fieldName: 'ticketId',
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
      label: 'Status',
      fieldName: 'customerIssueStatus',
      type: 'text'
    },
    {
      label: 'Schema',
      fieldName: 'schema',
      type: 'text'
    },
    {
      label: 'Type',
      fieldName: 'type',
      type: 'text'
    },
    {
      label: 'Sub Type',
      fieldName: 'subType',
      type: 'text'
    },
    {
      label: 'Symptom',
      fieldName: 'symptom',
      type: 'text'
    },
    {
      label: 'Summary',
      fieldName: 'summary',
      type: 'text'
    },
    {
      label: 'Account Id',
      fieldName: 'accountId',
      type: 'text'
    },
    {
      label: 'Bugs',
      fieldName: 'blockedByIssueId',
      type: 'text'
    },
    {
      label: 'Source',
      fieldName: 'originalVendorGroup',
      type: 'text'
    },
    {
      label: 'Source (Blocked/Blocking Tickets)',
      fieldName: 'blockingIssueId',
      type: 'text'
    },
    {
      label: 'Created Date',
      fieldName: 'createdTime',
      type: 'date',
      wrapText: true,
      sortable: "true",
      typeAttributes:{
        year: "numeric",
        month: "long",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
      }
    },
    {
      label: 'Updated',
      fieldName: 'updated',
      type: 'date',
      typeAttributes:{
        year: "numeric",
        month: "long",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
      }
    },
    {
      label: 'Follow Up',
      fieldName: 'followUp',
      type: 'text'
    },
    {
      label: 'Follow Up(Date & Time)',
      fieldName: 'requestedFollowUp',
      type: 'text'
    },
    {
      label: 'Due In Days',
      fieldName: 'daysLeft',
      type: 'text'
    },
    {
      label: 'Severity',
      fieldName: 'severity',
      type: 'text'
    },
    {
      label: 'Reason For Visit',
      fieldName: 'reasonForVisit',
      type: 'text',
      wrapText: true
    },
    {
      label: 'First Name',
      fieldName: 'firstName',
      type: 'text',
      wrapText: true
    },
    {
      label: 'In Party',
      fieldName: 'partySize',
      type: 'text'
    },
    {
      label: 'Customer Description',
      fieldName: 'customerDescription',
      type: 'text'
    },
    {
      label: 'Language',
      fieldName: 'language',
      type: 'text'
    },
    {
      label: 'Queue Time',
      fieldName: 'queueTime',
      type: 'text'
    },
    {
      label: 'Assignee',
      fieldName: 'assignee',
      type: 'text'
    },
    {
      label: 'Kind',
      fieldName: 'assignedGoogleGroup',
      type: 'text'
    },
    {
      label: 'Region',
      fieldName: 'fiberMarket',
      type: 'text'
    },
    {
      label: 'Fiber Space',
      fieldName: 'fiberSpaceCode',
      type: 'text'
    },
    {
      label: 'Vendor',
      fieldName: 'vendorGoogleGroup',
      type: 'text'
    }
  ];
  connectedCallback() {
    let groupData = {};
      groupData.detail = {};
      groupData.detail.value = this.value;
    this.handleChange(groupData);
  }
  handleChange(event) {
    try {
      this.boolTicketData = false;
      this.columns = [];
      let selectedGroup = [];
      let selectedColumns = [];
      switch(event.detail.value) {
        case "Construction":
          selectedGroup = this.constructionColumns;
          break;
        case "Escalations_ICS":
        case "Escalations_IST":
        case "Escalations_TCS":
          selectedGroup = this.escalationsColumns;
          break;
        case "Fiber_Space":
        case "Fiber_Space_Leads":
        case "Fiber_Space_Escalations":
          selectedGroup = this.fiberSpaceEscalationsColumns;
          break;
        case "Fiber_Space_Follow_up":
          selectedGroup = this.fiberSpaceFollowUpColumns;
          break;
        case "Fiber_Space_Wait_Queue":
          selectedGroup = this.fiberSpaceWaitQueueColumns;
          break;
        default:
          selectedGroup = this.csrColumns;
      }
      this.allColumns.forEach(function(column) {
        if(selectedGroup.indexOf(column.fieldName) != -1) {
          selectedColumns.push(column);
        }
      });
      this.columns = selectedColumns;
      this.resultdata = [];
      let requestObject = {};
      requestObject.value = event.detail.value;
      this.group = requestObject.value;
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'TCK_ExtractContactAndIssueTicket',
        options: '{}'
      };
      let inputObject = {};
      inputObject.kindName = this.group;
      let inputMap = JSON.stringify(inputObject);
      params.input = inputMap;
      this.omniRemoteCall(params, true)
          .then((response) => {
      this.resultdata = response.result.IPResult.ticketResponse;
      this.boolTicketData = true;
      })
      .catch((error) => {
        this.error = 'Error occured while fetching Ticket details.';
      });
    }
    catch(e) {
      console.log(JSON.stringify(e));
    }
  }
  handleSortdata(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
  }
  handleRowAction(event) {
    let OperationTicketId;
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    if (row.ticketId) {
      const data = {'bugafiberTicketId': row.ticketId, 'schema': row.schema}
      this[NavigationMixin.Navigate]({
        'type': 'standard__component',
        'attributes': {
          'componentName': 'c__genericAuraWrapperForConsoleLWC'
         },
        state: {
          c__initialData: JSON.stringify(data),
          c__isExpandView: true,
          c__lwcComponentName: 'c:buganizerTicketView',
          c__tabIcon: 'utility:bug',
          c__tabLabel: event.target.value
        }
     });
    }
  }
  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.resultdata));
    let keyValue = (a) => {
      return a[fieldname];
    };
    let isReverse = direction === 'asc' ? 1: -1;
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : '';
      y = keyValue(y) ? keyValue(y) : '';
      return isReverse * ((x > y) - (y > x));
    });
    this.resultdata = parseData;
  }
}