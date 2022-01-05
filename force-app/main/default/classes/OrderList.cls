/**
 *  @group CSR Console
 *  @description Controller for orderList LWC.
 *  This will fetch Orders and their related OrderItems of a selected Premises.
 */
global class OrderList implements vlocity_cmt.VlocityOpenInterface2 {

  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * fetchOrderOrderItemDetails method.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  global Boolean invokeMethod(String methodName, Map<String,Object> inputMap,
      Map<String,Object> outMap, Map<String,Object> options) {

    Boolean result = true;
    try {
      if ('fetchOrderDetails'.equalsIgnoreCase(methodName)) {
        fetchOrderDetails(inputMap, outMap, options);
      }
    }
    catch (Exception e) {
      result = false;
      LoggingUtility.insertExceptionLog('OrderListController', 'invokeMethod', e);
    }
    return result;
  }

  /**
   * @description This method fetches Order with related OrderItems.
   * @param inputMap This will have PremisesId.
   * @param outMap This will return the data of list of Orders and related OrderItems.
   * @param options Any optional parameters
   * @return null
   */
  public void fetchOrderDetails(Map<String,Object> inputMap,
      Map<String,Object> outMap, Map<String,Object> options) {

    try {
      String serviceAccountId = String.valueof(inputMap.get('serviceAccountId'));
      Map<String,OrderWrapper> orderWrapperByOrderId = new Map<String,OrderWrapper>();
      Map<String,OrderItem> orderItemById;
      // childItemByChildItemId this will have parent order item as key and its
      // child order item as value
      Map<String,OrderItemWrapper> childItemByChildItemId = new Map<String,OrderItemWrapper>();
      Map<String,List<OrderItemWrapper>> childItemsByOrderId =
          new Map<String,List<OrderItemWrapper>>();
      List<OrderItem> orderItems = new List<OrderItem>();
      if (serviceAccountId != null) {
        for (Order orderObject : [
            SELECT
              Id,
              OrderNumber,
              Type,
              vlocity_cmt__FulfilmentStatus__c,
              vlocity_cmt__OrderStatus__c,
              vlocity_cmt__SupersededOrderId__r.OrderNumber,
              vlocity_cmt__SupplementalAction__c
            FROM
              Order
            WHERE
              vlocity_cmt__DefaultServiceAccountId__c = :serviceAccountId
              AND vlocity_cmt__FulfilmentStatus__c != :Constants.ORDER.STATUS.SUPERSEDED
            ORDER BY OrderNumber DESC
        ]) {
          OrderWrapper orderWrap = new OrderWrapper();
          orderWrap.order = orderObject;
          orderWrapperByOrderId.put(orderObject.Id, orderWrap);
        }
        orderItemById = new Map<String,OrderItem>([
            SELECT
              Id,
              OrderId,
              vlocity_cmt__RootItemId__c,
              vlocity_cmt__ParentItemId__c,
              Order.vlocity_cmt__FulfilmentStatus__c,
              Order.Type,
              Quantity,
              Equipment_Returned__c,
              Product2Id,
              Product2.Name,
              vlocity_cmt__OneTimeCharge__c,
              vlocity_cmt__RecurringCharge__c,
              vlocity_cmt__Action__c,
              vlocity_cmt__SubAction__c,
              vlocity_cmt__IsChangesAllowed__c,
              Equipment_Ownership__c,
              Equipment_Return_Status__c,
              vlocity_cmt__SupplementalAction__c
            FROM
              OrderItem
            WHERE
              OrderId IN :orderWrapperByOrderId.keySet()
            ORDER BY
              vlocity_cmt__ParentItemId__c NULLS FIRST
        ]);
        for (OrderItem orderItemObject : orderItemById.values()) {
          if (!childItemByChildItemId.containsKey(orderItemObject.Id)) {
            childItemByChildItemId.put(orderItemObject.Id, new OrderItemWrapper(orderItemObject));
          }
          OrderItemWrapper currentOrderItemWrap = childItemByChildItemId.get(orderItemObject.Id);
          if (currentOrderItemWrap.parentItemId != null) {
            if (childItemByChildItemId.containsKey(currentOrderItemWrap.parentItemId)) {
              if (childItemByChildItemId.get(currentOrderItemWrap.parentItemId).childOrderItems ==
                  null) {
                childItemByChildItemId.get(currentOrderItemWrap.parentItemId).childOrderItems =
                  new List<OrderItemWrapper>();
              }
              childItemByChildItemId.get(currentOrderItemWrap.parentItemId).
                  childOrderItems.add(currentOrderItemWrap);
            }
          } else {
              List<OrderItemWrapper> parentOrderItems = new List<OrderItemWrapper>();
              if (childItemsByOrderId.containsKey(currentOrderItemWrap.orderId) ) {
                parentOrderItems = childItemsByOrderId.get(currentOrderItemWrap.orderId);
              }
              parentOrderItems.add(currentOrderItemWrap);
             childItemsByOrderId.put(currentOrderItemWrap.orderId, parentOrderItems);
            }
        }
        for (String orderId : orderWrapperByOrderId.keySet()) {
          if (childItemsByOrderId.containsKey(orderId)) {
            orderWrapperByOrderId.get(orderId).orderItems = new List<OrderItemWrapper>();
            orderWrapperByOrderId.get(orderId).orderItems.addAll(childItemsByOrderId.get(orderId));
          }
        }
      }
      outMap.put('orderList', JSON.serialize(orderWrapperByOrderId.values()));
    } catch (Exception e) {
      LoggingUtility.insertExceptionLog('OrderListController',
          'fetchOrderOrderItemDetails', e);
      throw e;
    }
  }

 /**
  * @description Wrapper class to hold information about Orders
  * and their related OrderItems.
  */
  public Class OrderWrapper {
    public Order order;
    public List<OrderItemWrapper> orderItems;
  }

 /**
  * @description Wrapper class to hold information about OrderItems
  * and their related child OrderItems.
  */
  public Class OrderItemWrapper {
    public String orderItemId;
    public String orderId;
    public String productName;
    public Decimal quantity;
    public String status;
    public String type;
    public String parentItemId;
    public Decimal oneTimeCharge;
    public Decimal recurringCharge;
    public String action;
    public String subAction;
    public Boolean equipmentReturned;
    public String equipmentReturnStatus;
    public Boolean isChangeAllowed;
    public String equipmentOwnership;
    public String supplementalAction;
    public List<OrderItemWrapper> childOrderItems;
    public OrderItemWrapper(OrderItem orderItemObject){
      this.orderItemId = orderItemObject.Id;
      this.orderId = orderItemObject.orderId;
      this.productName = orderItemObject.Product2.Name;
      this.quantity = orderItemObject.Quantity;
      this.status = orderItemObject.Order.vlocity_cmt__FulfilmentStatus__c;
      this.type = orderItemObject.Order.Type;
      this.oneTimeCharge = orderItemObject.vlocity_cmt__OneTimeCharge__c;
      this.parentItemId = orderItemObject.vlocity_cmt__ParentItemId__c;
      this.recurringCharge = orderItemObject.vlocity_cmt__RecurringCharge__c;
      this.action = orderItemObject.vlocity_cmt__Action__c;
      this.subAction = orderItemObject.vlocity_cmt__SubAction__c;
      this.equipmentReturned = orderItemObject.Equipment_Returned__c;
      this.equipmentReturnStatus = orderItemObject.Equipment_Return_Status__c;
      this.isChangeAllowed = orderItemObject.vlocity_cmt__IsChangesAllowed__c;
      this.equipmentOwnership = orderItemObject.Equipment_Ownership__c;
      this.supplementalAction = orderItemObject.vlocity_cmt__SupplementalAction__c;
    }
  }
}