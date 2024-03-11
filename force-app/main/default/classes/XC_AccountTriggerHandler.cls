public without sharing class XC_AccountTriggerHandler 
{
    private XC_AccountTriggerHandler() {}
    
    public static void checkAccountCreatedFromLead(List<Account> triggerNew)
    {
        for(Account acc : triggerNew)
        {
            if(acc.XC_WasCreatedFromLead__c)
            {
                acc.XC_ReauthorizationDate__c = Date.today().addYears(1);
                acc.Type = Acc.XC_CustomAccountType__c;
            }
        }
    }
    
    public static void updateParentAccount(List<Account> triggerNew)
    {
        Set<String> invAccIds = new Set <String>();
        Map<String, Account> custIdAccMap = new Map <String, Account>();
        
        // Prepare list
        for(Account acc : triggerNew)
        {
            if(acc.XC_InvoiceAccountId__c != null && acc.XC_CustomerId__c != acc.XC_InvoiceAccountId__c)
            {
                invAccIds.add(acc.XC_InvoiceAccountId__c);
            }
        }
        
        if(invAccIds.size() > 0)
        {
            // Get parent accounts
            List<Account> parentAccounts= [SELECT id, XC_CustomerId__c, XC_InvoiceAccountId__c FROM Account WHERE XC_CustomerId__c = :invAccIds
                                                                                                AND XC_InvoiceAccountId__c = :invAccIds];
            
            for (Account parent : parentAccounts)
            {
                if(parent.XC_CustomerId__c != null)
                {
                    custIdAccMap.put(parent.XC_CustomerId__c, parent);
                }
            }
            
            // Update parent account id
            for (Account acc : triggerNew)
            {
                if(custIdAccMap.containsKey (acc.XC_InvoiceAccountId__c) && acc.XC_CustomerId__c != acc.XC_InvoiceAccountId__c)
                {
                    acc.ParentId = custIdAccMap.get(acc.XC_InvoiceAccountId__c).id;
                }
            }
        }
        
    }
    
}