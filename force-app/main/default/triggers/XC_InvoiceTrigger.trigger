trigger XC_InvoiceTrigger on XC_Invoice__c (before insert) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT)
    {
        XC_InvoiceTriggerHandler.populateRelationshipFields(Trigger.new);
    }
}