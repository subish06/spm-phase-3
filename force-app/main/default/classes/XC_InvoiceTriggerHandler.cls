public without sharing class XC_InvoiceTriggerHandler 
{
    public static void populateRelationshipFields(List<XC_Invoice__c> triggerNew)
    {
        Set<String> externalAccountIds = new Set<String>();

        for(XC_Invoice__c invoice : triggerNew)
        {
            if(invoice.XC_CustomerId__c != null && invoice.XC_CustomerId__c != '')
            {
                externalAccountIds.add(invoice.XC_CustomerId__c);
            }
            else 
            {
                invoice.addError('Customer Id is missing');
            }
        }

        Map<String, Id> accMap = new Map<String, Id>();

        for(Account acc : [SELECT Id, XC_CustomerId__c FROM Account WHERE XC_CustomerId__c IN :externalAccountIds])
        {
            accMap.put(acc.XC_CustomerId__c, acc.Id);
        }

        for(XC_Invoice__c invoice : triggerNew)
        {
            if(accMap.containsKey(invoice.XC_CustomerId__c))
            {
                invoice.XC_Account__c = accMap.get(invoice.XC_CustomerId__c);
            }
            else 
            {
                invoice.addError('No matching account found for Customer Id');
            }
        }
    }
}