/**
* @group CSR Console
* @description Will return Orders for drop down which on selection will
*     display related Order Items.
*/
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const GRID_COLUMNS = [
  {
    label: 'Product Name',
    fieldName: 'productName',
    hideDefaultActions: true,
    type: 'text',
    initialWidth: 200
  },
  {
    label: 'Action',
    fieldName: 'action',
    hideDefaultActions: true,
    type: 'text'
  },{
    label: 'Supp',
    fieldName: 'supplementalAction',
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Recurring Charge',
    fieldName: 'recurringCharge',
    hideDefaultActions: true,
    type: 'currency',
    typeAttributes: {
      currencyCode: {
        fieldName: 'currencyIsoCode'
      },
      currencyDisplayAs: "symbol"
    },
    cellAttributes: {
      alignment: 'left'
    }
  },
  {
    label: 'One Time Charge',
    fieldName: 'oneTimeCharge',
    hideDefaultActions: true,
    type: 'currency',
    typeAttributes: {
      currencyCode: {
        fieldName: 'currencyIsoCode'
      },
      currencyDisplayAs: "symbol"
    },
    cellAttributes: {
      alignment: 'left'
    }
  },
  {
    label: 'Ownership',
    fieldName: 'equipmentOwnership',
    hideDefaultActions: true,
    type: 'text'
  },
  {
    label: 'Return Status',
    fieldName: 'equipmentReturnStatus',
    hideDefaultActions: true,
    type: 'text'
  }
];
const ORDER = {
  "SUPPLEMENTAL_ACTION": {
    "CANCEL" : "Cancel"
  },
  "UPDATE_STATUS" : {
    "CANCELLED" : "Cancelled",
    "COMPLETED" : "Completed",
  },
  "ORDER_OR_FULFILMENT_STATUS" : {
    "ACTIVATED" : "Activated",
    "DRAFT" : "Draft",
    "QUEUED" : "Queued",
    "REJECTED" : "Rejected"
  }
};

export default class orderList extends OmniscriptBaseMixin(LightningElement) {

  gridColumns = GRID_COLUMNS;
  isSpinnerLoaded = true;
  isOrderLineItems = false;
  orders = [];
  orderDetails = [];
  orderLineItems = [];
  orderLineItemsNotFoundMsg;
  serviceAccountId;
  selectedOrder = '';
  showTable = false;

  /**
   * @description This method is called everytime time the DOM is rerendered.
   */
  renderedCallback(){
    this.expandAllRows();
  }

  /**
   * @description Will fire everytime when Premises Id is changed. to get the Premises Id.
   * @return this.serviceAccountId Returns the serviceAccountId
   */
  @api get serviceAccountData() {
    return this.serviceAccountId;
  }

  /**
   * @description Will fire everytime when Premise Id is changed. to set the Premises Id.
   * @param  value - Value to be set
   */
  set serviceAccountData(value) {
    this.setAttribute('serviceAccountData', value);
    this.serviceAccountId = value;
    this.fetchLocation();
  }

  /**
   * @description Handler method for Pub/Sub and this will get the Order and Order Items data
   *     returned from controller.
   */
  fetchLocation() {
    this.isSpinnerLoaded = true;
    this.showTable = false;
    this.selectedOrder = '';

    let inputMap = { 'serviceAccountId': this.serviceAccountId };
    let params = {
      input: JSON.stringify(inputMap),
      sClassName: 'OrderList',
      sMethodName: 'fetchOrderDetails',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(result => {
      let orders = [{ label: 'Select an Order', value: '' }];

      if (result.result.orderList) {
        let serializedOrderList = result.result.orderList.split(',"childOrderItems":null')
            .join('');

        this.orderDetails = JSON.parse(serializedOrderList);
        this.checkAndUpdateStatus();

        if (this.orderDetails.length > 0) {
          this.orderDetails.forEach(orderObject => {
            let option = { label: 'Order Nbr: ' + orderObject.order.OrderNumber + ' - ' +
                (orderObject.order.Type === undefined ? '' : orderObject.order.Type) + ' - ' +
                orderObject.order.updatedStatus, value: orderObject.order.Id };
            orders.push(option);
          });
        }
        this.orders = orders;
        this.isSpinnerLoaded = false;
      }
    })
    .catch (error => {
      console.log(error);
    });
  }

  /**
   * @description Method to update the status to be displayed in UI for Orders and Order Line Items
   *     if vlocity_cmt__FulfilmentStatus__c node for Order and status node for Order Line Items
   *     is either Activated or Draft, status updated to Completed or Queued respectively.
   */
  checkAndUpdateStatus() {
    for (let i = 0; i < this.orderDetails.length; i++) {
      if (this.orderDetails[i].order) {
        let order = this.orderDetails[i].order;
        if (order.vlocity_cmt__FulfilmentStatus__c === ORDER.ORDER_OR_FULFILMENT_STATUS.ACTIVATED
              && order.vlocity_cmt__OrderStatus__c
              === ORDER.ORDER_OR_FULFILMENT_STATUS.ACTIVATED) {
          order.updatedStatus = ORDER.UPDATE_STATUS.COMPLETED;
        } else if (((order.vlocity_cmt__FulfilmentStatus__c
            === ORDER.ORDER_OR_FULFILMENT_STATUS.ACTIVATED
            || order.vlocity_cmt__FulfilmentStatus__c === ORDER.UPDATE_STATUS.CANCELLED)
            && order.vlocity_cmt__OrderStatus__c === ORDER.UPDATE_STATUS.CANCELLED)
            || order.vlocity_cmt__OrderStatus__c === ORDER.UPDATE_STATUS.REJECTED
            || order.vlocity_cmt__SupplementalAction__c === ORDER.SUPPLEMENTAL_ACTION.CANCEL) {
          order.updatedStatus = ORDER.UPDATE_STATUS.CANCELLED;
        } else if (order.vlocity_cmt__FulfilmentStatus__c
            === ORDER.ORDER_OR_FULFILMENT_STATUS.DRAFT
            && order.vlocity_cmt__OrderStatus__c === ORDER.ORDER_OR_FULFILMENT_STATUS.QUEUED) {
          order.updatedStatus = ORDER.ORDER_OR_FULFILMENT_STATUS.QUEUED;
        } else {
          order.updatedStatus = order.vlocity_cmt__FulfilmentStatus__c;
        }
      }

      if (this.orderDetails[i].orderItems) {
        this.orderDetails[i].orderItems.forEach(function iterate(orderItem) {
          if (orderItem.status === ORDER.ORDER_OR_FULFILMENT_STATUS.ACTIVATED) {
            orderItem.updatedStatus = ORDER.UPDATE_STATUS.COMPLETED;
          } else if (orderItem.status === ORDER.ORDER_OR_FULFILMENT_STATUS.DRAFT) {
            orderItem.updatedStatus = ORDER.ORDER_OR_FULFILMENT_STATUS.QUEUED;
          } else {
            orderItem.updatedStatus = orderItem.status;
          }
          Array.isArray(orderItem.childOrderItems) && orderItem.childOrderItems.forEach(iterate);
        });
      }
    }
  }

  /**
   * @description This will fire when Order is selected
   * @param  event - Fired event data
   */
  handleOrderChange(event) {
    this.isSpinnerLoaded = true;
    this.showTable = false;
    this.isOrderLineItems = false;

    let orderLineItems = [];

    setTimeout(() => {
      let orderId = event.detail.value;

      if (orderId != '') {
        let orderDetail = this.orderDetails.find(order => order.order.Id === orderId);
        if (orderDetail.orderItems !== undefined) {
          orderLineItems = JSON.parse(JSON.stringify(orderDetail.orderItems)
              .split('childOrderItems').join('_children'));
        }
        this.orderLineItems = orderLineItems;
        this.showTable = true;
        this.selectedOrder = orderId;
      } else {
        this.isOrderLineItems = true;
        this.orderLineItemsNotFoundMsg = 'There are no Order Line items found for selected Order';
      }
      this.isSpinnerLoaded = false;
    }, 500);
  }

  /**
   * @description This will expand all the grid rows.
   */
  expandAllRows() {
    const grid =  this.template.querySelector('lightning-tree-grid');

    if (grid) {
      grid.expandAll();
    }
  }
}