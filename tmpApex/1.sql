select vlocity_cmt__ProductId__c,vlocity_cmt__PriceListId__r.Name,vlocity_cmt__OfferId__c,Id,vlocity_cmt__DisplayText__c,vlocity_cmt__PricingElementId__r.vlocity_cmt__DisplayText__c,vlocity_cmt__PricingElementAmount__c,vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__AdjustmentMethod__c,vlocity_cmt__PricingElementId__r.Name,vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c,vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__RecurringFrequency__c,vlocity_cmt__IsVirtualPrice__c,vlocity_cmt__IsBasePrice__c from vlocity_cmt__PriceListEntry__c where vlocity_cmt__IsActive__c=true