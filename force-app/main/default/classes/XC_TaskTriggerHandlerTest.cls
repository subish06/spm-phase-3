@isTest
private class XC_TaskTriggerHandlerTest {
	
    @isTest
    private static void createTask(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Gibson';
		con.LastName = 'Brands';
        con.Email = 'test@test.com';
        insert con;

        Test.startTest();
        Task t = new Task();
        t.Subject = 'Test Task';
        t.WhatId = acc.Id;
        t.WhoId = con.Id;
        t.ActivityDate = Date.today();
        insert t;
        Test.stopTest();
        
        Task task = [SELECT Id, WhatId, XC_RecordTypeName__c FROM Task WHERE WhatId=:acc.Id LIMIT 1];
        System.assertEquals(task.XC_RecordTypeName__c, 'Dealer');
    }
    
    @isTest
    private static void editTask(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Gibson';
		con.LastName = 'Brands';
        con.Email = 'test@test.com';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();
        opp.StageName = 'New/Forecast';
        insert opp;
        
        Test.startTest();
        Task t = new Task();
        t.Subject = 'Test Task';
        t.WhatId = acc.Id;
        t.WhoId = con.Id;
        t.ActivityDate = Date.today();
        insert t;
        
        t.WhatId = opp.Id;
        update t;
        Test.stopTest();
        
        Task task = [SELECT Id, WhatId, Subject FROM Task WHERE WhatId=:opp.Id LIMIT 1];
        System.assert(task!=null);
    }
}