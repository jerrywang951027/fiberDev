/**
 * @group ZuoraUtils
 * @description This class will check for subscription and 
 * provide the rate plan id node.
 * is being used as a Remote Acion.
 */
public with sharing class ZuoraUtils {
  // Initialize class constants.
  public static final String CLASS_NAME = 'ZuoraUtils';
  public static final String ADD_ZUORA_RATE_PLANID_METHOD_NAME = 'addzuorarateplanid';
  public static final String INVOKE_METHOD_NAME = 'invokeMethod';

  // Keys for error messages.
  public static final String ERROR_MESSAGE_METHOD_NAME_BLANK = 'Method name is not provided';
    
  // Keys for input map.
  public static final String INPUT_MAP_FIBER_BILLING_LINE_KEY = 'fiberBillingCFSLine';
  public static final String INPUT_MAP_REMOVE_PRODUCT_KEY = 'removeProducts';
  public static final String INPUT_MAP_UPDATE_PRODUCT_KEY = 'updateProducts';
  public static final String INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY = 'removedProductsChangeOfPlan';
  public static final String INPUT_MAP_ZUORA_INSTANCE_ID_KEY = 'zuoraProductInstanceID';
  public static final String INPUT_MAP_RATE_PLAN_ID_KEY = 'ratePlanId';
  /**
   * @description This method is mandatory for Vlocity Open Interface.
   
  global Boolean invokeMethod(
      String methodName,
      Map<String, Object> inputMap,
      Map<String, Object> outMap,
      Map<String, Object> options)
  {
    try {
      if(ADD_ZUORA_RATE_PLANID_METHOD_NAME.equalsIgnoreCase(methodName)) {
        addZuoraRatePlanId(inputMap, outMap, options);
        return true;
      }
      else {
        LoggingUtility.insertExceptionLog(CLASS_NAME,
            INVOKE_METHOD_NAME, ERROR_MESSAGE_METHOD_NAME_BLANK);
        return false;
      } 
    } catch (Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, methodName, e);
      return false;
    }
  }*/

  /**
   * @description This method is acception inputMap which actually containing fiberBillingCFSLine
   *  and applying the logic as per provided node i.e removeProducts, updateProducts.
   */
  public static void addZuoraRatePlanId(
      Map<String, Object> inputMap,
      Map<String, Object> outMap,
      Map<String, Object> options)
  {
    Set<String> setOfZuoraProductInstanceIds = new Set<String> ();
    //If condition to check for fiberBillingCFSLine
    if (inputMap.containsKey(INPUT_MAP_FIBER_BILLING_LINE_KEY)) {
      Map<String, Object> jsonAttMap = 
        (Map<String, Object>) inputMap.get(INPUT_MAP_FIBER_BILLING_LINE_KEY);
      //If condition to check for removeProducts node.
      if (jsonAttMap.containsKey(INPUT_MAP_REMOVE_PRODUCT_KEY)) {
        fillZuoraProductInstanceId(
          INPUT_MAP_REMOVE_PRODUCT_KEY, jsonAttMap, setOfZuoraProductInstanceIds);
      }
      //If condition to check for updateProducts node.
      if (jsonAttMap.containsKey(INPUT_MAP_UPDATE_PRODUCT_KEY)) {
        fillZuoraProductInstanceId(
          INPUT_MAP_UPDATE_PRODUCT_KEY, jsonAttMap, setOfZuoraProductInstanceIds);
      }
      //If condition to check for removedProductsChangeOfPlan node.
      if (jsonAttMap.containsKey(INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY)) {
        fillZuoraProductInstanceId(
          INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY, jsonAttMap, setOfZuoraProductInstanceIds);
      }
    }
    //Remove null or empty string from set
    setOfZuoraProductInstanceIds.remove('');
    setOfZuoraProductInstanceIds.remove(null);
    
    //Fetch zuora subscription for given product instance ids.
    List<Zuora__SubscriptionRatePlan__c> listOfZuoraSubsCharges = [
      SELECT
        Id,
        RatePlanInstanceID__c,
        Zuora__External_Id__c
      FROM
        Zuora__SubscriptionRatePlan__c 
      WHERE
        RatePlanInstanceID__c IN :setOfZuoraProductInstanceIds
    ];

    //Map for mapping RatePlanInstanceID__c to Zuora__External_Id__c
    Map<String, String> mapOfRatePlanId = new Map<String, String>();
    for (Zuora__SubscriptionRatePlan__c subscription : listOfZuoraSubsCharges) {
      mapOfRatePlanId.put(
        subscription.RatePlanInstanceID__c, subscription.Zuora__External_Id__c);      
    }
    //Logic to add node of ratePlanId for following nodes i.e. removeProducts, updateProducts
    if (inputMap.containsKey(INPUT_MAP_FIBER_BILLING_LINE_KEY)) {
      Map<String, Object> jsonAttMap = 
        (Map<String, Object>) inputMap.get(INPUT_MAP_FIBER_BILLING_LINE_KEY );
      if (jsonAttMap.containsKey(INPUT_MAP_REMOVE_PRODUCT_KEY)) {
        fillRatePlanInstanceId(
          INPUT_MAP_REMOVE_PRODUCT_KEY, jsonAttMap, mapOfRatePlanId);
      }
      if (jsonAttMap.containsKey(INPUT_MAP_UPDATE_PRODUCT_KEY)) {
        fillRatePlanInstanceId(
          INPUT_MAP_UPDATE_PRODUCT_KEY, jsonAttMap, mapOfRatePlanId);
      }
      if (jsonAttMap.containsKey(INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY)) {
        fillRatePlanInstanceId(
          INPUT_MAP_REMOVE_PRODUCT_PLAN_CHANGE_KEY, jsonAttMap, mapOfRatePlanId);
      }
    }
    outMap.putAll(inputMap);
  }

  /**
   * @description This method is creating set of ZuoraProductInstanceId.
   */
  private static void fillZuoraProductInstanceId(
      String nodeName,
      Map<String, Object> inputMap,
      Set<String> setOfZuoraProductInstanceIds)
  {
    List<Object> jsonActionAttMapList = makeIterableInstance(
      inputMap, nodeName);
    //Iterating attribute map and filling the zuora product instance.
    for (Object jsonInstance : jsonActionAttMapList) {
      Map<String, Object> jsonActionAttMap = (Map<String, Object>) jsonInstance;
      //If condition to check for zuoraProductInstanceID node.
      if (jsonActionAttMap.containsKey(INPUT_MAP_ZUORA_INSTANCE_ID_KEY)) {
        String zuoraProductInstanceId = 
          (String)jsonActionAttMap.get(INPUT_MAP_ZUORA_INSTANCE_ID_KEY);
        setOfZuoraProductInstanceIds.add(zuoraProductInstanceId);
      }
    }
  }

  /**
   * @description This method is filling the map with ratePlanId node.
   */
  private static void fillRatePlanInstanceId(
    String nodeName,
    Map<String, Object> inputMap,
    Map<String, String> mapOfRatePlanId)
  {
    List<Object> jsonActionAttMapList = makeIterableInstance(
      inputMap, nodeName);
    //Iterating attribute map and adding the ratePlanId.
    for (Object jsonInstance : jsonActionAttMapList) {
      Map<String, Object> jsonActionAttMap = (Map<String, Object>) jsonInstance;
      //If condition to check for zuoraProductInstanceID node.
      if (jsonActionAttMap.containsKey(INPUT_MAP_ZUORA_INSTANCE_ID_KEY)) {
        String zuoraProductInstanceId = 
          (String)jsonActionAttMap.get(INPUT_MAP_ZUORA_INSTANCE_ID_KEY);
        String ratePlanId = mapOfRatePlanId.get(zuoraProductInstanceId);
        jsonActionAttMap.put(INPUT_MAP_RATE_PLAN_ID_KEY, ratePlanId);
      }
    }
  }
    
  /**
   * @description This method is making iterable instance i.e. List.
   */
  private static List<Object> makeIterableInstance(
    Map<String, Object> inputMap, String nodeName)
  {
    Object recordInstance = (Object)inputMap.get(nodeName);
    //If condition to check for recordInstance type.
    if (!(recordInstance instanceof List<Object>)) {
      return new List<Object> {recordInstance};
    } else {
      return (List<Object>) recordInstance;
    }
  }
}