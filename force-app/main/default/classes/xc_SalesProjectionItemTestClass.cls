@isTest
public with sharing class xc_SalesProjectionItemTestClass {
    @TestSetup
    static void createTestData(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        Profile p1= [Select Id from Profile where Name LIKE 'System Administrator'];
        Contact c = new Contact();
        c.FirstName = 'Contact1';
        c.LastName ='Last';
        c.AccountId = acc.Id;
        insert c;
        
        User u = new User();
        u.FirstName = 'User1';
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
        
        
        System.runAs(u){
            XC_SalesProjection__c sp = new XC_SalesProjection__c();
            sp.Status__c = 'Draft';
            sp.XC_Account__c = acc.Id;
            sp.BusinessUnit__c = 'USA';
            sp.XC_Fiscal_Year__c = 2023;
            sp.XC_Fiscal_Period__c = 1;
            insert sp;

            XC_SalesProjectionItem__c spi = new XC_SalesProjectionItem__c();
            spi.PlannedQuantity__c = 200;
            spi.PlannedSales__c = 1000.00;
            spi.Sales_Projection__c = sp.Id;
            insert spi;
            
            XC_SalesProjectionItem__c spi1 = new XC_SalesProjectionItem__c();
            spi1.PlannedQuantity__c = 100;
            spi1.PlannedSales__c = 2000.00;
            spi1.Sales_Projection__c = sp.Id;
            insert spi1;
        }
    }

    @isTest
    public static void batchApexPass(){
        User u = [SELECT Id, FirstName from User where FirstName='User1'];
        System.runAs(u){
            Test.startTest();
            Id jobId = xc_SalesProjectionItemExport.callSPBatch('12345','USA', 2023);
            System.assert(jobId != null);
            Test.stopTest();
        }
    }   

    //*** Commented below code which supports the Import and Export of SPI Data on the UI
    //  ********************** */
    // @isTest
    // public static void exportPass(){
    //     User u = [SELECT Id, FirstName from User where FirstName='User1'];
    //     System.runAs(u){
    //         Test.startTest();
    //         XC_SalesProjection__c sp = [SELECT Id from XC_SalesProjection__c];
    //         List<XC_SalesProjectionItem__c> spi = xc_SalesProjectionItemExport.getSalesProjectionItemExport(sp.Id);
    //         System.assert(spi.size()>0);
    //         Test.stopTest();
    //     }
    // }

    // @isTest
    // public static void importFail(){
    //     User u = [SELECT Id, FirstName from User where FirstName='User1'];
    //     System.runAs(u){
    //         Test.startTest();
    //         XC_SalesProjection__c sp = [SELECT Id from XC_SalesProjection__c];
    //         list<XC_SalesProjectionItem__c> spi1 = [SELECT Id from XC_SalesProjectionItem__c];
    //         String spi = xc_SalesProjectionItemExport.importSalesProjectionItems(spi1, sp.Id);
    //         System.assert(spi == 'Failure');
    //         Test.stopTest();
    //     }
    // }
    
    // @isTest
    // public static void importPass(){
    //     User u = [SELECT Id, FirstName from User where FirstName='User1'];
    //     System.runAs(u){
    //         Test.startTest();
    //         XC_SalesProjection__c sp = [SELECT Id from XC_SalesProjection__c];
    //         list<XC_SalesProjectionItem__c> spi1 = [SELECT Id, PlannedQuantity__c,PlannedSales__c  from XC_SalesProjectionItem__c];
    //         String spi = xc_SalesProjectionItemExport.importSalesProjectionItems(spi1, sp.Id);
    //         System.assert(spi == 'Success');
    //         Test.stopTest();
    //     }
    // }
    
    
    // @isTest
    // public static void export12Pass(){
    //     User u = [SELECT Id, FirstName from User where FirstName='User1'];
    //     System.runAs(u){
    //         Test.startTest();
    //      //   XC_SalesProjection__c sp = [SELECT Id from XC_SalesProjection__c];
    //         List<XC_SalesProjectionExportWrapper> spi = xc_SalesProjectionItemExport.getSalesProjectionItemExcelExport('12345','USA',2023);
    //         System.assert(spi.size()>0);
    //         Test.stopTest();
    //     }
    // } 
}