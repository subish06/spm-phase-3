@isTest
public without sharing class XC_UpdateAccountTargetValuesScheduleTest 
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

        acc = [SELECT Id, XC_TargetThisMonth__c, XC_TargetThisQuarter__c, XC_TargetThisYear__c, XC_RevenueThisMonth__c, XC_RevenueThisQuarter__c, XC_RevenueThisYear__c FROM Account WHERE Id = :acc.Id LIMIT 1];

        XC_TargetUtilities.blankTargetDataForRefresh(acc);

        update acc;

        System.assertEquals(0, acc.XC_TargetThisMonth__c);
        System.assertEquals(0, acc.XC_RevenueThisMonth__c);

        XC_UpdateAccountTargetValuesSchedulable.testFullRefresh = true;

        Database.executeBatch(new XC_UpdateAccountTargetValuesSchedulable(), 50);

        Test.stopTest();

        acc = [SELECT Id, XC_TargetThisMonth__c, XC_TargetThisQuarter__c, XC_TargetThisYear__c, XC_RevenueThisMonth__c, XC_RevenueThisQuarter__c, XC_RevenueThisYear__c FROM Account WHERE Id = :acc.Id LIMIT 1];

        System.assert(0 != acc.XC_TargetThisMonth__c);
        System.assert(0 != acc.XC_RevenueThisMonth__c);
    }
}