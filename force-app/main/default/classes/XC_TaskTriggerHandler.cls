public without sharing class XC_TaskTriggerHandler
{
    public static void updateAccountRecordTypeName(List<Task> triggerNew)
    {
        List<Task> accountTaskList = new List<Task>();
        Set<Id> accIds = new Set<Id>();

        for(Task curTask : triggerNew)
        {
            //Id idToProccess = '00611000002ZXX';              
            if(curTask.WhatId != null && curTask.WhatId.getSObjectType() == Account.sObjectType)
            {
                accountTaskList.add(curTask);
                accIds.add(curTask.WhatId);
            }
            // Schema.sObjectType entityType = curTask.whatId.getSObjectType();
            // System.assert(entityType == Account.sObjectType);
        }

        Map<Id, Account> accList = new Map<Id, Account>([SELECT Id, RecordType.Name FROM Account WHERE Id IN :accIds]);

        for(Task curTask : accountTaskList)
        {
            curTask.XC_RecordTypeName__c = accList.get(curTask.WhatId).RecordType.Name;
        }
    }

    public static void updateAccountRecordTypeName(List<Task> triggerNew, Map<Id, Task> triggerOldMap)
    {
        List<Task> updateTaskList = new List<Task>();
        
        for(Task curTask : triggerNew)
        {          
            if(curTask.WhatId != triggerOldMap.get(curTask.Id).WhatId)
            {
                updateTaskList.add(curTask);
            }
        }

        if(!updateTaskList.isEmpty())
        {
            updateAccountRecordTypeName(updateTaskList);
        }
    }
}