public without sharing class XC_TargetUtilities 
{
    private static final Integer fiscalYearStartMonth = 4;
    //private static final Integer fiscalYearStartDay = 1;

    private XC_TargetUtilities() {}
    

    public static Map<String, Date> getFiscalYearDates()
    {
        Map<String, Date> returnMap = new Map<String, Date>();

        Date today = Date.today();

        Date startDate;
        Date endDate;

        if(today.month() >= fiscalYearStartMonth)
        {
            
            startDate = Date.newInstance(today.year(), fiscalYearStartMonth, 1);

            Integer daysInMonth = Date.daysInMonth(today.year() + 1, fiscalYearStartMonth - 1);
            endDate = Date.newInstance(today.year() + 1, fiscalYearStartMonth - 1, daysInMonth);

            returnMap.put('startDate', startDate);
            returnMap.put('endDate', endDate);
        }
        else 
        {
            startDate = Date.newInstance(today.year() - 1, fiscalYearStartMonth, 1);

            Integer daysInMonth = Date.daysInMonth(today.year(), fiscalYearStartMonth - 1);
            endDate = Date.newInstance(today.year(), fiscalYearStartMonth - 1, daysInMonth);

            returnMap.put('startDate', startDate);
            returnMap.put('endDate', endDate);
        }

        return returnMap;
    }

    public static Map<String, Date> getFiscalQuarterDates()
    {
        Map<String, Date> returnMap = new Map<String, Date>();

        Date today = Date.today();

        Date startDate;
        Date endDate;

        Integer endMonthYearOffset = 0;

        Integer monthOffset = Math.mod(fiscalYearStartMonth, 3);
        Integer endMonth = (today.month() - monthOffset) / 3;
        endMonth = fiscalYearStartMonth + (3 * endMonth) - 1;

        if(endMonth > 12)
        {
            endMonth -= 12;
            endMonthYearOffset += 1;
        }

        //endMonth = endMonth > 12 ? endMonth - 12 : endMonth;
        Integer startMonth = endMonth - 2;

        if(startMonth < 1)
        {
            startMonth += 12;
        }
        //startMonth = startMonth < 1 ? startMonth + 12 : startMonth;

        startDate = Date.newInstance(today.year(), startMonth, 1);

        Integer daysInMonth = Date.daysInMonth(today.year() + endMonthYearOffset, endMonth);
        endDate = Date.newInstance(today.year() + endMonthYearOffset, endMonth, daysInMonth);

        returnMap.put('startDate', startDate);
        returnMap.put('endDate', endDate);

        return returnMap;
    }

    public static void addTargetDataToAccountFields(XC_Target__c target, Boolean isSubtract, Account acc, Date today, Map<String, Date> fiscalYearMap, Map<String, Date> fiscalQuarterMap)
    {
        Decimal targetToAdd = target.XC_RevenueTarget__c == null ? 0 : target.XC_RevenueTarget__c;
        Decimal actualToAdd = target.XC_RevenueActuals__c == null ? 0 : target.XC_RevenueActuals__c;

        if(isSubtract)
        {
            targetToAdd *= -1;
            actualToAdd *= -1;
        }

        acc.XC_TargetThisMonth__c = acc.XC_TargetThisMonth__c == null ? 0 : acc.XC_TargetThisMonth__c;
        acc.XC_TargetThisQuarter__c = acc.XC_TargetThisQuarter__c == null ? 0 : acc.XC_TargetThisQuarter__c;
        acc.XC_TargetThisYear__c = acc.XC_TargetThisYear__c == null ? 0 : acc.XC_TargetThisYear__c;

        acc.XC_RevenueThisMonth__c = acc.XC_RevenueThisMonth__c == null ? 0 : acc.XC_RevenueThisMonth__c;
        acc.XC_RevenueThisQuarter__c = acc.XC_RevenueThisQuarter__c == null ? 0 : acc.XC_RevenueThisQuarter__c;
        acc.XC_RevenueThisYear__c = acc.XC_RevenueThisYear__c == null ? 0 : acc.XC_RevenueThisYear__c;

        if(target.XC_Month__c.month() == today.month())
        {
            acc.XC_TargetThisMonth__c += targetToAdd == null ? 0 : targetToAdd;
            acc.XC_RevenueThisMonth__c += actualToAdd == null ? 0 : actualToAdd;
        }
        if(target.XC_Month__c >= fiscalQuarterMap.get('startDate') && target.XC_Month__c <= fiscalQuarterMap.get('endDate'))
        {
            acc.XC_TargetThisQuarter__c += targetToAdd == null ? 0 : targetToAdd;
            acc.XC_RevenueThisQuarter__c += actualToAdd == null ? 0 : actualToAdd;
        }
        if(target.XC_Month__c >= fiscalYearMap.get('startDate') && target.XC_Month__c <= fiscalYearMap.get('endDate'))
        {
            acc.XC_TargetThisYear__c += targetToAdd == null ? 0 : targetToAdd;
            acc.XC_RevenueThisYear__c += actualToAdd == null ? 0 : actualToAdd;
        }
    }

    public static void blankTargetDataForRefresh(Account acc)
    {
        acc.XC_TargetThisMonth__c = 0;
        acc.XC_TargetThisQuarter__c = 0;
        acc.XC_TargetThisYear__c = 0;

        acc.XC_RevenueThisMonth__c = 0;
        acc.XC_RevenueThisQuarter__c = 0;
        acc.XC_RevenueThisYear__c = 0;
    }

    public static void updateAccountToDateFields(Account acc, Date today, Map<String, Date> fiscalYearMap, Map<String, Date> fiscalQuarterMap)
    {
        acc.XC_TargetMTD__c = (acc.XC_TargetThisMonth__c == null || acc.XC_TargetThisMonth__c == 0) ? 0 : (acc.XC_TargetThisMonth__c / Date.daysInMonth(today.year(), today.month())) * today.day(); 
        acc.XC_TargetQTD__c = (acc.XC_TargetThisQuarter__c == null || acc.XC_TargetThisQuarter__c == 0) ? 0 : (acc.XC_TargetThisQuarter__c / (fiscalQuarterMap.get('startDate').daysBetween(fiscalQuarterMap.get('endDate')) + 1)) * fiscalQuarterMap.get('startDate').daysBetween(today);
        acc.XC_TargetYTD__c = (acc.XC_TargetThisYear__c == null || acc.XC_TargetThisYear__c == 0) ? 0 : (acc.XC_TargetThisYear__c / (fiscalYearMap.get('startDate').daysBetween(fiscalYearMap.get('endDate')) + 1)) * fiscalYearMap.get('startDate').daysBetween(today);
        
        acc.XC_RevenueMTD__c = (acc.XC_RevenueThisMonth__c == null || acc.XC_RevenueThisMonth__c == 0) ? 0 : (acc.XC_RevenueThisMonth__c / Date.daysInMonth(today.year(), today.month())) * today.day();
        acc.XC_RevenueQTD__c = (acc.XC_RevenueThisQuarter__c == null || acc.XC_RevenueThisQuarter__c == 0) ? 0 : (acc.XC_RevenueThisQuarter__c / (fiscalQuarterMap.get('startDate').daysBetween(fiscalQuarterMap.get('endDate')) + 1)) * fiscalQuarterMap.get('startDate').daysBetween(today);
        acc.XC_RevenueYTD__c = (acc.XC_RevenueThisYear__c == null || acc.XC_RevenueThisYear__c == 0) ? 0 : (acc.XC_RevenueThisYear__c / (fiscalYearMap.get('startDate').daysBetween(fiscalYearMap.get('endDate')) + 1)) * fiscalYearMap.get('startDate').daysBetween(today);
    }
}