public class OSPEmailHelper {

  public final static String EMPTY_LINE = '';

  public static String getOSPEmailTemplateName(OSP_Review__c ospObj) {
    if(ospObj.TechOps_Serviceability_Form_Status__c ==
          MxuConstants.OspReview.SERVICEABILITY.REVIEWED &&
          //Commenting out constants and hard-coding it in program for v2 to v3 migration
          //ospObj.OSP_Build_Status__c != Constants.EMPTY_LINE &&
          ospObj.OSP_Build_Status__c != EMPTY_LINE &&
          ospObj.OSP_Build_Status__c == MxuConstants.OspReview.BUILD_STATUS.HHP &&
          ospObj.On_Hybrid_Ring__c  == MxUConstants.OspReview.HYBRID_RING.IS_HYBRIDRING) {
        return  MxUConstants.Property.EMAIL_TEMPLATE.HHP_HYBRID_EMAIL_TEMPLATE;
    } else if (ospObj.TechOps_Serviceability_Form_Status__c ==
          MxuConstants.OspReview.SERVICEABILITY.REVIEWED &&
          //Commenting out constants and hard-coding it in program for v2 to v3 migration
          //ospObj.OSP_Build_Status__c != Constants.EMPTY_LINE &&
          ospObj.OSP_Build_Status__c != EMPTY_LINE &&
          ospObj.OSP_Build_Status__c == MxuConstants.OspReview.BUILD_STATUS.HHP &&
          ospObj.On_Hybrid_Ring__c  == MxUConstants.OspReview.HYBRID_RING.ISNOT_HYBRIDRING) {
        return MxUConstants.Property.EMAIL_TEMPLATE.HHP_NON_HYBRID_EMAIL_TEMPLATE;
    } else if (ospObj.TechOps_Serviceability_Form_Status__c ==
         MxuConstants.OspReview.SERVICEABILITY.REVIEWED &&
           (ospObj.OSP_Build_Status__c  ==
           MxuConstants.OspReview.BUILD_STATUS.HH ||
           ospObj.OSP_Build_Status__c  ==
           MxuConstants.OspReview.BUILD_STATUS.HHA) &&
         ospObj.On_Hybrid_Ring__c  == MxUConstants.OspReview.HYBRID_RING.IS_HYBRIDRING) {
       return MxUConstants.Property.EMAIL_TEMPLATE.HHA_HYBRID_EMAIL_TEMPLATE;
    }
    else if(ospObj.TechOps_Serviceability_Form_Status__c ==
         MxuConstants.OspReview.SERVICEABILITY.REVIEWED &&
           (ospObj.OSP_Build_Status__c  ==
           MxuConstants.OspReview.BUILD_STATUS.HH ||
            ospObj.OSP_Build_Status__c  ==
            MxuConstants.OspReview.BUILD_STATUS.HHA) &&
          ospObj.On_Hybrid_Ring__c  == MxUConstants.OspReview.HYBRID_RING.ISNOT_HYBRIDRING) {
      return MxUConstants.Property.EMAIL_TEMPLATE.HHA_NON_HYBRID_EMAIL_TEMPLATE;
    }
    return null;
  }
  public static List<Messaging.SingleEmailMessage> createPropertyEmails(
        EmailTemplate emTemplate, List<OSP_Review__c> ospReviews) {
    Set<Id> reviewedProperties = new Set<Id>();
    for (OSP_Review__c osp :ospReviews){
       reviewedProperties.add(osp.Property__c);
    }
    Map<Id, Property__c> propertybyIDMap = new Map<Id, Property__c>
        ([Select Id, Opportunity__r.OwnerID from Property__c where id IN :reviewedProperties ]);
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    if (emTemplate != null) {
      for (Property__c prop : propertybyIDMap.values()) {
        if (prop.Opportunity__r.OwnerID != null) {
          Messaging.SingleEmailMessage mail =
              Messaging.renderStoredEmailTemplate(emTemplate.Id, null,
                                                prop.Id);
          mail.setTargetObjectId(prop.Opportunity__r.OwnerId);
          mail.setSaveAsActivity(false);
          emailsToSend.add(mail);
        }
      }
    }
    return emailsToSend;
  }
  public class OSPEmailTemplate {
    public Emailtemplate template;
    public List<OSP_Review__c> ospReviews = new List<OSP_Review__c>();
    public OSPEmailTemplate(EmailTemplate template) {
      this.template = template;
    }
  }
}