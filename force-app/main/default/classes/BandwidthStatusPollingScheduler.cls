public with sharing class BandwidthStatusPollingScheduler implements Schedulable {
  public static final String CLASS_NAME = 'BandwidthStatusPollingScheduler';
  public static final String METHOD_NAME = 'execute';
  public static final String EXTRACT_FRL_FOR_POLLING = 'XOM_ExtractFrlForBandwidthStatusPolling';
  
  // Keys for event type in BandWidth_Status_Polling__e.
  public static final String EVENT_TYPE_E911 = 'E911';
  public static final String EVENT_TYPE_PORTIN = 'PortIn';
  public static final String INPUT_MAP_FRL_KEY = 'frl';
  public static final String INPUT_MAP_ASYNC_STATUS_KEY = 'asyncTransactionStatus';
  public static final String INPUT_MAP_TELEPHONE_NUMBER_KEY = 'telephoneNumber';
  public static final String INPUT_MAP_FRL_ID_KEY = 'frlId';
  public static final String INPUT_MAP_ORDER_ID_KEY = 'orderId';
  public static final String INPUT_MAP_SERVICE_ACCOUNT_ID_KEY = 'serviceAccountId';
  public static final String INPUT_MAP_E911_ORDER_ID_KEY = 'e911OrderId';
  public static final String INPUT_MAP_PORTIN_ORDER_ID_KEY = 'portInOrderId';
  public static final String INPUT_MAP_PORTIN_KEY = 'Port-in';
  public static final String INPUT_MAP_E911_ORDER_STATUS_KEY = 'e911OrderStatus';
  public static final String INPUT_MAP_PORTIN_ORDER_STATUS_KEY = 'portInOrderStatus';

  /**
   * @description This method is mandatory for scheduler
   * It contains the logic of fetch FRLs and publish the event.
   */
  public void execute(SchedulableContext ctx) {
    try {
      Map<String, Object> inputMap = new Map<String, Object>();
      //Call the DataRaptor to get the qualified FRLs.
      vlocity_cmt.DRProcessResult result = 
          vlocity_cmt.DRGlobal.processObjectsJSON(json.serialize(inputMap), EXTRACT_FRL_FOR_POLLING);
      //Deserialize the DataRaptor output for processing in Apex.
      Map<String, Object> myTransformResult = (Map<String, Object>)result.toJson();
      List<Bandwidth_Status_Polling__e > listOfBandwidthEvent = new List<Bandwidth_Status_Polling__e>();
      if (myTransformResult.containsKey(INPUT_MAP_FRL_KEY)) {
        List<Object> techAttributeList = (List<Object>)myTransformResult.get(INPUT_MAP_FRL_KEY);
        for (Object attData : techAttributeList) {
          Map<String, Object> eachAttbuteRecordMap = (Map<String, Object>)attData;
          // Create event objects.
          String asyncStatus = getNodeValue(eachAttbuteRecordMap, INPUT_MAP_ASYNC_STATUS_KEY);
          if (asyncStatus.containsIgnoreCase(EVENT_TYPE_E911)) {
            String bandwidthOrderId = 
              getNodeValue(eachAttbuteRecordMap, INPUT_MAP_E911_ORDER_ID_KEY);
            if (bandwidthOrderId != null) {
              String currentStatus =
                getNodeValue(eachAttbuteRecordMap, INPUT_MAP_E911_ORDER_STATUS_KEY);
              Bandwidth_Status_Polling__e newEvent = mapBandwidthStatusPolling (
                eachAttbuteRecordMap, bandwidthOrderId, currentStatus, EVENT_TYPE_E911);
              listOfBandwidthEvent.add(newEvent);
            }
          }
          if (asyncStatus.containsIgnoreCase(INPUT_MAP_PORTIN_KEY)) {
            String bandwidthOrderId = 
              getNodeValue(eachAttbuteRecordMap, INPUT_MAP_PORTIN_ORDER_ID_KEY);
            if (bandwidthOrderId != null) {
              String currentStatus = 
                getNodeValue(eachAttbuteRecordMap, INPUT_MAP_PORTIN_ORDER_STATUS_KEY);
              Bandwidth_Status_Polling__e newPortInEvent = mapBandwidthStatusPolling (
                eachAttbuteRecordMap, bandwidthOrderId, currentStatus, EVENT_TYPE_PORTIN);
              listOfBandwidthEvent.add(newPortInEvent);
            }
          } 
        }
      }
      // Call method to publish events.
      List<Database.SaveResult> results = EventBus.publish(listOfBandwidthEvent);
    }
    // Exception occured. Throw exception.
    catch (Exception ex) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, ex);
      throw ex;
    }
  }

  /**
   * @description This method is creating the instance of event
   * and mapping the values.
   */
  private Bandwidth_Status_Polling__e mapBandwidthStatusPolling (
    Map<String, Object> eachAttbuteRecordMap,
    String bandwidthOrderId,
    String currentStatus,
    String eventType) 
  {
    Bandwidth_Status_Polling__e newPortInEvent = new Bandwidth_Status_Polling__e (
      Current_Status__c = currentStatus,
      TN__c = getNodeValue(eachAttbuteRecordMap, INPUT_MAP_TELEPHONE_NUMBER_KEY),
      FRL_Id__c = getNodeValue(eachAttbuteRecordMap, INPUT_MAP_FRL_ID_KEY),
      OM_Order_Id__c = getNodeValue(eachAttbuteRecordMap, INPUT_MAP_ORDER_ID_KEY),
      Service_AccountId__c = getNodeValue(eachAttbuteRecordMap, INPUT_MAP_SERVICE_ACCOUNT_ID_KEY),
      Bandwidth_Order_Id__c = bandwidthOrderId,
      Event_Type__c = eventType
    );
    return newPortInEvent;
  }
    
  /**
   * @description This method is returning
   * the value of given node
   */
  private String getNodeValue (
    Map<String, Object> attributeMap,
    String node) 
  {
    if ( attributeMap.containsKey(node) && attributeMap.get(node) != null) {
      return (String)attributeMap.get(node);
    } else {
      return null;
    }
  }
}