trigger XC_GiveawayProductTrigger on XC_GiveawayProduct__c (before insert, before update) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT)
    {
        XC_GiveawayProductTriggerHandler.populateCost(Trigger.new);
    }
    else if(Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
    {
        XC_GiveawayProductTriggerHandler.checkForPopulateCost(Trigger.new, Trigger.oldMap);
    }
}