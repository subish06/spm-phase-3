trigger XC_TargetTrigger on XC_Target__c (after insert, after update, after delete, after undelete) 
{
    if(Trigger.operationType == System.TriggerOperation.AFTER_INSERT)
    {
        XC_TargetTriggerHandler.updateTargetFieldsInsert(Trigger.new);
    }
    else if(Trigger.operationType == System.TriggerOperation.AFTER_UPDATE)
    {
        XC_TargetTriggerHandler.updateTargetFieldsUpdate(Trigger.new, Trigger.oldMap);
    }
    else if(Trigger.operationType == System.TriggerOperation.AFTER_DELETE)
    {
        XC_TargetTriggerHandler.updateTargetFieldsDelete(Trigger.old);
    }
    else if(Trigger.operationType == System.TriggerOperation.AFTER_UNDELETE)
    {
        XC_TargetTriggerHandler.updateTargetFieldsInsert(Trigger.new);
    }
}