trigger XC_TaskTrigger on Task (before insert, before update) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
    {
        XC_TaskTriggerHandler.updateAccountRecordTypeName(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT)
    {
        XC_TaskTriggerHandler.updateAccountRecordTypeName(Trigger.new);
    }
}