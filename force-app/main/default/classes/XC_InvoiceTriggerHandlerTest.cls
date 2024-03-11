@isTest
private class XC_InvoiceTriggerHandlerTest {
	
    @isTest
    private static void populateRelationshipFieldsTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        
        Test.startTest();
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_InvoiceNumber__c = '12345x';
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        insert inv;
        Test.stopTest();
        
        XC_Invoice__c invoice = [SELECT Id, XC_Account__c, XC_CustomerId__c FROM XC_Invoice__c WHERE XC_CustomerId__c = '12345' LIMIT 1];
        System.assertEquals(invoice.XC_Account__c, acc.Id);
    }
}