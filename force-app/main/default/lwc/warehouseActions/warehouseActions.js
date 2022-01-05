/**
 * @group WarehouseActions
 * @description To call custom setting for Warehouse Location.
 */
import { LightningElement, track } from 'lwc';
import warehouseLocations from '@salesforce/apex/WarehouseActionsController.getWarehouseLocations';
export default class WarehouseActions extends LightningElement {
  @track warehouseItems=[];
  @track selectedValue;
  connectedCallback(){
    console.log('connected callback called');
    warehouseLocations()
    .then(result => {
      this.warehouseItems = result;
    })
    console.log("selectedValue in connected callback" + this.selectedValue);
  }

  changeOptionHandler(event){
    console.log("changeHandler called");
    this.selectedValue = event.target.value;
    console.log("selectedValue=" + this.selectedValue);
    this.selectedValue = event.target.value;
    console.log('ChildComp Check'+this.selectedValue)
    const customEventCheck = new CustomEvent("valueCheck", {    
      detail: this.selectedValue, 
      bubbles: true
    });
    this.dispatchEvent(customEventCheck); 
  }
}