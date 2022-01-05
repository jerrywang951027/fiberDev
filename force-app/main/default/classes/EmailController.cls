/**
 * @description Creating email service to send Gama.
 * @group EmailController
 */
Public with sharing class EmailController {

  /**
   * @description to get GFiber Template Folder;
   */
  @AuraEnabled(cacheable = true)
  public static void getFolder(Map<String, Object> input,
    Map<String, Object> outMap, Map<String, Object> options) {
    List <Map<String, String>> uiOptionsMap = new List<Map<String, String>>();
    Map<String, String> tempMap = new Map<String, String> ();
    outMap.put('label', Label.GFiber_Template_Folder);
  }

  /**
   * @description to get templates name of folder GFiber Template Folder;
   */
  @AuraEnabled(cacheable = true)
  public static Map<String, Object> getTemplates(Map<String, Object> input,
    Map<String, Object> outMap, Map<String, Object> options) {
    List<Map<String, String>> uiOptionsMap = new List < Map<String, String>>();
    list<EmailTemplate> temp = new list<EmailTemplate>();
    list<String> templateList = new list<String>();
    temp = [
      SELECT
        Id,
        Name
      FROM
        EmailTemplate
      WHERE
        isActive = true
      AND
        Folder.Name = :Label.GFiber_Template_Folder
    ];
    for (EmailTemplate TemplateRecords : temp) {
      Map<String, String> tempMap = new Map<String, String>();
      tempMap.put('Id', TemplateRecords.Id);
      tempMap.put('TemplateLabel', TemplateRecords.Name);
      uiOptionsMap.add(tempMap);
    }
    outMap.put('options', uiOptionsMap);
    return outMap;
  }

  /**
   * @description to get templates details of folder GFiber Template Folder;
   */
  @AuraEnabled(cacheable = true)
  public static EmailTemplate getEmailTemplateDetail(
    Map<String, Object> input, Map<String, Object> outMap,
    Map<String, Object> options) {
    EmailTemplate template = new EmailTemplate();
    String subject;
    String body;
    try {
      template = [
        SELECT
          Id,
          body,
          subject,
          HtmlValue
        FROM
          EmailTemplate
        WHERE
          Id = :String.valueOf(input.get('templateId'))
      ];
      string htmlReplace = '';
      htmlReplace = template.HtmlValue;
      String FirstName = UserInfo.getFirstName();
      if (htmlReplace != null) {
        htmlReplace = htmlReplace.replace('{!User.Name}', FirstName);
      }
      outMap.put('subject', template.subject);
      outMap.put('body', htmlReplace);
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog('EmailController',
        'getEmailTemplateDetail', exp);
      throw exp;
    }
    return template;
  }

  /**
   * @description to get email of account's primary contact
   *  or lead based on record Id;
   */
  @AuraEnabled(cacheable = true)
  public static void getEmail(
    Map<String, Object> input, Map<String, Object> outMap,
    Map<String, Object> options) {
    Lead leadObj = new Lead();
    Id recordId = String.valueOf(input.get('recordId'));
    String email = '';
    try {
      if (recordId.getSObjectType().getDescribe().getName() == 'Lead') {
        leadObj = [
        SELECT
          Id,
          Name,
          Email
        FROM
          Lead
        WHERE
          Id = :recordId
        ];
        email = leadObj.Email;
        outMap.put('email', email);
      } else if (recordId.getSObjectType().getDescribe().getName() == 'Account') {
        Account acc = new Account();
        acc = [
          SELECT
            Id,
            vlocity_cmt__PrimaryContactId__r.Email
          FROM
            Account
          WHERE
            Id = :recordId
          LIMIT 1
        ];
        email = acc.vlocity_cmt__PrimaryContactId__r.Email;
        outMap.put('email', email);
      }

    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog('EmailController',
        'getEmail', exp);
      throw exp;
    }
  }

  /**
   * @description to get open contact ticket from Account or Lead;
   */
  @AuraEnabled(cacheable = true)
  public static void getContactTicket(
    Map<String, Object> input,
    Map<String, Object> outMap,
    Map<String, Object> options) {
    Lead leadObj = new Lead();
    Id recordId = String.valueOf(input.get('recordId'));
    String sObjName = '';
    boolean isContact = false;
    try {
      if (String.isNotBlank(recordId)) {
        sObjName = recordId.getSObjectType().getDescribe().getName();
      }
      if (sObjName == 'Lead') {
        list<History_Event__c> contact = new list <History_Event__c>();
        contact = [
          SELECT
            Id,
            Lead__c,
            Status__c
          FROM
            History_Event__c
          WHERE
            Lead__c = :recordId
          AND
            Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
        ];
        if (contact.size() > 0) {
          outMap.put('isContact', true);
        } else {
          outMap.put('isContact', false);
        }
      } else if (sObjName == 'Account') {
        list<History_Event__c> contact = new list<History_Event__c>();
        contact = [
          SELECT
            Id,
            Account__c,
            Status__c
          FROM
            History_Event__c
          WHERE
            Account__c = :recordId
          AND
            Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
        ];
        if (contact.size() > 0) {
          outMap.put('isContact', true);
        } else {
          outMap.put('isContact', false);
        }
      }
    } catch (Exception exp) {
      LoggingUtility.insertExceptionLog('EmailController',
        'getEmail', exp);
      throw exp;
    }
  }

  /**
   * @description to send email address to gama using gama API.
   */
  @AuraEnabled(cacheable = true)
  public static Map<String, Object> sendEmailService(
    Map<String, Object> input,
    Map<String, Object> outMap,
    Map<String, Object> options) {
    String gaiaId = '';
    String subject = String.valueOf(input.get('subject'));
    Id recordId = String.valueOf(input.get('recordId'));
    Map<String, Object> message;
    String sObjName = recordId.getSObjectType().getDescribe().getName();
    list<History_Event__c> openContact = new list <History_Event__c>();
    Account acc = new Account();
    Lead leadObj = new Lead();
    if (sObjName == 'Lead') {
      openContact = [
        SELECT
          Id,
          Lead__c,
          Status__c
        FROM
          History_Event__c
        WHERE
          Lead__c = :recordId
        AND
          Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
      ];

      leadObj = [
        SELECT
          id,
          Name,
          vlocity_cmt__PremisesId__r.vlocity_cmt__PremisesIdentifier__c,
          Email
        FROM
          Lead
        WHERE
          id = :recordId
      ];
      input.put('requestId',
          leadObj.vlocity_cmt__PremisesId__r.vlocity_cmt__PremisesIdentifier__c +
            '-' + System.now());
    } else if (sObjName == 'Account') {
      openContact = [
        SELECT
          Id,
          Account__c,
          Status__c
        FROM
          History_Event__c
        WHERE
          Account__c = :recordId
        AND
          Status__c = :Constants.HISTORY_EVENT.STATUS.OPEN
      ];

      acc = [
        SELECT
          Id,
          vlocity_cmt__PremisesId__r.vlocity_cmt__PremisesIdentifier__c,
          vlocity_cmt__PrimaryContactId__r.Email, vlocity_cmt__PrimaryContactId__r.Gaia_Id__c
        FROM
          Account
        WHERE
          Id = :recordId
        LIMIT 1
      ];
      input.put('requestId',
          acc.vlocity_cmt__PremisesId__r.vlocity_cmt__PremisesIdentifier__c +
            '-' + System.now());
    } 
    input.put('campaignId', Label.Email_Campaign);
    input.put('languagePreference', 'en');
    input.put('subject', subject);
    input.remove('recordId');

    /**
     * Call the IP via runIntegrationService and save the output to ipOutput.
     */
    outMap = (Map<String, Object> )
    vlocity_cmt.IntegrationProcedureService.runIntegrationService(
        'TCK_UpdateSendAdhocEmail', input, options);
    History_Action__c historyAction = new History_Action__c();
    if (subject == 'Remote Authentication Form') {
      historyAction.Type__c = 'Proof of Residency Requested';
    } else {
      historyAction.Type__c = Constants.HISTORY_EVENT.TYPE.EMAIL;
    }
    historyAction.Email_Campaign_Id__c = Label.Email_Campaign;
    historyAction.Email_Request_Id__c = String.ValueOf(input.get('requestId'));
    historyAction.Email_Sent_To__c = String.ValueOf(input.get('emailId'));
    historyAction.Email_Subject__c = String.ValueOf(input.get('subject'));
    historyAction.Email_Body__c = String.valueOf(input.get('body'));
    if (sObjName == 'Lead') {
      historyAction.Lead__c = recordId;
    } else if (sObjName == 'Account') {
      historyAction.Account__c = recordId;
    }
    historyAction.History_Event__c = openContact.get(0).Id;
    insert historyAction;
    return message;
  }
}