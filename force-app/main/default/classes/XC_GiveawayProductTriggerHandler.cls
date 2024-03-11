public without sharing class XC_GiveawayProductTriggerHandler 
{
    public static void populateCost(List<XC_GiveawayProduct__c> triggerNew)
    {
        Set<Id> prodIds = new Set<Id>();
        List<XC_GiveawayProduct__c> updateGiveawayProds = new List<XC_GiveawayProduct__c>();

        for(XC_GiveawayProduct__c giveawayProd : triggerNew)
        {
            if(giveawayProd.XC_Product__c != null && giveawayProd.XC_Quantity__c != null && giveawayProd.XC_Quantity__c > 0)
            {
                updateGiveawayProds.add(giveawayProd);
                prodIds.add(giveawayProd.XC_Product__c);
            }
            else 
            {
                giveawayProd.NonFormulaCost__c = 0;
            }
        }

        Map<Id, Product2> relatedProdMap = new Map<Id, Product2>([SELECT Id, XC_Cost__c FROM Product2 WHERE Id IN :prodIds]);

        for(XC_GiveawayProduct__c giveawayProd : updateGiveawayProds)
        {
            if(relatedProdMap.containsKey(giveawayProd.XC_Product__c) && relatedProdMap.get(giveawayProd.XC_Product__c).XC_Cost__c != null)
            {
                giveawayProd.NonFormulaCost__c = giveawayProd.XC_Quantity__c * relatedProdMap.get(giveawayProd.XC_Product__c).XC_Cost__c;
            }
            else 
            {
                giveawayProd.NonFormulaCost__c = 0;
            }
        }
    }

    public static void checkForPopulateCost(List<XC_GiveawayProduct__c> triggerNew, Map<Id, XC_GiveawayProduct__c> triggerOldMap)
    {
        List<XC_GiveawayProduct__c> prodsToUpdateCost = new List<XC_GiveawayProduct__c>();

        for(XC_GiveawayProduct__c giveawayProd : triggerNew)
        {
            XC_GiveawayProduct__c oldGiveawayProd = triggerOldMap.get(giveawayProd.Id);

            if(giveawayProd.XC_Product__c != oldGiveawayProd.XC_Product__c || giveawayProd.XC_Quantity__c != oldGiveawayProd.XC_Quantity__c)
            {
                prodsToUpdateCost.add(giveawayProd);
            }
        }

        if(!prodsToUpdateCost.isEmpty())
        {
            populateCost(prodsToUpdateCost);
        }
    }
}