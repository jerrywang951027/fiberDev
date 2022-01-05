/**
 *  @group Pause guided flow
 *  @description to update Order Item action and status fields when Order is Paused.
 */
global with sharing class CartUtils implements vlocity_cmt.VlocityOpenInterface {
  /**
   * @description The VlocityOpenInterface2 method override to dynamically call method.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  global Boolean invokeMethod(String methodName, Map<String, Object> inputMap,
      Map<String, Object> outMap, Map<String, Object> options) {
    Boolean result = true;
    try {
      if (methodName.equals('updateOrderProduct')) {
        updateOrderItem(inputMap, outMap, options);
      }
      else {
        result = false;
      }
    }
    catch (Exception e) {
      result = false;
      LoggingUtility.insertExceptionLog('CartUtils', 'invokeMethod', e);
    }
    return result;
  }

  /**
   * @description This method fetches OrderItems related to Order and
   * updates the action, subAction and provisioning status of it to Pause.
   * @param inputMap This will have fdoId - OrderId.
   * @param outMap This will return the data of list of Orders and related OrderItems.
   * @param options Any optional parameters
   */
  void updateOrderItem(Map<String, Object> inputMap, Map<String, Object> outMap,
      Map<String, Object> options) {
    String orderId = (String)inputMap.get('fdoId');
    String status = (String)inputMap.get('status');
    String actionType = (String)inputMap.get('actionType');
    String subAction = (String)inputMap.get('subAction');
    List<OrderItem> updateOrderItemList = new List<OrderItem>();
    List<OrderItem> orderItemList = [
        SELECT
          Id,
          vlocity_cmt__Action__c,
          vlocity_cmt__ProvisioningStatus__c,
          vlocity_cmt__SubAction__c
        FROM
          OrderItem
        WHERE OrderId = :orderId];
    if (orderItemList != null && orderItemList.size() > 0) {
      for (OrderItem orderItemRecord : orderItemList) {
        orderItemRecord.vlocity_cmt__Action__c = actionType;
        orderItemRecord.vlocity_cmt__ProvisioningStatus__c = status;
        orderItemRecord.vlocity_cmt__SubAction__c = subAction;
        updateOrderItemList.add(orderItemRecord);
      }
      if (updateOrderItemList != null && updateOrderItemList.size() > 0) {
        update updateOrderItemList;
      }
    }
  }
}