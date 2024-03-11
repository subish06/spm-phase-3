public without sharing class XC_UpdateGiveawayFiscalYearSchedulable implements Database.Batchable<sObject>, Schedulable 
{
    public XC_UpdateGiveawayFiscalYearSchedulable() {}

    public void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(new XC_UpdateGiveawayFiscalYearSchedulable());
    }

    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, XC_ForCurrentFiscalYear__c, XC_NonFormulaForCurrentFiscalYear__c'
                            + ' FROM XC_Giveaway__c';
        if(Test.isRunningTest())
        {
            query += ' WHERE XC_NonFormulaForCurrentFiscalYear__c = false';
        }
        else 
        {
            query += ' WHERE XC_ForCurrentFiscalYear__c = false AND XC_NonFormulaForCurrentFiscalYear__c = true';
        }
                            
        return Database.getQueryLocator(query);
     }
  
     public void execute(Database.BatchableContext BC, List<sObject> scope)
     {
        List<XC_Giveaway__c> giveawayList = (List<XC_Giveaway__c>)scope;
        for(XC_Giveaway__c giveaway : giveawayList)
        {
            giveaway.XC_NonFormulaForCurrentFiscalYear__c = giveaway.XC_ForCurrentFiscalYear__c;
        }      

        update giveawayList;
     }
  
     public void finish(Database.BatchableContext BC){}
}