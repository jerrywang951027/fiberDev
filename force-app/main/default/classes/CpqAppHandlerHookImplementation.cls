global with sharing class CpqAppHandlerHookImplementation implements vlocity_cmt.VlocityOpenInterface
{
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        
        try
        {
            System.debug('____ CpqAppHandlerHookImplementation ' + methodName);
            
            if (( methodName.equalsIgnoreCase('postCartsItems.PreInvoke'))  || ( methodName.equalsIgnoreCase('putCartsItems.PreInvoke')) 
                || ( methodName.equalsIgnoreCase('deleteCartsItems.PreInvoke')) || ( methodName.equalsIgnoreCase('getCartsItems.PreInvoke')))
            {
                
                //String cartSObjType = (input.get('cartId'));
                // if(cartSObjType == 'Order')
                {
                    CartsItems_PreInvoke(methodName, input, output,options);
                }
                return true;
            }
            
            return false;
        }
        catch (Exception ex)
        {
            System.debug('--- Exception: ' + ex.getMessage());
            System.debug('--- Stack Trace: ' + ex.getStackTraceString());
            throw ex;
        }
    }
    private void CartsItems_PreInvoke(String methodName, Map <String, Object> input,  Map<String, Object> output, Map <String,Object> options)
    {
        Decimal cartQty = 0;
        String Accidentifier =null;
        List<OrderItem> Item = (List<OrderItem>)input.get('items'); 
        // will use object and we can object type
        List<Order> O = (List<Order>)input.get('cartId');
        
        for(OrderItem It  : Item) 
        {
            if(It.Product2.ProductCode == 'C-ISP-004')
            {
                cartQty= cartQty+It.Quantity;
            }
        }
        for(Order Ord  : O) 
        {
            Accidentifier = Ord.AccountId;
            break;
        }
        List<Asset> Qt =  [Select Quantity from Asset where  ProductCode= 'C-ISP-004' And AccountId = :Accidentifier];
        for(Asset quantities : Qt){
            cartQty = quantities.Quantity + cartQty;
        }
        String fieldname = 'Installation_Type__c';
        if( cartQty > 4 ) {	
            input.put(fieldname,'Professional Installation');
        }
        else
        {
            input.put(fieldname,'Self Installation');
        }
    }
}