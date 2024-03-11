trigger XC_InvoiceLineItemTrigger on XC_InvoiceLineItem__c (before insert) {
    
    if(Trigger.operationType == System.TriggerOperation.BEFORE_INSERT)
    {
        XC_InvoiceLineItemTriggerHandler.populateProductRelationship(Trigger.new);
    }
}