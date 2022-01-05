/**
 * @group Integration Procedure EmailController class
 * @description EmailController test class hold.
 */

@isTest
private class EmailControllerTest {

   /**
   * @description this test method validates spicified template folder
   * if the Validate key follows the expected formation rules.
   */
  @isTest
  static void getTemplateFolder() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'getFolder';
    Folder folderName = TestDataFactory.getEmailTemplateFolder();
    inputMap.put('Id', folderName.Id);
    TicketingUtils controller = new TicketingUtils();
    Map<String, String> allOPtionsMap = new Map<String, String>();

    Test.startTest();
      controller.invokeMethod(methodName, inputMap, outMap, optionsMap);
      List<Map<String, Object>> templateList =
          (List<Map<String, Object>>)outMap.get('options');
    Test.stopTest();
    System.assertEquals(folderName.Name, outMap.get('label'),
        methodName+' should return template folder name by criteria');
  }

  /**
   * @description this test method validates spicified template folder and templates
   * if the Validate key follows the expected formation rules.
   */
  @isTest
  static void getTemplates() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'getTemplates';
    EmailTemplate template = TestDataFactory.getEmailTemplate();
    insert template;

    inputMap.put('TemplateLabel', template.Name);
    inputMap.put('Id', template.Id);
    TicketingUtils controller = new TicketingUtils();

    Test.startTest();
      controller.invokeMethod(methodName, inputMap, outMap, optionsMap);
      List<Map<String, Object>> templateList =
          (List<Map<String, Object>>)outMap.get('options');
    Test.stopTest();
    Map<String, String> allOPtionsMap = new Map<String, String>();
    for(Map<String, Object> optionss:templateList){
          allOPtionsMap.put((String)optionss.get('TemplateLabel'),(String)optionss.get('value'));
    }
    System.assertEquals(true,
        allOPtionsMap.containsKey(template.Name),
        methodName+' should return template name by criteria');
  }

  /**
   * @description this test method validates template detail
   * if the Validate key follows the expected formation rules.
   */
  @isTest
  static void getEmailTemplateDetailTest() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'getEmailTemplateDetail';
    EmailTemplate template = TestDataFactory.getEmailTemplate();
    insert template;

    inputMap.put('templateId', template.Id);
    inputMap.put('TemplateLabel', template.Name);
    inputMap.put('subject', 'templatesubject');
    inputMap.put('body', 'htmlReplace');

    TicketingUtils controller = new TicketingUtils();
    Map<String, String> allOPtionsMap = new Map<String, String>();

    Test.startTest();
       controller.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    System.assertEquals(false,
        allOPtionsMap.containsKey(template.Name),
        methodName+' should return template name by criteria');
  }

  /**
   * @description this test method validates Lead object detail
   * if the Validate key follows the expected formation rules.
   */
  @isTest
  static void getLeadEmailTest() {

    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'getEmail';

    Lead leadRecord = TestDataFactory.getLeadData();
    leadRecord.Email = 'test@google.com';
    insert leadRecord;

    inputMap.put('recordId', leadRecord.Id);
    outMap.put('email', leadRecord.Email);
    TicketingUtils emailControllerRecord =
        new TicketingUtils();

    Test.startTest();
      emailControllerRecord.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    System.assertEquals(leadRecord.Email,outMap.get('email'),
        methodName+' should return email by criteria');
  }

   /**
   * @description this test method validates Primary Contact detail
   * if the Validate key follows the expected formation rules.
   */
  @isTest
  static void getPrimaryContactTicketBasedLead() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'getContactTicket';

    Lead leadRecord = TestDataFactory.getLeadData();
    leadRecord.Email = 'test@google.com';
    insert leadRecord;

    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;

    Contact contactRecord = TestDataFactory.getContactData(accountRecord.Id);
    contactRecord.Email = 'test@google.com';
    contactRecord.Account = accountRecord;
    insert contactRecord;

    History_Event__c historyEventRecord = TestDataFactory.getHistoryEventData();
    historyEventRecord.External_Ticket__c = '202583921';
    historyEventRecord.Status__c = 'Open';
    historyEventRecord.Lead__c = leadRecord.Id;
    insert historyEventRecord;

    String recordId = String.valueOf(leadRecord.Id);
    String sObjName = 'Lead';
    inputMap.put('recordId', leadRecord.Id);
    inputMap.put('isContact', false);

    TicketingUtils emailController =
        new TicketingUtils();
    Map<String, String> allOPtionsMap = new Map<String, String>();

    Test.StartTest();
      emailController.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    System.assertEquals(false,
        allOPtionsMap.containsKey(leadRecord.Id),
        methodName+' should return lead by criteria');
  }

  /**
   * @description this test method validates Primary Contact's Account detail
   * if the Validate key follows the expected formation rules.
   */
  @isTest
  static void getPrimaryContactTicketBasedAccount() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'getContactTicket';

    Lead leadRecord = TestDataFactory.getLeadData();
    leadRecord.Email = 'test@google.com';
    insert leadRecord;

    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;

    Contact contactRecord = TestDataFactory.getContactData(accountRecord.Id);
    contactRecord.Email = 'test@google.com';
    contactRecord.Account = accountRecord;
    insert contactRecord;

    History_Event__c historyEventRecord = TestDataFactory.getHistoryEventData();
    historyEventRecord.External_Ticket__c = '202583921';
    historyEventRecord.Status__c = 'Open';
    historyEventRecord.Lead__c = leadRecord.Id;
    insert historyEventRecord;

    String recordId = String.valueOf(leadRecord.Id);
    String sObjName = 'Lead';
    inputMap.put('recordId', leadRecord.Id);
    inputMap.put('isContact', true);

    TicketingUtils emailControllerRecord =
        new TicketingUtils();
    Test.startTest();
      emailControllerRecord.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    System.assertEquals(true, outMap.get('isContact'),
        methodName+' should return lead by criteria');
  }

  /**
   * @description this test method validates Primary Contact's Account availability detail
   * if the Validate key follows the expected formation rules.
   */
  @isTest
  static void getPrimaryOpenContactBasedAccount() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'getContactTicket';

    Lead leadRecord = TestDataFactory.getLeadData();
    leadRecord.Email = 'test@google.com';
    insert leadRecord;

    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;

    Contact contactRecord = TestDataFactory.getContactData(accountRecord.Id);
    contactRecord.Email = 'test@google.com';
    contactRecord.Account = accountRecord;
    insert contactRecord;

    History_Event__c historyEventRecord = TestDataFactory.getHistoryEventData();
    historyEventRecord.External_Ticket__c = '202583921';
    historyEventRecord.Status__c = 'Open';
    historyEventRecord.Account__c = accountRecord.Id;
    insert historyEventRecord;

    String recordId = String.valueOf(accountRecord.Id);
    String sObjName = 'Account';
    inputMap.put('recordId', accountRecord.Id);
    inputMap.put('isContact', false);

    TicketingUtils emailControllerRecord =
    new TicketingUtils();
    Test.startTest();
      emailControllerRecord.invokeMethod(methodName, inputMap, outMap, optionsMap);
    Test.stopTest();
    System.assertEquals(true, outMap.get('isContact'),
        methodName+' should return true based on account by criteria');
  }

  /**
   * @description this test method validates to called IP
   * to send account contact's email service to Gama.
   */
  @isTest
  static void getsendAccountEmailService() {
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'sendEmailService';

    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;

    String subject = 'subject';
    String recordId = String.valueOf(accountRecord.Id);
    String sObjName = 'Account';

    History_Event__c historyEventRecord = TestDataFactory.getHistoryEventData();
    historyEventRecord.External_Ticket__c = '202583921';
    historyEventRecord.Status__c = 'Open';
    historyEventRecord.Account__c = accountRecord.Id;
    historyEventRecord.Email_Campaign_Id__c = Decimal.valueOf(Label.Email_Campaign);
    insert historyEventRecord;

    input.put('emailId', 'test@google.com');
    input.put('body', 'body');
    input.put('recordId', recordId);
    input.put('campaignId', Label.Email_Campaign);
    input.put('languagePreference', 'en');
    input.put('subject', 'subject');
    input.put('requestId', '1231231');

    Test.startTest();
      TicketingUtils emailController =
          new TicketingUtils();
      emailController.invokeMethod(methodName, input, outMap, optionsMap);
    Test.stopTest();
    System.assertEquals(Decimal.valueOf(Label.Email_Campaign),
        historyEventRecord.Email_Campaign_Id__c,
        methodName+' should send campainId to gama by account');
  }

  /**
   * @description this test method validates to called IP
   * to send lead email service to Gama.
   */
  @isTest
  static void getsendLeadEmailService() {
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionsMap = new Map<String, Object>();
    String methodName = 'sendEmailService';
    Lead leadRecord = TestDataFactory.getLeadData();
    leadRecord.Email = 'test@google.com';
    insert leadRecord;

    String subject = 'subject';
    String recordId = String.valueOf(leadRecord.Id);
    String sObjName = 'Lead';

    History_Event__c historyEventRecord = TestDataFactory.getHistoryEventData();
    historyEventRecord.External_Ticket__c = '202583921';
    historyEventRecord.Status__c = 'Open';
    historyEventRecord.Lead__c = leadRecord.Id;
    historyEventRecord.Email_Campaign_Id__c = Decimal.valueOf(Label.Email_Campaign);
    insert historyEventRecord;

    input.put('emailId', 'test@google.com');
    input.put('body', 'body');
    input.put('recordId', recordId);
    input.put('campaignId', Label.Email_Campaign);
    input.put('languagePreference', 'en');
    input.put('subject', 'subject');
    input.put('requestId', system.now());

    Test.startTest();
    TicketingUtils  emailController =
        new TicketingUtils();
      emailController.invokeMethod(methodName, input, outMap, optionsMap);
    Test.stopTest();
    System.assertEquals(Decimal.valueOf(Label.Email_Campaign),
        historyEventRecord.Email_Campaign_Id__c,
        methodName+' should send campainId to gama by led');
  }
}