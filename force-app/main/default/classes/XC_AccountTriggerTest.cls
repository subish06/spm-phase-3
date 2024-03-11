@isTest
public without sharing class XC_AccountTriggerTest 
{
    @isTest
    public static void testCreatedFromLead()
    {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test account';
        acc.XC_WasCreatedFromLead__c = true;
        acc.XC_CustomAccountType__c = 'Brick & Mortar';
        
        insert acc;

        acc = [SELECT Id, XC_ReauthorizationDate__c, Type, XC_CustomAccountType__c FROM Account WHERE Id = :acc.Id LIMIT 1];

        System.assert(acc.XC_ReauthorizationDate__c != null);
        System.assertEquals(acc.XC_CustomAccountType__c, acc.Type);

        Test.stopTest();

    }

    @isTest
    public static void testNotCreatedFromLead()
    {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test account';
        acc.XC_WasCreatedFromLead__c = false;
        acc.XC_CustomAccountType__c = 'Brick & Mortar';
        
        insert acc;

        acc = [SELECT Id, XC_ReauthorizationDate__c, Type, XC_CustomAccountType__c FROM Account WHERE Id = :acc.Id LIMIT 1];

        System.assertEquals(null, acc.XC_ReauthorizationDate__c);
        System.assert(acc.XC_CustomAccountType__c != acc.Type);

        Test.stopTest();

    }
    
    @isTest
    private static void updateParentAccountTest(){
        Account parentAccount = new Account();
        parentAccount.Name = 'Test Parent Account';
        parentAccount.XC_CustomerId__c = '12345';
        parentAccount.XC_InvoiceAccountId__c = '12345';
        insert parentAccount;
        
        Test.startTest();
        
        Account childAccount = new Account();
        childAccount.Name = 'Test Child Account';
        childAccount.XC_CustomerId__c = '67890';
        childAccount.XC_InvoiceAccountId__c = '12345';
        insert childAccount;
        
        Test.stopTest();
		
        Account acc = [SELECT Id, ParentId, XC_CustomerId__c FROM Account WHERE XC_CustomerId__c = '67890' LIMIT 1];
        System.assert(acc.ParentId != null);
    }
}