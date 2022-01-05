import { api, LightningElement, track } from 'lwc';
import dataTableCell from 'vlocity_cmt/dataTableCell';

export default class HistoryTabSummaryDataTableCell extends dataTableCell {
  @track summaryData;
  renderedCallback() {
    if(this.cellData) {
      // console.log('this.cellData',JSON.stringify(this.cellData));
      // console.log('this.cellData',this.cellData.value);
      // console.log('this.rowData',JSON.stringify(this.rowData));
    }
    // console.log('this.cellData.value'+this.cellData.value);
    // this.summaryData = JSON.parse(this.cellData.value);
  }
}