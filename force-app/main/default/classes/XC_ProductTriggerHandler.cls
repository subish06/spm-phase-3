public without sharing class XC_ProductTriggerHandler 
{
    public static void updateGiveawayProductsOnCostChange(List<Product2> triggerNew, Map<Id, Product2> triggerOldMap) 
    {
        List<Product2> prodsToUpdateChildCost = new List<Product2>();

        for(Product2 prod : triggerNew)
        {
            Product2 oldProd = triggerOldMap.get(prod.Id);

            if(prod.XC_Cost__c != oldProd.XC_Cost__c)
            {
                prodsToUpdateChildCost.add(prod);
            }
        }

        if(!prodsToUpdateChildCost.isEmpty())
        {
            updateChildCost(prodsToUpdateChildCost);
        }
    }

    private static void updateChildCost(List<Product2> prodList)
    {
        Map<Id, Product2> prodMap = new Map<Id, Product2>(prodList);

        List<XC_GiveawayProduct__c> giveawayProdList = [SELECT Id, NonFormulaCost__c, XC_Quantity__c, XC_Product__c 
                                                            FROM XC_GiveawayProduct__c 
                                                            WHERE XC_Product__c IN :prodMap.keySet()];

        List<XC_GiveawayProduct__c> updateList = new List<XC_GiveawayProduct__c>();

        for(XC_GiveawayProduct__c giveawayProd : giveawayProdList)
        {
            if(giveawayProd.XC_Quantity__c != null && prodMap.get(giveawayProd.XC_Product__c).XC_Cost__c != null)
            {
                Double newCost = (giveawayProd.XC_Quantity__c * prodMap.get(giveawayProd.XC_Product__c).XC_Cost__c).setScale(2);
                if(newCost != giveawayProd.NonFormulaCost__c)
                {
                    giveawayProd.NonFormulaCost__c = newCost;
                    updateList.add(giveawayProd);
                }
            }
            else 
            {
                //giveawayProd.NonFormulaCost__c = giveawayProd.XC_Quantity__c * relatedProdMap.get(giveawayProd.XC_Product__c).XC_Cost__c;
                Double newCost = 0;
                if(newCost != giveawayProd.NonFormulaCost__c)
                {
                    giveawayProd.NonFormulaCost__c = newCost;
                    updateList.add(giveawayProd);
                }
            }
        }

        if(!updateList.isEmpty())
        {
            update updateList;
        }
    }
}