trigger XC_GiveawayTrigger on XC_Giveaway__c (before update) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
    {
        XC_GiveawayTriggerHandler.checkForSubmitForApproval(Trigger.new, Trigger.oldMap);
    }
}