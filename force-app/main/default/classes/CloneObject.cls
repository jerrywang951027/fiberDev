/**
 *  @group CSR Console
 *  @description This class will be used to clone the records of an object and their child items.
 */
public class CloneObject {

  /**
   * @description This method clones an Order with related OrderItems.
   * @param inputMap This will have OrderId to be cloned.
   * @param outMap This will return the cloned order Id
   * @param options Any optional parameters
   * @return null
   */
  public void cloneOrderWithOrderProducts (Map <String, Object> input,
      Map <String, Object> output, Map <String, Object> options) {
    String orderId = ((String)input.get('OrderId') == null) ? '' : (String)input.get('OrderId') ;

    Order originalOrder = [
        SELECT
          Id,
          AccountId,
          EffectiveDate,
          vlocity_cmt__RequestDate__c,
          vlocity_cmt__RequestedStartDate__c,
          Status,
          Pricebook2Id, 
          vlocity_cmt__PriceListId__c,
          Type,
          Sub_Type__c, (
              SELECT
                Id,
                Product2.Id,
                Quantity,
                vlocity_cmt__JSONAttribute__c,
                vlocity_cmt__AssetId__c,
                ListPrice,
                UnitPrice,
                PricebookEntryId,
                vlocity_cmt__EffectiveOneTimeTotal__c,
                vlocity_cmt__AssetReferenceId__c,
                vlocity_cmt__OneTimeCharge__c,
                TotalPrice,
                vlocity_cmt__RecurringCharge__c
              FROM
                OrderItems
          )
          FROM
            Order
          WHERE
            Id = :orderId
    ] ;
    if (originalOrder != null) {
      Order clonedOrder = originalOrder.clone(false, true, true, true) ;
      insert clonedOrder ;

      List <OrderItem> orderProductList = originalOrder.OrderItems ;
      if (orderProductList.size() > 0) {
        List <OrderItem> orderProductCloneList = new List <OrderItem>() ;
        for (OrderItem orderProduct : orderProductList) {
          OrderItem orderProductCloned = orderProduct.clone(false, true, true, true) ;
          orderProductCloned.OrderId = clonedOrder.Id ;
          orderProductCloneList.add(orderProductCloned) ;
        }
        insert orderProductCloneList ;
      }
      output.put ('clonedOrderId', clonedOrder.Id) ;
    }
  }
}