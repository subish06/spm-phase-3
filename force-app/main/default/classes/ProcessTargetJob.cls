public class ProcessTargetJob {
    
   /* implements Database.Batchable<sObject> public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(
            [SELECT Id, Account_Id__c, Account_Owner_Id__c, Target_Per_Account__c, Status__c,
             CurrencyIsoCode, Financial_Year__c, BDD__c, Account_Id__r.Authorized_Business_Units__c FROM Pending_Targets__c WHERE Status__c = 'Pending' LIMIT 50]
        );
       
    }
    
    public void execute(Database.BatchableContext BC, List<Pending_Targets__c> scope) {
        Id businessUnitId;
        
        Map<String, Id> buMap = new Map<String, Id>();
        Map<Id, Integer> accTotalBUMap  = new Map<Id, Integer>();
        List<Target_Config__c> tConfigList = new List<Target_Config__c>();
        List<Pending_Targets__c> pTargetList = new List<Pending_Targets__c>();
        
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            
        for(Business_Unit__c busUnit : [SELECT Id,name from Business_Unit__c WHERE Available_for_Target__c = true]) {
            buMap.put(busUnit.name, busUnit.Id);
        }
        
        for (Pending_Targets__c pTarget : scope) {
            for (String bu : pTarget.Account_Id__r.Authorized_Business_Units__c.split(';')) {
                if(buMap.containsKey(bu)) {
                    businessUnitId  = buMap.get(bu);
                }
                
                for(String month : monthSet) {
                    Integer totalBuCount = buMap.size();
                    Decimal targetPerMonth = (pTarget.Target_Per_Account__c / totalBuCount) / 12;
                    Target_Config__c tConfig = new Target_Config__c();
                    tConfig.Account__c = pTarget.Account_Id__c;
                    tConfig.BDM__c = pTarget.Account_Owner_Id__c;
                    tConfig.BDD__c = pTarget.BDD__c;
                    tConfig.Financial_Year__c = pTarget.Financial_Year__c;
                    tConfig.Target__c = targetPerMonth;
                    tConfig.Month__c = month;
                    tConfig.Business_Unit__c = businessUnitId;
                    tConfig.Level__c = 'BDM';
                    tConfig.CurrencyIsoCode = pTarget.CurrencyIsoCode;
                    tConfigList.add(tConfig);
                }
            }
            pTarget.Status__c = 'Completed';
            pTargetList.add(pTarget);
        }
        
        if(!tConfigList.isEmpty()){
            Insert tConfigList;
            
            if(!pTargetList.isEmpty()){
                Update pTargetList;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
       Integer count = 0;
        count = [SELECT COUNT() FROM Pending_Targets__c WHERE Status__c = 'Pending'];
        
        if(count > 0) {
            ProcessTargetJob batch = new ProcessTargetJob();
            Database.executeBatch(batch);
        }
         else {
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email, CreatedBy.Name from AsyncApexJob where Id =:BC.getJobId()];
             
            Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mymail.setToAddresses(toAddresses);
            mymail.setReplyTo('noreply@gibson.com');
            mymail.setSenderDisplayName('Gibson Salesforce Support');
            mymail.setSubject('Target Setting Completed');
            //mymail.setPlainTextBody('Your Target Setting has been completed successfully. Kindly check ');
            mymail.setHtmlBody('Dear '+a.CreatedBy.Name+ '<p> I hope this email finds you well. I am writing to inform you about the target setting process that was recently completed.I am pleased to confirm that the target setting has been completed successfully.</p>');
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
        }
    }*/
    
}