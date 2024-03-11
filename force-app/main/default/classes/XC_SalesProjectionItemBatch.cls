public class XC_SalesProjectionItemBatch implements Database.Batchable<sObject>, Database.Stateful{ 

    public final Set<Id> salesProjectionIds;
    private List<XC_SalesProjectionItem__c> salesProjectionItems = new List<XC_SalesProjectionItem__c>();

    public XC_SalesProjectionItemBatch(Set<Id> ids){
        salesProjectionIds = ids;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, XC_HistoricalQuantity__c, XC_Account__r.XC_InvoiceAccountId__c, BusinessUnit__c, XC_Account__c, XC_Account__r.XC_CustomerId__c, XC_Fiscal_Year__c, XC_Fiscal_Period__c, XC_Admin_Account_Target_Qty__c, AccountTarget__c FROM XC_SalesProjection__c WHERE Id IN :salesProjectionIds ORDER BY XC_Account__r.XC_CustomerId__c]);
    }    

    public void execute(Database.BatchableContext info, List<XC_SalesProjection__c> scope){
        Map<String,List<XC_SalesProjection__c>> projectionsByAccountAndBusinessUnit = new Map<String,List<XC_SalesProjection__c>>();
        Map<String,Double> yearyAccountTotals = new Map<String,Double>();
        
        for(XC_SalesProjection__c sp : scope){
            String mapKey = sp.XC_Account__c + sp.BusinessUnit__c + sp.XC_Fiscal_Year__c;
            if(projectionsByAccountAndBusinessUnit.containsKey(mapKey)){
                   List<XC_SalesProjection__c> spList = projectionsByAccountAndBusinessUnit.get(mapKey);
                   spList.add(sp);
                   projectionsByAccountAndBusinessUnit.put(mapKey, spList);
               } else {
                   List<XC_SalesProjection__c> newSalesProjList = new List<XC_SalesProjection__c>();
                   newSalesProjList.add(sp);
                   projectionsByAccountAndBusinessUnit.put(mapKey, newSalesProjList);
               }
            if(yearyAccountTotals.containsKey(mapKey)){
                   Double previousValue = yearyAccountTotals.get(mapKey);
                   yearyAccountTotals.put(mapKey, previousValue + sp.XC_Admin_Account_Target_Qty__c);
               } else {
                   yearyAccountTotals.put(mapKey, sp.XC_Admin_Account_Target_Qty__c);
               }
        }
        
        for(String mapKey : projectionsByAccountAndBusinessUnit.keySet()){
            XC_SalesProjectionController.createSalesProjectionItems(projectionsByAccountAndBusinessUnit.get(mapKey), yearyAccountTotals.get(mapKey));
        }
    }       

    public void finish(Database.BatchableContext info){     

    } 
 }