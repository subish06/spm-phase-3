public without sharing class XC_GiveawayTriggerHandler 
{
    public static void checkForSubmitForApproval(List<XC_Giveaway__c> triggerNew, Map<Id, XC_Giveaway__c> triggerOldMap)
    {
        for(XC_Giveaway__c giveaway : triggerNew)
        {
            if(giveaway.XC_Status__c == 'Pending Approval' && triggerOldMap.get(giveaway.Id).XC_Status__c != 'Pending Approval')
            {
                giveaway.XC_SubmittedForApprovalBy__c = UserInfo.getUserId();
            }
        }
    }
}