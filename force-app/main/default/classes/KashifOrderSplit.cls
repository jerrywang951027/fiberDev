public with sharing class KashifOrderSplit {
    public KashifOrderSplit() {

    }

    private List<OrderItem> processEVPLBundles(List<OrderItem> lstParentOLIs){
        Set<OrderItem> setParentOLIsTemp = new Set<OrderItem>(lstParentOLIs);
        Set<OrderItem> setEVPLBundleParents = new Set<OrderItem>();
        //EVPL Bundle Parent Product Code
        String EVPLHostProductCode = 'ENT_ETH_EVPL_0002';
        String EVPLRemoteProductCode = 'ENT_ETH_EVPL_0010';
        //1// EVPL Host Extraction
        for(OrderItem oli : lstParentOLIs) {
            List<OrderItem> lstEVPLBundle = null;
            if(oli.Product2.ProductCode == EVPLHostProductCode){
                setEVPLBundleParents.add(oli);
                //All EVPL bundles stay together in one sub Order
                Boolean containsGroup = finalSubOrderGroups.containsKey(EVPLHostProductCode);
                if(containsGroup){
                    //Dont add duplicate
                    //No Need for this//mapOliGrps.get(oli.vlocity_cmt_LineNumber_c).add(oli);
                }
                else{
                   //Create the new subOrderGroup for this EVPL Parent
                   lstEVPLBundle = new List<OrderItem>();
                   lstEVPLBundle.add(oli);
                   finalSubOrderGroups.put(EVPLHostProductCode, lstEVPLBundle);
                }
                //Remove the item from the set
                setParentOLIsTemp.remove(oli);
            }
        }
        //Find all the OLIs which has LineNumber starting with the lineNumber of EVPLBundleParent
        for(OrderItem oliEBP : setEVPLBundleParents){
            String lineNumber = oliEBP.vlocity_cmt_LineNumber_c;
            for(OrderItem oli : lstParentOLIs) {
                if((oli.vlocity_cmt_LineNumber_c).startsWith(oliEBP.vlocity_cmt_LineNumber_c + '.')){
                    finalSubOrderGroups.get(EVPLHostProductCode).add(oli);
                    //Remove the item from the set
                    setParentOLIsTemp.remove(oli);
                }
            }
        }
        //2//UNI Extraction (UNI_Host/UNI_Remote)
        Set<OrderItem> setUNIOLIs = new Set<OrderItem>();
        for(OrderItem oli : lstParentOLIs) {
            if(oli.Product2.ProductCode == EVPLRemoteProductCode){
                //Get UNI_Host & UNI_Remote
                String uniHostId = oli.UNI_Host__c;
                String uniRemoteId = oli.UNI_Remote__c;
                if(String.isNotBlank(uniHostId) || String.isNotBlank(uniRemoteId)){
                    for(OrderItem oli2 : lstParentOLIs) {
                        //UNI Host
                        if(String.isNotBlank(uniHostId) && oli2.Id == uniHostId){
                            setUNIOLIs.add(oli2);
                            setParentOLIsTemp.remove(oli2);
                        }
                        //UNI Remote
                        if(String.isNotBlank(uniRemoteId) && oli2.Id == uniRemoteId){
                            setUNIOLIs.add(oli2);
                            setParentOLIsTemp.remove(oli2);
                        }
                    }
                }
            }
        }
        //Add UNI items to the final list
        for(OrderItem oli : setUNIOLIs){
            finalSubOrderGroups.get(EVPLHostProductCode).add(oli);
        }
        return new List<OrderItem>(setParentOLIsTemp);
    }
}
