/**
 * @group Order
 * @description This handler class is for Order object trigger.
 *    It holds order trigger activities
 */
public with sharing class OrderTriggerHandler {
  public final static String CLASS_NAME = 'OrderTriggerHandler';
  /**
   * @description afterUpdateHandler It is invoked after record update is completed.
   * @param newOrders It contains new version of Orders as a list.
   * @param oldOrderMap It is a map of Orders which contains old version data.
   * @return null
   */
  public static void afterUpdateHandler(List<Order> newOrders, Map<Id,Order> oldOrderMap) {
    refreshConvertedLead(newOrders, oldOrderMap);
    convertLead(newOrders, oldOrderMap);
  }

  /**
   * @description To convert the Lead based on Premises of Order.
   * Lead status is updated to converted when Order status is In Progress
   * @params newOrders It contains new version of Orders as a list.
   * @return null
   */
  public static void convertLead(List<Order> newOrders, Map<Id,Order> oldOrderMap) {
    final String METHOD_NAME = 'convertLead';
    Set<Id> accountIds = new Set<Id>();
    Set<Id> premisesIds = new Set<Id>();
    Map<Id, Id> contactIdByAccountId = new Map<Id, Id>();
    Map<Id, Lead> mapOrderByPremisesId = new Map<Id, Lead>();
    List<Lead> convertedLeads = new List<Lead>();
    List<Lead> convertedCustomersLeads = new List<Lead>();
    try {
      for (Order order : newOrders) {
        if (oldOrderMap.get(order.Id).vlocity_cmt__OrderStatus__c
            != order.vlocity_cmt__OrderStatus__c
            && order.vlocity_cmt__OrderStatus__c == Constants.ORDER.STATUS.IN_PROGRESS
            && order.vlocity_cmt__DefaultPremisesId__c != null) {
          accountIds.add(order.accountId);
          premisesIds.add(order.vlocity_cmt__DefaultPremisesId__c);
        }
      }
      // Assigning account and contact Id's to map
      List<Contact> contactList = [
          SELECT
            Id, accountId
          FROM
            Contact
          WHERE
            accountId IN :accountIds
      ];
      for (Contact contact : contactList) {
        contactIdByAccountId.put(contact.accountId, contact.Id);
      }
      // Query for the Lead fields based on valid Premises
      List<Lead> leadsList = [
          SELECT Id, Name,
            Status, Account__c, Contact__c,
            vlocity_cmt__PremisesId__c, OwnerId, LastModifiedById
          FROM
            Lead
          WHERE
            vlocity_cmt__PremisesId__c IN :premisesIds
          AND Is_Converted__c = false
          ORDER BY LastModifiedDate DESC
      ];

      for(Lead leadRecord : leadsList){
        if(String.isNotBlank(leadRecord.vlocity_cmt__PremisesId__c)){
          if(!mapOrderByPremisesId.containsKey(leadRecord.vlocity_cmt__PremisesId__c)){
            mapOrderByPremisesId.put(leadRecord.vlocity_cmt__PremisesId__c, leadRecord);
          }
        }
      }
      History_Event__c historyEventRecord =
              new History_Event__c();
      if(!mapOrderByPremisesId.isEmpty()){
        for (Order order : newOrders) {
          if (mapOrderByPremisesId.containsKey(order.vlocity_cmt__DefaultPremisesId__c)) {
            Lead leadRecord = mapOrderByPremisesId.get(order.vlocity_cmt__DefaultPremisesId__c);
            leadRecord.OwnerId = leadRecord.LastModifiedById;
            leadRecord.Status = Constants.LEAD.STATUS.CONVERTED;
            leadRecord.Account__c = order.accountId;
            leadRecord.Contact__c = contactIdByAccountId.get(order.accountId);
            convertedLeads.add(leadRecord);
            //if(leadRecord.RecordTypeId == RecordTypeUtils.CUSTOMER_LEAD_ID){
              historyEventRecord.Order__c = order.Id;
              historyEventRecord.Type__c = 'Sign Up';//RecordTypeUtils
              historyEventRecord.Account__c = order.accountId;
            //}
            mapOrderByPremisesId.remove(order.vlocity_cmt__DefaultPremisesId__c);
          }
        }
      }
      if (!convertedLeads.isEmpty()) {
        update convertedLeads;
          historyEventRecord.Lead__c = convertedLeads.get(0).Id;
          insert historyEventRecord;
      }
    }
    catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }
  
  public static string getsignOrderPlanType(string orderId){
    list<OrderItem> productList = new list<OrderItem>();
    productList = [
        SELECT
          Id, 
          Product2.Name
        FROM 
          OrderItem 
        WHERE 
          OrderId = :orderId 
        AND 
          Product2.vlocity_cmt__Type__c = :'Internet'
    ];
    return productList.get(0).Product2.Name;
  }

  /*
   * @description To refresh converted Lead to new Lead.
   * when Order is changed from In Progress to Cancelled, a new Lead is created.
   * @param newOrders It contains new version of Orders as a list.
   * @param oldOrderMap It is a map of Orders which contains old version data.
   * @return  null
   */
  public static void refreshConvertedLead(List<Order> newOrders, Map<Id,Order> oldOrderMap) {
    final String METHOD_NAME = 'refreshConvertedLead';
    Set<Id> accountIds = new Set<Id>();
    List<Lead> newLeads = new List<Lead>();
    try {
      for (Order order : newOrders) {
        if ((order.vlocity_cmt__OrderStatus__c == Constants.ORDER.STATUS.CANCELLED
            && oldOrderMap.get(order.Id).vlocity_cmt__OrderStatus__c ==
            Constants.ORDER.STATUS.IN_PROGRESS) && order.accountId != null) {
          accountIds.add(order.accountId);
        }
      }
      List<Lead> leadsList = [
          SELECT Id, Name,
            Status, Sub_Status__c,
            Account__c, Contact__c,
            OwnerId, vlocity_cmt__PremisesId__c
          FROM
            Lead
          WHERE
            Account__c IN :accountIds
            AND Status = :Constants.LEAD.STATUS.CONVERTED
          ORDER BY CreatedDate DESC
      ];
      if (!leadsList.isEmpty()) {
        for (Lead leadRecord : leadsList) { 
           // system.debug('errMsg '+LeadUtils.addLeadToSalesQueue(leadRecord));
          Lead changedLeadRecord = LeadUtils.addLeadToSalesQueue(leadRecord);
          changedLeadRecord.Account__c = null;
          changedLeadRecord.Contact__c = null;
          changedLeadRecord.Sub_Status__c = '';
          newLeads.add(changedLeadRecord);
        }
      }
      if (!newLeads.isEmpty()) {
        update newLeads;
      }
    }
    catch (Exception exp) {
      LoggingUtility.insertExceptionLog(CLASS_NAME, METHOD_NAME, exp);
      throw exp;
    }
  }
}