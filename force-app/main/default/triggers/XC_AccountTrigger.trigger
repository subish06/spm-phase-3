trigger XC_AccountTrigger on Account (before insert,before update) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT)
    {
        XC_AccountTriggerHandler.checkAccountCreatedFromLead(Trigger.new);
    }
    
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT || Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
    {
        XC_AccountTriggerHandler.updateParentAccount(Trigger.new);
    }
}