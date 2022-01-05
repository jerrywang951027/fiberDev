public class ProjectHelper {
  public static void updatePropertyUnitCountIfSeveralProjects(
      List<Project__c> newProjects, Map<Id, Project__c> oldMapProjects) {
    Set<Id> propertyIds = new Set<Id>();
    List<Property__c> propertyToUpdate = new List<Property__c>();
    List<Property__c> parentProperties = new List<Property__c>();
    if(oldMapProjects == null) {
      for(Project__c projectObj : newProjects) {
        propertyIds.add(projectObj.Property__c);
      }
    } else {
      for(Project__c projectObj : newProjects) {
        Project__c oldProject = oldMapProjects.get(projectObj.Id);
        if(projectObj.Number_of_Residential_Units__c !=
               oldProject.Number_of_Residential_Units__c ||
           projectObj.Number_of_Commercial_Units__c !=
               oldProject.Number_of_Commercial_Units__c ||
           projectObj.Number_of_Common_Area_Units__c !=
               oldProject.Number_of_Common_Area_Units__c) {
          propertyIds.add(projectObj.Property__c);
        }
      }
    }
    if(!propertyIds.isEmpty()) {
      parentProperties = [SELECT
                            Id,
                            (SELECT
                               Id,
                               Number_of_Residential_Units__c,
                               Number_of_Commercial_Units__c,
                               Number_of_common_area_units__c
                             FROM
                               Projects__r
                             )
                          FROM
                            Property__c
                          WHERE
                            Id IN :propertyIds
      ];
    }
    for(Property__c propertyObj : parentProperties) {
      if(!propertyObj.Projects__r.isEmpty() &&
          propertyObj.Projects__r.size() > 1) {
        propertyObj.Number_of_Residential_Units__c = 0;
        propertyObj.Number_of_common_area_units__c = 0;
        propertyObj.Number_of_Commercial_Units__c = 0;
        for(Project__c proj : propertyObj.Projects__r) {
          propertyObj.Number_of_Residential_Units__c +=
              proj.Number_of_Residential_Units__c != null ?
                  proj.Number_of_Residential_Units__c : 0;
          propertyObj.Number_of_common_area_units__c +=
              proj.Number_of_common_area_units__c != null ?
                  proj.Number_of_common_area_units__c : 0;
          propertyObj.Number_of_Commercial_Units__c +=
              proj.Number_of_Commercial_Units__c != null ?
                  proj.Number_of_Commercial_Units__c : 0;
        }
        propertyObj.Updated_From_Projects__c = true;
        propertyToUpdate.add(propertyObj);
      }
    }

    if(!propertyToUpdate.isEmpty()) {
      update propertyToUpdate;
    }
  }
}