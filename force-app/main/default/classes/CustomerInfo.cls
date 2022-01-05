/**
* @group customerInfo
* @description Wrapper to transform customer information data.
*/

global with sharing class CustomerInfo implements vlocity_cmt.VlocityOpenInterface2 {

  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * transformCustomerInfo method.
   * @param methodName The name of the method that will be invoked
   * @param inputMap The inputs of the method
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  global boolean invokeMethod(String methodName, Map <String, Object> inputMap,
      Map <String, Object> outMap, Map <String, Object> options) {

    Boolean result = true;
    try {
      if (String.isNotBlank(methodName) && methodName.equalsIgnoreCase('transformCustomerInfo')) {
        transformCustomerInfo(inputMap, outMap, options);
      }
    } catch (Exception exp) {
      result = false;
      LoggingUtility.insertExceptionLog('CustomerInfo', 'invokeMethod', exp);
      throw exp;
    }
    return result;
  }

  /*
   * @description To transform customer information data.
   */
  public void transformCustomerInfo(Map <String, Object> inputMap, Map <String, Object> outMap,
      Map <String, Object> options) {

    String jsonString = JSON.serialize(inputMap.get('customerAccount'));
    CustomerInfoCustomerAccount customerInfoResponseObj = new CustomerInfoCustomerAccount();
    if (String.isNotBlank(jsonString)) {
      customerInfoResponseObj = (CustomerInfoCustomerAccount)JSON.deserialize(jsonString,
          CustomerInfoCustomerAccount.class);
    }
    outMap.put('response', JSON.serialize(customerInfoResponseObj, true));
  }

  class CustomerInfoCustomerAccount {
    public String id;
    public CustomerInfoPrimaryContact primaryContact;
    public CustomerInfoServiceAccounts[] serviceAccounts;
  }

  class CustomerInfoServiceAccounts {
    public String accountState;
    public CustomerInfoBillingAccount billingAccount;
    public String id;
    public CustomerInfoItems[] items;
    public CustomerInfoPremises premises;
    public Decimal sumRecurringTotalMicros;
  }

  class CustomerInfoItems {
    public String action;
    public String activationTime;
    public String assetReferenceId;
    public String billingStartTime;
    public String cpeType;
    public String equipmentReturnStatus;
    public String id;
    public Decimal oneTimeTotalMicros;
    public CustomerInfoProduct product;
    public Decimal recurringTotalMicros;
  }

  class CustomerInfoProduct {
    public String description;
    public String legacyProductCode;
    public String productCode;
    public String type;
    public String zuoraRatePlanChargeId;
  }

  class CustomerInfoPremises {
    public String city;
    public String globalAddressId;
    public String state;
    public String streetAddress;
    public String zipCode;
  }

  class CustomerInfoBillingAccount {
    public String accountNumber;
    public String attemptedCancellationTime;
    public String billCycleDay;
    public Decimal daysDelinquent;
    public String state;
  }

  class CustomerInfoPrimaryContact {
    public String gaiaId;
  }
}