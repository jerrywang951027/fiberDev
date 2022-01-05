/**
 * @group Console Utils
 * @description Collection of methods for console including entry method for VIP
 */
global class ConsoleUtils implements vlocity_cmt.VlocityOpenInterface{
  /**
   * @description used in the generateRandomId method to create a random Id
   */
  global static String SEPARATOR = '-';

  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * fetchOrderOrderItemDetails method.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method 
   * @param outMap A map to store output information in  
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  global Boolean invokeMethod(String methodName,
      Map<String,Object> input, 
      Map<String,Object> output,
      Map<String,Object> options) {
    try {
      if (methodName.equals('generateRandomNumber')) {
        generateRandomNumber(input, output, options);
      } else if (methodName.equalsIgnoreCase('generateKey')) {
        generateKey(input, output, options);
      } else if (methodName.equalsIgnoreCase('countEquipmentMethod')) {
        countEquipments(input, output, options);
      } else if (methodName.equalsIgnoreCase('cloneOrderWithOrderProducts')) {
        cloneOrderWithOrderProducts(input, output, options);
      }
    return true;
    } catch(Exception e) {
        system.debug('e message = '+e.getLineNumber());
        system.debug('e message = '+e.getCause());
      return false;
    }
  }

  /**
   * @description implementation of the method that invokes the generateRandomId
   * at KeyGenerator, which will return unique account id
   * @param inputMap The key value pair that will be passed to the invoked method
   * @param outMap map that will receive the map of the response
   * @param options map optional parameters
   */ 
  public void generateKey(Map<String,Object> inputMap, 
      Map<String,Object> outputMap,
      Map<String,Object> options){
    String keyPrefix = (String)inputMap.get('prefix');
    Integer keyTotalLength = (Integer)inputMap.get('totalLength');
    Integer keySegmentSize = (Integer)inputMap.get('segmentSize');

    String returnedKey =
    KeyGenerator.generateRandomId(keyPrefix, keyTotalLength , keySegmentSize);
    outputMap.put('returnedKey',returnedKey);
  }

  /**
   * @description implementation of the method that invokes the generateRandomNumber
   * at KeyGenerator, which will return unique account id
   * @param inputMap The key value pair that will be passed to the invoked method
   * @param outMap map that will receive the map of the response
   * @param options map optional parameters
   */   
  public void generateRandomNumber(Map<String,Object> inputMap, 
      Map<String,Object> outputMap,
      Map<String,Object> options){
    String randomNumber =  KeyGenerator.generateRandomNumber();
    outputMap.put('returnedKey', randomNumber);
  }

  /**
   * @description method to invoke filtering and counting the equipments.
   * @param inputMap OrderItems will be passed as input parameter.
   * @param outMap map that will receive the map of the response
   * @param options map optional parameters
   */
  public void countEquipments(Map<String,Object> inputMap, 
      Map<String,Object> outputMap,
      Map<String,Object> options){
    EquipmentUtils EquipmentUtilsObject = new EquipmentUtils();
    EquipmentUtilsObject.countEquipmentMethod(inputMap, outputMap, options);
  }
  
  /**
   * @description method to invoke cloning an Order with related OrderItems.
   * @param inputMap map that will have OrderId to be cloned.
   * @param outMap map that will receive the map of the response
   * @param options map optional parameters
   */
  public void cloneOrderWithOrderProducts (Map <String, Object> inputMap, 
      Map <String, Object> outputMap,
      Map <String, Object> options){
    CloneObject clonedObject = new CloneObject() ;
    clonedObject.cloneOrderWithOrderProducts (inputMap, outputMap, options) ;
  }  
}