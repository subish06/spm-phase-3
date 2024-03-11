@isTest
public without sharing class XC_GiveawayTriggerHandlerTest 
{
    @isTest
    public static void testPopulateSubmitForApproval()
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

        insert giveaway;

        giveaway.XC_Status__c = 'Pending Approval';

        update giveaway;

        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), [SELECT XC_SubmittedForApprovalBy__c FROM XC_Giveaway__c WHERE Id = :giveaway.Id LIMIT 1].XC_SubmittedForApprovalBy__c);
    }

    @isTest
    public static void testNoPopulateSubmitForApproval()
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

        insert giveaway;

        giveaway.XC_Status__c = 'Shipped';

        update giveaway;

        Test.stopTest();

        System.assertEquals(null, [SELECT XC_SubmittedForApprovalBy__c FROM XC_Giveaway__c WHERE Id = :giveaway.Id LIMIT 1].XC_SubmittedForApprovalBy__c);
    }
}