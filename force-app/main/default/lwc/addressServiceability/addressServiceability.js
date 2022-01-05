/**
 * @group Address Serviceability
 * @description To perform Address verify whether Address is servicable or not,
 * also To check customer details based on search functionality.
 */
import { api, LightningElement, track } from 'lwc';
import { getDataHandler } from 'vlocity_cmt/utility';
import { NavigationMixin } from 'lightning/navigation';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

// Importing pubsub
import pubsub from 'vlocity_cmt/pubsub';
// Declaring and Initializing constants

const COLUMNS = [
  {
    label: 'Location Serviceability',
    fieldName: 'serviceability',
    type: 'text'
  },
  {
    label: 'Location Eligibility',
    fieldName: 'eligibility',
    type: 'text'
  },
  {
    label: 'Location Ineligibility Reason',
    fieldName: 'ineligibleReason',
    type: 'text'
  },
  {
    label: 'Address Equipment State',
    fieldName: 'addressEquipmentState',
    type: 'text'
  }
];

const ACCOUNT_COLUMNS = [
  {
    label: 'Account Name',
    fieldName: 'AccountName',
    type: 'text'
  },
  {
    label: 'Status',
    fieldName: 'Status',
    type: 'text'
  },
  {
    label: 'Contact Name',
    fieldName: 'ContactName',
    type: 'text'
  },
  {
    label: 'Phone Number',
    fieldName: 'PhoneNumber',
    type: 'text'
  },
  {
    label: 'Email',
    fieldName: 'Email',
    type: 'text'
  }
];

const LEAD_COLUMNS = [
  {
    label: 'Lead Name',
    fieldName: 'LeadName',
    type: 'text'
  },
  {
    label: 'Phone Number',
    fieldName: 'PhoneNumber',
    type: 'text'
  },
  {
    label: 'Email',
    fieldName: 'Email',
    type: 'text'
  },
  {
    label: 'Status',
    fieldName: 'Status',
    type: 'text'
  },
  {
    label: 'Sub Status',
    fieldName: 'SubStatus',
    type: 'text'
  }
];

const PREMISES_COLUMNS = [
  {
    label: 'Premises Name',
    fieldName: 'PremisesName',
    type: 'text'
  },
  {
    label: 'Address',
    fieldName: 'Address',
    type: 'text'
  },
  {
    label: 'Address Type',
    fieldName: 'AddressType',
    type: 'text'
  },
  {
    label: 'Eligibility',
    fieldName: 'Eligibility',
    type: 'text'
  },
  {
    label: 'Ineligible Reason',
    fieldName: 'IneligibleReason',
    type: 'text'
  }
];

export default class AddressServiceabilityLWC extends
    OmniscriptBaseMixin(NavigationMixin(LightningElement)) {

  // TODO (b/193033539) To set properties based on variable used(data binding)
  // Declaring and Initializing Decorators
  _isTechnician;
  @api fromFlow;
  @api nextstep;

  @track data = [];
  @track historyEventId
  @track searchColumns = [];
  @track searchResponseView = [];
  @track selectedRow = [];
  @track suggestions = [];

  @track fromFlowFooter = '';
  @track searchInputData = '';
  @track searchType = '';
  @track searchResults = '';

  @track actualAccountCheckboxLabel = 'Create a new Lead if this Account is not related to the ' +
      'customer you are speaking to.';
  @track leadCheckboxLabel = 'Create a new Lead if this lead is not related to the ' +
      'customer you are speaking to.';
  @track noAddressIdRadioLabel = 'It was not possible to find additional information about the ' +
      'requested address. Please select one of the options to proceed.';
  @track nonServiceableRadioLabel = 'The selected address is not serviceable. ' +
      'Please select one of the below option to proceed.';

  @track columns = COLUMNS;
  @track inputAddress;
  @track inputAddressField;
  @track selectLength = 0;

  // SmartyStreet and Address Service API
  @track isLoader = false;
  @track isNoAddressId = false;
  @track isSearchResponse = false;
  @track isServerError = false;
  @track isSpinnerLoaded = false;
  @track isSuggestions = false;
  @track isSmartyResponse = false;
  @track notServiceable = false;

  // Input Search text Check
  @track isEmptySearchText = false; //shows error when next is clicked without entering search text
  @track isNoMatchFoundError = false; //flag when address entered is not avaiable from smartystreet
  @track searchMessage = false; //flag to check record exist message after click on search button
  // Address Details informantion

  @track isAccountActive = true;
  @track isAccountEnable = false;
  @track isLeadEnable = false;
  @track isNewLead = false;
  @track isNotSearchClick = false;
  @track isPremisesEnable = false;
  @track isRecordAvailable = false;
  @track isShowDetails = false;
  @track navigateToRecord = false;
  @track recordSelection = false;
  @track recordSelectionFlag = false;
  @track showSearchButton = false;
  @track showSearchFlag = false;
  noAddressIdValue = "";
  notServiceableValue = "";

  @api
  set isTechnician(data) {
    if (data) {
    this._isTechnician = data;
    }
  } get isTechnician() {
    return this._isTechnician;
  }
  /**
   * @description Choice set options for no Address Id returned from server(Address Service API).
   */
  get noAddressIdOptions() {
    return [
      {
        label: "Create new lead with unverified address and enter the customer's information.",
        value: 'NoAddressId'
      },
      {
        label: 'The customer does not want to proceed.',
        value: 'NotIntrested'
      }
    ];
  }

  /**
   * @description Choice set options for non-serviceable Address.
   */
  get notServiceableOptions() {
    return [
      {
        label: "Enter customer's information to log their interest in Google Fiber Service.",
        value: 'FutureInterested'
      },
      {
        label: "Address should be validated with address wizard because it should be serviceable.",
        value: 'SuspectServiceable'
      },
      {
        label: 'The customer does not want to proceed.',
        value: 'NotInterested'
      }
    ];
  }

  /**
  * @description On Load changes connacted callback.
  */
  connectedCallback() {
    if (this.omniJsonData && this.omniJsonData.addressInfoResponse &&
        this.omniJsonData.addressInfoResponse.street &&
        this.omniJsonData.addressInfoResponse.city &&
        this.omniJsonData.addressInfoResponse.state &&
        this.omniJsonData.addressInfoResponse.zip5) {
      this.inputAddress = this.omniJsonData.addressInfoResponse.street + ' ' +
          (this.omniJsonData.addressInfoResponse.unitNumber ?
          this.omniJsonData.addressInfoResponse.unitNumber + ' ' : '') +
          this.omniJsonData.addressInfoResponse.city + ', ' +
          this.omniJsonData.addressInfoResponse.state + ' ' +
          this.omniJsonData.addressInfoResponse.zip5;
      /*if (this.omniJsonData.addressInfoResponse.serviceability === 'SERVICEABLE') {
        this.searchInputData = this.omniJsonData.addressInfoResponse.addressId;
        this.searchType ='addressId';
        this.getAddressDetails();
      } else */if (this.omniJsonData.addressInfoResponse.serviceability === 'NON_SERVICEABLE') {
		  this.searchInputData = this.omniJsonData.addressInfoResponse.addressId;
        this.notServiceable = true;
        this.searchType ='addressId';
        this.getAddressDetails();
      } else if (!this.omniJsonData.addressInfoResponse.addressId) {
        this.isNoAddressId = true;
      } else {
        this.searchInputData = this.omniJsonData.addressInfoResponse.addressId;
        this.searchType ='addressId';
        this.getAddressDetails();
      }
    } else if (this.omniJsonData && this.omniJsonData.ContextId) {
      this.historyEventId = this.omniJsonData.ContextId;
      let requestObject = {};
      requestObject.historyEventId = this.omniJsonData.ContextId;
      let params = {
        input: JSON.stringify(requestObject),
        sClassName: 'vlocity_cmt.IntegrationProcedureService',
        sMethodName: 'TCK_ExtractHistoryEventDetails',
        options: '{}'
      };

      this.omniRemoteCall(params, true).then(response => {
        let responseData = {};
        responseData.target = {};
        responseData.target.value = '';
        if (response.result && response.result.IPResult &&
            (response.result.IPResult.email || response.result.IPResult.phone)) {
          this.inputAddress = response.result.IPResult.phone ?
              response.result.IPResult.phone : response.result.IPResult.email ;
          this.showSearchButton = true;
          this.isSearchError = false;
        }
        responseData.target.value = this.inputAddress ? this.inputAddress : '';
        this.handleChange(responseData);
      });
    }
  }

  /**
   * @description Handle Search of address to call SmartyStreet API and to search customer details.
   * @param event Fired event data(Search Text)
   */
  handleChange(event) {
    let addressIdPattern = /\S+-\S+/;
    let emailPattern = /\S+@\S+\.\S+/;
    let namePattern = /^[^\s]+\s[^\s]+$/i;
    let phonePattern = /^[0-9]{10}$/;
    let serialNumberPattern = /(^[a-zA-Z0-9]*\w{5})+$/i;
    let ticketPattern = /^[0-9]{9}$/;

    this.isEmptySearchText = false;
    this.isNoAddressId = false;
    this.isNotSearchClick = true;
    this.isSearchError = false;
    this.isSearchResponse = false;
    this.isShowDetails = false;
    this.isSuggestions = false;
    this.navigateToRecord = false;
    this.notServiceable = false;
    this.radioSelectionValue = '';
    this.recordSelection = false;
    this.recordSelectionFlag = false;
    this.searchColumns = [];
    this.searchMessage = false;
    this.searchResponseView = [];
    this.showSearchButton = true;
    this.showSearchFlag = false;

    this.searchInputData = event.target.value ? event.target.value : '';

    if (event.target.value === '') {
      this.searchType = '';
      this.isSmartyResponse = false;
      this.showSearchButton = false;
      this.isNotSearchClick = false;
    }
    else if (event.target.value.match(phonePattern)) {
      this.searchType = 'phone';
    }
    else if (event.target.value.match(ticketPattern)) {
      this.searchType = 'ticket';
    }
    else if (event.target.value.match(emailPattern)) {
      this.searchType = 'email';
    }
    else if (event.target.value.match(addressIdPattern)) {
      this.searchType = 'addressId';
    }
    else if (event.target.value.match(namePattern)) {
      this.callToSmartyStreet(event.target.value, '');
      this.searchType = 'name';
    }
    else if (event.target.value.match(serialNumberPattern) &&
        (event.target.value.match(namePattern) || []).length === 0) {
      this.searchType = 'serialNumber';
    }
    else {
      this.callToSmartyStreet(event.target.value, '');
      this.searchType = 'address';
      this.showSearchButton = false;
    }
  }

  /**
   * @description To verify and fetch customer details(Lead, Account, and Premises record).
   * @param event Fired event data(Customer Details)
   */
  getAddressDetails(event) {
    this.searchResponseView = [];
    this.searchColumns = [];
    this.isSearchResponse = false;
    this.searchMessage = false;
    this.isSearchError = false;
    this.isNotSearchClick = false;
    this.showSearchFlag = false;
    //this.notServiceable = false;
    this.isNoAddressId = false;
    this.recordSelection = false;
    this.recordSelectionFlag = false;
    this.navigateToRecord = false;
    this.radioSelectionValue = '';

    let searchIn = (this.selectedAddressId) ? this.selectedAddressId : this.searchInputData;
    let params = {
      input: {},
      sClassName: 'SearchController',
      sMethodName: '',
      options: '{}'
    };

    if (this.searchInputData) {
      let inputObject = {};
      if (this.searchType === 'phone') {
        inputObject = {
          phoneNumber: this.searchInputData,
          emailAddress: null,
          ticketNumber: null
        };
      }
      else if (this.searchType === 'email') {
        inputObject = {
          phoneNumber: null,
          emailAddress: this.searchInputData,
          ticketNumber: null
        };
      }
      else if (this.searchType === 'ticket') {
        inputObject = {
          phoneNumber: null,
          emailAddress: null,
          ticketNumber: this.searchInputData
        };
      }
      else if (this.searchType === 'addressId') {
        inputObject = {
          addressId: this.searchInputData
        };
      }
      else if (this.searchType === 'name') {
        inputObject = {
          inputName: this.searchInputData
        };
      }
      else if (this.searchType === 'serialNumber') {
        inputObject = {
          inputSerialNumber: this.searchInputData
        };
      } else {
        inputObject = {
          addressId: this.selectedAddressId
        };
      }

      this.inputMap = JSON.stringify(inputObject);
      params.input = this.inputMap;

      if (this.searchType === 'phone' || this.searchType === 'email' ||
          this.searchType === 'ticket') {
        params.sMethodName = 'getCustomerDetails';
        this.callToRemoteMethod(params);
      } else if (this.searchType === 'name') {
        params.sMethodName = 'getCustomerDetailsByName';
        this.callToRemoteMethod(params);
      } else if (this.searchType === 'serialNumber') {
        params.sMethodName = 'getCustomerDetailsBySerialNumber';
        this.callToRemoteMethod(params);
      } else {
        params.sMethodName = 'getCustomerDetailsByAddressId';
        this.callToRemoteMethod(params);
      }
    } else {
      let inputObject = {};
      inputObject = {
        addressId: this.selectedAddressId
      };
      this.inputMap = JSON.stringify(inputObject);
      params.input = this.inputMap;
      params.sMethodName = 'getCustomerDetailsByAddressId';
      this.callToRemoteMethod(params);
    }
  }

  /**
   * @description Generic method to call omniRemoteCall method.
   * @param params to pass in omniRemoteCall method.
   */
  callToRemoteMethod(params) {
    this.omniRemoteCall(params, true).then(response => {
      let result = (typeof response.result.details === 'string') ?
          JSON.parse(response.result.details) : response.result.details;
      this.onResponseSuccess(result);
      this.isNoMatchFoundError = false;
      if (params.sMethodName === 'getCustomerDetailsByAddressId') {
        this.searchMessage = (result.premisesList.length > 0) ? false : true;
        this.isAccountCorrect = (result.contactList.length > 0 && (this.searchType === 'address' || this.searchType === 'addressId'))
            ? true : false;
        this.isLeadCorrect = (this.isAccountCorrect === false &&
            result.leadList.length > 0 && (this.searchType === 'address' || this.searchType === 'addressId'))
            ? true : false;
        console.log('this.isAccountCorrect::'+this.isAccountCorrect+'this.isLeadCorrect:::'+this.isLeadCorrect);
      }
    }).catch (error => {
      this.searchMessage = false;
    });
  }

  /**
  * @description To handle mapping of Server data with the data table in UI.
  * @param response Fired on Search criteria with AddressId, Phone, Email and Address
  * @return null
  */
  onResponseSuccess(response) {
    try {
      this.responseLeadView = [];
      this.responseAccountView = [];
      this.responsePremisesView = [];
      this.isSearchResponse = true;
      this.isAccountEnable = false;
      this.isLeadEnable = false;
      this.isPremisesEnable = false;
      this.premisesColumns = [];
      this.leadColumns = [];
      this.accountColumns = [];
      if (response && ((response.contactList && response.contactList.length > 0) ||
          (response.premisesList && response.premisesList.length > 0) ||
          (response.leadList && response.leadList.length > 0))) {
		  this.notServiceable = false;
        // Contact and Account details WRT search text.
        if (response.contactList && Array.isArray(response.contactList)
            && response.contactList.length > 0) {
          response.contactList.forEach(record => {
            let recordObject = {};
            recordObject.AccountName = record.Account.Name;
            recordObject.recordId = record.AccountId;
            recordObject.Status = record.Account.vlocity_cmt__Status__c;
            this.isAccountActive = (record.Account.vlocity_cmt__Status__c == 'Active' ||
                record.Account.vlocity_cmt__Status__c == 'Pending') ? true : false;
            /*if (record.Account.vlocity_cmt__Status__c != 'Active' ||
                record.Account.vlocity_cmt__Status__c != 'Pending') {
               this.isAccountActive = false;
             }*/
            recordObject.ContactName = record.Name;
            recordObject.PhoneNumber = record.Phone;
            recordObject.Email = record.Email;
            if (this.accountColumns.length === 0) {
              this.accountColumns = ACCOUNT_COLUMNS;
            }
            this.responseAccountView.push(recordObject);
            this.isSearchResponse = true;
            this.isAccountEnable = true;
          });
        }
        // Premises details WRT search text
        if (response.premisesList && Array.isArray(response.premisesList)
            && response.premisesList.length > 0) {
          let recordObject = {};
          response.premisesList.forEach(record => {
            recordObject.PremisesName = record.Name;
            recordObject.recordId = record.Id;
            recordObject.Address = (record.vlocity_cmt__StreetAddress__c + ', ' +
              record.vlocity_cmt__City__c + ', ' +
              record.vlocity_cmt__State__c + ', ' +
              record.vlocity_cmt__PostalCode__c + ', ' +
              record.vlocity_cmt__Country__c);
            recordObject.Eligibility = record.Eligibility__c;
            recordObject.IneligibleReason = record.Ineligibility_Reason__c;
            recordObject.AddressType = 'SINGLE FAMILY UNIT';
            if (this.premisesColumns.length === 0) {
              this.premisesColumns = PREMISES_COLUMNS;
            }
            this.responsePremisesView.push(recordObject);
            this.isSearchResponse = true;
            this.isPremisesEnable = true;
          });
          this.omniApplyCallResp({
            'existingPremisesRecord': response.premisesList[0]
          });
        }
        // Lead details based on search text
        if (response.leadList && Array.isArray(response.leadList) &&
            response.leadList.length > 0) {
          response.leadList.forEach(record => {
            let recordObject = {};
            recordObject.LeadName = record.Name;
            recordObject.recordId = record.Id;
            recordObject.PhoneNumber = record.Phone;
            recordObject.Email = record.Email;
            recordObject.Status = record.Status;
            recordObject.SubStatus = record.Sub_Status__c;
            if (this.leadColumns.length === 0) {
              this.leadColumns = LEAD_COLUMNS;
            }
            this.responseLeadView.push(recordObject);
            this.isSearchResponse = true;
            this.isLeadEnable = true;
          });
        }
        this.isRecordAvailable = true;
      } else {
        (this.searchType === 'address') ? this.searchMessage = true : this.isSearchError = true;
      }
    } catch (error) {
      this.isNoMatchFoundError = true;
    }
  }

  /**
  * @description To handle Visiblity of the selection record in UI
  * @param event Fired event data
  * @return null
  */
  onCheckboxChange(event) {
    if (event.target.checked) {
      this.isNewLead = true;
      this.isLeadEnable = false;
      this.isPremisesEnable = false;
      this.isAccountEnable = false;
      this.isNotSearchClick = false;
      this.recordSelection = true;
      this.recordSelectionFlag = false;
      this.navigateToRecord = false;
      this.omniApplyCallResp({
        'isNewLead': 'Yes',
        'isAccountActive': this.isAccountActive
      });
    } else {
      this.isNewLead = false;
      this.isLeadEnable = true;
      this.isPremisesEnable = true;
      this.isAccountEnable = true;
      this.isNotSearchClick = false;
      this.recordSelection = false;
      this.recordSelectionFlag = false;
      this.navigateToRecord = false;
      this.omniApplyCallResp({
        'isNewLead': 'No'
      });
    }
  }

  /**
  * @description To handle Visiblity of the selection record in UI
  * @param event Fired event data
  */
  onSelectRecord(event) {
    this.isNotSearchClick = false;
    this.selectedRow = event.detail.selectedRows;
    this.recordIdPassed = event.detail.selectedRows[0].recordId;
    this.navigateToRecord = true;
    this.recordSelection = true;
    this.recordSelectionFlag = false;
    this.isLeadEnable = true;
    this.isPremisesEnable = true;
    this.isAccountEnable = true;
    event.detail.selectedRows.forEach(record => {
      let recordObject = {};
      if ('AccountName' in record) {
        this.isLeadEnable = false;
        this.isPremisesEnable = false;
      }
      else if ('PremisesName' in record) {
        this.isAccountEnable = false;
        this.isLeadEnable = false;
      }
      else {
        this.isAccountEnable = false;
        this.isPremisesEnable = false;
      }
    });
  };

  /**
  * @description To handle Navigation based on record selection.
  * @param recordId To navigate to the particular record based on this Id.
  * @return null
  */
  navigateToRecordPage(recordId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: 'view'
      }
    });
  }

  /**
  * @description To call getCalloutSmartyStreet from SmartyStreet API
  * and pass searchKey as a parameter to get list of addresses
  * @params Street Input to fetch the actual address.
  * @params selected Input to fetch the actual address with entries information.
  * @return null
  */
  callToSmartyStreet(searchKey, entries) {
    this.suggestions = [];
    this.data = [];
    this.isNoMatchFoundError = false;
    this.isServerError = false;
    this.searchResults = '';
    this.isLoader = true;
    this.isSmartyResponse = false;
    // to call server side method to fire SmartyStreet API
    let smartyStreetData = {
      street: encodeURIComponent(searchKey),
      selected: encodeURIComponent(entries)
    }
    this.inputMap = JSON.stringify(smartyStreetData);
    var params = {
      input: this.inputMap,
      sClassName: 'AddressServiceCallout',
      sMethodName: 'getCalloutSmartyStreet',
      options: '{}',
    };

    this.omniRemoteCall(params, true).then(response => {
      if (response) {
        let result = (typeof response.result.addressList === 'string')
          ? JSON.parse(response.result.addressList) : response.result.addressList;
        let _this = this;
        _this.isLoader = false;
        _this.suggestions = [];
        if (Object.keys(result).length !== 0 && result.suggestions) {
          this.isSuggestions = true;
          this.searchResults = result.suggestions;
          result.suggestions.forEach(element => {
            setTimeout(function () {
              _this.suggestions.push(_this.changeAddressFormat(element));
            }, 100);
          });
        } else {
          this.isSuggestions = true;
          this.isNoMatchFoundError = true;
        }
      }
    }).catch(error => {
      this.isLoader = false;
      this.isServerError = (Object.keys(error).length === 0 && this.searchType === 'address') ?
        true : false;
    });
  }

  /**
   * @description To populate selected address in the text field and call loadAddressDetails method
   * to format the address as response of Address service API.
   * @param event Fired event data
   * @return null
   */
  selectAddress(event) {
    this.searchType = 'address';
    event.preventDefault();
    let index = event.target.dataset.index;
    this.inputAddress = this.suggestions[index].suggestion;
    this.template.querySelector('.input-address').value = this.inputAddress;
    this.isSuggestions = false;
    this.loadAddressDetails(this.searchResults[index]);
  }

  /**
  * @description To populate the entries(units in Apt.) from Smartystreets API response.
  * @param event Fired event data
  */
  selectEntries(event) {
    event.preventDefault();
    // Index value to see multiple entries which was causing error on selecting the address
    let index = event.currentTarget.dataset.index;
    this.inputAddress =
      this.searchResults[index].street_line + ' ' + this.searchResults[index].secondary;
    let selectedAddr =
        this.inputAddress + ' (' + this.searchResults[index].entries + ') ' +
        this.searchResults[index].city + ' ' +
        this.searchResults[index].state + ' ' + this.searchResults[index].zipcode;
    this.callToSmartyStreet(this.inputAddress, selectedAddr);
  }

  /**
  * @description To format the selected address which needs to be pass to callToGetAddressInfo
  * method. Response format to get addressId from Address service API.
  * @param event Fired event data
  */
  loadAddressDetails(selectedAddr) {
    let updatedAddrObj = {};
    let keysMap = {
      street_line: 'street',
      secondary: 'unitNumber',
      zipcode: 'zip5'
    }
    let updatedAddr = this.renameObjKeys(keysMap, selectedAddr);
    delete updatedAddr.entries;
    updatedAddrObj.search_criteria = updatedAddr;
    this.callToGetAddressInfo(updatedAddrObj);
  }

  /**
  * @description To call apex class method callToGetAddressInfo and
  * pass addrObj as a parameter to get address details
  * @param event Fired event data
  */
  callToGetAddressInfo(addrObj) {
    this.isSmartyResponse = true;
    this.isLoader = true;

    let addressInfoData = {
      smartyStreet: JSON.stringify(addrObj)
    }
    this.inputMap = JSON.stringify(addressInfoData);
    var params = {
      input: this.inputMap,
      sClassName: 'AddressServiceCallout',
      sMethodName: 'getAddressInfo',
      options: '{}',
    };

    this.omniRemoteCall(params, true).then(response => {
      let result = (typeof response.result.serviceAddressData === 'string') ?
          JSON.parse(response.result.serviceAddressData) : response.result.serviceAddressData;
      this.selectedAddressId = result.addressId;
      this.omniApplyCallResp({
        'addressInfoResponse': result
      });
      //Fix for defect : 199062191 : Wrong address getting populated on customer information capture screen
      if (this.omniJsonData &&
        this.omniJsonData.CustomerInformation &&
        this.omniJsonData.CustomerInformation.AddressInformationBlock &&
        this.omniJsonData.CustomerInformation.AddressInformationBlock.streetValue &&
        this.omniJsonData.CustomerInformation.AddressInformationBlock.zipcode &&
        this.omniJsonData.CustomerInformation.AddressInformationBlock.cityValue &&
        this.omniJsonData.CustomerInformation.AddressInformationBlock.stateValue) {
        this.omniApplyCallResp({
          'CustomerInformation': {
            'AddressInformationBlock': {
              'streetValue': result.street,
              'cityValue': result.city,
              'stateValue': result.state,
              'zipcode': result.zip5
            }
          }
        });
      }

      if (result.addressId) {
        this.isNoAddressId = false;
        this.showSearchButton = true;
      } else {
        this.isNoAddressId = true;
      }
      if (result.addressId && result.serviceability !== "SERVICEABLE") {
        this.notServiceable = true;
        this.showSearchButton = (result.serviceability == 'NON_SERVICEABLE') ? true:false;
        this.showSearchFlag = (result.serviceability == 'NON_SERVICEABLE') ? false:true;
      } else {
        this.isNotSearchClick = true;
        this.notServiceable = false;
      }
      this.data.push(result);
      this.isShowDetails = true;
      this.isLoader = false;
      if (this.fromFlow) {
        this.callToPubsub(result);
      }
    }).catch (error => {
      if (this.fromFlow) {
        this.callToPubsub(error);
      }
      if (result.addressId) {
        this.isNoAddressId = false;
      } else {
        this.isNoAddressId = true;
      }
      this.isLoader = false;
    });
  }

  /**
  * @description To capture radio option selection.
  * @param event Fired event data
  */
  onRadioSelection(event) {
    this.recordSelection = true;
    this.recordSelectionFlag = false;
    this.radioSelectionValue = event.target.value;

    this.omniApplyCallResp({
      'radioSelection': event.target.value
    });
  }

  /**
  * @description To rename object keys based on keysMap
  * @param event Fired event data
  */
  renameObjKeys(keysMap, obj) {
    return Object.keys(obj).reduce(
      (acc, key) => ({
        ...acc,
        ...{
          [keysMap[key] || key]: obj[key]
        }
      }), {}
    );
  }

  /**
  * @description To build the complete address as a string from different address
  * components (city, state, zipcode, etc)
  * @param suggestion Response of SmartyStreet API
  */
  changeAddressFormat(suggestion) {
    let addrObj = {};
    let updatedSuggestion = '';
    if (suggestion.entries > 1) {
      addrObj.isEntries = true;
    } else {
      addrObj.isEntries = false;
    }
    if (suggestion.secondary) {
      if (suggestion.entries > 1) {
        updatedSuggestion = " " + suggestion.secondary + " (" + suggestion.entries + " entries)";
      } else if (suggestion.entries === 1) {
        updatedSuggestion = " " + suggestion.secondary;
      }
    }
    addrObj.suggestion =
      suggestion.street_line + updatedSuggestion + " " + suggestion.city + ", " +
      suggestion.state + " " + suggestion.zipcode;
    return addrObj;
  }

  /**
  * @description To handle the next button/screen of the flow.
  */
  handleNext(event) {
    let selectedRow = this.selectedRow[0];
    if (this.navigateToRecord) {
      if (this.historyEventId) {
        this.associateHistoryEvent();
      } else {
        this.navigateToRecordPage(selectedRow.recordId);
      }
    } else if (this.isNoAddressId === false && this.showSearchButton && this.isNotSearchClick) {
      this.showSearchFlag = true;
    } else if (this.isNoAddressId || this.notServiceable) {
      if (this.radioSelectionValue && this.radioSelectionValue !== 'NotInterested') {
        this.inputAddressField = {
          "addressPassedToCustomFooter": this.inputAddress
        }
        this.callToPubsub(this.inputAddressField);
        this.omniNextStep();

        this.isEmptySearchText = false;
      } else {
        this.recordSelectionFlag = true;
      }
    } else if (this.recordSelection === false && this.isRecordAvailable) {
      this.recordSelectionFlag = true;
      this.isEmptySearchText = false;
    } else if (this.inputAddress == undefined) {
      this.isEmptySearchText = true;
    } else {
      this.inputAddressField = {
        "addressPassedToCustomFooter": this.inputAddress
      }
      this.callToPubsub(this.inputAddressField);
      this.omniNextStep();
      this.isEmptySearchText = false;
    }
  }

  /**
  * @description To associated history event with account/lead/permises.
  */
  associateHistoryEvent() {
    this.isSpinnerLoaded = true;
    let requestObject = {};
    requestObject.historyEventId = this.historyEventId;
    let IP_NAME;
    if(this.selectedRow[0].hasOwnProperty('LeadName')) {
      requestObject.leadId = this.selectedRow[0].recordId;
      IP_NAME = 'TCK_UpdateContactTicketOnLeadAssociation';
      this.updateBugafiberTicket(requestObject, IP_NAME);
    }
    else if(this.selectedRow[0].hasOwnProperty('AccountName')) {
      requestObject.accountId = this.selectedRow[0].recordId;
      IP_NAME = 'TCK_UpdateContactTicketOnAccountAssociation';
      this.updateBugafiberTicket(requestObject, IP_NAME);
    }
    else if(this.selectedRow[0].hasOwnProperty('PremisesName')) {
      let data =
          JSON.stringify({
            premisesId : this.selectedRow[0].recordId ,
            historyEventId : this.historyEventId
          });
      this.updateHistoryEventDR(data);
    }
  }

  /**
  * @description updates BugaFiber ticket on Account association.
  */
  updateBugafiberTicket(requestObject, IP_NAME) {
    this.historyEventMessage = "";
    this.error = undefined;
    let params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: IP_NAME,
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      this.isSpinnerLoaded = false;
    if (response.result && response.result.IPResult && response.result.IPResult.openHistoryEvent) {
      this.historyEventMessage = "A contact ticket is already open for the " +
        (requestObject.accountId ?"Account" : "Lead") + ". Navigate to " +
      (requestObject.accountId ?"Account" : "Lead") + " and close the contact ticket.";
    } else {
      this.navigateToRecordPage(this.selectedRow[0].recordId);
    }
    }).catch (error => {
      this.isSpinnerLoaded = false;
      this.error = 'Error occured while calling the IP.';
    });
  }
  
  navigateToSelectedRecord(event) {
    this.navigateToRecordPage(this.selectedRow[0].recordId);
  }

  /**
  * @description Invokes a DataRaptor to update history event details.
  */
  async updateHistoryEventDR(data) {
    let requestData = {};
    requestData.value = {};
    requestData.type = 'dataraptor';
    requestData.value.inputMap = data;
    requestData.value.bundleName = 'TCK_UpdateHistoryEventDetails';
    await getDataHandler(JSON.stringify(requestData)).then(result => {
      let parsedResult = JSON.parse(result);
      this.isSpinnerLoaded = false;
      this.navigateToRecordPage(this.selectedRow[0].recordId);
    }).catch(error => {
      this.isSpinnerLoaded = false;
      this.error = 'Error occured while updaing the History Event.';
    });
  }

  /**
  * @description To fire pubsub and pass the data to registered components.
  */
  callToPubsub(data) {
    pubsub.fire('notifyparent', data);
  }
  /**
  * @description To handle navigation to Omniscript to create contact ticket.
  */
  handleNavigationToContactTicket() {
    this[NavigationMixin.Navigate]({
      type: 'standard__component',
      attributes: {
        componentName: 'c__ADRCreateContactTicketFromSearchWrapper'
      }
    });
  }
}