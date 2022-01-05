/**
 * @group CSR Console.
 * @description Displays all the Devices that can be returned and are returned.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

const ORDER_ITEM_EQUIPMENT_RETURN_KEY = 'equipmentReturned';
const ORDER_ITEM_RETURN_CHARGES_BLOCKED_KEY = 'returnChargesBlocked';

export default class ReturnDeviceList extends OmniscriptBaseMixin(LightningElement) {
  @api orderItems;
  changedOrderItems = [];

  /**
   * @description Handler to update the Order Item.
   * @param event Event from the Return checkbox field.
   */
  updateEquipmentReturn(event) {
    this.updateChangedOrderItems(event, ORDER_ITEM_EQUIPMENT_RETURN_KEY);
  }

  /**
   * @description Handler to update the Order Item.
   * @param event Event from the Return Charges Blocked checkbox field.
   */
  updateBlockedCharges(event) {
    this.updateChangedOrderItems(event, ORDER_ITEM_RETURN_CHARGES_BLOCKED_KEY);
  }

  /**
   * @description Method to update the Omniscript JSON.
   * @param event Event from the checkbox field.
   */
  updateChangedOrderItems(event, attribute) {
    const index = event.target.dataset.index;
    const orderItem = Object.assign({}, this.orderItems[index]);
    if (this.changedOrderItems.length) {
      const itemIndex = this.changedOrderItems.findIndex(item =>
        item.orderItemId === event.target.dataset.key);
      const newOrderItem = this.changedOrderItems[itemIndex];
      newOrderItem[attribute] = event.target.checked;
      if (!this.hasOrderItemChanged(newOrderItem, orderItem)) {
        this.changedOrderItems.splice(itemIndex, 1);
      }
    } else {
      orderItem[attribute] = event.target.checked;
      this.changedOrderItems.push(orderItem);
    }
    this.omniApplyCallResp({"updatedOrderItems": this.changedOrderItems});
  }

  /**
   * @description Tells us if the order Item is updated.
   * @param newOrderItem Order item in the changedOrderItems.
   * @param oldOrderItem Order item in the Omniscript data.
   * @return Boolean.
   */
   hasOrderItemChanged(newOrderItem, oldOrderItem) {
    return (newOrderItem[ORDER_ITEM_EQUIPMENT_RETURN_KEY] !==
        oldOrderItem[ORDER_ITEM_EQUIPMENT_RETURN_KEY] ||
        newOrderItem[ORDER_ITEM_RETURN_CHARGES_BLOCKED_KEY] !==
        oldOrderItem[ORDER_ITEM_RETURN_CHARGES_BLOCKED_KEY]);
  }
}