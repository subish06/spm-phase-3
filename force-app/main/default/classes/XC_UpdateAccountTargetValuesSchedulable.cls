public without sharing class XC_UpdateAccountTargetValuesSchedulable implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    @testVisible
    private static Boolean testFullRefresh = false;

    public XC_UpdateAccountTargetValuesSchedulable() 
    {
        
    }

    private static Boolean doFullRefresh()
    {
        Date today = Date.today();
        Boolean doFullRefresh = today.day() == 1 ? true : false;
        //doFullRefresh = true;

        if(Test.isRunningTest())
        {
            return testFullRefresh;
        }
        else 
        {
            return doFullRefresh;
        }
    }
    

    public void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new XC_UpdateAccountTargetValuesSchedulable(), 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query;
        //Date today = Date.today();
        Map<String, Date> fiscalYearMap = XC_TargetUtilities.getFiscalYearDates();
        Map<String, Date> fiscalQuarterMap = XC_TargetUtilities.getFiscalQuarterDates();
        Date startDate = fiscalYearMap.get('startDate');
        Date endDate = fiscalYearMap.get('endDate');

        //need to do the full refresh
        //if(today.day() == 1)
        if(doFullRefresh())
        {
            query = 'SELECT Id, XC_TargetMTD__c, XC_TargetQTD__c, XC_TargetYTD__c,'
                            + ' XC_RevenueMTD__c, XC_RevenueQTD__c, XC_RevenueYTD__c,'
                            + ' XC_TargetThisMonth__c, XC_TargetThisQuarter__c, XC_TargetThisYear__c,'
                            + ' XC_RevenueThisMonth__c, XC_RevenueThisQuarter__c, XC_RevenueThisYear__c,'
                            + ' (SELECT Id, XC_Month__c, XC_Account__c, XC_RevenueTarget__c, XC_RevenueActuals__c FROM Targets__r WHERE XC_Month__c >= :startDate AND XC_Month__c <= :endDate)'
                        + ' FROM Account'
                        + ' WHERE XC_TargetRecordCount__c > 0';
        }
        //only need to update the To Date values
        else 
        {
            query = 'SELECT Id, XC_TargetMTD__c, XC_TargetQTD__c, XC_TargetYTD__c,'
                            + ' XC_RevenueMTD__c, XC_RevenueQTD__c, XC_RevenueYTD__c,'
                            + ' XC_TargetThisMonth__c, XC_TargetThisQuarter__c, XC_TargetThisYear__c,'
                            + ' XC_RevenueThisMonth__c, XC_RevenueThisQuarter__c, XC_RevenueThisYear__c'
                        + ' FROM Account'
                        + ' WHERE XC_TargetRecordCount__c > 0';
                        //+ ' WHERE (XC_TargetMTD__c != null && XC_TargetMTD__c > 0) || (XC_TargetQTD__c != null && XC_TargetQTD__c > 0) || (XC_TargetYTD__c != null && XC_TargetYTD__c > 0) || (XC_RevenueMTD__c != null && XC_RevenueMTD__c > 0) || (XC_RevenueQTD__c != null && XC_RevenueQTD__c > 0) || (XC_RevenueYTD__c != null && XC_RevenueYTD__c > 0)';
        }
        
        return Database.getQueryLocator(query);
     }
  
     public void execute(Database.BatchableContext bc, List<sObject> scope)
     {
        List<Account> accList = (List<Account>)scope;

        Map<String, Date> fiscalYearMap = XC_TargetUtilities.getFiscalYearDates();
        Map<String, Date> fiscalQuarterMap = XC_TargetUtilities.getFiscalQuarterDates();
        Date today = Date.today();

        //need to do the full refresh
        if(doFullRefresh())
        {
            for(Account acc : accList)
            {
                XC_TargetUtilities.blankTargetDataForRefresh(acc);

                for(XC_Target__c target : acc.Targets__r)
                {
                    XC_TargetUtilities.addTargetDataToAccountFields(target, false, acc, today, fiscalYearMap, fiscalQuarterMap);
                }

                XC_TargetUtilities.updateAccountToDateFields(acc, today, fiscalYearMap, fiscalQuarterMap);
            }  

            update accList;
        }
        //only need to update the To Date values
        else 
        {
            for(Account acc : accList)
            {
                XC_TargetUtilities.updateAccountToDateFields(acc, today, fiscalYearMap, fiscalQuarterMap);
            }  
            update accList;
        }

        
     }
  
     public void finish(Database.BatchableContext bc){}
}