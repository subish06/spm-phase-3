trigger XC_LoanTrigger on XC_AssetLoan__c (before update, after update) 
{
    if(Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
    {
        XC_LoanTriggerHandler.checkForSubmitForApproval(Trigger.new, Trigger.oldMap);
    }
    else if(Trigger.operationType == System.TriggerOperation.AFTER_UPDATE)
    {
        XC_LoanTriggerHandler.checkForReturnedStatus(Trigger.new, Trigger.oldMap);
    }
}