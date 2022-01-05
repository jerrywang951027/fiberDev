/**
 * @group ResolveLostPendingReceipt
 * @description To call ResolveLostPendingReceipt components operations.
 */
 import {LightningElement, track, api} from 'lwc';
 import checkIfLdapExists from '@salesforce/apex/I2msTechnicianController.checkIfLdapExists';
 import confirmLost from '@salesforce/apex/I2msTechnicianController.confirmLost';
 import extractJsonData from '@salesforce/apex/I2msTechnicianController.extractJsonData';
 export default class ResolveLostPendingReceipt extends LightningElement {
 
   @api warehouse;
   
   @track jsonList;
   @track selectedValueList = [];
 
   searchKeyInput;
   techNameValue;
   enteredTechName;
   isNoRecord = true;
   checked = false;
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
   /**
    * @description Method for calling FindSerial API to get PreAssigned devices
    */
   findSerials(techName) {
     extractJsonData({
       searchKey: techName,
       status: 'LOST_PENDING_RECEIPT'
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
    * making call to api for confirm lost devices
    */
   handleConfirmLost() {
     this.template.querySelector('input').value = null;
     let inputMap = [];
     let childIndex, childSerialNo, childGpn, index, gpn, childInput, input, locationCode;
     let parentSerialNo, parentIndex, parentGpn, parentInput, parentJson, parentLocationCode;
     this.selectedValueList.forEach(serialNo => {
       index = (this.jsonList.findIndex(node =>
           node.deviceOwnership.serialKey.serialNumber == serialNo));
           gpn = this.jsonList[index].deviceOwnership.serialKey.gpn;
           locationCode = this.jsonList[index].deviceOwnership.currentAttribute.googleLocationCode;
           childIndex = (this.jsonList.findIndex(node =>
           node.parentSerialKey.serialNumber == serialNo));
       if (childIndex >= 0) {
         childSerialNo = this.jsonList[childIndex].deviceOwnership.serialKey.serialNumber;
         childGpn = this.jsonList[childIndex].deviceOwnership.serialKey.gpn;
       }
       if (this.jsonList[index].parentSerialKey.serialNumber) {
         parentSerialNo = this.jsonList[index].parentSerialKey.serialNumber;
         parentIndex = (this.jsonList.findIndex(node =>
             node.deviceOwnership.serialKey.serialNumber == parentSerialNo));
         if (parentIndex >= 0) {
           parentJson=this.jsonList[parentIndex];
           parentGpn = parentJson.deviceOwnership.serialKey.gpn;
           parentLocationCode = parentJson.deviceOwnership.currentAttribute.googleLocationCode;
         }
       }
       input = {
         'serialNo': serialNo,
         'gpn': gpn,
         'locationCode': locationCode
       }
       if (this.selectedValueList.includes(childSerialNo) != true) {
         if (childSerialNo && childGpn) {
           childInput = {
             'serialNo': childSerialNo,
             'gpn': childGpn,
             'locationCode': locationCode
           }
           inputMap.push(childInput);
         }
       }
       if (this.selectedValueList.includes(parentSerialNo) != true) {
         if (parentSerialNo && parentGpn) {
           parentInput = {
             'serialNo': parentSerialNo,
             'gpn': parentGpn,
             'parentLocationCode': parentLocationCode
           }
           inputMap.push(parentInput);
         }
       }
       inputMap.push(input);
     })
     confirmLost({
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