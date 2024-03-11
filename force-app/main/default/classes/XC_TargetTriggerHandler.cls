public without sharing class XC_TargetTriggerHandler 
{
    private XC_TargetTriggerHandler() {}

    public static void updateTargetFieldsInsert(List<XC_Target__c> triggerNew)
    {
        Map<Id, List<XC_Target__c>> accToValidTargetMap = new Map<Id, List<XC_Target__c>>();
        Set<Id> accIds = new Set<Id>();
        Map<String, Date> fiscalYearMap = XC_TargetUtilities.getFiscalYearDates();
        Map<String, Date> fiscalQuarterMap = XC_TargetUtilities.getFiscalQuarterDates();

        for(XC_Target__c target : triggerNew)
        {
            if(target.XC_Month__c >= fiscalYearMap.get('startDate') && target.XC_Month__c <= fiscalYearMap.get('endDate'))
            {
                accIds.add(target.XC_Account__c);
                if(!accToValidTargetMap.containsKey(target.XC_Account__c))
                {
                    accToValidTargetMap.put(target.XC_Account__c, new List<XC_Target__c>());
                }
                accToValidTargetMap.get(target.XC_Account__c).add(target);
            }
        }

        List<Account> accList = [SELECT Id, XC_TargetMTD__c, XC_TargetQTD__c, XC_TargetYTD__c, 
                                        XC_RevenueMTD__c, XC_RevenueQTD__c, XC_RevenueYTD__c,
                                        XC_TargetThisMonth__c, XC_TargetThisQuarter__c, XC_TargetThisYear__c,
                                        XC_RevenueThisMonth__c, XC_RevenueThisQuarter__c, XC_RevenueThisYear__c
                                    FROM Account
                                    WHERE Id IN :accIds];

        Date today = Date.today();

        for(Account acc : accList)
        {
            for(XC_Target__c target : accToValidTargetMap.get(acc.Id))
            {
                XC_TargetUtilities.addTargetDataToAccountFields(target, false, acc, today, fiscalYearMap, fiscalQuarterMap);
            }

            XC_TargetUtilities.updateAccountToDateFields(acc, today, fiscalYearMap, fiscalQuarterMap);
        }

        if(!accList.isEmpty())
        {
            update accList;
        }
    }

    public static void updateTargetFieldsUpdate(List<XC_Target__c> triggerNew, Map<Id, XC_Target__c> triggerOldMap)
    {
        Map<Id, List<XC_Target__c>> accToValidTargetMap = new Map<Id, List<XC_Target__c>>();
        Set<Id> accIds = new Set<Id>();
        Map<String, Date> fiscalYearMap = XC_TargetUtilities.getFiscalYearDates();
        Map<String, Date> fiscalQuarterMap = XC_TargetUtilities.getFiscalQuarterDates();

        for(XC_Target__c target : triggerNew)
        {
            if((target.XC_Month__c >= fiscalYearMap.get('startDate') && target.XC_Month__c <= fiscalYearMap.get('endDate')) || (triggerOldMap.get(target.Id).XC_Month__c >= fiscalYearMap.get('startDate') && triggerOldMap.get(target.Id).XC_Month__c <= fiscalYearMap.get('endDate')))
            {
                accIds.add(target.XC_Account__c);
                if(!accToValidTargetMap.containsKey(target.XC_Account__c))
                {
                    accToValidTargetMap.put(target.XC_Account__c, new List<XC_Target__c>());
                }
                accToValidTargetMap.get(target.XC_Account__c).add(target);
            }
        }

        List<Account> accList = [SELECT Id, XC_TargetMTD__c, XC_TargetQTD__c, XC_TargetYTD__c, 
                                        XC_RevenueMTD__c, XC_RevenueQTD__c, XC_RevenueYTD__c,
                                        XC_TargetThisMonth__c, XC_TargetThisQuarter__c, XC_TargetThisYear__c,
                                        XC_RevenueThisMonth__c, XC_RevenueThisQuarter__c, XC_RevenueThisYear__c
                                    FROM Account
                                    WHERE Id IN :accIds];

        Date today = Date.today();

        for(Account acc : accList)
        {
            for(XC_Target__c target : accToValidTargetMap.get(acc.Id))
            {
                XC_TargetUtilities.addTargetDataToAccountFields(triggerOldMap.get(target.Id), true, acc, today, fiscalYearMap, fiscalQuarterMap);
                XC_TargetUtilities.addTargetDataToAccountFields(target, false, acc, today, fiscalYearMap, fiscalQuarterMap);
            }

            XC_TargetUtilities.updateAccountToDateFields(acc, today, fiscalYearMap, fiscalQuarterMap);
        }

        if(!accList.isEmpty())
        {
            update accList;
        }
    }

    public static void updateTargetFieldsDelete(List<XC_Target__c> triggerOld)
    {
        Map<Id, List<XC_Target__c>> accToValidTargetMap = new Map<Id, List<XC_Target__c>>();
        Set<Id> accIds = new Set<Id>();
        Map<String, Date> fiscalYearMap = XC_TargetUtilities.getFiscalYearDates();
        Map<String, Date> fiscalQuarterMap = XC_TargetUtilities.getFiscalQuarterDates();

        for(XC_Target__c target : triggerOld)
        {
            if(target.XC_Month__c >= fiscalYearMap.get('startDate') && target.XC_Month__c <= fiscalYearMap.get('endDate'))
            {
                accIds.add(target.XC_Account__c);
                if(!accToValidTargetMap.containsKey(target.XC_Account__c))
                {
                    accToValidTargetMap.put(target.XC_Account__c, new List<XC_Target__c>());
                }
                accToValidTargetMap.get(target.XC_Account__c).add(target);
            }
        }

        List<Account> accList = [SELECT Id, XC_TargetMTD__c, XC_TargetQTD__c, XC_TargetYTD__c, 
                                        XC_RevenueMTD__c, XC_RevenueQTD__c, XC_RevenueYTD__c,
                                        XC_TargetThisMonth__c, XC_TargetThisQuarter__c, XC_TargetThisYear__c,
                                        XC_RevenueThisMonth__c, XC_RevenueThisQuarter__c, XC_RevenueThisYear__c
                                    FROM Account
                                    WHERE Id IN :accIds];

        Date today = Date.today();

        for(Account acc : accList)
        {
            for(XC_Target__c target : accToValidTargetMap.get(acc.Id))
            {
                XC_TargetUtilities.addTargetDataToAccountFields(target, true, acc, today, fiscalYearMap, fiscalQuarterMap);
            }

            XC_TargetUtilities.updateAccountToDateFields(acc, today, fiscalYearMap, fiscalQuarterMap);
        }

        if(!accList.isEmpty())
        {
            update accList;
        }
    }
}