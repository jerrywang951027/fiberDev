/**
 * @group Order
 * @description Test class for OrderTriggerHandler to improve code coverage and test functionality.
 */
@isTest
private class OrderTriggerHandlerTest {
  /**
   * @description Test data set up method.
   */
  @testSetup
  private static void testSetup() {
    Logging_Level__c setting = TestDataFactory.getLoggingSetting();
    insert setting;
    List<Order> orderList = new List<Order>();
    Account accountRecord = TestDataFactory.getAccountData();
    insert accountRecord;
    Contact contactRecord = TestDataFactory.getContactData(accountRecord.Id);
    insert contactRecord;
    vlocity_cmt__Premises__c premisesRecord =
        TestDataFactory.getPremisesData(Constants.PREMISES.STATUS.SUBMITTED_FOR_REVIEW);
    insert premisesRecord;
    Lead leadRecord = TestDataFactory.getLeadData();
    leadRecord.Status = Constants.LEAD.STATUS.STATUS_NEW;
    leadRecord.vlocity_cmt__PremisesId__c= premisesRecord.Id;
    insert leadRecord;
    Order orderRecord = TestDataFactory.getOrderData(accountRecord.Id);
    orderRecord.vlocity_cmt__DefaultPremisesId__c = premisesRecord.Id;
    insert orderRecord;
    orderRecord.vlocity_cmt__OrderStatus__c = Constants.ORDER.STATUS.IN_PROGRESS;
    //update orderRecord;
  }

  /**
   * @description Positive scenario to check Lead status update based on Order status.
   * @param NA
   * @return null
   */
  @isTest
  private static void updateOrderStatusToInProgressOrderShouldConvertLead() {
      Account accountRecord = [
        SELECT Id
        FROM
          Account
        LIMIT 1
    ];

    List<Order> orderInput = [
        SELECT
          Id, Status,
          vlocity_cmt__OrderStatus__c
        FROM
          Order
        WHERE
          AccountId = :accountRecord.Id
    ];

    Test.startTest();
      orderInput[0].vlocity_cmt__OrderStatus__c = Constants.ORDER.STATUS.IN_PROGRESS;
      update orderInput;
    Test.stopTest();
    List<Lead> leadRecord = [
        SELECT
          Id, Status
        FROM
          Lead
        WHERE
          Account__c = :accountRecord.Id
    ];

    System.assertEquals(Constants.LEAD.STATUS.CONVERTED, leadRecord[0].Status);
  }

  /**
   * @description Positive scenario to check Lead status update
   * when order status updated to Cancelled.
   * @param NA
   * @return null
   */
  @isTest
  private static void updateOrderStatusInProgressToCancelledShouldChangeLeadStatusToNew() {
    Account accountList = [
        SELECT
          Id
        FROM
          Account
        LIMIT 1
    ];

    List<Order> orderInput = [
        SELECT Id,
          Status,
          vlocity_cmt__DefaultPremisesId__c,
          vlocity_cmt__OrderStatus__c
        FROM
          Order
        WHERE
          accountId = :accountList.Id
    ];

    Test.startTest();
      orderInput[0].vlocity_cmt__OrderStatus__c = Constants.ORDER.STATUS.CANCELLED;
      update orderInput;
    Test.stopTest();

    Lead leadResponse = [
        SELECT Id,
          Status
        FROM
          Lead
        WHERE
          vlocity_cmt__PremisesId__r.Id =: orderInput[0].vlocity_cmt__DefaultPremisesId__c
        LIMIT 1
    ];

    System.assertEquals(Constants.LEAD.STATUS.STATUS_NEW, leadResponse.Status);
  }
}