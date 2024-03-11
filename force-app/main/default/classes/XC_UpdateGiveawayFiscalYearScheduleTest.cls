@isTest
public without sharing class XC_UpdateGiveawayFiscalYearScheduleTest
{
    @isTest
    public static void testUpdateFiscalYear()
    {
        Test.startTest();

        Contact con = new Contact();
        con.LastName = 'test Contact';

        insert con;

        XC_Giveaway__c giveaway = new XC_Giveaway__c();
        //giveaway.Name = 'test Giveaway';
        giveaway.XC_Contact__c = con.Id;
        giveaway.XC_Status__c = 'New';
        giveaway.XC_Description__c = 'test';
        giveaway.XC_NonFormulaForCurrentFiscalYear__c = false;

        insert giveaway;

        Database.executeBatch(new XC_UpdateGiveawayFiscalYearSchedulable());

        Test.stopTest();

        giveaway = [SELECT XC_ForCurrentFiscalYear__c, XC_NonFormulaForCurrentFiscalYear__c FROM XC_Giveaway__c WHERE Id = :giveaway.Id LIMIT 1];

        System.assertEquals(giveaway.XC_ForCurrentFiscalYear__c, giveaway.XC_NonFormulaForCurrentFiscalYear__c);
    }

    @isTest
    public static void testScheduled()
    {
        Test.startTest();

        String jobId = System.schedule('Update Giveaways for new Fiscal YearTEST', '0 1 0 1 4 ?', new XC_UpdateGiveawayFiscalYearSchedulable());

        Integer cronCount = [SELECT Count() FROM CronTrigger WHERE id = :jobId];

        System.assert(cronCount > 0);

        Test.stopTest();


    }
}