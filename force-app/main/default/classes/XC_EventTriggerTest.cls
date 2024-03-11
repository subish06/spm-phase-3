@isTest
public without sharing class XC_EventTriggerTest 
{
    @isTest
    public static void testPopulateRecordTypeName_Insert()
    {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test account';

        insert acc;

        Event evt = new Event();
        evt.WhatId = acc.Id;
        evt.StartDateTime = Datetime.now();
        evt.EndDateTime = Datetime.now().addHours(1);

        insert evt;

        Test.stopTest();

        System.assertEquals([SELECT RecordType.Name FROM Account WHERE Id = :acc.Id LIMIT 1].RecordType.Name, [SELECT XC_RecordTypeName__c FROM Event WHERE Id = :evt.Id].XC_RecordTypeName__c);
    }

    @isTest
    public static void testPopulateRecordTypeName_Update()
    {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dealer' LIMIT 1].Id;

        insert acc;

        Event evt = new Event();
        evt.WhatId = acc.Id;
        evt.StartDateTime = Datetime.now();
        evt.EndDateTime = Datetime.now().addHours(1);

        insert evt;

        acc = new Account();
        acc.Name = 'test account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EntertainmentRelations' LIMIT 1].Id;

        insert acc;

        evt.WhatId = acc.Id;

        update evt;

        Test.stopTest();

        System.assertEquals([SELECT RecordType.Name FROM Account WHERE Id = :acc.Id LIMIT 1].RecordType.Name, [SELECT XC_RecordTypeName__c FROM Event WHERE Id = :evt.Id].XC_RecordTypeName__c);
    }
}