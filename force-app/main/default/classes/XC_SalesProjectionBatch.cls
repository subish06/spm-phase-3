public without sharing class XC_SalesProjectionBatch implements Database.Batchable<sObject>, Database.Stateful {

    public final List<Object> data;
    public final List<String> accountNumbers;
    public final List<String> bdmList;
    private List<XC_SalesProjection__c> salesProjections = new List<XC_SalesProjection__c>();

    public XC_SalesProjectionBatch(List<Object> excelData, List<String> ids, List<String> bdmEmails){
        data = excelData;
        accountNumbers = ids;
        bdmList = bdmEmails;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, XC_CustomerId__c FROM Account WHERE XC_CustomerId__c IN :accountNumbers]);
    }   

    public void execute(Database.BatchableContext info, List<Account> accounts){

        Map<String,String> accountIdsByCustomerNumber = new Map<String,String>();
        for(Account acc : accounts){
            accountIdsByCustomerNumber.put(acc.XC_CustomerId__c, acc.Id);
        } 
        
        salesProjections.addAll(XC_SalesProjectionController.uploadSalesProjections(data, accountIdsByCustomerNumber, bdmList));
       
    } 

    public void finish(Database.BatchableContext info){    
        Set<Id> salesProjectionIds = new Set<Id>();
        if(salesProjections.size() != 0) {
            for(XC_SalesProjection__c sp : salesProjections){
                salesProjectionIds.add(sp.Id);
            }
        }
        XC_SalesProjectionItemBatch spib = new XC_SalesProjectionItemBatch(salesProjectionIds);
        Database.executeBatch(spib, 12); 
    } 
}