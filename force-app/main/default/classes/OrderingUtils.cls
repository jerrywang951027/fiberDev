/**
 * @group OrderingUtils
 * @description This class will split the order
 * is being used as a Remote Acion.
 */
global with sharing class OrderingUtils implements vlocity_cmt.VlocityOpenInterface {
  public static final String CLASS_NAME = 'OrderingUtils';

  /**
   * @description This method is mandatory for Vlocity Open Interface.
   */
  global Boolean invokeMethod(
      String methodName,
      Map<String, Object> inputMap,
      Map<String, Object> outMap,
      Map<String, Object> options)
  {
    try {
      if (methodName.equals('splitorderitem')) {
        splitOrderItems(inputMap, outMap, options);
        for (Map<String, Object> outMapIns : (List<Map<String, Object>>)outMap.get('results')) {
          if ((outMapIns.get('errMessage') != null
              && (!((String)outMapIns.get('errMessage')).contains('NO_JOB')))
            || (outMapIns.get('errorCode') != null && outMapIns.get('errorCode') != 'INVOKE-200')) {
            throw new OrderingUtilsException(''+outMapIns.get('errMessage'));
          }
        }
      }
    } catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, methodName, e);
      throw e;
    }
    return true;
  }

  /**
   * @description This method is acception inputMap which actually
   * containing order id and getting OrderItem.
   */
  public void splitOrderItems(
      Map<String, Object> inputMap,
      Map<String, Object> outMap,
      Map<String, Object> options)
  {
    String orderId = (String) inputMap.get('orderId');
    outMap.put('results', new List<Map<String, Object>>());
    List<OrderItem> orderItemList = [
      SELECT
        Id,
        orderId,
        vlocity_cmt__ParentItemId__c
      FROM
        OrderItem
      WHERE
        orderId = :orderId
      ORDER BY
        vlocity_cmt__LineItemNumber__c
    ];
    for (OrderItem oi : orderItemList) {
      splitIndividualOrderItem(oi, outMap);
    }
  }

  /**
   * @description This method is taking OrderItem and calling
   * DefaultSplitProductImplementation to invoke split.
   */
  private void splitIndividualOrderItem(OrderItem oi, Map<String, Object> outMap) {
   // replace with any valid OrderItem Id, can also be used for OpportunityItems or QuoteLineItems
    vlocity_cmt.ProductLineItemActionParam productLineItemActionParam =
        new vlocity_cmt.ProductLineItemActionParam();
    productLineItemActionParam.action = 'Split';
    productLineItemActionParam.parentId = oi.OrderId;
    productLineItemActionParam.lineItemId = oi.Id;

    productLineItemActionParam.itemInfoMap = new Map<String, Object>();
    Map<String, Object> inputMap = new Map<String, Object>();
    inputMap.put('SplitProduct', productLineItemActionParam);
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    vlocity_cmt.DefaultSplitProductImplementation split =
        new vlocity_cmt.DefaultSplitProductImplementation();
    split.invokeMethod('SplitProduct', inputMap, outputMap, optionsMap);
    ((List<Map<String, Object>>)outMap.get('results')).add(outputMap);
  }
  /**
   * @description This is inner class for handling exception related to OrderingUtils.
   */
  private class OrderingUtilsException extends Exception {}
}