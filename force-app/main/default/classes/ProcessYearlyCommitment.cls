public class ProcessYearlyCommitment implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Business_Unit__c FROM Product2 WHERE Available_for_commitment__c = true');
    }
    
    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        Set<Id> bdmIds = new Set<Id>();
        List<Target_Commit_Stats__c> targetCommitList1 = new List<Target_Commit_Stats__c>();
        List<Target_Commit_Stats__c> targetCommitList2 = new List<Target_Commit_Stats__c>();
        List<Target_Commit_Stats__c> targetCommitList3 = new List<Target_Commit_Stats__c>();
        List<Target_Commit_Stats__c> targetCommitList4 = new List<Target_Commit_Stats__c>();
        List<Target_Commit_Stats__c> targetCommitList5 = new List<Target_Commit_Stats__c>();
        
        Map<String, Id> buMap = new Map<String, Id>();
        Map<String, List<Account>> buAccListMap = new Map<String, List<Account>>();
        Integer currentYear = Date.today().year();
        
        if(Date.today().month() > 3){
            currentYear = Date.today().year() + 1;
        }
    
        String currentYearString = String.valueOf(currentYear);
        String currentFY = 'FY-' + currentYearString.substring(2);
        
        for(Business_Unit__c bu : [SELECT Id, Unique_Name__c FROM Business_Unit__c WHERE Available_for_Target__c = true]) {
            buMap.put(bu.Unique_Name__c, bu.Id);
        }
        
        for(Hierarchy_Config__c  hc : [SELECT Id, User__c FROM Hierarchy_Config__c WHERE Role__c = 'DTC BDD'  AND User__c = '005020000033g0HAAQ']) {//Role__c = 'BDM'
            bdmIds.add(hc.User__c);
        }
        
        for(Account acc : [SELECT Id, OwnerId, Authorized_Business_Units__c FROM Account WHERE OwnerId IN: bdmIds]) {
            if(acc.Authorized_Business_Units__c != null){
                for(String bu : acc.Authorized_Business_Units__c.split(';')) {
                    if(buAccListMap.containsKey(bu)) {
                        buAccListMap.get(bu).add(acc);
                        continue;
                    }
                    buAccListMap.put(bu, new List<Account>{acc});
                }
            }
        }
        
        Integer count = 1;
        for(Product2 prd : scope) {
            if(!buAccListMap.containsKey(prd.Business_Unit__c) || !buMap.containsKey(prd.Business_Unit__c)) {
                continue;
            }
            
            for(Account acc : buAccListMap.get(prd.Business_Unit__c)) {
                String uniqueKey = currentFY + '-' + String.valueOf(acc.OwnerId).substring(0, 15) + '-' + String.valueOf(acc.Id).substring(0, 15) + '-'
                    + String.valueOf(buMap.get(prd.Business_Unit__c)).substring(0, 15) + '-' + String.valueOf(prd.Id).substring(0, 15) ;
                    
                Target_Commit_Stats__c tcs = new Target_Commit_Stats__c(
                    Account__c = acc.Id,
                    BDM__c  = acc.OwnerId,
                    Business_Unit__c = buMap.get(prd.Business_Unit__c),
                    IsUpload__c = false, Product__c = prd.Id,
                    Financial_Year__c = currentFY ,
                    Unique_key__c = uniqueKey
                );
                
                if(count <= 9000) {
                    targetCommitList1.add(tcs);
                }
                else if(count <= 18000) {
                    targetCommitList2.add(tcs);
                }
                else if (count <= 27000) {
                    targetCommitList3.add(tcs);
                }
                else if (count <= 35000) {
                    targetCommitList4.add(tcs);
                }
                else if (count <= 42000)  {
                    targetCommitList5.add(tcs);
                }
                count++;
            }
        }
        
        if(!targetCommitList1.isEmpty()) {
            Insert targetCommitList1;
        }
        
        if(!targetCommitList2.isEmpty()) {
            Insert targetCommitList2;
        }
        
        if(!targetCommitList3.isEmpty()) {
            Insert targetCommitList3;
        }
        
        if(!targetCommitList4.isEmpty()) {
            Insert targetCommitList4;
        }
        
        if(!targetCommitList5.isEmpty()) {
            Insert targetCommitList5;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }

}