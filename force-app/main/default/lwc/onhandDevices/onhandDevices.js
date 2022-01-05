/**
 * @group onhandDevices
 * @description Search all onhand devices based on warehouse passed selected
 */
// Import Lightning decorators
import {
  api,
  LightningElement,
  track
} from "lwc";
// Get data from SAP, based on FindSerial API
import FindSerialRestMethod from "@salesforce/apex/i2msFindSerialAPI.FindSerialRestMethod";
// Get warehouse and description mapping
import WarehouseMapping from "@salesforce/apex/i2msFindSerialAPI.WarehouseMapping";
// Get model and description mapping
import ModelDescriptionBasedOnGPN
    from "@salesforce/apex/i2msFindSerialAPI.ModelDescriptionBasedOnGPN";

// Columns for Tree Grid
const columns = [{
    label: 'Plan/Model',
    fieldName: 'Model'
  },
  {
    label: 'GPN',
    fieldName: 'GPN'
  },
  {
    label: 'Description',
    fieldName: 'Description'
  },
  {
    label: 'Serial',
    fieldName: 'Serial'
  },
  {
    label: 'Quantity',
    fieldName: 'Amount'
  },

];

export default class onhandDevices extends LightningElement {

  // Global and local variables
  @api warehouse
  @api warehouseaccess

  @track invalidSelectionMessage;
  @track spinner = true;
  @track validSelection = false;

  columns = columns;
  data = [];
  error;

  // Download file
  downloadCSVFile(event) {
    let rowEnd = '\n';
    let csvString = '';

    // This set elminates the duplicates if have any duplicate keys
    let rowData = new Set();
    let location = event.target.value;
    const arrayRecord = []

    // Get data from screen into arrays
    for (let eachData of this.data) {
      for (let eachDataParent of eachData) {
        for (let eachDataChild of eachDataParent._children) {
          if (eachDataChild.Location === location) {
            arrayRecord.push(eachDataChild);
            delete eachDataChild.keyField;
          }
        }
      }
    }
    // Getting keys from data
    arrayRecord.forEach(function(record) {
      Object.keys(record).forEach(function(key) {
        rowData.add(key);
      });
    });

    /***
     * Array.from() method returns an Array object from any object with a
     * length property or an iterable object.
     */
    rowData = Array.from(rowData);
    rowData[0] = 'Location';
    rowData[1] = 'Model';
    rowData[2] = 'GPN';
    rowData[3] = 'Description';
    rowData[4] = 'Serial';
    rowData[5] = 'Amount';

    // Splitting using ','
    csvString += rowData.join(',');
    csvString += rowEnd;

    // Main for loop to get the data based on key value
    for (let i = 0; i < arrayRecord.length; i++) {
      let colValue = 0;

      // Validating keys in data
      for (let key in rowData) {
        if (rowData.hasOwnProperty(key)) {
          // Key value
          // Ex: Id, Name
          let rowKey = rowData[key];
          // add , after every value except the first.
          if (colValue > 0) {
            csvString += ',';
          }
          // If the column is undefined, it as blank in the CSV file.
          let value = arrayRecord[i][rowKey] === undefined ? '' : arrayRecord[i][rowKey];
          //let value = "33"
          csvString += '"' + value + '"';
          colValue++;
        }
      }
      csvString += rowEnd;
    }
    const today = new Date();

    // Form file name to be downloaded
    var dateTime = (String(today.getFullYear() + '-' +
        ("0" + (today.getMonth() + 1)).slice(-2) +'-' +
        ("0" + today.getDate()).slice(-2) + '_' +
        ("0" + today.getHours()).slice(-2) + ':' +
        ("0" + today.getMinutes()).slice(-2) + ':' +
        ("0" + today.getSeconds()).slice(-2))).replaceAll('-', '').replaceAll(':', '');
    let downloadElement = document.createElement('a');
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
    downloadElement.target = '_self';
    downloadElement.download = 'OnHand_' + location + '_' + dateTime + '.csv';
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  // Fetch onhand data from API and display on screen
  @api async fetchOnhand(Parm, warehouseAccessFromPublicGroup) {

    // API variables
    var apiResponse = ''
    var slotsData = ''
    var reqJson = ''

    // Setting spinner value as true, since we have started fetching data from API
    this.spinner = true;

    // Check if warehouse was passed in
    this.validSelection = Parm
    if (this.validSelection) {

      // Check if user have sufficient authority to view warehouse data
      this.validSelection = warehouseAccessFromPublicGroup
      if (this.validSelection) {

        const warehousMappingResponse = await WarehouseMapping();
        const value = warehousMappingResponse.find(Arr => Arr.Description__c === Parm);

        // Populate request parameter for API
        var Parameter = '{ "criteria": { "devicesSearch": "ON_HAND_DEVICES_ONLY",\
            "on_hand_location_codes" :  ["' +
            value.Name + '","' + value.Name + 'M" ], "pageSize": 5000 } }'
        var combined_data = []

        // Call API in loop and amend if output if any next token was received
        do {
          apiResponse = await FindSerialRestMethod({
            requestParameter: Parameter
          });
          slotsData = await JSON.parse(apiResponse);
          combined_data.push(slotsData)
          reqJson = slotsData.nextPageToken
          Parameter = '{ "pageToken":' + '"' + reqJson + '" }';
        }
        while (reqJson != null);

        this.buildData(combined_data, Parm);
      } else {
        // Display error that user was not authorized for this warehouse
        this.invalidSelectionMessage = " Not Authorized for warehouse " + Parm;
      }
    } else {
      // Warehouse can't be blank, display error!
      this.invalidSelectionMessage = " Please select a warehouse and then click OnHand Devices ";
    }
  }

  // Build data as per Tree-Grid, to display it on the screen
  async buildData(inputData, inputParm) {

    // Create array's to form data as per tree grid requirement
    const parentArray = [];
    const childArray = [];
    this.spinner = false;

    // Sort Array to display on screen.
    function dynamicSort(property) {
      var sortOrder = 1;
      if (property[0] === "-") {
        sortOrder = -1;
        property = property.substr(1);
      }
      return function(a, b) {
        var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
        return result * sortOrder;
      }
    }

    // Variables to get model and description from custon settings
    var modelDescriptionValues = ''
    var modelFromCS = ''
    var descriptionFromCS = ''

    // Get model and description from custon settings
    const modelDescriptionFullData = await ModelDescriptionBasedOnGPN();

    /**
     * For creating Tree Grid Format, we need to have parent and child data formation with
     * common keyfield,
     * - Create an array parentArray which has Location, model, Amount and an empty
     * array as _children (this _children will later be filled with all the data 
     * corresponding to same keyfield) parentArray will have duplicates,
     * which will be removed further by uniqueKits
     */
    for (const elements of inputData) {
      for (const model of elements.serials) {

        // Get Model from Custom Settings
        try {
          modelDescriptionValues = 
              modelDescriptionFullData.find(Arr => Arr.Name === model.serialKey.gpn);
          modelFromCS = modelDescriptionValues.Model__c
        } catch (err) {
          modelFromCS = ''
        }

        // Get Description from Custom Settings
        try {
          modelDescriptionValues = 
              modelDescriptionFullData.find(Arr => Arr.Name === model.serialKey.gpn);
          descriptionFromCS = modelDescriptionValues.Description__c
        } catch (err) {
          descriptionFromCS = ''
        }

        // Parent tree-grid formation
        parentArray.push({
          Location: model.lastKnownGoogleLocationCode,
          Model: modelFromCS,
          keyField: model.lastKnownGoogleLocationCode + modelFromCS,
          Amount: 0,
          _children: []
        })

        // Child tree-grid formation 
        childArray.push({
          Location: model.lastKnownGoogleLocationCode,
          Model: modelFromCS,
          GPN: model.serialKey.gpn,
          Description: descriptionFromCS,
          Serial: model.serialKey.serialNumber,
          Amount: 1,
          keyField: model.lastKnownGoogleLocationCode + modelFromCS
        })
      }
    }

    // Sort array as per KeyFields
    parentArray.sort(dynamicSort("keyField"));

    // Get all unique locations
    const uniqueKits = 
        [...new Map(parentArray.map(item => [item['Location'], item])).values()]

    // Get all unique KeyFields
    const uniqueKeyFields = 
        [...new Map(parentArray.map(item => [item['keyField'], item])).values()]

    // This array will create _children component, uniqueKeyFields._children = [childArray]
    for (const eachuniqueKeyFields of uniqueKeyFields) {
      let count = 0;
      for (const eachchildArray of childArray) {
        if (eachuniqueKeyFields.keyField === eachchildArray.keyField) {
          eachuniqueKeyFields._children.push(eachchildArray)
          count = count + eachchildArray.Amount;
        }
      }
      eachuniqueKeyFields.Amount = count;
    }

    // treeGridData is the final array and build as per tree-grid requirement
    const treeGridData = []
    for (var eachUniqueKits of uniqueKits) {
      var getUniqueKits = []
      for (var eachUniqueKeyFields of uniqueKeyFields) {
        if (eachUniqueKits.Location === eachUniqueKeyFields.Location) {
          getUniqueKits.push(eachUniqueKeyFields)
        }
      }
      treeGridData.push(getUniqueKits)
    }

    // Moving values to 'data' and 'columns' which are the fields required for Tree-grid
    this.data = Array.from(treeGridData.values());
    this.columns = Array.from(columns.values());
    return
  }

  //For connected call back get warehouse and access
  connectedCallback(warehouse, warehouseaccess) {
    this.fetchOnhand(this.warehouse, this.warehouseaccess)
  }
}