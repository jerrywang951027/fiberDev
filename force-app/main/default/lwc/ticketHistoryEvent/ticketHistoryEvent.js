import { api, LightningElement, track, wire } from 'lwc';
import getHistoryEvents from '@salesforce/apex/HistoryEventUtils.getHistoryEvents';

const columns = [
  {
    label: 'Bugafiber Ticket Id',
    fieldName: 'bugafiberTicketId',
    type: 'url',
    typeAttributes: {
      label: {
        fieldName: 'name'
      },
    target: '_parent'
    }
  },
  {
    label: 'Type',
    fieldName: 'type'
  },
  {
    label: 'Ticket Open Date',
    fieldName: 'eventDate',
    type: 'date',
    typeAttributes: {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    },
    sortable: true
  },
  {
    label: 'Ticket Close Date',
    fieldName: 'eventEndDate',
    type: 'date',
    typeAttributes: {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    },
    sortable: true
  },
  {
    label: 'Ticket Updated Date',
    fieldName: 'ticketUpdatedDate',
    type: 'date',
    typeAttributes: {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    },
    sortable: true
  }
];

export default class TicketHistory extends LightningElement {
  @api recordId;
  records;
  wiredRecords;
  error;
  columns = columns;
  draftValues = [];
  @wire(getHistoryEvents, {ticketId: '$recordId'})
  HistoryEvents( value ) {
    this.wiredRecords = value;
    const { data, error } = value;
    if (data) {
      let contactTicketList = JSON.parse(JSON.stringify(data));
      contactTicketList = contactTicketList.map( row => {
        return {
          name: row.External_Ticket__c,
          event: row.Id,
          type: row.Type__c,
          eventDate: row.Event_Date__c,
          eventEndDate: row.Event_End_Date__c,
          ticketUpdatedDate: row.Ticket_Updated_Date__c,
          bugafiberTicketId: '/' + row.Id
        };
      })
      this.records = contactTicketList;
    } else if (error) {
      this.records = undefined;
      console.log(error.message);
    }
  }
}