@isTest
private class XC_InvoiceLineItemTriggerHandlerTest {
  @isTest
    private static void getInvoiceTriggerTest(){
        Profile p1= [Select Id from Profile where Name='System Administrator'];
        
        user u =new User();
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Firstname='Bruce';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
        
        List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();
        System.runAs(u){
        Account acc = new Account();
        acc.Name = 'Test Account';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        
        
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='123';
        insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product2';
        pt.StockKeepingUnit = '1111';
        insert pt;

        Order ord = new Order();
      ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = System.today();
      insert ord;
            
      
                    
        Test.startTest();
        XC_InvoiceLineItem__c inl = new XC_InvoiceLineItem__c();
        inl.XC_Invoice__c = inv.Id;
        inl.XC_ItemNumber__c = '1111';
        insert inl;
        Test.stopTest();
        System.assert(inl!=null);
        }
    }
    
    

}