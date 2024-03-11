trigger XC_CaseTrigger on Case (before insert) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT)
    {
        XC_CaseTriggerHandler.checkQueueOwnership(Trigger.new);
    }
}