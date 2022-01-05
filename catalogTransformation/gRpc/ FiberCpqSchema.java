
package com.google.access.bss.sfdc.schema;

/**
 * Fiber SFDC CPQ schema that captures fields used by BSS logic. The list of fields for each object
 * here is not the full list.
 */
public final class FiberCpqSchema {
  private FiberCpqSchema() {}
  
  // TODO(b/178406188): Fix enum constant names to be all uppercase due to java style violation.

  /** The SBQQ__ErrorCondition__c object. */
  public static enum ErrorCondition implements SalesforceField {
    Id,
    Name,
    // What kind of value should the filter be checked against.
    SBQQ__FilterType__c,
    // The value to perform the filter with, if FilterType is 'Value'.
    SBQQ__FilterValue__c,
    // The index number of this condition, can be used if the Rule itself has advanced condition.
    SBQQ__Index__c,
    // The operator of this condition.
    SBQQ__Operator__c,
    // The object to test against.
    SBQQ__TestedObject__c,
    // The field in the object to test against. Dependent on the TestedObject.
    SBQQ__TestedField__c,
    // Formula field reflecting whether the parent Rule is active.
    SBQQ__ParentRuleIsActive__c,
    // The Product Rule this condition belongs to.
    SBQQ__Rule__c,
    ;

    public static String type() {
      return "SBQQ__ErrorCondition__c";
    }
  }

  /** The Product2 object. */
  public static enum Product implements SalesforceField {
    Activated__c,
    Cms_Lineup_Id__c,
    Criteria__c,
    Description,
    Effective_End_Date__c,
    Effective_Start_Date__c,
    Family,
    Fiber_Market__c,
    GFiber_Cost__c,
    GFiber_Device_Type__c,
    GFiber_Device_Model__c,
    GFiber_Min_IPv4_Subnet_Prefix__c,
    GFiber_Min_IPv6_Subnet_Prefix__c,
    Id,
    IsActive,
    Name,
    ProductCode,
    Product_Line__c,
    Product_Sub_Line__c,
    SBQQ__Component__c,
    Static_Ip_Ipv4_Address_Count__c,
    Static_Ip_Has_Ipv4_Lan_Service__c,
    Static_Ip_Ipv4_Lan_Subnet_Prefix__c,
    TV_Package_Id__c,
    Zuora_Product_Id__c,
    SureTax_Transaction_Type_Code__c,
    SureTax_Regulatory_Code__c,
    Line_Item_Message__c,
    Payments_Usage_Type__c,
    Sub_Service_Id__c,
    ;

    public static String type() {
      return "Product2";
    }
  }

  /** The SBQQ__ProductAction__c object. */
  public static enum ProductAction implements SalesforceField {
    Id,
    Name,
    // The type of action to perform.
    SBQQ__Type__c,
    // The field to filter Product to perform the action.
    SBQQ__FilterField__c,
    // The value to filter the field on.
    SBQQ__FilterValue__c,
    // The operator to perform the filter on the field with the value.
    SBQQ__Operator__c,
    // Formula field reflecting whether the parent Rule is active.
    SBQQ__ParentRuleIsActive__c,
    // The Product Rule this action belongs to.
    SBQQ__Rule__c,
    ;

    public static String type() {
      return "SBQQ__ProductAction__c";
    }
  }

  /** The SBQQ__ProductFeature__c object. */
  public static enum ProductFeature implements SalesforceField {
    Id,
    Name,
    // ID of parent product.
    SBQQ__ConfiguredSKU__c,
    // Minimum number of options that may be chosen from this group.
    SBQQ__MaxOptionCount__c,
    // Maximum number of options that may be chosen from this group.
    SBQQ__MinOptionCount__c,
    // For display order in UI.
    SBQQ__Number__c,
    ;

    public static String type() {
      return "SBQQ__ProductFeature__c";
    }
  }

  /** The SBQQ__ProductOption__c object. */
  public static enum ProductOption implements SalesforceField {
    Id,
    Name,
    // Whether OptionType is AUTOMATIC.
    GFiber_Automatic__c,
    // Whether OptionType is INCLUDED.
    SBQQ__Bundled__c,
    // ID of parent product of parent feature.
    SBQQ__ConfiguredSKU__c,
    // ID of parent feature.
    SBQQ__Feature__c,
    // Minimum number of the product that may be chosen at a time.
    SBQQ__MaxQuantity__c,
    // Maximum number of the product that may be chosen at a time.
    SBQQ__MinQuantity__c,
    // ID of product.
    SBQQ__OptionalSKU__c,
    // The formula field reflecting the ProductCode of the OptionalSKU.
    SBQQ__ProductCode__c,
    // Whether OptionType is REQUIRED.
    SBQQ__Required__c,
    // Whether OptionType is RECOMMENDED.
    SBQQ__Selected__c,
    // For display order in UI.
    SBQQ__Number__c,
    ;

    public static String type() {
      return "SBQQ__ProductOption__c";
    }
  }

  /** The Product_Rate_Plan__c object. */
  public static enum ProductRatePlan implements SalesforceField {
    Id,
    Name,
    Criteria__c,
    Effective_End_Date__c,
    Effective_Start_Date__c,
    Fiber_Market__c,
    Product_Rate_Plan_Code__c,
    Product__c,
    Zuora_Product_Rate_Plan_Id__c,
    Line_Item_Message__c,
    ;

    public static String type() {
      return "Product_Rate_Plan__c";
    }
  }

  /** The Product_Rate_Plan_Charge__c object. */
  public static enum ProductRatePlanCharge implements SalesforceField {
    Id,
    Apply_Discount_To__c,
    Charge_Model__c,
    Charge_Type__c,
    Discount_Level__c,
    Name,
    Product_Rate_Plan__c,
    Recurrences__c,
    Tax_Code__c,
    Tax_Mode__c,
    Taxable__c,
    Unit_Type__c,
    Zuora_Product_Rate_Plan_Charge_Id__c,
    Trigger_Event__c,
    ;

    public static String type() {
      return "Product_Rate_Plan_Charge__c";
    }
  }

  /** The Product_Rate_Plan_Charge_Tier__c object. */
  public static enum ProductRatePlanChargeTier implements SalesforceField {
    Id,
    Name,
    Starting_Unit__c,
    Ending_Unit__c,
    Price__c,
    Price_Format__c,
    Product_Family__c,
    Product_Rate_Plan_Charge__c,
    Hardware_Ownership__c,
    Is_Bundled__c,
    Return_Window_Display_Days__c,
    Return_Window_Enforced_Days__c,
    ;

    public static String type() {
      return "Product_Rate_Plan_Charge_Tier__c";
    }
  }

  /** The SBQQ__ProductRule__c object. */
  public static enum ProductRule implements SalesforceField {
    Id,
    Name,
    // Whether the rule is active.
    SBQQ__Active__c,
    // The advanced condition if ConditionsMet is 'Advanced'.
    SBQQ__AdvancedCondition__c,
    // How the conditions are evaluated, AND, OR, or Advanced.
    SBQQ__ConditionsMet__c,
    // The scope of the Rule.
    SBQQ__Scope__c,
    // The type of the Rule.
    SBQQ__Type__c,
    // When to evaluate the rule. CPQ required field, not used by ProductCatalogService.
    SBQQ__EvaluationEvent__c,
    // Fields used to filter product rules.
    Criteria__c,
    Fiber_Market__c,
    Product_Rule_Code__c,
    ;

    public static String type() {
      return "SBQQ__ProductRule__c";
    }
  }

  /** The SBBQ_Subscription__c object. */
  @SuppressWarnings("ConstantCaseForConstants")
  public static enum Subscription implements SalesforceField {
    Id,
    Activation_time__c,
    Available_ipv4_address_count__c,
    Billing_start_date__c,
    Chromecast_offer_Promo_code__c,
    Chromecast_offer_Retrieval_time__c,
    Chromecast_offer_type__c,
    CMS_Lineup_Id__c,
    Combined_External_Id__c,
    Fds_Account_Id__c,
    Internal_name__c,
    Internet_Type__c,
    Ip_Address_Type__c,
    Ip_Allocation_Type__c,
    Name,
    Product_Id__c,
    Provider_billing_end_time__c,
    Provider_order_id__c,
    Provider_username__c,
    Service_billing_status__c,
    Service_end_date__c,
    Service_Type__c,
    static_IP_Service_Activation_time__c,
    Static_IP_Service_Billing_start_date__c,
    Streaming_Service_Provider__c,
    Subnet_prefix__c,
    Subscription_Period__c,
    Subscription_Type__c,
    TV_Package_Id__c,
    YouTube_TV_Service_Option__c;

    public static String type() {
      return "SBBQ_Subscription__c";
    }
  }
}
