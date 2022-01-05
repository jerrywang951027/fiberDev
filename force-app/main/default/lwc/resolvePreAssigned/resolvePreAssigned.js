/**
 * @group ResolvepreAssigned
 * @description To call ResolvepreAssigned components operations.
 */
 import { api, LightningElement, track } from 'lwc';
 import checkIfLdapExists from '@salesforce/apex/I2msTechnicianController.checkIfLdapExists';
 import extractJsonData from '@salesforce/apex/I2msTechnicianController.extractJsonData';
 import updateDeviceOwnership from '@salesforce/apex/I2msTechnicianController.updateDeviceOwnership';
 
 export default class ResolvePreAssigned extends LightningElement {
 
   @api warehouse;
   
   @track jsonList;
   @track selectedValueList = [];
   
   searchKeyInput;
   techNameValue;
   enteredTechName;
   isNoRecord = true;
   requestBody;
   showError = false;
 
   /**
    * @description Method for checking the user name in the Technician group
    * @param userName to be used for Technician name
    */
   checkLdap(techName) {
     let ldapEmail = techName + '@google.com';
     checkIfLdapExists({
       userEmail: ldapEmail
     })
     .then(result => {
       let res = result;
       if (res == true) {
         this.showError = false;
         this.findSerials(techName);
       } else {
         this.jsonList = [];
         this.showError = true;
       }
     });
   }
 
   /**
    * @description Method for searching Technician on click of enter key
    */
   handleKeypress(event) {
     if (event.which == 13) {
       let techName = this.template.querySelector('input').value;
       this.techNameValue = techName;
       if (techName != '' && techName != null) {
         this.checkLdap(techName);
       }
     }
   }
 
   /**
    * @description Method for searching Technician on click of search button
    */
   handleSearch() {
     let techName = this.template.querySelector('input').value;
     this.techNameValue = techName;
     if (techName != '' && techName != null) {
       this.checkLdap(techName);
     }
   }
   findSerials(techName) {
     extractJsonData({
       searchKey: techName,
       status: 'PRE_ASSIGNED_SPARE'
     })
     .then(result => {
       if (result) {
         let res = JSON.parse(result);
         this.isNoRecord = false;
         this.jsonList = res;
       } else {
         this.isNoRecord = true;
       }
     });
   }
 
   /**
    * @description Method for updating selected values on check box click
    */
   handleCheckboxClick(event) {
     let serialNo = event.target.value;
     let isSelected = event.target.checked;
     if (serialNo) {
       if (isSelected) {
         this.selectedValueList.push(serialNo);
       } else {
         if (this.selectedValueList.length > 0) {
           for (let i = 0; i < this.selectedValueList.length; i++) {
             if (this.selectedValueList[i] == serialNo) {
               this.selectedValueList.splice(i, 1);
             }
           }
         }
       }
     }
   }
 
   /**
    * @description Method for handling select all option in check box
    */
   handleSelectAll(event) {
     let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
       for (let i = 0; i < checkboxes.length; i++) {
         checkboxes[i].checked = event.target.checked;
       }
     let isSelected = event.target.checked;
       if (isSelected == true) {
         this.jsonList.forEach(node => {
           this.selectedValueList.push(node.deviceOwnership.serialKey.serialNumber);
         });
       } else {
         this.selectedValueList = [];
       }
     }
 
   /**
    * @description Method for checking parent/child relationship and
    * making call to API for Unassign devices
    */
   handleUnassign() {
     this.template.querySelector('input').value = null;
     let inputMap = [];
     //ver for child
     let childIndex, childSerialNumber, childGpn, serialIndex, gpn, childInput, input;
     let parentSerialNumber, parentIndex, parentGpn, parentInput;
     this.selectedValueList.forEach(serialNo => {
       serialIndex = (this.jsonList.findIndex(node =>
           node.deviceOwnership.serialKey.serialNumber == serialNo));
           gpn = this.jsonList[serialIndex].deviceOwnership.serialKey.gpn;
           childIndex = (this.jsonList.findIndex(node =>
           node.parentSerialKey.serialNumber == serialNo));
       if (childIndex >= 0) {
         childSerialNumber = this.jsonList[childIndex].deviceOwnership.serialKey.serialNumber;
         childGpn = this.jsonList[childIndex].deviceOwnership.serialKey.gpn;
       }
       if (this.jsonList[serialIndex].parentSerialKey.serialNumber) {
         parentSerialNumber = this.jsonList[serialIndex].parentSerialKey.serialNumber;
         parentIndex = (this.jsonList.findIndex(node =>
             node.deviceOwnership.serialKey.serialNumber == parentSerialNumber));
         if (parentIndex >= 0) {
           parentGpn = this.jsonList[parentIndex].deviceOwnership.serialKey.gpn;
         }
       }
       input = {
         'serialNo': serialNo,
         'gpn': gpn
       }
       if (this.selectedValueList.includes(childSerialNumber) != true) {
         if (childSerialNumber && childGpn) {
           childInput = {
             'serialNo': childSerialNumber,
             'gpn': childGpn
         }
           inputMap.push(childInput);
         }
       }
       if (this.selectedValueList.includes(parentSerialNumber) != true) {
         if (parentSerialNumber && parentGpn) {
           parentInput = {
             'serialNo': parentSerialNumber,
             'gpn': parentGpn
           }
           inputMap.push(parentInput);
         }
       }
       inputMap.push(input);
     })
     updateDeviceOwnership({
       inputData: JSON.stringify(inputMap),
       userLdap: this.techNameValue
     })
     .then(result => {
       if (result) {
         this.findSerials(this.techNameValue);
         this.selectedValueList = [];
       }
     });
   }
 }