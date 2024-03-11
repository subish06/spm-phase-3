public class ProcessTargetCommitRecords implements Database.Batchable<sObject>, Database.Stateful {
    
    Map<Id, String> BDMID_MAP = new Map<Id, String>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String dynamicQuery = 'SELECT Id, Account__c, BDM__c, BDM__r.Email, Product__c,Product__r.Start_Date__c, Business_Unit__c, Financial_Year__c, Non_Available_Product__c, ' + 
            'Key__c, Status__c, Unit_Price__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c,Check_Error__c, ' + 
            'Oct__c, Nov__c, Dec__c FROM Target_Commit_Stats__c WHERE Status__c = \'Pending\' AND IsUpload__c = True';
        return Database.getQueryLocator(dynamicQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Commit_Stats__c> scope) {
       Map<String, Integer> monthMap = new Map<String, Integer>{
            'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
            'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
        };
                    
        List<Order_Commitment__c> ordCommitList = new List<Order_Commitment__c>();
        Map<String, Target_Commit_Stats__c> keyMap = new Map<String, Target_Commit_Stats__c>();
        List<String> months = new List<String>{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
        Integer currentMonth = System.today().month();
        Integer currentDay = System.today().day();
        
        for(Target_Commit_Stats__c tcs : scope) {
            for(String month : months) {
                String numericPart = tcs.Financial_Year__c.substring(3);
                Integer baseYear = 2000; 
                Integer fullYear = baseYear + Integer.valueOf(numericPart);
                
                if (monthMap.get(month) > 3) {
                    fullYear--;
                }
                
                if(monthMap.get(month) < currentMonth && System.today().year() == fullYear) {
                    continue;
                }
                
                Date itemStartDate = Date.newInstance(fullYear, monthMap.get(month), 1);
                
                if(tcs.Product__r.Start_Date__c != null){
                    if (
                        currentMonth == monthMap.get(month) && currentDay >= tcs.Product__r.Start_Date__c.day() && 
                        itemStartDate.month() == tcs.Product__r.Start_Date__c.month() && 
                        itemStartDate.year() == tcs.Product__r.Start_Date__c.year()
                    ) {
                        itemStartDate = tcs.Product__r.Start_Date__c;
                    }
                    
                    if(itemStartDate < tcs.Product__r.Start_Date__c) {
                        tcs.Check_Error__c = true;
                        BDMID_MAP.put(tcs.BDM__c, tcs.BDM__r.Email);
                        continue;
                    }
                }
                keyMap.put(tcs.key__c+'-'+month, tcs);
            }
        }
        
        Update scope;
        
        for(Order_Commitment__c existOrdCommitment : [SELECT Id, Key__c, Month__c, Quantity__c FROM Order_Commitment__c where key__c IN : keyMap.keySet()]){
            if(keyMap.containsKey(existOrdCommitment.Key__c)){
                Sobject sObj = keyMap.get(existOrdCommitment.Key__c);
                existOrdCommitment.Quantity__c = (Decimal) sObj.get(existOrdCommitment.Month__c+'__c');
                keyMap.remove(existOrdCommitment.Key__c);
                ordCommitList.add(existOrdCommitment);
            }
        }
        
        for(String key : keyMap.keySet()) {
            Sobject sObj = keyMap.get(key);
            Order_Commitment__c ord = new Order_Commitment__c();
            ord.Account__c = (Id) sObj.get('Account__c');
            ord.BDM__c = (Id) sObj.get('BDM__c');
            ord.Product__c = (Id) sObj.get('Product__c');
            ord.Business_Unit__c = (Id) sObj.get('Business_Unit__c');
            ord.Unit_Price__c = (Decimal) sObj.get('Unit_Price__c');
            ord.Financial_Year__c = (String) sObj.get('Financial_Year__c');
            
            String month = key.subString(key.length() - 3);
            ord.Month__c = month;
            ord.Quantity__c = (Decimal) sObj.get(month+'__c');
            
            ordCommitList.add(ord);
        }
        
        if (!ordCommitList.isEmpty()) {
            upsert ordCommitList;
        }
        
        for (Target_Commit_Stats__c tcStats : scope) {
            tcStats.Status__c = 'Completed';
        }
        update scope;
    }
    
    
    
    public void finish(Database.BatchableContext bc) {
        Set<Id> remainingBDMIds = new Set<Id>(BDMID_MAP.keySet());
        Map<Id, String> bdmIdToNameMap = new Map<Id, String>();
        
        if(!BDMID_MAP.keySet().isEmpty()) {
            for (User bdmUser : [SELECT Id, Name FROM User WHERE Id IN :remainingBDMIds]) {
                bdmIdToNameMap.put(bdmUser.Id, bdmUser.Name);
            }
            
            for(
                AggregateResult tcs : [SELECT COUNT(Id) bdmCount,BDM__c,Status__c FROM Target_Commit_Stats__c WHERE BDM__c IN : BDMID_MAP.keySet()
                                       AND Status__c = 'Pending' GROUP BY BDM__c, Status__c])
            {
                BDMID_MAP.remove((Id) tcs.get('BDM__c'));
            }
        }
        
        if(!BDMID_MAP.keySet().isEmpty()) {
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate et = [SELECT Id, subject, HtmlValue FROM EmailTemplate WHERE DeveloperName =: 'Non_available_SKU_Template'];            
            
            for(String email : BDMID_MAP.values()) {
                
                if(et != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] { email };
                        String body = et.HtmlValue;
                    
                    for (Id bdmId : remainingBDMIds) {
                        String bdmName = bdmIdToNameMap.get(bdmId);
                        body = body.replaceAll('\\{!Target_Commit_Stats__c.BDM__c\\}', bdmName);
                        mail.setToAddresses(toAddresses);
                        mail.setTemplateId(et.Id); 
                        mail.setSubject(et.subject);
                        mail.setHTMLBody(body);
                    }
                    
                    mailList.add(mail);
                }
            }
            
            Messaging.sendEmail(mailList);
        }    
    }
    
}