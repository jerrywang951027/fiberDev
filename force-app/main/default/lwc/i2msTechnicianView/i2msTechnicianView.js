import { LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UsernameId from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import checkIfLdapExists from '@salesforce/apex/GetWarehouseTechnicianData.checkIfLdapExists';
import getWarehouseData from '@salesforce/apex/GetWarehouseTechnicianData.getWarehouseData';
import acceptDevices from '@salesforce/apex/GetWarehouseTechnicianData.acceptDevices';
import rejectselectedDevices from '@salesforce/apex/GetWarehouseTechnicianData.rejectselectedDevices';
import reportDOA from '@salesforce/apex/GetWarehouseTechnicianData.reportDOA';
import reportLost from '@salesforce/apex/GetWarehouseTechnicianData.reportLost';
import reportSurplus from '@salesforce/apex/GetWarehouseTechnicianData.reportSurplus';
import techTransfer from '@salesforce/apex/GetWarehouseTechnicianData.techTransfer';


export default class i2msTechnicianView extends LightningElement {
   userId = Id;
   PAGE_SIZE = 5;
   @track inboundDeviceList = '';
   @track myDeviceList = '';
   @track outboundDeviceList = '';
   userEmail = '';
   techNameValue = '';
   @track disableAllButtons = false;

   inboundDeviceTableDataToShow = [];
   selectedinboundDeviceTablePageNumber;
   totalinboundDeviceTablePages;
   loadingInboundDevicesData = true;
   showInboundDeviceTable = false;

   myDeviceTableDataToShow = [];
   selectedMyDeviceTablePageNumber;
   totalMyDeviceTablePages;
   loadingMyDevicesData = true;
   showMyDevicesTable = false;

   outboundDeviceTableData = [];
   outboundDeviceTableDataToShow = [];
   selectedoutboundDeviceTablePageNumber;
   totaloutboundDeviceTablePages;
   showOutboundDevicesTable = false;

   showDeviceSuccessAlert = false;
   showDeviceWarningAlert = false;
   successAlertMessage = '';
   warningAlertMessage = '';
   ALERT_TIMEOUT = 5000;

   @track openModal1 = false;
   @track openModal2 = false;

   @wire(getRecord, { recordId: Id, fields: [UsernameId, userEmailFld] })
   userDetails({ error, data }) {
      if (data) {
         this.userEmail = data.fields.Email.value;
         console.log(this.userId + '   ---------   ' + this.userEmail);
         if (this.userEmail != '') {
            this.techNameValue = this.userEmail.replace('@google.com', '');
            this.getInboundDevices();
            this.getMyDevices();
         }
      }
   }

   /*****INBOUND DEVICES*****/
   getInboundDevices() {

      if (this.userEmail == '') {
         return;
      }

      checkIfLdapExists({ userEmail: this.userEmail })
         .then(ldapState => {
            console.log('LDAP State From server :' + ldapState);
            if (!ldapState || ldapState == 'false') {
               this.showWarningAlert('This user is not an assigned Technician.');
               this.loadingInboundDevicesData = false;
               return;
            }

            getWarehouseData({ searchKey: this.techNameValue, inboundMode: true, statusList: ['PRE_ASSIGNED_SPARE', 'PRE_TRANSFER'] })
               .then(result => {
                  this.loadingInboundDevicesData = false;
                  console.log('GETWAREHOUSEDATA - INBOUND DEVICES ' + result);
                  if (result) {
                     let res = JSON.parse(result);
                     this.inboundDeviceList = res;
                     this.populateInboundDevicesTableData();
                  } else {
                     console.log('NOOOOO RSULTS!!')
                  }
               }, err => {
                  console.log(err);
                  this.loadingInboundDevicesData = false;
               });
         });
   }

   populateInboundDevicesTableData() {

      this.showInboundDeviceTable = (this.inboundDeviceList.length > 0);

      /***********inbound DEVICES**********/
      for (var index = 0; index < this.inboundDeviceList.length; index++) {

         var from = this.inboundDeviceList[index].deviceOwnership.currentAttribute.googleLocationCode;
         if (this.inboundDeviceList[index].deviceOwnership.currentAttribute.ownershipStatus == 'PRE_TRANSFER') {
            from = this.inboundDeviceList[index].deviceOwnership.currentAttribute.currentOwner;
         }

         var isRejectable = false;
         if (this.inboundDeviceList[index].deviceOwnership.currentAttribute.transactionType && this.inboundDeviceList[index].deviceOwnership.currentAttribute.transactionType == 'TRANSFER') {
            isRejectable = true;
         }

         this.inboundDeviceList[index].isRejectable = isRejectable;
         this.inboundDeviceList[index].deviceOwnership.currentAttribute.from = from;
         this.inboundDeviceList[index].selected = false;
         this.inboundDeviceList[index].pageNumber = parseInt(index / this.PAGE_SIZE) + 1;
      }

      this.totalinboundDeviceTablePages = this.inboundDeviceList[this.inboundDeviceList.length - 1].pageNumber;
      this.selectedinboundDeviceTablePageNumber = 1;
      this.inboundDeviceTableDataToShow = this.inboundDeviceList.filter(element => element.pageNumber == this.selectedinboundDeviceTablePageNumber);
   }

   updateSelectedDevice(event) {
      let serialNo = event.target.value;
      let isSelected = event.target.checked;
      var elementInteracted = this.inboundDeviceList.find(ele => ele.serialKey.serialNumber == serialNo);
      if (elementInteracted) {
         elementInteracted.selected = isSelected;
      }
   }

   /*Accept Devices*/
   acceptDevices() {

      var selectedInboundDevices = this.getSelectedAndChildDevicesFromList(this.inboundDeviceList);

      if (!selectedInboundDevices || selectedInboundDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to accept");
         return;
      }

      this.disableAllButtons = true;

      var devicesToSend = [];
      for (var i = 0; i < selectedInboundDevices.length; i++) {
         devicesToSend.push({
            serialNumber: selectedInboundDevices[i].serialKey.serialNumber,
            gpn: selectedInboundDevices[i].serialKey.gpn,
            owner: this.techNameValue
         });
      }

      acceptDevices({ devices: devicesToSend })
         .then(result => {
            console.log('Accept Device O/P >> ' + (result));
            this.disableAllButtons = false;
            if (result && result != '' && result != {}) {
               let res = JSON.parse(result);
               console.log('YES RESULTS!!!');
               this.showSuccessAlert(`Devices reported as Accepted`);
               this.getInboundDevices();
               this.getMyDevices();
            } else {
               //   console.log('NOOOOO RSULTS!!')
            }
         }, err => {
            console.log('Accept Error : ' + JSON.stringify(err));
            this.showWarningAlert('An error occurred. Please try after some time.');
            this.disableAllButtons = false;
         });
   }

   /*Reject Devices*/
   rejectDevices() {

      var selectedInboundDevices = this.getSelectedAndChildDevicesFromList(this.inboundDeviceList);

      if (!selectedInboundDevices || selectedInboundDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to reject");
         return;
      }

      if (selectedInboundDevices.some(element => element.isRejectable == false)) {
         this.showWarningAlert("Could not reject device: devices cannot be rejected if pre-assigned (contact the warehouse for assistance)");
         return;
      }

      var devicesToSend = [];
      for (var i = 0; i < selectedInboundDevices.length; i++) {
         devicesToSend.push({
            serialNumber: selectedInboundDevices[i].serialKey.serialNumber,
            gpn: selectedInboundDevices[i].serialKey.gpn,
            owner: selectedInboundDevices[i].deviceOwnership.currentAttribute.from
         });
      }

      this.disableAllButtons = true;

      rejectselectedDevices({ devices: devicesToSend })
         .then(result => {
            console.log('batchUpdate>>' + (result));
            this.disableAllButtons = false;
            if (result && result != '') {
               let res = JSON.parse(result);
               //   console.log('YES RESULTS!!!');
               this.showSuccessAlert(`Devices reported as Rejected`);
               this.getInboundDevices();
               this.getMyDevices();
            } else {
               //   console.log('NOOOOO RSULTS!!')
            }
         }, err => {
            console.log('Reject Error : ' + JSON.stringify(err));
            this.showWarningAlert('An error occurred. Please try after some time.');
            this.disableAllButtons = false;
         });
   }

   /* MY DEVICES */
   getMyDevices() {
      if (this.userEmail == '') {
         return;
      }


      checkIfLdapExists({ userEmail: this.userEmail })
         .then(ldapState => {
            console.log('LDAP State From server :' + ldapState);
            if (!ldapState || ldapState == 'false') {
               this.showWarningAlert('This user is not an assigned Technician.');
               this.loadingMyDevicesData = false;
               return;
            }

            getWarehouseData({ searchKey: this.techNameValue, inboundMode: false, statusList: ['ACKNOWLEDGED', 'DOA_PENDING_RECEIPT', 'SURPLUS_PENDING_RECEIPT', 'RMA_PENDING_RECEIPT', 'LOST_PENDING_RECEIPT', 'PRE_TRANSFER'] })
               .then(result => {
                  this.loadingMyDevicesData = false;
                  if (result) {
                     let res = JSON.parse(result);
                     console.log('YES RESULTS!!!');
                     this.myDeviceList = res;
                     this.populateMyDevicesTableData();
                  } else {
                     console.log('NOOOOO RSULTS!!')
                  }
               }, err => {
                  console.log(err);
                  this.loadingMyDevicesData = false;
               });
         });
   }

   populateMyDevicesTableData() {

      this.showMyDevicesTable = (this.myDeviceList.length > 0);

      for (var index = 0; index < this.myDeviceList.length; index++) {

         this.myDeviceList[index].ticketId = '';
         this.myDeviceList[index].selected = false;
         this.myDeviceList[index].pageNumber = parseInt(index / this.PAGE_SIZE) + 1;
      }

      this.totalMyDeviceTablePages = this.myDeviceList[this.myDeviceList.length - 1].pageNumber;
      this.selectedMyDeviceTablePageNumber = 1;
      this.myDeviceTableDataToShow = this.myDeviceList.filter(element => element.pageNumber == this.selectedMyDeviceTablePageNumber);


      this.outboundDeviceTableData = this.myDeviceList.filter(element => element.deviceOwnership.currentAttribute.ownershipStatus == 'PRE_TRANSFER').map(function (element) {
         return {
            "serialNumber": element.serialKey.serialNumber,
            "gpn": element.serialKey.gpn,
            "description": element.description,
            "status": element.deviceOwnership.currentAttribute.ownershipStatus,
            "to": element.deviceOwnership.currentAttribute.newOwner
         };
      });

      this.showOutboundDevicesTable = (this.outboundDeviceTableData && this.outboundDeviceTableData.length > 0);

      /***********Outbound DEVICES page initiation**********/
      for (var index = 0; index < this.outboundDeviceTableData.length; index++) {
         this.outboundDeviceTableData[index].pageNumber = parseInt(index / this.PAGE_SIZE) + 1;
      }

      this.totaloutboundDeviceTablePages = this.outboundDeviceTableData.length > 0 ? this.outboundDeviceTableData[this.outboundDeviceTableData.length - 1].pageNumber : 0;
      this.selectedoutboundDeviceTablePageNumber = 1;
      this.outboundDeviceTableDataToShow = this.outboundDeviceTableData.filter(element => element.pageNumber == this.selectedoutboundDeviceTablePageNumber);
   }

   /*INBOUND Devices Prev and Next*/
   gotoInboundDeviceTablePreviousPage() {
      if (this.selectedinboundDeviceTablePageNumber == 1) {
         return;
      }

      this.selectedinboundDeviceTablePageNumber--;
      this.inboundDeviceTableDataToShow = this.inboundDeviceList.filter(element => element.pageNumber == this.selectedinboundDeviceTablePageNumber);
   }

   gotoInboundDeviceTableNextPage() {
      if (this.selectedinboundDeviceTablePageNumber == this.totalinboundDeviceTablePages) {
         return;
      }

      this.selectedinboundDeviceTablePageNumber++;
      this.inboundDeviceTableDataToShow = this.inboundDeviceList.filter(element => element.pageNumber == this.selectedinboundDeviceTablePageNumber);
   }

   /*My Devices Prev and Next*/
   gotoMyDeviceTablePreviousPage() {
      if (this.selectedMyDeviceTablePageNumber == 1) {
         return;
      }

      this.selectedMyDeviceTablePageNumber--;
      this.myDeviceTableDataToShow = this.myDeviceList.filter(element => element.pageNumber == this.selectedMyDeviceTablePageNumber);
   }

   gotoMyDeviceTableNextPage() {
      if (this.selectedMyDeviceTablePageNumber == this.totalMyDeviceTablePages) {
         return;
      }

      this.selectedMyDeviceTablePageNumber++;
      this.myDeviceTableDataToShow = this.myDeviceList.filter(element => element.pageNumber == this.selectedMyDeviceTablePageNumber);
   }

   /*Outbound Devices Prev and Next*/
   gotoOutboundDeviceTablePreviousPage() {
      if (this.selectedoutboundDeviceTablePageNumber == 1) {
         return;
      }

      this.selectedoutboundDeviceTablePageNumber--;
      this.outboundDeviceTableDataToShow = this.outboundDeviceTableData.filter(element => element.pageNumber == this.selectedoutboundDeviceTablePageNumber);
   }

   gotoOutboundDeviceTableNextPage() {
      if (this.selectedoutboundDeviceTablePageNumber == this.totaloutboundDeviceTablePages) {
         return;
      }

      this.selectedoutboundDeviceTablePageNumber++;
      this.outboundDeviceTableDataToShow = this.outboundDeviceTableData.filter(element => element.pageNumber == this.selectedoutboundDeviceTablePageNumber);
   }

   updateMySelectedDevice(event) {
      let serialNo = event.target.value;
      let isSelected = event.target.checked;
      var elementInteracted = this.myDeviceList.find(ele => ele.serialKey.serialNumber == serialNo);
      if (elementInteracted) {
         elementInteracted.selected = isSelected;
      }
   }

   //Transfer to Tech
   handleDeviceTransferClick() {

      var selectedMyDevices = this.getSelectedAndChildDevicesFromList(this.myDeviceList);

      if (selectedMyDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to transfer");
         return;
      }

      var techName = this.template.querySelector('input[data-my-id=deviceTechnicianNameInput]').value;
      console.log(techName);

      var devicesToSend = [];
      for (var i = 0; i < selectedMyDevices.length; i++) {
         devicesToSend.push({
            serialNumber: selectedMyDevices[i].serialKey.serialNumber,
            gpn: selectedMyDevices[i].serialKey.gpn,
            owner: selectedMyDevices[i].deviceOwnership.currentAttribute.currentOwner
         });
      }

      this.disableAllButtons = true;

      checkIfLdapExists({ userEmail: techName + '@google.com' })
         .then(ldapState => {
            console.log('LDAP State From server :' + ldapState);
            if (!ldapState || ldapState == 'false') {
               this.showWarningAlert('This user is not an assigned Technician.');
               this.disableAllButtons = false;
               return;
            }

            techTransfer({ devices: devicesToSend, newOwner: techName })
               .then(result => {
                  console.log('Tech Transfer >>' + (result));
                  this.disableAllButtons = false;
                  if (result && result != '') {
                     let res = JSON.parse(result);
                     console.log('YES RESULTS - tech transfer!');
                     this.showSuccessAlert(`Devices is transferred to ${techName}`);

                     // refresh My Devices data table
                     this.getMyDevices();
                     this.getInboundDevices();

                  } else {
                     console.log('NO RESULTS FOUND!')
                  }

               }, err => {
                  console.log('Error : ' + JSON.stringify(err));
                  this.showWarningAlert('An error occurred. Please try after some time.');
                  this.disableAllButtons = false;
               });
         }, err => {
            console.log('Error : ' + JSON.stringify(err));
            this.showWarningAlert('An error occurred. Please try after some time.');
            this.disableAllButtons = false;
         });
   }

   // Modal - 1
   showModal1() {
      console.log('Modal1 Open');
      var selectedMyDevices = this.myDeviceList.filter(ele => ele.selected == true);

      if (selectedMyDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to report");
         return;
      }
      this.openModal1 = true;
      console.log('Modal1:', this.openModal1);
   }
   closeModal1() {
      this.openModal1 = false;
      this.selectedDOALEDStatus = '';
      this.selectedDOAReasonCode = '';
   }

   handleDoaLedStatusChange(event) {
      this.selectedDOALEDStatus = event.detail.value;
   }

   handleReasonCodeChange(event) {
      this.selectedDOAReasonCode = event.detail.value;
   }

   reportDOA_Click() {

      var selectedMyDevices = this.getSelectedAndChildDevicesFromList(this.myDeviceList);

      if (selectedMyDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to report");
         return;
      }

      const doaReasonDescription = this.template.querySelector('lightning-textarea').value;
      console.log(this.selectedDOALEDStatus);
      console.log(this.selectedDOAReasonCode);
      console.log(doaReasonDescription);

      if (this.selectedDOALEDStatus == '' || this.selectedDOAReasonCode == '' || doaReasonDescription == undefined || doaReasonDescription == '') {
         return;
      }

      var devicesToSend = [];
      for (var i = 0; i < selectedMyDevices.length; i++) {
         devicesToSend.push({
            serialNumber: selectedMyDevices[i].serialKey.serialNumber,
            gpn: selectedMyDevices[i].serialKey.gpn,
            owner: this.techNameValue
         });
      }

      reportDOA({ devices: devicesToSend, deviceStatus: this.selectedDOALEDStatus, defectReason: this.selectedDOAReasonCode, comments: doaReasonDescription })
         .then(result => {
            console.log('DOA Output >>' + (result));
            if (result && result != '') {
               let res = JSON.parse(result);
               console.log('YES RESULTS!');
               this.closeModal1();
               this.showSuccessAlert(`Devices reported as DOA by ${this.techNameValue}`);

               // refresh My Devices data table
               this.getMyDevices();

            } else {
               console.log('NO RESULTS FOUND!')
            }
         }, err => {
            console.log('DOA Error : ' + JSON.stringify(err));
            this.showWarningAlert('An error occurred. Please try after some time.');
         });
   }

   /********Modal-2***********/
   showModal2() {

      var selectedMyDevices = this.myDeviceList.filter(ele => ele.selected == true);

      if (selectedMyDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to report");
         return;
      }

      this.openModal2 = true;
   }
   closeModal2() {
      this.openModal2 = false;
   }

   /****************Report Lost****************/
   reportLost_Click(description) {

      var selectedMyDevices = this.getSelectedAndChildDevicesFromList(this.myDeviceList);

      if (selectedMyDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to report");
         return;
      }

      const lostReasonDescription = this.template.querySelector('lightning-textarea').value;
      console.log(lostReasonDescription);

      if (lostReasonDescription == undefined || lostReasonDescription == '') {
         return;
      }

      var devicesToSend = [];
      for (var i = 0; i < selectedMyDevices.length; i++) {
         devicesToSend.push({
            serialNumber: selectedMyDevices[i].serialKey.serialNumber,
            gpn: selectedMyDevices[i].serialKey.gpn,
            owner: this.techNameValue
         });
      }

      reportLost({ devices: devicesToSend, comments: lostReasonDescription })
         .then(result => {
            console.log('Report Lost Output >>' + (result));
            if (result && result != '') {
               let res = JSON.parse(result);
               console.log('YES RESULTS!!!');
               this.closeModal2();
               this.showSuccessAlert(`Devices reported as lost by ${this.techNameValue}`);

               // refresh My Devices data table
               this.getMyDevices();

            } else {
               console.log('NO RESULTS!!')
            }
         }, err => {
            console.log('Report Lost Error : ' + JSON.stringify(err));
            this.showWarningAlert('An error occurred. Please try after some time.');
         });
   }

   /**********Report Surplus**********/
   reportSurplus_Click() {

      var selectedMyDevices = this.getSelectedAndChildDevicesFromList(this.myDeviceList);
      if (selectedMyDevices.length <= 0) {
         this.showWarningAlert("Please mark devices to report");
         return;
      }

      var devicesToSend = [];
      for (var i = 0; i < selectedMyDevices.length; i++) {
         devicesToSend.push({
            serialNumber: selectedMyDevices[i].serialKey.serialNumber,
            gpn: selectedMyDevices[i].serialKey.gpn,
            owner: this.techNameValue
         });
      }

      reportSurplus({ devices: devicesToSend })
         .then(result => {
            console.log('Report Surplus output >>' + (result));
            if (result && result != '') {
               let res = JSON.parse(result);
               console.log('YES RESULTS!!!');
               this.showSuccessAlert(`Devices reported as surplus by ${this.techNameValue}`);

               // refresh My Devices Data
               this.getMyDevices();

            } else {
               console.log('NOOOOO RSULTS!!')
            }
         }, err => {
            console.log('Surplus Error : ' + JSON.stringify(err));
            this.showWarningAlert('An error occurred. Please try after some time.');
         });
   }

   getSelectedAndChildDevicesFromList(deviceList) {

      if (!deviceList || deviceList.length <= 0) {
         return [];
      }

      var selectedList = deviceList.filter(ele => ele.selected == true);

      for (var i = 0; i < selectedList.length; i++) {
         for (var j = 0; j < deviceList.length; j++) {
            if (deviceList[j].parentSerialKey) {
               if (deviceList[j].parentSerialKey.gpn == selectedList[i].serialKey.gpn && deviceList[j].parentSerialKey.serialNumber == selectedList[i].serialKey.serialNumber) {
                  var elementExists = selectedList.find(ele =>
                     ele.serialKey.gpn == deviceList[j].serialKey.gpn &&
                     ele.serialKey.serialNumber == deviceList[j].serialKey.serialNumber
                  );

                  if (!elementExists) {
                     selectedList.push(deviceList[j]);
                  }
               }
            }
         }
      }

      return selectedList;
   }

   /*Alerts*/
   showSuccessAlert(message) {
      if (message == '')
         return;

      this.successAlertMessage = message;
      this.showDeviceSuccessAlert = true;
      this.showDeviceWarningAlert = false;
      setTimeout(() => {
         this.showDeviceSuccessAlert = false;
         this.successAlertMessage = '';
      }, this.ALERT_TIMEOUT);
   }

   showWarningAlert(message) {
      if (message == '')
         return;

      this.warningAlertMessage = message;
      this.showDeviceSuccessAlert = false;
      this.showDeviceWarningAlert = true;
      setTimeout(() => {
         this.showDeviceWarningAlert = false;
         this.warningAlertMessage = '';
      }, this.ALERT_TIMEOUT);
   }

   doaLedStatusList = [
      { label: 'LED - Off', value: 'LED - Off' },
      { label: 'LED - Blinking Red', value: 'LED - Blinking Red' },
      { label: 'LED - Solid Red', value: 'LED - Solid Red' },
      { label: 'LED - Blinking Purple', value: 'LED - Blinking Purple' },
      { label: 'LED - Solid Purple', value: 'LED - Solid Purple' },
      { label: 'LED - Solid Blue', value: 'LED - Solid Blue' },
      { label: 'LED - Slow Blinking Blue', value: 'LED - Slow Blinking Blue' },
      { label: 'LED - Fast Blinking Blue', value: 'LED - Fast Blinking Blue' },
      { label: 'LED - Cycling through multiple colors', value: 'LED - Cycling through multiple colors' },
      { label: 'N/A - Nest Product', value: 'N/A - Nest Product' }
   ];

   doaReasonCodeList = [
      {
         label: "--- select ---",
         value: "--- select ---"
      },
      {
         label: "COMMON - Connectivity::Customer Network::FJ to NB - No, slow, or intermittent connectivity from FJ to NB.",
         value: "COMMON - Connectivity::Customer Network::FJ to NB"
      },
      {
         label: "COMMON - Connectivity::Fiber Network::Provision Failed - no connection to ACS or does not check in",
         value: "COMMON - Connectivity::Fiber Network::Provision Failed"
      },
      {
         label: "COMMON - Damaged::Act of God - Damage from lightning or flood",
         value: "COMMON - Damaged::Act of God"
      },
      {
         label: "COMMON - Damaged::Physically Damaged - physically damaged connectors, cover etc",
         value: "COMMON - Damaged::Physically Damaged"
      },
      {
         label: "COMMON - Device Not Present - device associated with the account is missing / not present",
         value: "COMMON - Device Not Present"
      },
      {
         label: "COMMON - Functioning Device::Accessory Required and No Spares Available - accessory is missing or broken",
         value: "COMMON - Functioning Device::Accessory Required and No Spares Available"
      },
      {
         label: "COMMON - Functioning Device::CPE Compatibility - device is functioning well, but replaced for CPE compatibility",
         value: "COMMON - Functioning Device::CPE Compatibility"
      },
      {
         label: "COMMON - Functioning Device::Discrepancy::Account or Serial Number - device serial number or associated account is wrong",
         value: "COMMON - Functioning Device::Discrepancy::Account or Serial Number"
      },
      {
         label: "COMMON - Functioning Device::Downgraded or Canceled Service - device replaced because customer downgraded or canceled service",
         value: "COMMON - Functioning Device::Downgraded or Canceled Service"
      },
      {
         label: "COMMON - Functioning Device::Installing Trusted Tester - device replaced with a newer generation device",
         value: "COMMON - Functioning Device::Installing Trusted Tester"
      },
      {
         label: "COMMON - Functioning Device::LED Not Working - device is ok, but LED is not on",
         value: "COMMON - Functioning Device::LED Not Working"
      },
      {
         label: "COMMON - Functioning Device::Label or Scan Issue - scanner or label issue",
         value: "COMMON - Functioning Device::Label or Scan Issue"
      },
      {
         label: "COMMON - Functioning Device::Proactive Swap::Failure Indicated by Diagnostics - diagnostics indicate device is not functioning properly",
         value: "COMMON - Functioning Device::Proactive Swap::Failure Indicated by Diagnostics"
      },
      {
         label: "COMMON - Functioning Device::Proactive Swap::Onsite Evaluation - no clear issue or symptom but tech determines swap would be beneficial",
         value: "COMMON - Functioning Device::Proactive Swap::Onsite Evaluation"
      },
      {
         label: "COMMON - Functioning Device::TLC - Tender Loving Care, i.e. customer appeasement.",
         value: "COMMON - Functioning Device::TLC"
      },
      {
         label: "COMMON - Functioning Device::Upgraded Service - replaced because customer upgraded service",
         value: "COMMON - Functioning Device::Upgraded Service"
      },
      {
         label: "COMMON - Infested - bugs or pests or mold or other infestation",
         value: "COMMON - Infested"
      },
      {
         label: "COMMON - Potential Safety::Electrical - electrical safety issue",
         value: "COMMON - Potential Safety::Electrical"
      },
      {
         label: "COMMON - Potential Safety::Other - other safety issue; NOT electrical or thermal",
         value: "COMMON - Potential Safety::Other"
      },
      {
         label: "COMMON - Potential Safety::Thermal - high temperature or thermal safety issue",
         value: "COMMON - Potential Safety::Thermal"
      },
      {
         label: "COMMON - Power::No Power from Adapter - device does not power on even after adapter swap",
         value: "COMMON - Power::No Power from Adapter"
      },
      {
         label: "COMMON - Rebooting - device continuously reboots or resets itself",
         value: "COMMON - Rebooting"
      },
      {
         label: "COMMON - Swap Did Not Fix - Issue was misdiagnosed, no trouble was found, or device swapped by mistake",
         value: "COMMON - Swap Did Not Fix"
      },
      {
         label: "COMMON - TV::Black Screen - no channels displayed, only black screen",
         value: "COMMON - TV::Black Screen"
      },
      {
         label: "COMMON - Test/Training - never given to customer",
         value: "COMMON - Test/Training"
      },
      {
         label: "GFHD100 - Connectivity::Customer Network::WiFi::Low Speed - Slow WiFi but speed is ok when wired.",
         value: "GFHD100 - Connectivity::Customer Network::WiFi::Low Speed"
      },
      {
         label: "GFHD100 - Connectivity::Customer Network::WiFi::No Signal - No or Intermittent WiFi signal, but wired is functioning properly.",
         value: "GFHD100 - Connectivity::Customer Network::WiFi::No Signal"
      },
      {
         label: "GFHD100 - Connectivity::Customer Network::Wired::No Connection - No, Slow or intermittent wired connectivity but WiFi is ok",
         value: "GFHD100 - Connectivity::Customer Network::Wired::No Connection"
      },
      {
         label: "GFHD100 - Fan::Not Functioning / Noisy - fan not running or is noisy",
         value: "GFHD100 - Fan::Not Functioning / Noisy"
      },
      {
         label: "GFHD100 - Remote::Not Pairing - swapping TV Box because remote is not pairing",
         value: "GFHD100 - Remote::Not Pairing"
      },
      {
         label: "GFHD100 - TV::Missing Channels - some channels are missing",
         value: "GFHD100 - TV::Missing Channels"
      },
      {
         label: "GFHD100 - TV::Pixelation - Screen displays the broadcast, but images are pixelated",
         value: "GFHD100 - TV::Pixelation"
      },
      {
         label: "GFHD100 - TV::Stuck::Connecting - TV Box is stuck at boot, connecting, loading, or spinning wheel.",
         value: "GFHD100 - TV::Stuck::Connecting"
      },
      {
         label: "GFHD100 - TV::Stuck::Freezing - Images on the screen are freezing",
         value: "GFHD100 - TV::Stuck::Freezing"
      },
      {
         label: "GFHD100 - TV::Subscription Service - service like Netflix or Vudu not working correctly",
         value: "GFHD100 - TV::Subscription Service"
      },
      {
         label: "GFHD200 - Connectivity::Customer Network::WiFi::Low Speed - Slow WiFi but speed is ok when wired.",
         value: "GFHD200 - Connectivity::Customer Network::WiFi::Low Speed"
      },
      {
         label: "GFHD200 - Connectivity::Customer Network::WiFi::No Signal - No or Intermittent WiFi signal, but wired is functioning properly.",
         value: "GFHD200 - Connectivity::Customer Network::WiFi::No Signal"
      },
      {
         label: "GFHD200 - Connectivity::Customer Network::Wired::No Connection - No, Slow or intermittent wired connectivity but WiFi is ok",
         value: "GFHD200 - Connectivity::Customer Network::Wired::No Connection"
      },
      {
         label: "GFHD200 - Remote::Not Pairing - swapping TV Box because remote is not pairing",
         value: "GFHD200 - Remote::Not Pairing"
      },
      {
         label: "GFHD200 - TV::Missing Channels - some channels are missing",
         value: "GFHD200 - TV::Missing Channels"
      },
      {
         label: "GFHD200 - TV::Pixelation - Screen displays the broadcast, but images are pixelated",
         value: "GFHD200 - TV::Pixelation"
      },
      {
         label: "GFHD200 - TV::Stuck::Connecting - TV Box is stuck at boot, connecting, loading, or spinning wheel.",
         value: "GFHD200 - TV::Stuck::Connecting"
      },
      {
         label: "GFHD200 - TV::Stuck::Freezing - Images on the screen are freezing",
         value: "GFHD200 - TV::Stuck::Freezing"
      },
      {
         label: "GFHD200 - TV::Subscription Service - service like Netflix or Vudu not working correctly",
         value: "GFHD200 - TV::Subscription Service"
      },
      {
         label: "GFLT100 - Connectivity::Fiber Network::Alarms - excessive alarms reported by IST",
         value: "GFLT100 - Connectivity::Fiber Network::Alarms"
      },
      {
         label: "GFLT100 - Connectivity::Fiber Network::No Connectivity - Network provisioned, but No or Intermittent connectivity",
         value: "GFLT100 - Connectivity::Fiber Network::No Connectivity"
      },
      {
         label: "GFLT100 - TV::Pixelation - Screen displays the broadcast, but images are pixelated",
         value: "GFLT100 - TV::Pixelation"
      },
      {
         label: "GFLT110 - Connectivity::Fiber Network::Alarms - excessive alarms reported by IST",
         value: "GFLT110 - Connectivity::Fiber Network::Alarms"
      },
      {
         label: "GFLT110 - Connectivity::Fiber Network::No Connectivity - Network provisioned, but No or Intermittent connectivity",
         value: "GFLT110 - Connectivity::Fiber Network::No Connectivity"
      },
      {
         label: "GFLT110 - Power::No Power from/to POE - device does not provide/receive POE",
         value: "GFLT110 - Power::No Power from/to POE"
      },
      {
         label: "GFLT110 - TV::Pixelation - Screen displays the broadcast, but images are pixelated",
         value: "GFLT110 - TV::Pixelation"
      },
      {
         label: "GFMN100 - Connectivity::Customer Network::Client Device - connectivity issue with non-Fiber device requiring a swap",
         value: "GFMN100 - Connectivity::Customer Network::Client Device"
      },
      {
         label: "GFMN100 - Connectivity::Customer Network::WiFi::Low Speed - Slow WiFi but speed is ok when wired.",
         value: "GFMN100 - Connectivity::Customer Network::WiFi::Low Speed"
      },
      {
         label: "GFMN100 - Connectivity::Customer Network::WiFi::No Signal - No or Intermittent WiFi signal, but wired is functioning properly.",
         value: "GFMN100 - Connectivity::Customer Network::WiFi::No Signal"
      },
      {
         label: "GFMN100 - Connectivity::Customer Network::Wired::No Connection - No, Slow or intermittent wired connectivity but WiFi is ok",
         value: "GFMN100 - Connectivity::Customer Network::Wired::No Connection"
      },
      {
         label: "GFMN100 - Power::No Power from/to POE - device does not provide/receive POE",
         value: "GFMN100 - Power::No Power from/to POE"
      },
      {
         label: "GFMS100 - Fan::Not Functioning / Noisy - fan not running or is noisy",
         value: "GFMS100 - Fan::Not Functioning / Noisy"
      },
      {
         label: "GFMS100 - HDD - defective harddisk drive",
         value: "GFMS100 - HDD"
      },
      {
         label: "GFMS100 - TV::DVR - issue playing recorded show(s)",
         value: "GFMS100 - TV::DVR"
      },
      {
         label: "GFMS100 - TV::No Connection - Includes: bad A/V conn, bad Coax, or HDMI incompatibility",
         value: "GFMS100 - TV::No Connection"
      },
      {
         label: "GFMS100 - TV::Stuck::Connecting - TV Box is stuck at boot, connecting, loading, or spinning wheel.",
         value: "GFMS100 - TV::Stuck::Connecting"
      },
      {
         label: "GFRG100 - Connectivity::Customer Network::Client Device - connectivity issue with non-Fiber device requiring a swap",
         value: "GFRG100 - Connectivity::Customer Network::Client Device"
      },
      {
         label: "GFRG100 - Connectivity::Customer Network::WiFi::Low Speed - Slow WiFi but speed is ok when wired.",
         value: "GFRG100 - Connectivity::Customer Network::WiFi::Low Speed"
      },
      {
         label: "GFRG100 - Connectivity::Customer Network::WiFi::No Signal - No or Intermittent WiFi signal, but wired is functioning properly.",
         value: "GFRG100 - Connectivity::Customer Network::WiFi::No Signal"
      },
      {
         label: "GFRG100 - Connectivity::Customer Network::Wired::No Connection - No, Slow or intermittent wired connectivity but WiFi is ok",
         value: "GFRG100 - Connectivity::Customer Network::Wired::No Connection"
      },
      {
         label: "GFRG100 - Fan::Not Functioning / Noisy - fan not running or is noisy",
         value: "GFRG100 - Fan::Not Functioning / Noisy"
      },
      {
         label: "GFRG100 - TV::No Connection - Includes: bad A/V conn, bad Coax, or HDMI incompatibility",
         value: "GFRG100 - TV::No Connection"
      },
      {
         label: "GFRG100 - TV::Stuck::Connecting - TV Box is stuck at boot, connecting, loading, or spinning wheel.",
         value: "GFRG100 - TV::Stuck::Connecting"
      },
      {
         label: "GFRG110 - Connectivity::Customer Network::Client Device - connectivity issue with non-Fiber device requiring a swap",
         value: "GFRG110 - Connectivity::Customer Network::Client Device"
      },
      {
         label: "GFRG110 - Connectivity::Customer Network::WiFi::Low Speed - Slow WiFi but speed is ok when wired.",
         value: "GFRG110 - Connectivity::Customer Network::WiFi::Low Speed"
      },
      {
         label: "GFRG110 - Connectivity::Customer Network::WiFi::No Signal - No or Intermittent WiFi signal, but wired is functioning properly.",
         value: "GFRG110 - Connectivity::Customer Network::WiFi::No Signal"
      },
      {
         label: "GFRG110 - Connectivity::Customer Network::Wired::No Connection - No, Slow or intermittent wired connectivity but WiFi is ok",
         value: "GFRG110 - Connectivity::Customer Network::Wired::No Connection"
      },
      {
         label: "GFRG110 - Fan::Not Functioning / Noisy - fan not running or is noisy",
         value: "GFRG110 - Fan::Not Functioning / Noisy"
      },
      {
         label: "GFRG110 - TV::No Connection - Includes: bad A/V conn, bad Coax, or HDMI incompatibility",
         value: "GFRG110 - TV::No Connection"
      },
      {
         label: "GFRG110 - TV::Stuck::Connecting - TV Box is stuck at boot, connecting, loading, or spinning wheel.",
         value: "GFRG110 - TV::Stuck::Connecting"
      },
      {
         label: "GFRG200 - Connectivity::Customer Network::Client Device - connectivity issue with non-Fiber device requiring a swap",
         value: "GFRG200 - Connectivity::Customer Network::Client Device"
      },
      {
         label: "GFRG200 - Connectivity::Customer Network::WiFi::Low Speed - Slow WiFi but speed is ok when wired.",
         value: "GFRG200 - Connectivity::Customer Network::WiFi::Low Speed"
      },
      {
         label: "GFRG200 - Connectivity::Customer Network::WiFi::No Signal - No or Intermittent WiFi signal, but wired is functioning properly.",
         value: "GFRG200 - Connectivity::Customer Network::WiFi::No Signal"
      },
      {
         label: "GFRG200 - Connectivity::Customer Network::Wired::No Connection - No, Slow or intermittent wired connectivity but WiFi is ok",
         value: "GFRG200 - Connectivity::Customer Network::Wired::No Connection"
      },
      {
         label: "GFRG200 - Fan::Not Functioning / Noisy - fan not running or is noisy",
         value: "GFRG200 - Fan::Not Functioning / Noisy"
      },
      {
         label: "GFRG200 - Power::No Power from/to POE - device does not provide/receive POE",
         value: "GFRG200 - Power::No Power from/to POE"
      },
      {
         label: "GFRG200 - TV::No Connection - Includes: bad A/V conn, bad Coax, or HDMI incompatibility",
         value: "GFRG200 - TV::No Connection"
      },
      {
         label: "GFRG200 - TV::Stuck::Connecting - TV Box is stuck at boot, connecting, loading, or spinning wheel.",
         value: "GFRG200 - TV::Stuck::Connecting"
      },
      {
         label: "GFRG210 - Connectivity::Customer Network::Client Device - connectivity issue with non-Fiber device requiring a swap",
         value: "GFRG210 - Connectivity::Customer Network::Client Device"
      },
      {
         label: "GFRG210 - Connectivity::Customer Network::WiFi::Low Speed - Slow WiFi but speed is ok when wired.",
         value: "GFRG210 - Connectivity::Customer Network::WiFi::Low Speed"
      },
      {
         label: "GFRG210 - Connectivity::Customer Network::WiFi::No Signal - No or Intermittent WiFi signal, but wired is functioning properly.",
         value: "GFRG210 - Connectivity::Customer Network::WiFi::No Signal"
      },
      {
         label: "GFRG210 - Connectivity::Customer Network::Wired::No Connection - No, Slow or intermittent wired connectivity but WiFi is ok",
         value: "GFRG210 - Connectivity::Customer Network::Wired::No Connection"
      },
      {
         label: "GFRG210 - Fan::Not Functioning / Noisy - fan not running or is noisy",
         value: "GFRG210 - Fan::Not Functioning / Noisy"
      },
      {
         label: "GFRG210 - HDD - defective harddisk drive",
         value: "GFRG210 - HDD"
      },
      {
         label: "GFRG210 - Power::No Power from/to POE - device does not provide/receive POE",
         value: "GFRG210 - Power::No Power from/to POE"
      },
      {
         label: "GFRG210 - TV::DVR - issue playing recorded show(s)",
         value: "GFRG210 - TV::DVR"
      },
      {
         label: "GFRG210 - TV::No Connection - Includes: bad A/V conn, bad Coax, or HDMI incompatibility",
         value: "GFRG210 - TV::No Connection"
      },
      {
         label: "GFRG210 - TV::Stuck::Connecting - TV Box is stuck at boot, connecting, loading, or spinning wheel.",
         value: "GFRG210 - TV::Stuck::Connecting"
      },
      {
         label: "GOOGLE_WIFI_1 - Warranty::Returned - CUSTOMER PURCHASED, UNDER WARRANTY FOR REPLACEMENT",
         value: "GOOGLE_WIFI_1 - Warranty::Returned"
      }
   ];

}