/**
* ProjectTriggerHandler.cls - Handler class for Project Trigger.
* @version 1.0
*/
public class ProjectTriggerHandler {
  public static final String PROJECT_STATUS_COMPLETED = 'Completed';
  public static void handle (List<Project__c> newList, List<Project__c> oldList,
      Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {
    if (Trigger.isBefore) {
      // to be implemented
    } else if(Trigger.isAfter) {
      if (Trigger.isInsert) {
        onAfterInsert(newList);
      } else if (Trigger.isUpdate) {
        onAfterUpdate(newMap, oldMap);
      } else if (Trigger.isDelete) {
        onDelete(oldList);
      }
    }
  }

  public static void onAfterInsert(List<Project__c> newList) {
    populatePropertyOnFDSAddress(newList);
    updatePropertyUnitsAndPRID(newList, null);
    ProjectHelper.updatePropertyUnitCountIfSeveralProjects(newList, null);
  }

  public static void onAfterUpdate(Map<Id, Project__c> newMap,
      Map<Id, Project__c> oldMap) {
    updatePropertyOnFDSAddress(newMap, oldMap);
    updatePropertyUnitsAndPRID(newMap.values(), oldMap);
    ProjectHelper.updatePropertyUnitCountIfSeveralProjects(newMap.values(),
        oldMap);
  }

  public static void onDelete(List<Project__c> oldList) {
    updatePropertyUnitsAndPRID(oldList, null);
  }

//update
  public static void updatePropertyOnFDSAddress(Map<Id, Project__c> newMap,
      Map<Id, Project__c> oldMap) {
    Map<String, Project__c> projectByPRIDToUpdateAddress =
        new Map<String, Project__c>();
    for (Id projectId : newMap.keySet()) {
      Project__c newProject = newMap.get(projectId);
      Project__c oldProject = oldMap.get(projectId);
      if ((newProject.Property__c != oldProject.Property__c
          || newProject.PRID__c != oldProject.PRID__c)
          && String.isNotBlank(newProject.PRID__c)) {
        projectByPRIDToUpdateAddress.put(newProject.PRID__c, newProject);
      }
      if (newProject.PRID__c != oldProject.PRID__c &&
            String.isNotBlank(oldProject.PRID__c) &&
            !projectByPRIDToUpdateAddress.containsKey(oldProject.PRID__c)) {
        projectByPRIDToUpdateAddress.put(oldProject.PRID__c, null);
      }
    }
    if (!projectByPRIDToUpdateAddress.keySet().isEmpty()) {
      processPropertyOnFDSAddress(projectByPRIDToUpdateAddress);
    }
  }

//insert
  public static void populatePropertyOnFDSAddress(List<Project__c> projects) {
    Map<String, Project__c> projectByPRIDToInsertAddress =
        new Map<String, Project__c>();
    for (Project__c project : projects) {
      if (String.isNotBlank(project.PRID__c) &&
          String.isNotBlank(project.Property__c)) {
        projectByPRIDToInsertAddress.put(project.PRID__c, project);
      }
    }
    if (!projectByPRIDToInsertAddress.keySet().isEmpty()) {
      processPropertyOnFDSAddress(projectByPRIDToInsertAddress);
    }
  }

  // This method updates the unit count and PRID on property
  public static void updatePropertyUnitsAndPRID(List<Project__c> records,
      Map<Id, Project__c> oldMap) {
    Map<Id, Project__c> propertiesToUpdatePRID = new Map<Id, Project__c>();
    List<ID> propertiesToUpdateUnits = new List<Id>();
    for (Project__c project : records) {
      if (project.Property__c != null) {
        propertiesToUpdateUnits.add(project.Property__c);
      }
      if (project.Property__c != null
          && project.PRID__c != null) {
        propertiesToUpdatePRID.put(project.Property__c, project);
      }
    }
    if (!propertiesToUpdateUnits.isEmpty()) {
      updateUnits(propertiesToUpdateUnits, oldMap);
    }
    if (!propertiesToUpdatePRID.keySet().isEmpty()) {
      updatePridOnProperty(propertiesToUpdatePRID, oldMap);
    }
  }

  public static void updateUnits(List<Id> propIds,
      Map<Id, Project__c> oldMap) {
    List<Property__c> propList = [
        SELECT Id,
               Property_Status__c,
               Construction_Status__c,
               Market__c,
               Market_MXU_Sales_Lead__c,
               market_Tech_Ops_lead__c,
               (SELECT Id,
                       Status__c,
                       Sum_of_all_Units__c,
                       Active_Milestone_Name__c,
                       Construction_Status__c,
                       Date_Install_Ready__c
                FROM Projects__r
                WHERE status__c = :PROJECT_STATUS_COMPLETED)
        FROM Property__c
        WHERE Id IN :propIds];
    List<Property__c> propToUpdate = new List<Property__c>();
    for (Property__c prop : propList) {
      Decimal propUnits = 0;
      Property__c newProp;
      for (Project__c project : prop.Projects__r) {
        Project__c oldProject = (oldMap != null && oldMap.containsKey(project.Id)) ?
                                oldMap.get(project.Id) : null;
        if (project.status__c == PROJECT_STATUS_COMPLETED) {
          if (oldProject!= null
              && (project.Active_Milestone_Name__c !=
                  oldProject.Active_Milestone_Name__c
                  || project.Status__c != oldProject.Status__c
                  || project.Construction_Status__c !=
                     oldProject.Construction_Status__c)) {
            newProp = new Property__c(Id = prop.Id);
            newProp.Active_Milestone_Name__c =
                project.Active_Milestone_Name__c;
            newProp.Project_Status__c = project.status__c;
            newProp.Construction_Status_Project__c =
                project.Construction_Status__c;
            Datetime installDate = project.Date_Install_Ready__c;
            newProp.Install_Ready_Date__c = (installDate != null) ?
                Date.newInstance(installDate.year(),
                    installDate.month(), installDate.day()):
                null;
            if (prop.Market_MXU_Sales_Lead__c == null) {
              newProp.Market_MXU_Sales_Lead__c =
                  CustomMetadataUtil.getSalesEmailByMxUMarket(prop.Market__c);
            }
            if (prop.market_Tech_Ops_lead__c == null) {
              newProp.market_Tech_Ops_lead__c =
                  CustomMetadataUtil.getTechOpsEmailByMxUMarket(prop.Market__c);
            }
          }
          propUnits = propUnits + project.Sum_of_all_Units__c;
        }
      }
      if(prop.Construction_Status__c != propUnits) {
        newProp = (newProp != null) ? newProp :
                   new Property__c(Id = prop.Id);
        newProp.Construction_Status__c = propUnits;
      }
      if (newProp != null) {
        propToUpdate.add(newProp);
      }
    }
    if(propToUpdate.size() > 0) {
      update propToUpdate;
    }
  }

  /************************************************************************
    * Method to populate Property Details on FDS Address
  * *********************************************************************/
  public static void processPropertyOnFDSAddress(Map<String, Project__c> projects) {
    List<vlocity_cmt__Premises__c> addressesToUpdate = new List<vlocity_cmt__Premises__c>();
    List<vlocity_cmt__Premises__c> addressList = new List<vlocity_cmt__Premises__c>([
        SELECT Id,
               Project_ID__c,
               Property__c
        FROM vlocity_cmt__Premises__c
        WHERE Project_ID__c IN :projects.keySet() FOR UPDATE]);
    for (vlocity_cmt__Premises__c fdsAddress : addressList) {
        if (projects.get(fdsAddress.Project_ID__c) != null) {
            fdsAddress.Property__c =
                projects.get(fdsAddress.Project_ID__c).Property__c;
        } else {
            fdsAddress.Property__c = null;
        }
      addressesToUpdate.add(fdsAddress);
    }
    if (addressesToUpdate.size() > 0) {
      update addressesToUpdate;
    }
  }

   // Updates PRID on Property
  public static void updatePridOnProperty(Map<Id, Project__c> newProjects,
      Map<Id, Project__c> oldMap) {
    Set<Id> propertyIds = new Set<Id>();
    for (Project__c proj : newProjects.values()) {
      propertyIds.add(proj.Property__c);
    }
    Map<Id, Property__c> propertyMap = new Map<Id, Property__c>([
      SELECT
        Id,
        PRID__c
      FROM
        Property__c
      WHERE
        Id IN :propertyIds]);
    List<Property__c> propPRIDList = new List<Property__c>();
    for (Project__c proj : newProjects.values()) {
      if (oldMap == null || (proj.Property__c != oldMap.get(proj.Id).Property__c
            || proj.PRID__c != oldMap.get(proj.Id).PRID__c
            || proj.PRID__c != propertyMap.get(proj.Property__c).PRID__c)) {
      propPRIDList.add(new Property__c(Id = proj.Property__c,
          PRID__c = proj.PRID__c));
      }
    }
    if (!propPRIDList.isEmpty()) {
      update propPRIDList;
    }
  }
}