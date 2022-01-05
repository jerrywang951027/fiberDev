// Setup as without sharing as this is a utility class responsible for
// generating platform events and shall not run into issues due to permissions.
public without sharing class PlatformEventGenerator {
  public static final String CONFIG_SEPARATOR = ';';
  public static final String FIELD_VAL_IDENTIFIER = '<';
  public static final String TYPE_UPDATED = 'updated';
  public static final String TYPE_CREATED = 'created';
  public static final String TYPE_DELETED = 'deleted';
  public static final String EQUALS_OPERATOR = '=';
  public static final String NOT_EQUALS_OPERATOR = '!=';
  public static final String IN_OPERATOR = 'IN';

  static Map<Id, Platform_Events_Configurator__mdt> pEventConfigurationsById
      = new Map<Id, Platform_Events_Configurator__mdt>([
          SELECT Id, MasterLabel, Object_Name__c, Monitored_Fields__c,
                 Additional_Criteria__c, Monitor_Record_Create__c,DeveloperName,
                 Monitor_Record_Update__c, Platform_Event_Object_Name__c,
                 Platform_Event_Fields_Long__c, Platform_Event_Values_Long__c, Active__c
          FROM Platform_Events_Configurator__mdt
          WHERE Active__c = true]);

  // Invoked from respective object Trigger (After Insert/After Update only)
  // to publish an event if all criteria meets.
  public static void evaluateAndPublishChangeEvent(String objectName,
                                                   List<SObject> newRecords,
                                                   Map<Id, SObject> oldRecords) {
    evaluateAndPublishChangeEvent(objectName, newRecords, oldRecords, false);
  }

  // Overloaded method for Delete event support
  public static void evaluateAndPublishChangeEvent(String objectName,
                                                   List<SObject> newRecords,
                                                   Map<Id, SObject> oldRecords,
                                                   boolean isDelete) {
    try {
      // This setting will allow for declarative ON/OFF for this utility
      if (!gfiber2_Settings__c.getInstance().Enable_Platform_Event_Generator__c) {
        return;
      }
      isDelete = (isDelete == null ? false : isDelete);

      // Insert triggers shall pass null for oldRecords
      // Delete triggers shall pass null for newRecords
      boolean isUpdate = (oldRecords != null) && !isDelete;
      boolean isInsert = (oldRecords == null);
      List<SObject> srcRecords = (isDelete ? oldRecords.values() : newRecords);

      List<Platform_Events_Configurator__mdt> peConfigs =
          getMatchingPEConfigs(objectName, isInsert, isUpdate, isDelete);

      List<SObject> generatedEventList = new List<SObject>();
      for (Platform_Events_Configurator__mdt peConfig : peConfigs) {
        for (SObject newRecord : srcRecords) {
          SObject oldRecord = null;
          if (isUpdate) {
            oldRecord = oldRecords.get(newRecord.Id);
          }
          SObject peObj = evaluateRecordForCriteria(peConfig, oldRecord, newRecord, isDelete);
          if (peObj != null) {
            generatedEventList.add(peObj);
          }
        }
      }

      // Publish only from non-Test contexts
      if (!generatedEventList.isEmpty() && !Test.isRunningTest()) {
        List<Database.SaveResult> saveResults = EventBus.publish(generatedEventList);

        List<String> errors = new List<String>();
        for (Integer i = 0; i < saveResults.size(); i++) {
          Database.SaveResult sr = saveResults[i];
          if (!sr.isSuccess()) {
            for (Database.Error e : sr.getErrors()) {
              errors.add(e.getMessage());
            }
          }
        }
        if (errors.size() > 0) {
          ErrorUtils.createExceptionLog(String.join(errors, '\n'),
              (new System.DmlException()).getTypeName());
        }
      }
    } catch (Exception e) {
        ErrorUtils.createExceptionLog(e);
    }
  }


  // Evaluates the source record against criteria and monitored fields and
  // returns a PE object to publish
  public static SObject evaluateRecordForCriteria(Platform_Events_Configurator__mdt peConfig,
                                                  SObject srcRecordOld, SObject srcRecordNew,
                                                  boolean isDelete) {
    SObject peObj = null;
    Boolean platformEventEligible = false;
    List<String> monitoredFields = (peConfig.Monitored_Fields__c != null ?
                                    peConfig.Monitored_Fields__c.deleteWhitespace()
                                      .split(CONFIG_SEPARATOR) :
                                    new List<String>());
    List<String> additionalCriterias = (peConfig.Additional_Criteria__c != null ?
                                        peConfig.Additional_Criteria__c.deleteWhitespace()
                                          .split(CONFIG_SEPARATOR) :
                                        new List<String>());

    // For Updates only: Check if the monitored fields have changed + Additional Criteria
    if (srcRecordOld != null && !isDelete) {
      for (String fldName : monitoredFields) {
        if (srcRecordOld.get(fldName) != srcRecordNew.get(fldName)) {
          platformEventEligible = true;
          break;
        }
      }
    } else {
      // For Inserts and Deletes: Check only the Additional Criteria
      platformEventEligible = true;
    }

    // This check ensures any monitored fields are also evaluated earlier.
    if (platformEventEligible) {
      for (String criteriaConfig : additionalCriterias) {
        // Supporting only Equal to and Not Equal To operators at this time.
        if (criteriaConfig.contains(NOT_EQUALS_OPERATOR)) {
          List<String> criteriaElements = criteriaConfig.split(NOT_EQUALS_OPERATOR);
          if (criteriaElements.size() == 2) {
            String fld = criteriaElements.get(0);
            String val = criteriaElements.get(1).equalsIgnoreCase('null') ?
                null : criteriaElements.get(1);
            if (srcRecordNew.get(fld) == val) {
              platformEventEligible = false;
            }
          }
        } else if (criteriaConfig.contains(EQUALS_OPERATOR)) {
          List<String> criteriaElements = criteriaConfig.split(EQUALS_OPERATOR);
          if (criteriaElements.size() == 2) {
            String fld = criteriaElements.get(0);
            String val = criteriaElements.get(1).equalsIgnoreCase('null') ?
                null : criteriaElements.get(1);
            Object fldValue = srcRecordNew.get(fld);
             /* FldRecord(Object) comparison only works for String Data types.
                TypeCasting to Boolean for Boolean values */
            if (fldValue instanceof Boolean) {
              if (fldValue != Boolean.valueOf(val)) {
                platformEventEligible = false;
              }
            } else if (fldValue != val) {
              platformEventEligible = false;
            }
          }
        } else if (criteriaConfig.contains(IN_OPERATOR)) {
          platformEventEligible = evaluateForInCondition(criteriaConfig, srcRecordNew);
        }
      }
    }

    if (platformEventEligible) {
      peObj = generatePlatformEventRecord(peConfig, srcRecordNew,
                  (isDelete ? TYPE_DELETED :
                     (srcRecordOld != null ? TYPE_UPDATED : TYPE_CREATED)));
    }
    return peObj;
  }

  // Prepare a Platform Event object record as per matching config
  private static SObject generatePlatformEventRecord(Platform_Events_Configurator__mdt peConfig,
                                                    SObject srcRecord, String eventType) {
    List<String> peFieldsToSet = peConfig.Platform_Event_Fields_Long__c
        .deleteWhitespace().split(CONFIG_SEPARATOR);
    List<String> peValuesToSet = peConfig.Platform_Event_Values_Long__c
        .deleteWhitespace().split(CONFIG_SEPARATOR);
    String peObjectName = peConfig.Platform_Event_Object_Name__c.deleteWhitespace();

    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(peObjectName);
    SObject peObj = targetType.newSObject();
    // Set the fields on platform event record as per config
    for(integer indx = 0; indx < peFieldsToSet.size(); indx++) {
      String fldName = peFieldsToSet.get(indx);
      String fldVal = peValuesToSet.get(indx);
      Object fldValObj = null;
      // Check if the value is a field reference or hard coded
      if (fldVal.startsWith(FIELD_VAL_IDENTIFIER)) {
        // find hard coded value enclosed in <>
        fldValObj = fldVal.substring(1, fldVal.length() - 1).trim();
      } else {
        fldValObj = srcRecord.get(fldVal);
      }
      if (fldValObj != null) {
        peObj.put(fldName, fldValObj);
      }
    }
    // Event type is set for each Platform Event as per DML event
    peObj.put('Event_Type__c', eventType);
    return peObj;
  }

  // There could be multiple platform configuration for an object with different criterias
  private static List<Platform_Events_Configurator__mdt> getMatchingPEConfigs(String objectName,
                                                                             boolean isCreate,
                                                                             boolean isUpdate,
                                                                             boolean isDelete) {
    List<Platform_Events_Configurator__mdt> peConfigs =
        new List<Platform_Events_Configurator__mdt>();
    for (Platform_Events_Configurator__mdt pe : pEventConfigurationsById.values()) {
      if (pe.Object_Name__c != null && pe.Object_Name__c.equalsIgnoreCase(objectName)
          && ((isCreate && pe.Monitor_Record_Create__c == isCreate)
              || (isUpdate && pe.Monitor_Record_Update__c == isUpdate)
               || (isDelete && pe.Monitor_Record_Delete__c == isDelete))) {
        peConfigs.add(pe);
      }
    }
    return peConfigs;
  }


  private static boolean evaluateForInCondition(String criteriaConfig, SObject srcRecordNew) {
    Boolean platformEventEligible = false;
    List<String> criteriaElements = criteriaConfig.split(IN_OPERATOR);
    if (criteriaElements.size() == 2) {
      String fld = criteriaElements.get(0);
      // Converts (Value1,Value2) --> [Value1, Value2]
      List<String> valuesList = criteriaElements.get(1).deleteWhitespace().
          removeStart('(').removeEnd(')').split(',');
      for (String val : valuesList) {
        // Comparing the field value without white spaces.
        if (((String)srcRecordNew.get(fld)).deleteWhitespace() == val) {
          platformEventEligible = true;
          break;
        }
      }
    }
    return platformEventEligible;
  }
}