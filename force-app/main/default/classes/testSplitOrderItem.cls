global with sharing class testSplitOrderItem implements vlocity_cmt.VlocityOpenInterface {
  global testSplitOrderItem() {
  }

  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    Boolean result = true;
    try {
      if (methodName.equals('splitorderitem')) {
        splitorderitem(inputMap, outMap, options);
      } else {
        result = false;
      }
    } catch (Exception e) {
      System.debug('invokeMethod -> exception: ' + e);
      result = false;
    }

    return result;
  }

  void splitorderitem(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    String orderId = (String) inputMap.get('orderId');
    System.debug(' order Id is : ' + orderId);
    OrderItem[] oiList = [
      SELECT id, orderId, vlocity_cmt__ParentItemId__c
      FROM OrderItem
      WHERE orderId = :orderId
      ORDER BY vlocity_cmt__LineItemNumber__c
    ];
    System.debug('retrieved order items list : ' + oiList);

    for (OrderItem oi : oiList) {
        Map<String, Object> outputMap = new Map<String, Object>();
        splitIndividualOrderItem(oi, outputMap);
    }

  }

  void splitIndividualOrderItem(OrderItem oi, Map<String, Object> outMap) {
    // replace with any valid OrderItem Id, can also be used for OpportunityItems or QuoteLineItems
    vlocity_cmt.ProductLineItemActionParam productLineItemActionParam = new vlocity_cmt.ProductLineItemActionParam();
    productLineItemActionParam.action = 'Split';
    productLineItemActionParam.parentId = oi.OrderId;
    productLineItemActionParam.lineItemId = oi.id;
    Map<String, Object> itemInfoMap = new Map<String, Object>();

    productLineItemActionParam.itemInfoMap = itemInfoMap;
    Map<String, Object> inputMap1 = new Map<String, Object>();
    inputMap1.put('SplitProduct', productLineItemActionParam);
    system.debug('inputMap: ' + inputMap1);
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    vlocity_cmt.DefaultSplitProductImplementation split = new vlocity_cmt.DefaultSplitProductImplementation();
    split.invokeMethod('SplitProduct', inputMap1, outputMap, optionsMap);
    System.debug('outputMap: ' + outputMap);
  }
}