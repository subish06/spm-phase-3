public without sharing class XC_LoanTriggerHandler 
{
    public static void checkForSubmitForApproval(List<XC_AssetLoan__c> triggerNew, Map<Id, XC_AssetLoan__c> triggerOldMap)
    {
        for(XC_AssetLoan__c loan : triggerNew)
        {
            if(loan.XC_Status__c == 'Pending Approval' && triggerOldMap.get(loan.Id).XC_Status__c != 'Pending Approval')
            {
                loan.XC_SubmittedForApprovalBy__c = UserInfo.getUserId();
            }
        }
    }

    public static void checkForReturnedStatus(List<XC_AssetLoan__c> triggerNew, Map<Id, XC_AssetLoan__c> triggerOldMap)
    {
        Map<Id, XC_AssetLoan__c> updatedMap = new Map<Id, XC_AssetLoan__c>();

        for(XC_AssetLoan__c loan : triggerNew)
        {
            if(loan.XC_Status__c == 'Returned' && triggerOldMap.get(loan.Id).XC_Status__c != 'Returned')
            {
                updatedMap.put(loan.Id, loan);
            }
        }

        List<XC_GearWall__c> gearWallList = [SELECT Id, XC_AssetLoan__c, XC_Status__c FROM XC_GearWall__c WHERE XC_AssetLoan__c IN :updatedMap.keySet()];

        for(XC_GearWall__c gearWall : gearWallList)
        {
            gearWall.XC_Status__c = updatedMap.get(gearWall.XC_AssetLoan__c).XC_Status__c;
        }

        if(!gearWallList.isEmpty())
        {
            update gearWallList;
        }
    }
}