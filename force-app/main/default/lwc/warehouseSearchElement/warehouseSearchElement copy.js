/**
   * =========================================================================================================================
   * @ LWC Component Name . . . . . . . : warehouseSearchElement.js
   * @ Description. . . . . . . . . . . : This search element is present on the side bar in warehouse view and it will search
   * @                  the elements entered.
   * @ Date Creation. . . . . . . . . . : Nov 12th 2021
   * @ Author . . . . . . . . . . . . . : Praveen Thatha
   * =========================================================================================================================
   * @ Amendment Log-->
   * @ Change Request No: xxxxxxxxxxxxxxx Author: xxxxxxxxxxxxxxxxxxxxxx Date: xx/xx/xxxx
   * =========================================================================================================================
   */
// Include LWC decorators
import {
	api,
	LightningElement,
	track
} from 'lwc';
// Include Warehouse method to get warehouse code based on description
import WarehouseMapping from "@salesforce/apex/i2msFindSerialAPI.WarehouseMapping";
// Include Find Serial API to get data from server based on search made on screen
import FindSerialRestMethod from "@salesforce/apex/i2msFindSerialAPI.FindSerialRestMethod";
// Include Find child Serial API to get child details for Genealogy components
import FindChildSerialRestMethod from "@salesforce/apex/i2msFindSerialAPI.FindChildSerialRestMethod";

// Main column heading for datatable
const columns = [{
		label: 'GPN',
		fieldName: 'gpn',
		sortable: "true"
	},
	{
		label: 'Serial Number',
		fieldName: 'serial_number',
		sortable: "true"
	},
	{
		label: 'Status',
		fieldName: 'status',
		sortable: "true"
	},
	{
		label: 'Current Owner',
		fieldName: 'current_owner',
		sortable: "true"
	},
	{
		label: 'Transfer To',
		fieldName: 'transfer_to',
		sortable: "true"
	},
	{
		type: "button",
		label: 'History',
		typeAttributes: {
			label: 'History',
			name: 'History',
			title: 'History',
			disabled: false,
			value: 'history',
			iconPosition: 'left'

		}
	},
	{
		type: "button",
		label: 'Genealogy',
		typeAttributes: {
			label: 'Genealogy',
			name: 'Genealogy',
			title: 'Genealogy',
			disabled: false,
			value: 'genealogy',
			iconPosition: 'left'
		}
	}
];

// Column heading for History datatable
const columns_history = [{
		label: 'Timestamp',
		fieldName: 'timestamp'
	},
	{
		label: 'Transaction Type',
		fieldName: 'transaction_type'
	},
	{
		label: 'To Status',
		fieldName: 'to_status'
	},
	{
		label: 'Current Owner',
		fieldName: 'current_owner'
	},
	{
		label: 'To Owner',
		fieldName: 'to_owner'
	},
	{
		label: 'Location',
		fieldName: 'location'
	},
	{
		label: 'Account ID',
		fieldName: 'account_id'
	},
	{
		label: 'Ticket ID',
		fieldName: 'ticket_id'
	},
	{
		label: 'User',
		fieldName: 'user'
	}
];

// Column heading for Child-Genealogy datatable
const columns_genealogy_child = [{
		label: 'Child GPN',
		fieldName: 'child_gpn'
	},
	{
		label: 'Child Serial Number',
		fieldName: 'child_serial_number'
	}
];

// Column heading for Parent-Genealogy datatable
const columns_genealogy_parent = [{
		label: 'Parent GPN',
		fieldName: 'parent_gpn'
	},
	{
		label: 'Parent Serial Number',
		fieldName: 'parent_serial_number'
	}
];

export default class WarehouseSearchElement extends LightningElement {

	// Defining scope of Global/Local communication variables
	@api combined_data;
	@api gpn;
	@api status;
	@api serialnumber;
	@api techname;
	@api warehouse;
	
	@track columns = columns;
	@track columns_history = columns_history;
	@track columns_genealogy_child = columns_genealogy_child;
	@track columns_genealogy_parent = columns_genealogy_parent;
	@track data;
	@track openModalGenealogy = false;
	@track openModalHistory = false;
	@track searchMessageDisplay;
	@track sortBy;
	@track sortDirection;
	@track spinner = true;
	@track validSelection = true;

	// Connected call back for first time call
	connectedCallback(warehouse, serialnumber, techname, gpn, status) {
		this.loadDataTable(this.warehouse, this.serialnumber, this.techname, this.gpn, this.status)
	}

	// Function to load Main datatable
	@api async loadDataTable(warehouseLocation, serialNumberValue, technameValue, gpnValue, statusValue) {

		// Define local variables
		var ApiResponse = ' '
		var slotsData = ' '
		var reqJson = ' '
		this.data = ' '
		var combined_data = []
		var AddRowToDataTable = [];
		this.validSelection = true;
		var count = 0;

		// Get warehouse code from description
		if (warehouseLocation !== '') {
			const warehousMappingResponse = await WarehouseMapping();
			warehouseLocation = warehousMappingResponse.find(Arr => Arr.Description__c === warehouseLocation);
		}

		// When Status is selected as ALL_PREASSIGNED, then make it as PRE_ASSIGNED, PRE_ASSIGNED_SPARE
		if (statusValue == 'ALL_PREASSIGNED') {
			statusValue = 'PRE_ASSIGNED", "PRE_ASSIGNED_SPARE'
		}

		// Form the API request parameter based on input values from screen.

		// If serial number was passed
		if (serialNumberValue !== '') {
			var Parameter = ' { "criteria" :{"serialKeys": {"serialNumber": "' + serialNumberValue + '"}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
		}

		// If TechName/LDAP was passed
		//  -Tech name will be checked in current owner and new owner, so there will be 2 API calls for that.
		//  -One for the current owner in this condition and other will the general condition.  
		else if (technameValue !== '') {

			// if multiple tech name was passed then split it into Array and stringify
			var techUsersJSON = '';
			technameValue = technameValue.replaceAll(" ", "").split(',')
			for (var i = 0; i < technameValue.length; i++) {
				if (technameValue[i] === "") {
					technameValue.splice(i, 1);
				}
			}

			techUsersJSON = JSON.stringify(technameValue);

			// If TechName/LDAP, GPN was passed and Status was empty 
			if (gpnValue !== '' && statusValue == '') {

				// Get data for current owner.
				Parameter = ' { "criteria" :{ "deviceOwnershipCriteria": { "currentOwners": ' + techUsersJSON + ', "gpns": "' + gpnValue + '"}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				ApiResponse = await FindSerialRestMethod({
					requestParameter: Parameter
				});
				slotsData = await JSON.parse(ApiResponse);
				if (JSON.stringify(slotsData) != '{}') {
					combined_data.push(slotsData)
				}

				// Parameter build for new owner will be used in generic API call
				Parameter = ' { "criteria" :{ "deviceOwnershipCriteria": { "newOwners": ' + techUsersJSON + ', "gpns": "' + gpnValue + '"}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
			}

			// If TechName/LDAP, Status was passed and GPN was empty 
			else if (gpnValue == '' && statusValue !== '') {

				// Get data for current owner.
				Parameter = ' { "criteria" :{"deviceOwnershipCriteria": { "currentOwners": ' + techUsersJSON + ' , "ownershipStatuses": ["' + statusValue + '"]}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				ApiResponse = await FindSerialRestMethod({
					requestParameter: Parameter
				});
				slotsData = await JSON.parse(ApiResponse);
				if (JSON.stringify(slotsData) != '{}') {
					combined_data.push(slotsData)
				}

				// Parameter build for new owner will be used in generic API call
				Parameter = ' { "criteria" :{"deviceOwnershipCriteria": { "newOwners": ' + techUsersJSON + ' , "ownershipStatuses": ["' + statusValue + '"]}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
			}

			// If TechName/LDAP, Status and GPN was passed 
			else if (gpnValue !== '' && statusValue !== '') {

				// Get data for current owner.
				Parameter = ' { "criteria" :{"deviceOwnershipCriteria": { "currentOwners": ' + techUsersJSON + ' , "gpns": "' + gpnValue + '", "ownershipStatuses": ["' + statusValue + '"]}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				ApiResponse = await FindSerialRestMethod({
					requestParameter: Parameter
				});
				slotsData = await JSON.parse(ApiResponse);
				if (JSON.stringify(slotsData) != '{}') {
					combined_data.push(slotsData)
				}

				// Parameter build for new owner will be used in generic API call
				Parameter = ' { "criteria" :{"deviceOwnershipCriteria": { "newOwners": ' + techUsersJSON + ', "gpns": "' + gpnValue + '", "ownershipStatuses": ["' + statusValue + '"]}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
			}

			// If only TechName/LDAP was passed
			else {

				// Get data for current owner.
				Parameter = ' { "criteria" :{"deviceOwnershipCriteria": { "currentOwners": ' + techUsersJSON + ' }, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				ApiResponse = await FindSerialRestMethod({
					requestParameter: Parameter
				});
				slotsData = await JSON.parse(ApiResponse);
				if (JSON.stringify(slotsData) != '{}') {
					combined_data.push(slotsData)
				}

				// Parameter build for new owner will be used in generic API call
				Parameter = ' { "criteria" :{"deviceOwnershipCriteria": { "newOwners": ' + techUsersJSON + ' }, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
			}
		}

		// If Warehouse and GPN was passed, TechName and Status was empty
		else if (gpnValue !== '' && warehouseLocation !== '' && technameValue == '' && statusValue == '') {
			Parameter = ' { "criteria" :{"deviceOwnershipCriteria": { "google_location_codes": ["' + warehouseLocation.Name + '", "' + warehouseLocation.Name + 'M' + '"], "gpns": "' + gpnValue + '"}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
		}

		// If Warehouse and Status was passed, TechName was empty
		else if (statusValue !== '' && warehouseLocation !== '' && technameValue == '') {

			// For OnHand Status load generic OnHand data
			if (statusValue == 'ONHAND') {

				// OnHand request with GPN
				if (gpnValue !== '') {
					Parameter = ' { "criteria" :{ "devicesSearch": "ON_HAND_DEVICES_ONLY", "on_hand_location_codes" :  ["' + warehouseLocation.Name + '", "' + warehouseLocation.Name + 'M' + '"], "serialKeys": {"gpn": "' + gpnValue + '"}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				}
				// OnHand request without GPN, results should be similar to OnHand devices from warehouse view
				else {
					Parameter = ' { "criteria" :{ "devicesSearch": "ON_HAND_DEVICES_ONLY", "on_hand_location_codes" :  ["' + warehouseLocation.Name + '", "' + warehouseLocation.Name + 'M' + '"], "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				}
			} else {
				// Status request with GPN
				if (gpnValue !== '') {
					Parameter = ' { "criteria" :{ "deviceOwnershipCriteria": { "google_location_codes": ["' + warehouseLocation.Name + '", "' + warehouseLocation.Name + 'M' + '"], "gpns": "' + gpnValue + '", "ownershipStatuses": ["' + statusValue + '"]}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				}
				// Status request without GPN
				else {
					Parameter = ' { "criteria" :{ "deviceOwnershipCriteria": { "google_location_codes": ["' + warehouseLocation.Name + '", "' + warehouseLocation.Name + 'M' + '"], "ownershipStatuses": ["' + statusValue + '"]}, "deviceOwnershipHistory" : "REQUIRED", "pageSize" : 2000} }'
				}
			}
		}

		// Select errors, if any!
		// When GPN or Status was passed and warehouse was empty
		if (warehouseLocation == '' && serialNumberValue == '' && technameValue == '' && (gpnValue !== '' || statusValue !== '')) {
			this.validSelection = false;
			this.searchMessageDisplay = 'Please select a warehouse for this search criteria'
		}
		// When nothing has been entered and search was clicked.
		else if (serialNumberValue == '' && technameValue == '' && gpnValue == '' && statusValue == '') {
			this.validSelection = false;
			this.searchMessageDisplay = 'Please make a valid search selection'
		}

		// Form message to be displayed on top of the table, showing which all search fields were searched.
		if (this.validSelection == true) {

			// Append message for Serial Number
			var searchMessage = ' '
			if (serialNumberValue) {
				searchMessage += ' Serial ' + serialNumberValue;
			}

			// Append message for Tech Name
			if (technameValue) {
				if (searchMessage != ' ') {
					searchMessage += ', '
				}
				searchMessage += 'Tech ' + technameValue;
			}

			// Append message for GPN 
			if (gpnValue) {
				if (searchMessage != ' ') {
					searchMessage += ', '
				}
				searchMessage += 'GPN ' + gpnValue;
			}

			// Append message for Status
			if (statusValue) {
				if (searchMessage != ' ') {
					searchMessage += ', '
				}
				if (statusValue == 'PRE_ASSIGNED", "PRE_ASSIGNED_SPARE') {
					searchMessage += 'Status PRE_ASSIGNED, PRE_ASSIGNED_SPARE'
				} else {
					searchMessage += 'Status ' + statusValue;
				}
			}

			// Append M in warehouse location, as this is the refurbished location and should be included in original search.
			if (warehouseLocation !== '' && serialNumberValue == '' && technameValue == '' && (gpnValue !== '' || statusValue !== '')) {
				searchMessage += ' for Location ' + warehouseLocation.Name + ', ' + warehouseLocation.Name + 'M';
			}

			// Switch on the Spinner
			this.spinner = true;

			// Call API program in loop, so that data can be retrieved from next page token as well.
			do {
				ApiResponse = await FindSerialRestMethod({
					requestParameter: Parameter
				});
				slotsData = await JSON.parse(ApiResponse);
				if (JSON.stringify(slotsData) != '{}') {
					combined_data.push(slotsData)
				}
				reqJson = slotsData.nextPageToken
				Parameter = '{ "pageToken":' + '"' + reqJson + '" }';
			}
			while (reqJson != null);

			// Load data into datatable
			if (JSON.stringify(combined_data[0]) != '{}') {
				for (const elements of combined_data) {
					for (const model of elements.serials) {
						count += 1;
						AddRowToDataTable.push({
							serial_number: model.serialKey.serialNumber,
							gpn: model.serialKey.gpn,
							current_owner: model.deviceOwnership.currentAttribute.currentOwner,
							transfer_to: model.deviceOwnership.currentAttribute.newOwner,
							status: model.deviceOwnership.currentAttribute.ownershipStatus,
							// Also, store history record, which will be used later on
							history: model.deviceOwnership.attributeHistories
						})
					}
				}
				this.data = AddRowToDataTable;
			}
			this.searchMessageDisplay = 'Search Result for' + searchMessage + ' (Total ' + count + ' Results)';
		}
		this.spinner = false;
	}

	// Call this function when any row-action is performed on datatable
	async callRowAction(event) {

		// Define local variables
		var AddRowToHistoryTable = [];
		let currentDate = new Date();
		this.data_history = ' '
		const serial_ = event.detail.row.serial_number;
		const gpn_ = event.detail.row.gpn
		const actionName = event.detail.action.name;

		// When History button was selected on screen
		if (actionName === 'History') {

			// Show History model
			this.openModalHistory = true;
			this.messageHistoryForSerialNumber = 'History for Serial Number ' + serial_;

			// Format date time based on current time-zone
			let formatter = new Intl.DateTimeFormat('default', {
				year: "numeric",
				month: "short",
				day: "numeric",
				hour: "2-digit",
				minute: "2-digit",
				second: '2-digit',
				hour12: "false",
				timeZoneName: 'short',
			})

			// This response is received from main datatable
			const records = JSON.parse(JSON.stringify(this.data))

			// Search serial number and GPN in main table
			const record = records.find(Arr => Arr.serial_number === serial_ && Arr.gpn === gpn_);

			// Populate History datatable from history field in Main data
			for (const x of record.history) {
				let formattedDate = formatter.format(Date.parse(x.commitTime));
				AddRowToHistoryTable.push({
					timestamp: formattedDate,
					transaction_type: x.transactionType,
					to_status: x.ownershipStatus,
					current_owner: x.currentOwner,
					to_owner: x.newOwner,
					location: x.googleLocationCode,
					account_id: x.accountID,
					ticket_id: x.ticketID,
					user: x.user
				})
			}
			this.data_history = AddRowToHistoryTable
		}

		// When Genealogy button was selected on screen
		else if (actionName === 'Genealogy') {

			// Show History model
			var AddRowToGenealogyTable = []
			var AddRowToParentGenealogyTable = []
			var ApiResponse = ''
			var combined_data = []
			var reqJson = ' '
			var slotsData = ''
			
			this.data_genealogy_child = ' '

			// Call API to fetch data from server
			if (serial_ !== '' || gpn_ !== '') {
				var Parameter = '{"parentSerialKey": {"serial_number": "' + serial_ + '","gpn": "' + gpn_ + '"}}'
				this.messageGenealogyForSerialNumber = 'Genealogy for Serial Number ' + serial_;
				var combined_data = []
				do {
					ApiResponse = await FindChildSerialRestMethod({
						requestChildParameter: Parameter
					});
					slotsData = await JSON.parse(ApiResponse);
					combined_data.push(slotsData)
					reqJson = slotsData.nextPageToken
					Parameter = '{ "pageToken":' + '"' + reqJson + '" }';
				}
				while (reqJson != null);
			}

			// Load child datatable 
			if (JSON.stringify(combined_data[0]) != '{}') {
				for (const x of combined_data) {
					for (const y of x.serials) {
						AddRowToGenealogyTable.push({
							child_serial_number: y.serialKey.serialNumber,
							child_gpn: y.serialKey.gpn
						})
					}
				}
				this.data_genealogy_child = AddRowToGenealogyTable
			}

			// Load parent datatable 
			AddRowToParentGenealogyTable.push({
				parent_serial_number: serial_,
				parent_gpn: gpn_
			})
			this.data_genealogy_parent = AddRowToParentGenealogyTable
			this.openModalGenealogy = true;
		}
	}

	// Sort handler
	handleSortAccountData(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);
	}

	// Sort based on field and direction
	sortAccountData(fieldname, direction) {

		let parseData = JSON.parse(JSON.stringify(this.data));

		let keyValue = (a) => {
			return a[fieldname];
		};

		let isReverse = direction === 'asc' ? 1 : -1;

		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : '';
			y = keyValue(y) ? keyValue(y) : '';

			return isReverse * ((x > y) - (y > x));
		});

		this.data = parseData;

	}

	// Close button on History screen
	closeModalHistory() {
		this.openModalHistory = false;
	}

	// Close button on Genealogy screen
	closeModalGenealogy() {
		this.openModalGenealogy = false;
	}
}