public class OSPReviewHelper {



  public static void setEmailAlias(List<OSP_Review__c> newOSPReviews) {
    for (OSP_Review__c review : newOSPReviews) {
      review.Email_Alias__c =
          CustomMetadataUtil.getTechOpsEmailByMxUMarket(review.Property_Market__c);
    }
  }

  public static void sendOSPReview(List<OSP_Review__c> newOSPReviews) {
    List<Messaging.SingleEmailMessage> emailsToSend =
        new List<Messaging.SingleEmailMessage>();

    List<EmailTemplate> emailTemplateList = [
        SELECT Id
        FROM EmailTemplate
        WHERE DeveloperName = :MxUConstants.OspReview.EMAIL_TEMPLATE.OSP_REVIEW
        LIMIT 1
    ];

    if (!emailTemplateList.isEmpty()) {
      Emailtemplate emTemplate = emailTemplateList.get(0);
      for (OSP_Review__c reviewObj : newOSPReviews) {
        if (reviewObj.Email_Alias__c != null) {
          Messaging.SingleEmailMessage mail =
            Messaging.renderStoredEmailTemplate(emTemplate.Id, null, reviewObj.Id);
          mail.setToAddresses(new List<String> {reviewObj.Email_Alias__c});
          mail.setSaveAsActivity(false);
          emailsToSend.add(mail);
        }
      }
    }

    if (!emailsToSend.isEmpty()) {
      Messaging.sendEmail(emailsToSend);
    }
  }

  /**
   * Method for processing changes in TechOsp Serviceability and
   * Build Status/Sub Status.
   */
  public static void processServiceabilityAndBuildStatusChange(
    List<OSP_Review__c> newOspReviews, Map<Id, OSP_Review__c> oldMapOspReviews) {
    Map<Id, Property__c> parentPropertyMap = new Map<Id, Property__c>();
    Map<Id, Lead> parentLeadMap = new Map<Id, Lead>();
    List<sObject> parentsToUpdate = new List<sObject>();
    // Commenting out constants and hard-coding it in program for v2 to v3 migration
    String DUPLICATE = 'Duplicate';

    for (OSP_Review__c objOSPReview : newOspReviews) {
      if (oldMapOspReviews == null) {
        if (objOSPReview.Property__c != null) {
          parentPropertyMap.put(objOSPReview.Property__c,
              new Property__c(Id = objOSPReview.Property__c));
        } else if (objOSPReview.Lead__c != null) {
          parentLeadMap.put(objOSPReview.Lead__c,
              new Lead(Id = objOSPReview.Lead__c));
        }
      } else if (oldMapOspReviews != null &&
          objOSPReview.OSP_Build_Status__c !=
              oldMapOspReviews.get(objOSPReview.Id).OSP_Build_Status__c
          || (objOSPReview.TechOps_Serviceability_Form_Status__c !=
              oldMapOspReviews.get(objOSPReview.Id).TechOps_Serviceability_Form_Status__c &&
              objOSPReview.TechOps_Serviceability_Form_Status__c !=
                  // Commenting out constants and hard-coding it in program for v2 to v3 migration
                  //MxUConstants.OspReview.SERVICEABILITY.DUPLICATE)) {
                  DUPLICATE)) {

        if (objOSPReview.Property__c != null) {
          parentPropertyMap.put(objOSPReview.Property__c,
              fillTechOpsFieldsOnParentProperty(objOSPReview,
                  new Property__c(Id = objOSPReview.Property__c)));
        } else if (objOSPReview.Lead__c != null) {
          parentLeadMap.put(objOSPReview.Lead__c,
              fillTechOpsFieldsOnParentLead(objOSPReview,
                  new Lead(Id = objOSPReview.Lead__c)));
        }
      }
    }

    if (!parentLeadMap.isEmpty()) {
       stampOspBuildStatusOnLead(parentLeadMap);
       parentsToUpdate.addAll(parentLeadMap.values());
    }

    if (!parentPropertyMap.isEmpty()) {
      parentsToUpdate.addAll(parentPropertyMap.values());
    }

    if(!parentsToUpdate.isEmpty()) {
       update parentsToUpdate;
    }
  }

  /**
   * Find the best OSP Review based on TechOsp Serviceability (latest or
   * latest reviewed) and fill tech fields on related Lead
   */
  public static void stampOspBuildStatusOnLead(Map<Id, Lead> parentLeadMap) {
    List<Lead> parentLeadList = new List<Lead>();
    if (!parentLeadMap.isEmpty()) {
      parentLeadList = [SELECT
                          Id,
                          OSP_Build_Status__c,
                          OSP_Build_Sub_Status__c,
                          (SELECT
                             OSP_Build_Status__c,
                             OSP_Build_Sub_Status__c,
                             TechOps_Serviceability_Form_Status__c,
                             CreatedDate
                           FROM
                             OSP_Review__r
                           ORDER BY CreatedDate DESC)
                        FROM
                          Lead
                        WHERE
                          Id IN :parentLeadMap.keySet()
      ];
    }

    for (Lead objLead : parentLeadList) {
      OSP_Review__c bestOSPReview =
          getLatestOrLatestApprovedOSPReview(objLead.OSP_Review__r);
      if (objLead.OSP_Build_Status__c != bestOSPReview.OSP_Build_Status__c) {
        parentLeadMap.get(objLead.Id).OSP_Build_Status__c =
          bestOSPReview.OSP_Build_Status__c;
      }
    }
  }

  /**
   *  Fill TechOsp Decision and Serviceability on Property based on
   *  OSP Serviceability and OSP Build Statuses
   */
  private static Property__c fillTechOpsFieldsOnParentProperty(
      OSP_Review__c ospReview, Property__c parentProperty) {
    parentProperty.TechOps_Serviceability_Form_Status__c =
        ospReview.TechOps_Serviceability_Form_Status__c;
    if (ospReview.TechOps_Serviceability_Form_Status__c ==
        MxuConstants.OspReview.SERVICEABILITY.REVIEWED) {
      parentProperty.TechOps_Decision__c = true;
      parentProperty.Deployment_Status__c =
          ospReview.OSP_Build_Status__c;
      parentProperty.Deployment_Sub_Status__c =
          ospReview.OSP_Build_Sub_Status__c;
      parentProperty.Fiberhood_LCP__c =
          ospReview.Hut_Zone_OSP_Leg__c;
      parentProperty.PRID__c =
          ospReview.PRID__c;
    }
    if (ospReview.OSP_Build_Status__c ==
        MxuConstants.OspReview.BUILD_STATUS.HH &&
                   ospReview.OSP_Build_Sub_Status__c ==
                   MxuConstants.OspReview.BUILD_SUB_STATUS.NOT_IN_BUILD_AREA) {
      parentProperty.TechOps_Decision__c = false;
    }

    return parentProperty;
  }

  /**
   * Fill TechOsp Decision and Status on Lead based on
   * OSP Serviceability and OSP Build Statuses
   */
  private static Lead fillTechOpsFieldsOnParentLead(
      OSP_Review__c ospReview, Lead parentLead) {
    parentLead.Tech_Ops_Outcome__c =
        ospReview.TechOps_Serviceability_Form_Status__c;
    if (ospReview.TechOps_Serviceability_Form_Status__c ==
        MxuConstants.OspReview.SERVICEABILITY.REVIEWED) {
      parentLead.Status =
          MxuConstants.MxULead.STATUS.QUALIFIED_BY_SALES_AND_TECHOPS;
      parentLead.TechOps_Decision__c = true;
    }
    if (ospReview.OSP_Build_Status__c ==
        MxuConstants.OspReview.BUILD_STATUS.HH &&
        ospReview.OSP_Build_Sub_Status__c ==
            MxuConstants.OspReview.BUILD_SUB_STATUS.NOT_IN_BUILD_AREA) {
      parentLead.Status = MxuConstants.MxULead.STATUS.STAND_BY;
    }

    return parentLead;
  }

  /**
   * Find the best OSP Review based on TechOsp Serviceability
   * (latest or latest reviewed)
   */
  private static OSP_Review__c getLatestOrLatestApprovedOSPReview(
      List<OSP_Review__c> reviews) {
    for (OSP_Review__c reviewObj : reviews) {
      if (reviewObj.TechOps_Serviceability_Form_Status__c ==
          MxUConstants.OspReview.SERVICEABILITY.REVIEWED) {
        return reviewObj;
      }
    }
    return reviews.get(0);
  }

  public static void sendNotificationOnPropertyOspReviewComplete(
      List<OSP_Review__c> newOspReviews,
      Map<Id, OSP_Review__c> oldMapOspReviews) {
    if (!CheckTriggerRecursion.isTriggerEnabled(MxUConstants.Property.CONFIGURATION_LABEL.SEND_OSP_NOTIFICATION)) {
      return;
    }
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    // TODO(deepikaraina): Cleanup the Email code and move to Email Helper Class
    List<String> allEmailTypes = new List<String>();
    allEmailTypes.add(MxUConstants.Property.EMAIL_TEMPLATE.HHP_HYBRID_EMAIL_TEMPLATE);
    allEmailTypes.add(MxUConstants.Property.EMAIL_TEMPLATE.HHP_NON_HYBRID_EMAIL_TEMPLATE);
    allEmailTypes.add(MxUConstants.Property.EMAIL_TEMPLATE.HHA_HYBRID_EMAIL_TEMPLATE);
    allEmailTypes.add(MxUConstants.Property.EMAIL_TEMPLATE.HHA_NON_HYBRID_EMAIL_TEMPLATE);
    List <EmailTemplate> templates = [SELECT
                                        Id,
                                        DeveloperName
                                      FROM
                                        EmailTemplate
                                      WHERE
                                        DeveloperName IN :allEmailTypes
                                      LIMIT :allEmailTypes.size()];
    Map<String, OSPEmailHelper.OSPEmailTemplate> emailMapping
        = new Map<String, OSPEmailHelper.OSPEmailTemplate>();
    for (EmailTemplate template : templates) {
      emailMapping.put(template.DeveloperName, new OSPEmailHelper.OSPEmailTemplate(template));
    }
    for (OSP_Review__c ospObj : newOspReviews) {
      OSP_Review__c oldOsp = oldMapOspReviews.get(ospObj.Id);
      if (ospObj.Property__c != null &&
          ospObj.Lead__c == null &&
          ospObj.TechOps_Serviceability_Form_Status__c !=
          oldOsp.TechOps_Serviceability_Form_Status__c) {
            String emailTemplate = OSPEmailHelper.getOSPEmailTemplateName(ospObj);
            if (emailTemplate != null) {
              OSPEmailHelper.OSPEmailTemplate emailHolder = emailMapping.get(emailTemplate);
              emailHolder.ospReviews.add(ospObj);
            }
      }
    }
    for (OSPEmailHelper.OSPEmailTemplate emailHolder : emailMapping.values()) {
      emailsToSend.addAll(OSPEmailHelper.createPropertyEmails(emailHolder.template,
                                                 emailHolder.ospReviews));
    }
    if (!emailsToSend.isEmpty()) {
      Messaging.sendEmail(emailsToSend);
    }
  }
}