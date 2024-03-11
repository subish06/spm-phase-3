@isTest
public without sharing class XC_CaseTriggerTest 
{
    @testSetup
    public static void setup()
    {
        Test.startTest();

        Id dealerRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :XC_CaseTriggerHandler.DEALER_RECORD_TYPE_DEV_NAME LIMIT 1].Id;

        List<Account> accList = new List<Account>();

        Account acc = new Account();
        acc.RecordTypeId = dealerRecTypeId;
        acc.Name = XC_CaseTriggerHandler.KEY_ACCOUNTS_QUEUE_NAME;
        acc.XC_SegmentClassification__c = 'Key Account';

        accList.add(acc);

        acc = new Account();
        acc.RecordTypeId = dealerRecTypeId;
        acc.Name = XC_CaseTriggerHandler.DISTRIBUTOR_QUEUE_NAME;
        acc.XC_SegmentClassification__c = 'Distributor';

        accList.add(acc);

        acc = new Account();
        acc.RecordTypeId = dealerRecTypeId;
        acc.Name = XC_CaseTriggerHandler.LATAM_QUEUE_NAME;
        acc.XC_Region__c = 'LATAM';

        accList.add(acc);

        acc = new Account();
        acc.RecordTypeId = dealerRecTypeId;
        acc.Name = XC_CaseTriggerHandler.CONSUMER_ACCOUNT_NAME;

        accList.add(acc);

        acc = new Account();
        acc.RecordTypeId = dealerRecTypeId;
        acc.Name = XC_CaseTriggerHandler.INDIE_QUEUE_NAME;

        accList.add(acc);

        insert accList;

        List<Contact> conList = new List<Contact>();

        for(Account curAcc : accList)
        {
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.AccountId = acc.Id;

            conList.add(con);
        }

        insert conList;

        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :XC_CaseTriggerHandler.DEFAULT_QUEUE_NAME LIMIT 1].Id;

        List<Case> caseList = new List<Case>();

        for(Contact con : conList)
        {
            Case curCase = new Case();
            curCase.OwnerId = queueId;
            curCase.ContactId = con.Id;

            caseList.add(curCase);
        }

        insert caseList;

        Test.stopTest();

        List<AggregateResult> results = [SELECT Count(OwnerId) FROM Case];

        System.assertEquals(0, [SELECT Count() FROM Case WHERE OwnerId = :queueId]);
        System.assertEquals(5, results[0].get('expr0'));
    }

    @isTest
    public static void testQueueAssignment()
    {
        List<Group> caseQueues = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :XC_CaseTriggerHandler.CASE_QUEUE_NAMES];

        System.debug(caseQueues);


    }
}