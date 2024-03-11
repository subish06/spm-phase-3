public without sharing class XC_ARAgingController {
    
    @AuraEnabled
    public static List<XC_Invoice__c> getInvoiceList(){
        try{
            Contact cont = [SELECT AccountId,Id from Contact WHERE Id IN (SELECT ContactId  from User where Id=:UserInfo.getUserId())];
            Id accountId = cont.AccountId;
            List<XC_Invoice__c> invoices =  [SELECT Id, XC_DueDate__c,  XC_InvoiceDate__c,            
            XC_Total__c FROM XC_Invoice__c  WHERE XC_Account__c = :accountId];

            return invoices;
        }
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<XC_Invoice__c> getInvoiceListByIds(List<String> invoiceIds){
        try{
            List<XC_Invoice__c> invoices =  [SELECT Id, XC_InvoiceNumber__c, XC_DueDate__c,  XC_InvoiceDate__c,            
            XC_Total__c FROM XC_Invoice__c  WHERE Id IN:invoiceIds ORDER BY XC_DueDate__c ASC];

            return invoices;
        }
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}