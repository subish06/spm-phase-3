@isTest
public without sharing class XC_TargetTriggerTest 
{
    @isTest
    public static void testInsert()
    {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test Account';

        insert acc;

        XC_Target__c target = new XC_Target__c();
        target.XC_Month__c = Date.today();
        target.XC_Account__c = acc.Id;
        target.XC_RevenueTarget__c = 5;
        target.XC_RevenueActuals__c = 5;

        insert target;

        Test.stopTest();

        System.assertEquals(0, [SELECT XC_RevenuePercentVsTargetMTD__c FROM Account WHERE Id = :acc.Id LIMIT 1].XC_RevenuePercentVsTargetMTD__c);
    }

    @isTest
    public static void testUpdate()
    {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test Account';

        insert acc;

        XC_Target__c target = new XC_Target__c();
        target.XC_Month__c = Date.today();
        target.XC_Account__c = acc.Id;
        target.XC_RevenueTarget__c = 5;
        target.XC_RevenueActuals__c = 2;

        insert target;

        System.assert(0 != [SELECT XC_RevenuePercentVsTargetMTD__c FROM Account WHERE Id = :acc.Id LIMIT 1].XC_RevenuePercentVsTargetMTD__c);

        target.XC_RevenueActuals__c = 5;

        update target;

        Test.stopTest();

        System.assertEquals(0, [SELECT XC_RevenuePercentVsTargetMTD__c FROM Account WHERE Id = :acc.Id LIMIT 1].XC_RevenuePercentVsTargetMTD__c);
    }

    @isTest
    public static void testDelete()
    {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test Account';

        insert acc;

        XC_Target__c target = new XC_Target__c();
        target.XC_Month__c = Date.today();
        target.XC_Account__c = acc.Id;
        target.XC_RevenueTarget__c = 5;
        target.XC_RevenueActuals__c = 5;

        insert target;

        XC_Target__c target2 = new XC_Target__c();
        target2.XC_Month__c = Date.today();
        target2.XC_Account__c = acc.Id;
        target2.XC_RevenueTarget__c = 5;
        target2.XC_RevenueActuals__c = 0;

        insert target2;

        System.assert(0 != [SELECT XC_RevenuePercentVsTargetMTD__c FROM Account WHERE Id = :acc.Id LIMIT 1].XC_RevenuePercentVsTargetMTD__c);

        delete target2;

        Test.stopTest();

        System.assertEquals(0, [SELECT XC_RevenuePercentVsTargetMTD__c FROM Account WHERE Id = :acc.Id LIMIT 1].XC_RevenuePercentVsTargetMTD__c);
    }
}