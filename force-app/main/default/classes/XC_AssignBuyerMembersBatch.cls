public class XC_AssignBuyerMembersBatch implements Database.Batchable<sObject>{ 
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name,  Authorized_Business_Units__c,XC_PricingGroup__c FROM Account WHERE XC_PricingGroup__c != null AND Authorized_Business_Units__c != null AND IsBuyer = false]);
    }    

    public void execute(Database.BatchableContext info, List<Account> accounts){
        Map<String,Object> accountMap = new Map<String,Object>();

        for(Account a : accounts){
            Map<String,String> accountInfo = new Map<String,String>{
                'entity' => a.Authorized_Business_Units__c,
                'priceGroup' => a.XC_PricingGroup__c,
                'name' => a.Name
            };

            accountMap.put(a.Id, accountInfo);
        }

        XC_AssignAccountBuyerGroup.assignBuyerGroup(accountMap);

    }       

    public void finish(Database.BatchableContext info){     

    } 

}