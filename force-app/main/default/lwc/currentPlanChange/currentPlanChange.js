/**
 * @group CSR Console
 * @description Will show the details of OrderItems with prices in an Omniscript.
 */

  import { api, LightningElement } from 'lwc';
  import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

  const INCLUDED = 'Included';
  const NOT_AVAILABLE = 'N/A';
  const ZERO_DOLLAR = '$0';

  export default class CurrentPlanChange extends OmniscriptBaseMixin(LightningElement) {

    @api currentPlan;
    @api futurePlan;
    @api order;

    /**
     * @description To hide/show the Equipments section when order is new install.
     * @return true or false
     */
    get isShowCurrentPlan() {
      if(this.order && this.order.type != 'New Install' &&
          this.order.supersededOrderId != NOT_AVAILABLE) {
        return true;
      } else {
        return false;
      }
    }

    /**
     * @description To hide/show the equipments on Current Plan section.
     * @return true or false
     */
    get isShowCurrentPlanEquipment() {
      if((this.currentPlan.devicesToReturn && this.currentPlan.devicesToReturn.length > 0) ||
          (this.currentPlan.devicesToKeep && this.currentPlan.devicesToKeep.length > 0)) {
        return true;
      } else {
        return false;
      }
    }

    /**
     * @description To hide/show the equipments on Future Plan section.
     * @return true or false
     */
    get isShowFuturePlanEquipment() {
      if((this.futurePlan.devicesToReturn && this.futurePlan.devicesToReturn.length > 0) ||
          (this.futurePlan.devicesToKeep) && this.futurePlan.devicesToKeep.length > 0) {
        return true;
      } else {
        return false;
      }
    }

    /**
     * @description Getter to return current plan name of an Order Item.
     * @return currentPlan.plan.name
     */
    get getCurrentPlan() {
      if (this.currentPlan && this.currentPlan.plan && this.currentPlan.plan.name) {
        return this.currentPlan.plan.name;
      } else {
       return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return current plan price of an Order Item.
     * @return currentPlan.plan.price
     */
    get getCurrentPlanPrice() {
      if (this.currentPlan && this.currentPlan.plan && this.currentPlan.plan.price) {
        if (this.currentPlan.plan.price !== INCLUDED) {
          return `$${this.currentPlan.plan.price}`;
        } else {
          return this.currentPlan.plan.price;
        }
      } else {
        return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return additional storage of current Order.
     * @return currentPlan.storage.cloudStorage
     */
    get getCurrentAdditionalStorage() {
      if (this.currentPlan && this.currentPlan.storage && this.currentPlan.storage.cloudStorage) {
        return this.currentPlan.storage.cloudStorage;
      } else {
        return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return additional storage price of current Order.
     * @return currentPlan.storage.price
     */
    get getCurrentAdditionalStoragePrice() {
      if (this.currentPlan && this.currentPlan.storage && this.currentPlan.storage.price) {
        if (this.currentPlan.storage.price !== INCLUDED) {
          return `$${this.currentPlan.storage.price}`;
        } else {
          return this.currentPlan.storage.price;
        }
      } else {
        return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return devices that to be returned
     *     along with return by date and unreturn fee of current plan
     *     otherwise it will return false.
     * @return devices
     */
    get getCurrentPlanDevicesToReturn() {
      let devicesToReturn = [];

      if (this.currentPlan && this.currentPlan.devicesToReturn) {
        if (Array.isArray(this.currentPlan.devicesToReturn)
            && this.currentPlan.devicesToReturn.length > 0) {
          this.currentPlan.devicesToReturn.filter((item) => {
            let obj = {};
            obj.id = item.id;
            obj.name = item.name;
            obj.returnByDate = this.order.returnByDate;
            obj.deviceFee = item.unreturnedDeviceFee;
            if (item.price!== INCLUDED) {
              obj.price = `$${item.price}`;
            } else {
              obj.price = item.price;
            }
          devicesToReturn.push(obj);
         });
        } else if (this.currentPlan.devicesToReturn.constructor === Object) {
          let obj = {};
          obj.id = this.currentPlan.devicesToReturn.id;
          obj.name = this.currentPlan.devicesToReturn.name;
          obj.returnByDate = this.order.returnByDate;
          obj.deviceFee = this.currentPlan.devicesToReturn.unreturnedDeviceFee;
          if (this.currentPlan.devicesToReturn.price!== INCLUDED) {
            obj.price = `$${this.currentPlan.devicesToReturn.price}`;
          } else {
            obj.price = this.currentPlan.devicesToReturn.price;
          }
          devicesToReturn.push(obj);
        } else {
          devicesToReturn = false;
        }
      } else {
        devicesToReturn = false;
      }
      return devicesToReturn;
    }

    /**
     * @description Getter to return devices that to be kept
     *     along with prices of current plan otherwise it will return false.
     * @return devices
     */
    get getCurrentPlanDevicesToKeep() {
      let devicesToKeep = [];

      if (this.currentPlan && this.currentPlan.devicesToKeep) {
        if (Array.isArray(this.currentPlan.devicesToKeep)
            && this.currentPlan.devicesToKeep.length > 0) {
          this.currentPlan.devicesToKeep.filter((item) => {
            let obj = {};
            obj.id = item.id;
            obj.name = item.name;
            obj.returnByDate = NOT_AVAILABLE;
            obj.deviceFee = item.unreturnedDeviceFee;
            if (item.price!== INCLUDED) {
              obj.price = `$${item.price}`;
            } else {
              obj.price = item.price;
            }
            devicesToKeep.push(obj);
          });
        } else if (this.currentPlan.devicesToKeep.constructor === Object) {
          let obj = {};
          obj.id = this.currentPlan.devicesToKeep.id;
          obj.name = this.currentPlan.devicesToKeep.name;
          obj.returnByDate = NOT_AVAILABLE;
          obj.deviceFee = this.currentPlan.devicesToKeep.unreturnedDeviceFee;
          if (this.currentPlan.devicesToKeep.price!== INCLUDED) {
            obj.price = `$${this.currentPlan.devicesToKeep.price}`;
          } else {
            obj.price = this.currentPlan.devicesToKeep.price;
          }
          devicesToKeep.push(obj);
        } else {
          devicesToKeep = false;
        }
      } else {
        devicesToKeep = false;
      }
      return devicesToKeep;
    }

    /**
     * @description Getter to return plan name of future Order Item.
     * @return futurePlan.plan.name
     */
    get getFuturePlan() {
      let plan = [];
      if (this.futurePlan && this.futurePlan.plan) {
        if (Array.isArray(this.futurePlan.plan)
            && this.futurePlan.plan.length > 0) {
          this.futurePlan.plan.filter((item) => {
            let obj = {};
            obj.id = item.id;
            obj.name = item.name;
            if (item.price !== INCLUDED) {
              obj.price = `$${item.price}`;
            } else {
              obj.price = item.price;
            }
            if (item.oneTimeCharge !== ZERO_DOLLAR) {
              obj.oneTimePrice = item.oneTimeCharge;
            } else {
              obj.oneTimePrice = '';
            }
            plan.push(obj);
          });
        } else if (this.futurePlan.plan.constructor === Object) {
          let obj = {};
          obj.id = this.futurePlan.plan.id;
          obj.name = this.futurePlan.plan.name;
          if (this.futurePlan.plan.price !== INCLUDED) {
            obj.price = `$${this.futurePlan.plan.price}`;
          } else {
            obj.price = this.futurePlan.plan.price;
          }
          if (this.futurePlan.plan.oneTimeCharge !== ZERO_DOLLAR) {
            obj.oneTimePrice = this.futurePlan.plan.oneTimeCharge;
          } else {
            obj.oneTimePrice = '';
          }
          plan.push(obj);
        } else {
          plan = NOT_AVAILABLE;
        }
      } else {
        plan = NOT_AVAILABLE;
      }
      return plan;
    }

    /**
     * @description Getter to return additional storage of future Order.
     * @return futurePlan.storage.cloudStorage
     */
    get getFutureAdditionalStorage() {
      if (this.futurePlan && this.futurePlan.storage && this.futurePlan.storage.cloudStorage) {
        return this.futurePlan.storage.cloudStorage;
      } else {
        return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return additional storage price of future Order.
     * @return futurePlan.storage.price
     */
    get getFutureAdditionalStoragePrice() {
      if (this.futurePlan && this.futurePlan.storage && this.futurePlan.storage.price) {
        if (this.futurePlan.storage.price !== INCLUDED) {
          return `$${this.futurePlan.storage.price}`;
        } else {
          return this.futurePlan.storage.price;
        }
      } else {
        return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return additional storage One-time price of an Order Item.
     * @return futurePlan.storage.oneTimeCharge
     */
    get getFutureAdditionalStorageOneTimePrice() {
      if (this.futurePlan && this.futurePlan.storage && this.futurePlan.storage.oneTimeCharge) {
        if (this.futurePlan.storage.oneTimeCharge !== ZERO_DOLLAR) {
          return this.futurePlan.storage.oneTimeCharge;
        } else {
          return '';
        }
      } else {
        return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return devices that to be returned
     *     along with prices of future planned Order Items otherwise it will return false.
     * @return devices
     */
    get getFuturePlanDevicesToReturn() {
      let devicesToReturn = [];

      if (this.futurePlan && this.futurePlan.devicesToReturn) {
        if (Array.isArray(this.futurePlan.devicesToReturn)
            && this.futurePlan.devicesToReturn.length > 0) {
          this.futurePlan.devicesToReturn.filter((item) => {
            let obj = {};
            obj.id = item.id;
            obj.name = item.name;
            if (item.price !== INCLUDED) {
              obj.price = `$${item.price}`;
            } else {
              obj.price = item.price;
            }
            if (item.oneTimeCharge !== ZERO_DOLLAR) {
              obj.oneTimePrice = item.oneTimeCharge;
            } else {
              obj.oneTimePrice = '';
            }
            devicesToReturn.push(obj);
          });
        } else if (this.futurePlan.devicesToReturn.constructor === Object) {
          let obj = {};
          obj.id = this.futurePlan.devicesToReturn.id;
          obj.name = this.futurePlan.devicesToReturn.name;
          if (this.futurePlan.devicesToReturn.price !== INCLUDED) {
            obj.price = `$${this.futurePlan.devicesToReturn.price}`;
          } else {
            obj.price = this.futurePlan.devicesToReturn.price;
          }
          if (this.futurePlan.devicesToReturn.oneTimeCharge !== ZERO_DOLLAR) {
            obj.oneTimePrice = this.futurePlan.devicesToReturn.oneTimeCharge;
          } else {
            obj.oneTimePrice = '';
          }
          devicesToReturn.push(obj);
        } else {
          devicesToReturn = false;
        }
      } else {
        devicesToReturn = false;
      }
      return devicesToReturn;
    }

    /**
     * @description Getter to return devices that to be kept
     *     along with prices of future planned Order Items otherwise it will return false.
     * @return devices
     */
    get getFuturePlanDevicesToKeep() {
      let devicesToKeep = [];
      if (this.futurePlan && this.futurePlan.devicesToKeep) {
        if (Array.isArray(this.futurePlan.devicesToKeep)
            && this.futurePlan.devicesToKeep.length > 0) {
          this.futurePlan.devicesToKeep.filter((item) => {
            let obj = {};
            obj.id = item.id;
            obj.name = item.name;
            if (item.price !== INCLUDED) {
              obj.price =  `$${item.price}`;
            } else {
              obj.price =  item.price;
            }
            if (item.oneTimeCharge !== ZERO_DOLLAR) {
              obj.oneTimePrice = item.oneTimeCharge;
            } else {
              obj.oneTimePrice = '';
            }
            devicesToKeep.push(obj);
          });
        } else if (this.futurePlan.devicesToKeep.constructor === Object) {
          let obj = {};
          obj.id = this.futurePlan.devicesToKeep.id;
          obj.name = this.futurePlan.devicesToKeep.name;
          if (this.futurePlan.devicesToKeep.price !== INCLUDED) {
            obj.price =  `$${this.futurePlan.devicesToKeep.price}`;
          } else {
            obj.price =  this.futurePlan.devicesToKeep.price;
          }
          if (this.futurePlan.devicesToKeep.oneTimeCharge !== ZERO_DOLLAR) {
            obj.oneTimePrice = this.futurePlan.devicesToKeep.oneTimeCharge;
          } else {
            obj.oneTimePrice = '';
          }
          devicesToKeep.push(obj);
        } else {
          devicesToKeep = false;
        }
      } else {
        devicesToKeep = false;
      }
      return devicesToKeep;
    }

    /**
     * @description Getter to return Recurring total charges of an Order.
     * @return order.recurringChargeTotal
     */
    get getRecurringCharges() {
      if (this.order && this.order.recurringChargeTotal) {
        return this.order.recurringChargeTotal;
      } else {
        return NOT_AVAILABLE;
      }
    }

    /**
     * @description Getter to return One-Time total charges of an Order.
     * @return order.oneTimeChargeTotal
     */
    get getOneTimeCharges() {
      if (this.order && this.order.oneTimeChargeTotal) {
        return this.order.oneTimeChargeTotal;
      } else {
        return NOT_AVAILABLE;
      }
    }
  }