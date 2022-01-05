public class checkTriggerRecursion{
  public static Boolean leadTriggerBeforeUpdate=true;
  public static Boolean leadTriggerAfterUpdate=true;
  public static Boolean leadTriggerAfterInsert=true;
  public static Boolean caseAfterTrigger=true;
  public static Boolean woAfterUpdateTrigger=true;
  public static Boolean projectAfterInsertTrigger = true;
  public static Boolean projectAfterUpdateTrigger = true;
  public static Boolean FDSAdressTriggerBeforeUpdate = true;
  public static final String triggerConfigSplitterRegex = '\\s*[\\,\\;]\\s*';

  /** global setting to disable everywhere utilizing this code */
  @TestVisible
  private static Boolean bypassEverything = Test.isRunningTest() ? false :
      !gfiber2_Settings__c.getInstance().Enable_All_Apex_Triggers__c;
  @TestVisible
  private static Map<String, Boolean> enabledMap = new Map<String, Boolean>();
  static {
    loadTriggerConfigs();
  }

  /** check if a trigger or a code block in the trigger is enabled */
  public static Boolean isTriggerEnabled ( String objectAndOperation ) {
      Boolean triggerEnabled = enabledMap.containsKey(objectAndOperation)
          ? enabledMap.get(objectAndOperation) : true;
      return bypassEverything == false && triggerEnabled;
  }
  public static void enableTrigger(String objectAndOperation) {
      enabledMap.put(objectAndOperation, true);
  }
  public static void disableTrigger(String objectAndOperation) {
      enabledMap.put(objectAndOperation, false);
  }
  public static void setBypassEverything(Boolean trueOrFalse){
      bypassEverything = trueOrFalse;
  }
  /** reset all settings back to default */
  public static void reset(){
      enabledMap.clear();
      setBypassEverything(false);
      loadTriggerConfigs();
  }
  /** load hierachy custom setting TriggerConfig__c;
   *   parse objects or operations that should be run or bypassed. */
  private static void loadTriggerConfigs() {
    TriggerConfig__c config = TriggerConfig__c.getInstance();
    if (String.isNotBlank(config.Bypass_These__c)) {
      for (String objectOrOperation :
           config.Bypass_These__c.split(triggerConfigSplitterRegex)) {
        if (String.isNotBlank(objectOrOperation)) {
          enabledMap.put(objectOrOperation, false);
        }
      }
    }
    if (String.isNotBlank(config.Run_These__c)) {
      for (String objectOrOperation :
           config.Run_These__c.split(triggerConfigSplitterRegex)) {
        if (String.isNotBlank(objectOrOperation)) {
          enabledMap.put(objectOrOperation, true);
        }
      }
    }
  }
 }