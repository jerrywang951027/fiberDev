global with sharing class PrefixHelper implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod (String methodName,
                                 Map<String, Object> input,
                                 Map<String, Object> output,
                                 Map<String, Object> options) {
        try {
            if(methodName.equalsIgnoreCase('getPrefix')) {
                getPrefix(input,output,options);
                return true;
            }
            return false;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw ex;
        }                            
    }
    //get Prefix from Serial number
    private void getPrefix(Map<String, Object> input, Map<String, Object> output, Map<String, Object>options) {
        if(input != null){
            String SerialNumber = (String)input.get('SerialNumber');
            List<String> pref = SerialNumber.split('[^a-zA-Z]');
            System.debug(pref[0]);
            output.put('SerialNumberPrefix', pref[0]);
            output.put('Length', String.ValueOf(SerialNumber.length()));
        }    
    }
}