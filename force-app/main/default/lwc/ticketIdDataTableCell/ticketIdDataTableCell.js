import { api, LightningElement } from 'lwc';
import dataTableCell from 'vlocity_cmt/dataTableCell';
import { NavigationMixin } from 'lightning/navigation';
import pubsub from 'vlocity_cmt/pubsub';

export default class TicketIdDataTableCell extends NavigationMixin(dataTableCell) {
  @api timeZone;
  loadTicketDetails() {
    console.log('this.rowDate = '+JSON.stringify(this.rowData));
    if(this.rowData.isNotBuganiserTicket) {
      const recordId = this.rowData.id;

      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            actionName: 'view'
        },
      });
    } else {
      pubsub.fire('onclosemodal', 'closeModal', true);
      const data = {'bugafiberTicketId': this.cellData.value,'timeZone': this.timeZone};
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
          c__tabLabel: this.cellData.value
        }
      });
    }
  }
}