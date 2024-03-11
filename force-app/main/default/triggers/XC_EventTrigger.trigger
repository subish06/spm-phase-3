trigger XC_EventTrigger on Event (before insert, before update) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
    {
        XC_EventTriggerHandler.updateAccountRecordTypeName(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT)
    {
        XC_EventTriggerHandler.updateAccountRecordTypeName(Trigger.new);
    }
}