/***
* @group Implementations
*
* @description strongly typed interface: ProductAvailabilityInterface <br>
* <1>Intro and Purpose: Interface to return the list of available products <br>
* <2>Triggering the Interface: Called by getProducts() method in OrderManagement <br>
* <3>Other implementations: LocaleProductAvailability, FilterAvailabilityImplementation
**/
global inherited sharing class DefaultProductAvailabilityImplementation implements
    GlobalInterfaces.ProductAvailabilityInterface, PredictiveOSAwareInterface
{

/**
* @param item (SObject) : parent item ie Order, Quote or Oppty
* @param retval (List&ltPriceBookEntry&gt) :  list of PBE processed so far
* @return List&ltPriceBookEntry&gt : filtered list
* @description  This default implementation returns the list it was passed (retval)
*  or if that is null it returns back the complete list of PBE for the Pricebook on the parent item.
*/
    global List<PriceBookEntry> getAvailableProducts(SObject item, List<PriceBookEntry> retval)
    {
        if(retval ==null || (retval !=null && retval.size()==0))
        {
            retval = new List<PriceBookEntry> ();
            try
            {
                List<String> queryFields = new List<String>{'Id'
                    ,'Pricebook2Id'
                    ,'Product2Id'
                    ,'ProductCode'
                    ,'Product2.Type__c'
                    ,'Product2.SubType__c'
                    ,'Product2.Description'
                    ,'UnitPrice'
                    ,'Name'
                    ,'Product2.Name'
                    ,'Product2.JSONAttribute__c'
                    ,'RecurringPrice__c'
                    ,'IsActive'};
                Id pricebookId = null;
                String parentCurrencyIsoCode = null;
                String queryCondition = ' WHERE Pricebook2Id = :pricebookId ';
                queryCondition += ' AND (Product2.recordTypeId = null OR Product2.recordType.DeveloperName = \'Product\')';
                try
                {
                    pricebookId = (Id) item.get('Pricebook2Id');
                }
                catch (Exception e)
                {
                    SObject parentItem =
                        PredictiveObjectStore.getInstance().fetch(item.Id, new Set<String>{'Pricebook2Id'});
                    pricebookId = (Id)parentItem.get('Pricebook2Id');
                }
                
                if(UserInfo.isMultiCurrencyOrganization())
                {
                    try
                    {
                        parentCurrencyIsoCode = (String) item.get('CurrencyIsoCode');
                    }
                    catch (Exception e)
                    {
                        SObject parentItem =
                        PredictiveObjectStore.getInstance().fetch(item.Id, new Set<String>{'CurrencyIsoCode'});
                        parentCurrencyIsoCode = (String)parentItem.get('CurrencyIsoCode');
                    }
                    queryFields.add('CurrencyIsoCode');
                    queryCondition += ' AND CurrencyIsoCode = :parentCurrencyIsoCode';
                }
                
                String query = 'SELECT '+String.join(queryFields,',')+' FROM PricebookEntry '+queryCondition;
                retval = Database.query(query);
            }
            catch(Exception e)
            {
                throw e;
            }
       }

       return retval;
    }
}