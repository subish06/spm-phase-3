public class UpdateBDMTargetsBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, BDD__c, BDM__c, Financial_Year__c, Allocated_Percentage__c, CurrencyIsoCode FROM Target_Distribution__c WHERE BDD__c = \'' + currentUser + '\' AND financial_Year__c = \'' + financialYear + '\'');  
    }
    
    public void execute(Database.BatchableContext context, List<Target_Distribution__c> scope) {
        Map<Id, Target_Distribution__c> BDMTargetDistMap = new Map<Id, Target_Distribution__c>();
        for(Target_Distribution__c record : scope){
            Id bdmValue = (Id)record.get('BDM__c');
            BDMTargetDistMap.put(bdmValue, record);
        }
        
        BDDController.updateBDMTargets(currentUser, financialYear, bddTarget, BDMTargetDistMap, currencyVal);
    }
    
    public void finish(Database.BatchableContext context) {  
        List<Target_Acknowledgement__c> tAcknowledgeList = new List<Target_Acknowledgement__c>();
        Map<Id, Target_Acknowledgement__c> existingRecordsMap = new Map<Id, Target_Acknowledgement__c>();
        List<Target_Acknowledgement_History__c> ackHistoryList = new List<Target_Acknowledgement_History__c>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        User usr = [SELECT Id, Name, Email from User WHERE Id = : currentUser];
        //EmailTemplate et = [SELECT Id, subject, HtmlValue FROM EmailTemplate WHERE DeveloperName =: 'BDD_Target_Message'];
     
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { usr.Email };
       
        String body = 'Hi ' + usr.Name + ' , <br/><br/>';    
        body += 'Sales Target has been set for the ' + financialYear + ' successfully. Kindly review ' + financialYear + ' sales target.  <br/><br/>' ;
        body += 'Thank You. <br/>';
        body += 'Gibson Brands. <br/>';


        mail.setToAddresses(toAddresses);
        // mail.setTemplateId(et.Id);
        mail.setSubject('Sales Target Set Successfully - ' +financialYear);
        mail.setHTMLBody(body);
        mailList.add(mail);
        if(!mailList.isEmpty()){
            Messaging.sendEmail(mailList);
        }
        
        for (Target_Acknowledgement__c tAcknowledge : [SELECT Id, BDD__c, BDM__c, Status__c, Financial_Year__c,Comments__c FROM Target_Acknowledgement__c WHERE BDD__c = :currentUser AND BDM__c IN :bdmList AND Financial_Year__c = :financialYear]) {
            existingRecordsMap.put(tAcknowledge.BDM__c, tAcknowledge);
        }
        
        if(isAcknowledge){
            for(Id bdmId : bdmList){
                if (existingRecordsMap.containsKey(bdmId)) {
                    Target_Acknowledgement__c existingRecord = existingRecordsMap.get(bdmId);
                    existingRecord.Status__c = 'Target sent';
                    existingRecord.Comments__c = '';
                    tAcknowledgeList.add(existingRecord);
                } else {
                    Target_Acknowledgement__c newRecord = new Target_Acknowledgement__c();
                    newRecord.BDD__c = currentUser;
                    newRecord.BDM__c = bdmId;
                    newRecord.Status__c = 'Target sent';
                    newRecord.Financial_Year__c = financialYear;
                    newRecord.Comments__c = '';
                    tAcknowledgeList.add(newRecord);
                }
            }
        }
        if(!tAcknowledgeList.isEmpty()){
            Upsert tAcknowledgeList;
            for(Target_Acknowledgement__c tAcknowledge : tAcknowledgeList){
                Target_Acknowledgement_History__c newHistory = new Target_Acknowledgement_History__c();
                newHistory.Target_Acknowledgement__c = tAcknowledge.Id;
                newHistory.Status__c = tAcknowledge.Status__c;
                newHistory.Comments__c = tAcknowledge.Comments__c;
                ackHistoryList.add(newHistory);
            }
        }
        if(!ackHistoryList.isEmpty()){
            Insert ackHistoryList;
        }
    }
    
    private Id currentUser;
    private String financialYear;
    private decimal bddTarget;
    Private Map<Id, Target_Distribution__c> BDMTargetDistMap;
    Private string currencyVal; 
    Private Boolean isAcknowledge;
    Private List<string> bdmList;
    
    public UpdateBDMTargetsBatch(Id currentUser, String financialYear, Decimal BDDTarget, Map<Id, Target_Distribution__c> BDMTargetDistMap, String currencyVal,Boolean isAcknowledge,List<String> bdmList) {
        this.currentUser = currentUser;
        this.financialYear = financialYear;
        this.bddTarget = bddTarget;
        this.BDMTargetDistMap = BDMTargetDistMap;
        this.currencyVal = currencyVal;
        this.isAcknowledge = isAcknowledge;
        this.bdmList = bdmList;
    }
}