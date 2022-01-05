global with sharing class CpqAppHandlerHookHelper implements vlocity_cmt.VlocityOpenInterface {

  /*
  * @name CpqAppHandlerHookHelper
  * @description CpqAppHandlerHookHelper Class to implement custom logic of CPQ
  * @param methodName to invoke, input contains data passed to function
  * return Boolean
  */
  global Boolean invokeMethod(String methodName, Map<String, Object> input,
      Map<String, Object> output, Map<String, Object> options) {

    try {
      // If condition to check for PostInvoke
      if ((methodName.equalsIgnoreCase('postCartsItems.PostInvoke')) ||
          (methodName.equalsIgnoreCase('putCartsItems.PostInvoke')) ||
          (methodName.equalsIgnoreCase('deleteCartsItems.PostInvoke')) ||
          (methodName.equalsIgnoreCase('getCartsItems.PostInvoke'))) {
        Id cartId = (Id) input.get('cartId');
        String cartObjectName = cartId.getSObjectType().getDescribe().getName();
        // Check cartId is order object id then call  cartsItemsPostInvoke method
        if (cartObjectName == 'Order') {
          cartsItemsPostInvoke(methodName, input, output,options);
        }
      }
      //return false if cartId is not order objet id
      return false;
    }
    catch (Exception ex) {
        return false;
    }
  }

  /*
  * @description : Find Order line Items with Action ADD and Product code = “Google WIFI Devices”
    and sum the quanity If the sum is greater than 4 then set Professional_Install_Required__c
    to true.
    If Order.ServicePoint.Model = GFLT100 and order items exists  with action ADD for BYOR/Gwifi
    and order item does not exist with action add -
    Network Box then set Professional_Install_Required__c to true.
  * @param methodName to invoke, input contains data passed to function
  */
  private void cartsItemsPostInvoke(String methodName, Map<String, Object> input,
      Map<String, Object> output, Map<String, Object> options) {

    //Boolean indicating Professional_Install_Required__c.
    Boolean proInstallReqFlag = false;
    //Boolean indicating NetworkBox orderItem.
    Boolean checkNetworkBoxFlag = false;
    //varible to check the Google WIFI Devices.
    Integer totalQty = 0;
    Boolean isProfessionalInstallPresent = false;
    Boolean isOntPresent = false;
    String cartId = (Id) input.get('cartId');
    // Fetching order and orderitems.
    Order orderRecord = [
        SELECT
          Id,
          vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__c,
          Professional_Install_Required__c,
          vlocity_cmt__DefaultServicePointId__c,
          vlocity_cmt__DefaultServicePointId__r.Model__c,
          (SELECT
             Id,
             Product2.vlocity_cmt__Type__c,
             Product2.vlocity_cmt__SubType__c,
             vlocity_cmt__Action__c,
             Quantity,
             vlocity_cmt__JSONAttribute__c
           FROM
             OrderItems)
         FROM
           Order
         WHERE
           Id = :cartId LIMIT 1];

    // iterate each orderitem
    if (orderRecord.OrderItems.size() > 0) {
      List<OrderItem> orderItems = orderRecord.OrderItems;
      for (OrderItem item : orderItems) {
        //jsonAttMap used to store vlocity_cmt__JSONAttribute__c data from  each orderItem.
        Map<String, Object> jsonAttMap =
            (Map<String, Object>) JSON.deserializeUntyped(Item.vlocity_cmt__JSONAttribute__c );
        //ATT_CPE refers attribute category
        if (Constants.PRODUCT.TYPE.EQUIPMENT.equalsIgnoreCase(
            item.Product2.vlocity_cmt__Type__c) &&
            jsonAttMap.containsKey('ATT_CPE') && Item.Quantity != null) {
          //List of attribute details.
          List<Object> cpeAttributeList = (List<Object>)jsonAttMap.get('ATT_CPE');
          //iterate throgh each attribute data.
          for (Object attData : cpeAttributeList) {
            Map<String, Object> eachAttbuteRecordMap = (Map<String, Object>)AttData;
            //check if CPE Type is "Google Wifi" refernce for Google wifi devices.
            if (eachAttbuteRecordMap.containsKey('attributeuniquecode__c') &&
                eachAttbuteRecordMap.get('attributeuniquecode__c') == 'ATTR_CPE_TYPE' &&
                eachAttbuteRecordMap.get('value__c')=='Google Wifi' &&
                Item.vlocity_cmt__Action__c =='Add') {
              //sum the Google wifi device
              totalQty = totalQty + (integer)Item.Quantity;
              if (orderRecord.vlocity_cmt__DefaultServicePointId__r.MODEL__c == 'GFLT100') {
                proInstallReqFlag= true; //proInstallReqFlag set true when order.ServicePoint.model is 'GFLT100'.
              }
            }
            //check if CPE Type is "Customer Router" refernce for BOYR device.
            else if (eachAttbuteRecordMap.containsKey('attributeuniquecode__c') &&
                eachAttbuteRecordMap.get('attributeuniquecode__c') == 'ATTR_CPE_TYPE' &&
                eachAttbuteRecordMap.get('value__c') == 'BYOR' &&
                Item.vlocity_cmt__Action__c =='Add') {
              if (orderRecord.vlocity_cmt__DefaultServicePointId__r.MODEL__c == 'GFLT100') {
                //proInstallReqFlag set true when order.ServicePoint.model is 'GFLT100'.
                proInstallReqFlag= true;
              }
            }
            //check if CPE Type is "Network box Standard" refernce for Network Box device.
            else if (eachAttbuteRecordMap.containsKey('attributeuniquecode__c') &&
                eachAttbuteRecordMap.get('attributeuniquecode__c') == 'ATTR_CPE_TYPE' &&
                eachAttbuteRecordMap.get('value__c') == 'Network box Standard' &&
                Item.vlocity_cmt__Action__c == 'Add') {
              if (orderRecord.vlocity_cmt__DefaultServicePointId__r.MODEL__c == 'GFLT100') {
                //checkNetworkBoxFlag set true when order.ServicePoint.model is 'GFLT100'.
                checkNetworkBoxFlag = true;
              }
            }
            eachAttbuteRecordMap.clear();
          }
          cpeAttributeList.clear();
        }
        jsonAttMap.Clear();
        isProfessionalInstallPresent = isProfessionalInstallPresent ||
          Constants.PRODUCT.SUB_TYPE.PROFESSIONAL_INSTALL.equalsIgnoreCase(
            item.Product2.vlocity_cmt__SubType__c);
        isOntPresent = isOntPresent || (Constants.PRODUCT.SUB_TYPE.ONT
          .equalsIgnoreCase(item.Product2.vlocity_cmt__SubType__c) &&
          Constants.ORDER_ITEM.ACTION.ADD.equalsIgnoreCase(
          item.vlocity_cmt__Action__c));
      }
    }

    if(!String.isBlank(orderRecord
        .vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__c)) {
      String premiseId =
        orderRecord.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PremisesId__c;
      List<String> validNetworkTerminalTypes = new List<String>{
        Constants.SERVICE_POINT.NETWORK_TERMINAL_TYPE.FIBER_JACK,
        Constants.SERVICE_POINT.NETWORK_TERMINAL_TYPE.OPTICAL_CONNECTOR
      };
      vlocity_cmt__ServicePoint__c servicePoint = [
          SELECT
            Id
          FROM
            vlocity_cmt__ServicePoint__c
          WHERE
            vlocity_cmt__PremisesId__c =
            :premiseId
          AND
            vlocity_cmt__Status__c =
              :Constants.SERVICE_POINT.STATUS.CONNECTED
          AND
            Network_Terminal_Type__c = :validNetworkTerminalTypes
          LIMIT 1
      ];
      if(!(isProfessionalInstallPresent && isOntPresent) &&
          orderRecord.OrderItems.size() > 0) {
        if(servicePoint != null) {
          orderRecord.vlocity_cmt__DefaultServicePointId__c = servicePoint.Id;
        }
      } else{
        orderRecord.vlocity_cmt__DefaultServicePointId__c = null;
      }
    }
    
    //update order Professional_Install_Required__c field
    if (totalQty > 4 || (proInstallReqFlag == True && checkNetworkBoxFlag == false)) {
      orderRecord.Professional_Install_Required__c = true;
      update orderRecord;
    } else {
      orderRecord.Professional_Install_Required__c = false;
      update orderRecord;
    }
    //call runCartValidation methos to rerun the validations.
    vlocity_cmt.CpqAppHandler cpqAppHandler = new  vlocity_cmt.CpqAppHandler();
    Map<String, Object> inputs = new Map<String, Object>();
    Map<String, Object> outputMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    inputs.put('cartId', cartId );
    inputs.put('price', false);
    inputs.put('validate', true);
    inputs.put('methodName', 'runCartValidation');
    cpqAppHandler.invokeMethod('runCartValidation', inputs, outputMap, optionsMap);
  }
}