trigger XC_ProductTrigger on Product2 (after insert, after update) 
{
    if(Trigger.operationType == System.TriggerOperation.AFTER_UPDATE)
    {
        XC_ProductTriggerHandler.updateGiveawayProductsOnCostChange(Trigger.new, Trigger.oldMap);
    }
}