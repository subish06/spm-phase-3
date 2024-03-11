@isTest
public without sharing class XC_LoanTriggerTest 
{
    @isTest
    public static void testPopulateSubmitForApproval()
    {
        Test.startTest();

        Contact con = new Contact();
        con.LastName = 'test Contact';

        insert con;

        Product2 prod = new Product2();
        prod.Name = 'test Product';
        prod.XC_Cost__c = 5.00;

        insert prod;

        XC_AssetLoan__c loan = new XC_AssetLoan__c();
        loan.XC_Status__c = 'New';
        loan.XC_SKU__c = prod.Id;
        loan.XC_Contact__c = con.Id;

        insert loan;

        loan.XC_Status__c = 'Pending Approval';
        

        update loan;

        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), [SELECT XC_SubmittedForApprovalBy__c FROM XC_AssetLoan__c WHERE Id = :loan.Id LIMIT 1].XC_SubmittedForApprovalBy__c);
    }

    @isTest
    public static void testNoPopulateSubmitForApproval()
    {
        Test.startTest();

        Contact con = new Contact();
        con.LastName = 'test Contact';

        insert con;

        Product2 prod = new Product2();
        prod.Name = 'test Product';
        prod.XC_Cost__c = 5.00;

        insert prod;

        XC_AssetLoan__c loan = new XC_AssetLoan__c();
        loan.XC_Status__c = 'New';
        loan.XC_SKU__c = prod.Id;
        loan.XC_Contact__c = con.Id;

        insert loan;

        loan.XC_Status__c = 'New';
        

        update loan;

        Test.stopTest();

        System.assertEquals(null, [SELECT XC_SubmittedForApprovalBy__c FROM XC_AssetLoan__c WHERE Id = :loan.Id LIMIT 1].XC_SubmittedForApprovalBy__c);
    }

    @isTest
    public static void testReturnedStatus()
    {
        Test.startTest();

        Contact con = new Contact();
        con.LastName = 'test Contact';

        insert con;

        Product2 prod = new Product2();
        prod.Name = 'test Product';
        prod.XC_Cost__c = 5.00;

        insert prod;

        XC_AssetLoan__c loan = new XC_AssetLoan__c();
        loan.XC_Status__c = 'New';
        loan.XC_SKU__c = prod.Id;
        loan.XC_Contact__c = con.Id;

        insert loan;

        XC_GearWall__c gearWall = new XC_GearWall__c();
        gearWall.XC_AssetLoan__c = loan.Id;
        gearWall.XC_Status__c = 'Current';
        gearWall.XC_Contact__c = con.Id;
        gearWall.XC_Type__c = 'Loaned';
        gearWall.XC_Brand__c = 'Gibson';
        gearWall.XC_Quantity__c = 1;

        insert gearWall;

        loan.XC_Status__c = 'Returned';
        
        update loan;

        Test.stopTest();

        System.assertEquals(loan.XC_Status__c, [SELECT XC_Status__c FROM XC_GearWall__c WHERE Id = :gearWall.Id LIMIT 1].XC_Status__c);
    }
}