public without sharing class XC_CaseTriggerHandler 
{
    //keep the default queue as index 0
    @TestVisible
    private static final List<String> CASE_QUEUE_NAMES = new List<String>{'XC_CaseDefaultQueue', 'XC_KeyAccounts', 'XC_Distributors', 'XC_LATAM', 'XC_ConsumerService', 'XC_Indie'};

    @TestVisible
    private static final String DEFAULT_QUEUE_NAME = 'XC_CaseDefaultQueue';
    @TestVisible
    private static final String KEY_ACCOUNTS_QUEUE_NAME = 'XC_KeyAccounts';
    @TestVisible
    private static final String DISTRIBUTOR_QUEUE_NAME = 'XC_Distributors';
    @TestVisible
    private static final String LATAM_QUEUE_NAME = 'XC_LATAM';
    @TestVisible
    private static final String CONSUMER_SERVICE_QUEUE_NAME = 'XC_ConsumerService';
    @TestVisible
    private static final String INDIE_QUEUE_NAME = 'XC_Indie';

    @TestVisible
    private static final String CONSUMER_ACCOUNT_NAME = System.Label.XC_ConsumerAccountName;
    @TestVisible
    private static final String DEALER_RECORD_TYPE_DEV_NAME = 'Dealer';

    public static void checkQueueOwnership(List<Case> triggerNew)
    {
        List<Case> casesToReassign = new List<Case>();
        Set<Id> contactIds = new Set<Id>();
        List<Group> caseQueues = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :CASE_QUEUE_NAMES];
        Group defaultQueue;

        for(Group grp : caseQueues)
        {
            if(grp.DeveloperName == DEFAULT_QUEUE_NAME)
            {
                defaultQueue = grp;
                break;
            }
        }

        for(Case curCase : triggerNew)
        {
            if(curCase.OwnerId == defaultQueue.Id)
            {
                casesToReassign.add(curCase);

                if(curCase.ContactId != null)
                {
                    contactIds.add(curCase.ContactId);
                }
            }
        }

        if(!casesToReassign.isEmpty())
        {
            reassignQueueOwnership(casesToReassign, caseQueues, contactIds);
        }
    }

    private static void reassignQueueOwnership(List<Case> casesToReassign, List<Group> caseQueues, Set<Id> contactIds)
    {//result?.Account?.Name
        Map<Id, Contact> ContactMap = new Map<Id, Contact>([SELECT Id, AccountId, Account.Name, Account.Owner.Username,  Account.XC_SegmentClassification__c, Account.XC_Region__c, Account.RecordType.DeveloperName FROM Contact WHERE Id IN :contactIds]);

        // List<Case> keyAccountCases = new List<Case>();
        // List<Case> LATAMCases = new List<Case>();
        // List<Case> DistributorCases = new List<Case>();
        // List<Case> CustomerServiceCases = new List<Case>();
        // List<Case> IndieCases = new List<Case>();

        Map<String, Group> groupNameToGroupMap = new Map<String, Group>();

        for(Group grp : caseQueues)
        {
            groupNameToGroupMap.put(grp.DeveloperName, grp);
        }

        for(Case curCase : casesToReassign)
        {
            if(curCase.ContactId != null && ContactMap.containsKey(curCase.ContactId))
            {
                Contact curContact = ContactMap.get(curCase.ContactId);
                if(curContact?.Account?.RecordType?.DeveloperName == DEALER_RECORD_TYPE_DEV_NAME)
                {
                    if(curContact?.Account?.XC_SegmentClassification__c == 'KA')
                    {
                        curCase.OwnerId = groupNameToGroupMap.get(KEY_ACCOUNTS_QUEUE_NAME).Id;
                    }
                    else if(curContact?.Account?.Owner?.Username == Label.XC_LATAMAccountOwnerUsername)
                    {
                        curCase.OwnerId = groupNameToGroupMap.get(LATAM_QUEUE_NAME).Id;
                    }
                    else if(curContact?.Account?.XC_SegmentClassification__c == 'Distributor')
                    {
                        curCase.OwnerId = groupNameToGroupMap.get(DISTRIBUTOR_QUEUE_NAME).Id;
                    }
                    else 
                    {
                        curCase.OwnerId = groupNameToGroupMap.get(INDIE_QUEUE_NAME).Id;
                    }
                }
                else if(curContact?.Account?.Name == CONSUMER_ACCOUNT_NAME)
                {
                    curCase.OwnerId = groupNameToGroupMap.get(CONSUMER_SERVICE_QUEUE_NAME).Id;
                }
                else 
                {
                    curCase.OwnerId = groupNameToGroupMap.get(INDIE_QUEUE_NAME).Id;
                }
            }
            else 
            {
                //TODO
                    //check for consumer contact queue or indie queue
                curCase.OwnerId = groupNameToGroupMap.get(INDIE_QUEUE_NAME).Id;
            }
        }
    }
}