public without sharing class XC_EventTriggerHandler 
{
    public static void updateAccountRecordTypeName(List<Event> triggerNew)
    {
        List<Event> accountEventList = new List<Event>();
        Set<Id> accIds = new Set<Id>();

        for(Event curEvent : triggerNew)
        {
            //Id idToProccess = '00611000002ZXX';              
            if(curEvent.WhatId != null && curEvent.WhatId.getSObjectType() == Account.sObjectType)
            {
                accountEventList.add(curEvent);
                accIds.add(curEvent.WhatId);
            }
            // Schema.sObjectType entityType = curEvent.whatId.getSObjectType();
            // System.assert(entityType == Account.sObjectType);
        }

        Map<Id, Account> accList = new Map<Id, Account>([SELECT Id, RecordType.Name FROM Account WHERE Id IN :accIds]);

        for(Event curEvent : accountEventList)
        {
            curEvent.XC_RecordTypeName__c = accList.get(curEvent.WhatId).RecordType.Name;
        }
    }

    public static void updateAccountRecordTypeName(List<Event> triggerNew, Map<Id, Event> triggerOldMap)
    {
        List<Event> updateEventList = new List<Event>();
        
        for(Event curEvent : triggerNew)
        {          
            if(curEvent.WhatId != triggerOldMap.get(curEvent.Id).WhatId)
            {
                updateEventList.add(curEvent);
            }
        }

        if(!updateEventList.isEmpty())
        {
            updateAccountRecordTypeName(updateEventList);
        }
    }
}