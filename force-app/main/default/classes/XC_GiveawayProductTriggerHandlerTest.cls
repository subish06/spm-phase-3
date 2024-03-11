@isTest
public without sharing class XC_GiveawayProductTriggerHandlerTest 
{
    @isTest
    public static void testpopulateCost_Insert()
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

        Product2 prod = new Product2();
        prod.Name = 'test Product';
        prod.XC_Cost__c = 5.00;

        insert prod;

        XC_GiveawayProduct__c giveawayProd = new XC_GiveawayProduct__c();
        giveawayProd.XC_Product__c = prod.Id;
        giveawayProd.XC_Giveaway__c = giveaway.Id;
        giveawayProd.XC_Quantity__c = 2;

        insert giveawayProd;

        Test.stopTest();

        System.assertEquals(10, [SELECT NonFormulaCost__c FROM XC_GiveawayProduct__c WHERE Id = :giveawayProd.Id LIMIT 1].NonFormulaCost__c);
    }

    @isTest
    public static void testpopulateCost_Update()
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

        Product2 prod = new Product2();
        prod.Name = 'test Product';
        prod.XC_Cost__c = 5.00;

        insert prod;

        XC_GiveawayProduct__c giveawayProd = new XC_GiveawayProduct__c();
        giveawayProd.XC_Product__c = prod.Id;
        giveawayProd.XC_Giveaway__c = giveaway.Id;
        giveawayProd.XC_Quantity__c = 2;

        insert giveawayProd;

        giveawayProd.XC_Quantity__c = 3;

        update giveawayProd;

        Test.stopTest();

        System.assertEquals(15, [SELECT NonFormulaCost__c FROM XC_GiveawayProduct__c WHERE Id = :giveawayProd.Id LIMIT 1].NonFormulaCost__c);
    }
}