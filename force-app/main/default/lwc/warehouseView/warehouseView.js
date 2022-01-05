/**
 * @group Warehouseview
 * @description To get the selected warehouse from the warehouseaction.
 */
import { LightningElement, api,track } from 'lwc';
export default class FilterComponent extends LightningElement {
    @track selectedOption;
    @api warehouse;
    changeHandler(event) {
    const field = event.target.name;
    if (field === 'optionSelect') {
        this.selectedOption = event.target.value;
            alert("you have selected : " ,this.selectedOption);
        } 
    }
}