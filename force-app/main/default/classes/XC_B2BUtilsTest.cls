@isTest(SeeAllData = true)
public without sharing class XC_B2BUtilsTest 
{
    @isTest
    public static void resolveCommunityIdToWebstoreId()
    {
        Test.startTest();

        String commName = 'All Axcess';

        Id commId = [SELECT Id, Name FROM Network WHERE Name = :commName LIMIT 1].Id;

        String webStoreId = XC_B2BUtils.resolveCommunityIdToWebstoreId(commId);

        System.assertEquals([SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :commId LIMIT 1].WebStoreId, webStoreId);

        Test.stopTest();
    }

    @isTest
    public static void getUserAccountID()
    {
        Test.startTest();

        System.assertEquals([SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId, XC_B2BUtils.getUserAccountID());

        Test.stopTest();
    }
}