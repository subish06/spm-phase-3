public class bdmController2 {
    
    @AuraEnabled(Cacheable = true)
    Public static Boolean prepareBDMStats(Id currentUser, String financialYear) {
        return true;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetBDM(String financialYear,Id currentUser,String subChannel) {
        return getBDMTargetData(financialYear, currentUser, subChannel);
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getBDMTargetData(String financialYear,Id currentUser,String subChannel) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = True ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        getTargetValues(financialYear, currentUser, subChannel, busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
   private static void getTargetValues(String financialYear,Id currentUser,String subChannel, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, Month__c,CurrencyISOCode, SUM(Target__c) from Target_Config__c 
             where Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = True AND BDD__c =: currentUser AND Sub_Channel__c =: subChannel AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c,CurrencyISOCode]
        ) { 
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal target = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            target = target.setScale(2, System.RoundingMode.HALF_UP);
            
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), target
            );
        }
    }
    
    @AuraEnabled
    public static void saveBDMTargets(Id bddId, String subChannel, String financialYear, List<Map<String, Object>> updatedRecords,Boolean isAcknowledge) {
        String[] monthNames = new String[] {
            'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'
                };
                    
        Map<String, Map<String, Decimal>> buMonthDiff = new Map<String, Map<String, Decimal>>();
        Map<String, Map<String, Decimal>> buMonthNonDiff = new Map<String, Map<String, Decimal>>();
        Map<String, Map<String, Decimal>> busUnitTargetMap = new Map<String, Map<String, Decimal>>();
        
        Map<String, Decimal> buMonthAgr = new Map<String, Decimal>();
        Map<String, Decimal> missingBUMonthDiff = new Map<String, Decimal>();
        
        Map<String, List<Target_Config__c>> buMonthTConfigListMap = new Map<String, List<Target_Config__c>>();
        List<Target_Config__c> allTargetConfigs = new List<Target_Config__c>();
        List<Target_Acknowledgement__c> tAcknowledgeList = new List<Target_Acknowledgement__c>();
        Map<Id, Target_Acknowledgement__c> existingRecordsMap = new Map<Id, Target_Acknowledgement__c>();
        List<Target_Acknowledgement_History__c> ackHistoryList = new List<Target_Acknowledgement_History__c>();
        Decimal percentage = 0 ;
        
  		/*for (Target_Acknowledgement__c tAcknowledge : [SELECT Id, BDD__c, BDM__c, Status__c, Comments__c FROM Target_Acknowledgement__c WHERE BDD__c = :bddId AND BDM__c = :bdmId AND Financial_Year__c = :financialYear]) {
            existingRecordsMap.put(tAcknowledge.BDM__c, tAcknowledge);
        }
        
        
        if(isAcknowledge){
            if (existingRecordsMap.containsKey(bdmId)) {
                Target_Acknowledgement__c existingRecord = existingRecordsMap.get(bdmId);
               	existingRecord.Status__c = 'Target sent';
                existingRecord.Comments__c = '';
                tAcknowledgeList.add(existingRecord);
            } else {
                Target_Acknowledgement__c newRecord = new Target_Acknowledgement__c();
                newRecord.BDD__c = bddId;
                newRecord.BDM__c = bdmId;
                newRecord.Status__c = 'Target sent';
                newRecord.Financial_Year__c = financialYear;
                newRecord.Comments__c = '';
                tAcknowledgeList.add(newRecord);
            }
        }
        */
        
        for(Map<String, Object> busObj : updatedRecords) {
            Map<String, Decimal> monthTargetMap = new Map<String, Decimal>();
           /* for(String month : monthNames) {
                monthTargetMap.put(month, (Decimal) busObj.get(month));
            }*/
            
            for(String month : monthNames) {
                Integer currentMonthIndex = ((Date.today().month()) + 8 - ((Date.today().month()) + 8) / 12 * 12) + 1;
                Integer monthIndex = monthNames.indexOf(month) + 1;
                
                if (monthIndex >= currentMonthIndex){
                    monthTargetMap.put(month, (Decimal) busObj.get(month));
                }
            }
            String busUnit = (String) busObj.get('busUnit');
            if (String.isBlank(busUnit) || busUnit == 'Total') {
                continue;
            }
            
            busUnitTargetMap.put((String) busObj.get('busUnit'), monthTargetMap);
            
        }
        
        for(
            AggregateResult aggr :
            [SELECT Business_Unit__r.Name bu, Month__c month, SUM(Target__c) FROM Target_Config__c WHERE BDD__c =: bddId AND Business_Unit__r.Name IN : busUnitTargetMap.keySet()
             AND Financial_Year__c =: financialYear AND Sub_Channel__c =: subChannel GROUP BY Business_Unit__r.Name, Month__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
            String bu = (String) aggr.get('bu');
            String month = (String) aggr.get('month');
            Map<String, Decimal> monthDiff = new Map<String, Decimal>();
            monthDiff.put(month, 0);
            
            if(
                busUnitTargetMap.containsKey(bu) && busUnitTargetMap.get(bu).containsKey(month) &&
                busUnitTargetMap.get(bu).get(month) != target && target >= 0 && busUnitTargetMap.get(bu).get(month) != null
            ) {
                Integer currentMonthIndex = ((Date.today().month()) + 8 - ((Date.today().month()) + 8) / 12 * 12) + 1;
                Integer monthIndex = monthNames.indexOf(month) + 1;
                
                Integer currentFY = System.Today().year() + 1;
                String formattedFYear = String.valueOf(currentFY);
                String fyear = formattedFYear.substring(2, 4);
                
                if (monthIndex < currentMonthIndex && financialYear == 'FY-'+ fyear) {
                    throw new AuraHandledException('You cannot modify targets for past months. The target for the month of ' + month + ' has already passed.');
                }
                                
                if(target != 0){
                    percentage = (busUnitTargetMap.get(bu).get(month) - target) / target;
                }
                
                monthDiff.put(month, percentage);
                
                if(buMonthDiff.containsKey(bu)) {
                    buMonthDiff.get(bu).put(month, percentage);
                }
                else {
                    buMonthDiff.put(bu, monthDiff);
                }
            }
            else if(buMonthNonDiff.containsKey(bu)) {
                buMonthNonDiff.get(bu).put(month, 0);
            }
            else {
                buMonthNonDiff.put(bu, monthDiff);
            }
        }
        
        for(
            Target_Config__c tConfig :
            [SELECT Id, Business_Unit__r.Name, Month__c, Target__c FROM Target_Config__c WHERE BDD__c =: bddId AND
             Business_Unit__r.Name IN : busUnitTargetMap.keySet() AND Financial_Year__c =: financialYear AND Sub_Channel__c =: subChannel]
        ) {
            if(buMonthDiff.containsKey(tConfig.Business_Unit__r.Name) && buMonthDiff.get(tConfig.Business_Unit__r.Name).containsKey(tConfig.Month__c)) {
                tConfig.Target__c = tConfig.Target__c + (tConfig.Target__c * buMonthDiff.get(tConfig.Business_Unit__r.Name).get(tConfig.Month__c));
                tConfig.Target__c = tConfig.Target__c.setScale(2);
                
                String key = tConfig.Business_Unit__r.Name + '_' + tConfig.Month__c;
                
                if(!buMonthTConfigListMap.containsKey(key)) {
                    buMonthTConfigListMap.put(key, new List<Target_Config__c>{tConfig});
                }
                else {
                    buMonthTConfigListMap.get(key).add(tConfig);
                }
                
                if(!buMonthAgr.containsKey(key)) {
                    buMonthAgr.put(key, 0);
                } 
                buMonthAgr.put(key, buMonthAgr.get(key) + tConfig.Target__c);
                
            }
        }
        
        for(String bu : busUnitTargetMap.keySet()) {
            for(String month : busUnitTargetMap.get(bu).keySet()) {
                
                if(
                    (
                        !buMonthDiff.containsKey(bu) || !buMonthDiff.get(bu).containsKey(month)
                    ) &&
                    (
                        !buMonthNonDiff.containsKey(bu) || !buMonthNonDiff.get(bu).containsKey(month)
                    ) &&
                    busUnitTargetMap.get(bu).get(month) > 0
                ) {
                    missingBUMonthDiff.put(bu + '_' + month, busUnitTargetMap.get(bu).get(month));
                }
            }
        }
        if(!missingBUMonthDiff.keySet().isEmpty()) {
            List<Account> accList = [SELECT Id FROM Account WHERE Sub_Channel__c =: subChannel];
            List<Year_Stats__c> yearStatsList = [SELECT Id FROM Year_Stats__c WHERE Financial_Year__c =: financialYear LIMIT 1];
            
            if(!accList.isEmpty() && accList.size() > 0) {
                Map<String, Id> buMap = new Map<String, Id>();
                for(Business_Unit__c busUnit : [SELECT Id,name from Business_Unit__c WHERE Available_for_Target__c = true]) {
                    buMap.put(busUnit.name, busUnit.Id);
                }
                
                for(String key : missingBUMonthDiff.keySet()) {
                    String[] buMonth = key.split('_');
                    Decimal targetPerAcc = missingBUMonthDiff.get(key) / accList.size();
                    
                    for(Account acc : accList) {
                        Target_Config__c tConfig = new Target_Config__c(
                            Financial_Year__c = financialYear,
                            Month__c = buMonth[1],
                            BDD__c = bddId,
							Sub_Channel__c = subChannel,
                            Account__c = acc.Id,
                            Business_Unit__c = buMap.get(buMonth[0]),
                            Target__c = targetPerAcc,
                            Level__c = 'BDM',
                            Year_Stats__c = yearStatsList[0].Id
                        );
                        
                        if(!buMonthTConfigListMap.containsKey(key)) {
                            buMonthTConfigListMap.put(key, new List<Target_Config__c>{tConfig});
                        }
                        else {
                            buMonthTConfigListMap.get(key).add(tConfig);
                        }
                        
                        if(!buMonthAgr.containsKey(key)) {
                            buMonthAgr.put(key, 0);
                        }
                        buMonthAgr.put(key, buMonthAgr.get(key) + tConfig.Target__c);
                    }
                }
            }
        }
        
        if(!buMonthTConfigListMap.keySet().isEmpty()) {
            for(String bu : busUnitTargetMap.keySet()) {
                for(String month : busUnitTargetMap.get(bu).keySet()) {
                    String key = bu + '_' + month;
                    if(!buMonthAgr.containsKey(key) || buMonthAgr.get(key) == busUnitTargetMap.get(bu).get(month) || !buMonthTConfigListMap.containsKey(key)) {
                        continue;
                    }
                    
                    Decimal diff = busUnitTargetMap.get(bu).get(month) - buMonthAgr.get(key);
                    buMonthTConfigListMap.get(key)[0].Target__c += diff; 
                    
                }
            }
            
            
            for (List<Target_Config__c> targetConfigList : buMonthTConfigListMap.values()) {
                allTargetConfigs.addAll(targetConfigList);
            }
            upsert allTargetConfigs;
        }
       if(!tAcknowledgeList.isEmpty()){
            Upsert tAcknowledgeList;
            
            for(Target_Acknowledgement__c tAcknowledge : tAcknowledgeList){
                Target_Acknowledgement_History__c newHistory = new Target_Acknowledgement_History__c();
                newHistory.Target_Acknowledgement__c = tAcknowledge.Id;
                newHistory.Comments__c = tAcknowledge.Comments__c;
                newHistory.Status__c = tAcknowledge.Status__c;
                ackHistoryList.add(newHistory);
            }
        }
        
        if(!ackHistoryList.isEmpty()){
            Insert ackHistoryList;
        }
    }
    
     @AuraEnabled(cacheable=true)
    public static List<BDMAccount> getBDMAccountStats(Id loggedUser, String subChannel, String financialYear, String searchTerm) {
        Map<Id, BDMAccount> BDMAccountMap = new Map<Id, BDMAccount>();
        string searchKeyword = searchTerm + '%';
       
        for(
            Account bdmAccounts :
            [SELECT Id, Name, OwnerId, XC_Channel__c, Sub_channel__c FROM Account WHERE XC_Channel__c = 'DTC' AND sub_channel__c != null AND Sub_channel__c = : subChannel AND
             ParentId = NULL AND Authorized_Business_Units__c != NULL AND XC_AccountStatus__c = 'Active' AND OwnerId = :loggedUser AND Name LIKE : searchKeyword ORDER BY Name ASC]
        ) {
            BDMAccountMap.put(
                bdmAccounts.Id,  
                new BDMAccount(bdmAccounts.OwnerId, bdmAccounts.Name, bdmAccounts.Id, 0,0,0,0,0,0)
            );
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,  SUM(Overall_Actuals__c) FROM Target_Config__c WHERE Sub_channel__c = : subChannel
             AND Financial_Year__c =: financialYear AND Account__c IN : BDMAccountMap.keySet() GROUP BY Account__c]
        ) {
            Decimal actuals = (Decimal) aggr.get('expr0');
            Id accId = (Id) aggr.get('Account__c');
           
            if(BDMAccountMap.containsKey(accId)) {
                BDMAccountMap.get(accId).actualAmount = actuals;
            }  
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c, SUM(Target__c) FROM Target_Config__c WHERE  Sub_channel__c = : subChannel
             AND Financial_Year__c =: financialYear AND Account__c IN : BDMAccountMap.keySet() GROUP BY Account__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
            Id accId = (Id) aggr.get('Account__c');
           
            if(BDMAccountMap.containsKey(accId)) {
                BDMAccountMap.get(accId).targetAmount = target;
            }
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c, SUM(Variance_Amount__c) FROM Target_Config__c WHERE Sub_channel__c = : subChannel
             AND Financial_Year__c =: financialYear AND Account__c IN : BDMAccountMap.keySet() GROUP BY Account__c]
        ) {
            Decimal variance = (Decimal) aggr.get('expr0');
            Id accId = (Id) aggr.get('Account__c');
           
            if(BDMAccountMap.containsKey(accId)) {
                BDMAccountMap.get(accId).varianceAmount = variance;
            }
        }  
        return BDMAccountMap.values();
    }
    
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetSubChannel(Id loggedUser, String financialYear, Id accountId, String subChannel) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
       
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }        
        getTargetSubChannelValues(loggedUser, financialYear, accountId, subChannel, busUnitMonthSalesTarMap);
       
        return busUnitMonthSalesTarMap;
    }
   
    private static void getTargetSubChannelValues(Id loggedUser, String financialYear,Id accountId,String subChannel, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        for(
            AggregateResult aggr :
            [select Business_Unit__r.Name, Month__c, SUM(Target__c) from Target_Config__c
             where Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = true AND Account__c =: accountId AND BDD__C = :loggedUser
             AND Sub_Channel__c =: subChannel AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
           
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), target
            );
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getActualsSubChannel(Id loggedUser, String financialYear, Id accountId, String subChannel) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
       
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
       
        getActualValues(loggedUser, financialYear, accountId, subChannel, busUnitMonthSalesTarMap);
       
        return busUnitMonthSalesTarMap;
    }
   
    private static void getActualValues(ID loggedUser, String financialYear, Id accountId, String subChannel, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
       
        for(
            AggregateResult aggr :
            [select Business_Unit__r.Name, Month__c, SUM(Overall_Actuals__c) from Target_Config__c
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND Account__c =: accountId AND BDD__C =: loggedUser AND
             Sub_Channel__c =: subChannel AND Financial_Year__c =: financialYear AND BDD__C = :loggedUser group by Business_Unit__r.Name, Month__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
           
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), target
            );
        }
    }
   
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getVarianceBDM(Id loggedUser, String financialYear, Id accountId, String subChannel) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
       
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
       
        getVarianceValues(loggedUser, financialYear, accountId, subChannel, busUnitMonthSalesTarMap);
       
        return busUnitMonthSalesTarMap;
    }
   
    private static void getVarianceValues(Id loggedUser, String financialYear, Id accountId, String subChannel, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
       
        for(
            AggregateResult aggr :
            [select Business_Unit__r.Name, Month__c, SUM(Variance_Amount__c) from Target_Config__c
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND Account__c =: accountId  AND BDD__C =: loggedUser AND Sub_Channel__c =: subChannel AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
           
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), target
            );
        }
    }
   
    @AuraEnabled(Cacheable = true)
    public static List<String> getBusinessUnits(Id accountId) {
        Set<String> availableBUList = new Set<String>();
        List<String> businessUnitList = new List<String>();
       
        List<Account> accList = [Select Id,Authorized_Business_Units__c from Account WHERE Id =: accountId];
        if(!accList.isEmpty() && accList[0].Authorized_Business_Units__c != null) {
            businessUnitList = accList[0].Authorized_Business_Units__c.split(';');
        }
       
        for(Business_unit__c bu : [SELECT Id,name,Unique_Name__c FROM Business_unit__c WHERE Available_for_Target__c = true AND Unique_Name__c IN : businessUnitList ORDER BY Unique_Name__c ASC]) {
            availableBUList.add(bu.name);
        }
       
        return new List<String>(availableBUList);
    }
    
     @AuraEnabled
    Public static List<TargetCommitWrapper> downloadTargetCommitStats(Id accountId,Id selectedUser, String subChannel, String financialYear, String businessUnitName) {
        Set<Id> prdIds = new Set<Id>();
        Map<Id, Business_Unit__c> buMap = new Map<Id, Business_Unit__c>();
        List<Target_Commit_Stats__c> targetCommitList = new List<Target_Commit_Stats__c>();
        List<TargetCommitWrapper> targetCommitWrapperList = new List<TargetCommitWrapper>();
        Map<String, TargetCommitWrapper> monthPrdWrap = new Map<String, TargetCommitWrapper>();
        Map<Id, Decimal> productPriceMap = new Map<Id, Decimal>();
        
        
        List<Account> accList = [SELECT Id, XC_PricingGroup__c,OwnerId FROM Account WHERE Id =: accountId];
        if(accList.isEmpty()) {
            throw new AuraHandledException('Account is Empty');
        }
        
        if(businessUnitName != '' && businessUnitName != null){
            for (Business_Unit__c bu : [SELECT ID, Unique_Name__c FROM Business_Unit__c WHERE Unique_Name__c =: businessUnitName]){
                buMap.put(bu.Id, bu);
            }
        }
        Id priceBookId;
        
        for(
            BuyerGroup bgroup :
            [SELECT Id, (SELECT PriceBook2Id FROM BuyerGroupPricebooks WHERE IsActive = true AND PriceBook2.Name =: accList[0].XC_PricingGroup__c LIMIT 1) FROM BuyerGroup
             WHERE Id IN (SELECT BuyerGroupId FROM BuyerGroupMember where BuyerId =: accountId)]
        ) {
            if(!bgroup.BuyerGroupPricebooks.isEmpty()) {
                priceBookId = bgroup.BuyerGroupPricebooks[0].PriceBook2Id;
            }
        }
        
        if(businessUnitName == '' || businessUnitName == null){
            targetCommitList =[Select Id,Account__c,BDM__c,Product__c,Finish__c,SKU__c,Product_Business_Unit__c,Description__c, Jan__c, May__c, Dec__c, Nov__c, Oct__c, Sep__c,
                               Aug__c, Feb__c, Jul__c, Jun__c,Mar__c, Apr__c,IsUpload__c, Product__r.Start_Date__c,Non_Available_Product__c from Target_Commit_Stats__c  
                               WHERE IsUpload__c = false AND Product__r.Available_for_commitment__c = True AND Financial_Year__c =: financialYear AND Account__c =: accountId AND BDM__c =: selectedUser 
                               ORDER BY Product_Business_Unit__c ASC];
        }
        else{
            targetCommitList =[Select Id,Account__c,BDM__c,Product__c,Finish__c,SKU__c,Product_Business_Unit__c,Description__c, Jan__c, May__c, Dec__c, Nov__c, Oct__c, Sep__c,
                               Aug__c, Feb__c, Jul__c, Jun__c,Mar__c, Apr__c,IsUpload__c, Business_Unit__c, Product__r.Start_Date__c,Non_Available_Product__c from Target_Commit_Stats__c  
                               WHERE IsUpload__c = false AND Product__r.Available_for_commitment__c = True AND Financial_Year__c =: financialYear AND Account__c =: accountId
                               AND BDM__c =: selectedUser  AND Business_Unit__c IN: buMap.keySet()
                               ORDER BY Product_Business_Unit__c ASC];
        }
        
        for (Target_Commit_Stats__c targetCommit : targetCommitList) {
            prdIds.add(targetCommit.Product__c);
            
            TargetCommitWrapper targetCommitWrapper = new TargetCommitWrapper();
            targetCommitWrapper.productId =  targetCommit.Product__c;
            targetCommitWrapper.targetCommitId = targetCommit.Id;
            targetCommitWrapper.productCode = targetCommit.SKU__c ;
            targetCommitWrapper.finish = targetCommit.Finish__c;
            targetCommitWrapper.description = targetCommit.Description__c;
            targetCommitWrapper.businessUnit = targetCommit.Product_Business_Unit__c ;
            targetCommitWrapper.January = targetCommit.Jan__c;
            targetCommitWrapper.February = targetCommit.Feb__c;
            targetCommitWrapper.March = targetCommit.Mar__c;
            targetCommitWrapper.April = targetCommit.Apr__c ;
            targetCommitWrapper.May = targetCommit.May__c;
            targetCommitWrapper.June = targetCommit.Jun__c ;
            targetCommitWrapper.July = targetCommit.Jul__c;
            targetCommitWrapper.August = targetCommit.Aug__c ;
            targetCommitWrapper.September = targetCommit.Sep__c;
            targetCommitWrapper.October = targetCommit.Oct__c ;
            targetCommitWrapper.November = targetCommit.Nov__c;
            targetCommitWrapper.December = targetCommit.Dec__c;
            targetCommitWrapper.unitPrice = 0;
            targetCommitWrapper.startDate = targetCommit.Product__r.Start_Date__c;
            targetCommitWrapper.nonAvailableProduct = targetCommit.Non_Available_Product__c;
            
            targetCommitWrapperList.add(targetCommitWrapper);            
        }
        
        if(priceBookId == null) {
            return targetCommitWrapperList;
        }
        
        for (PricebookEntry pbEntry : [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :priceBookId AND Product2Id IN :prdIds]) {
            productPriceMap.put(pbEntry.Product2Id, pbEntry.UnitPrice);
        }
        
        for (TargetCommitWrapper prd : targetCommitWrapperList) {
            if (productPriceMap.containsKey(prd.productId)) {
                prd.unitPrice = productPriceMap.get(prd.productId);
            }
        }
        return targetCommitWrapperList;
    }
    
    @AuraEnabled
    Public static void updateTargetCommit(List<Target_Commit_Stats__c> targetCommitList) {
        Set<String> businessUnitUniqueNames = new Set<String>();
   		Set<String> productSKUs = new Set<String>();
        Map<String,Id> busUnitMap = new Map<String,Id>();
        Map<String, Id> prodMap = new Map<String,Id>();
        
        for (Target_Commit_Stats__c tcStats : targetCommitList) {
            businessUnitUniqueNames.add(tcStats.Product_Business_Unit__c);
            productSKUs.add(tcStats.Product_SKU__c);
        }
        
        for (Business_Unit__c busUnit : [SELECT Id, Unique_Name__c FROM Business_Unit__c WHERE Unique_Name__c IN :businessUnitUniqueNames]) {
            busUnitMap.put(busUnit.Unique_Name__c, busUnit.Id);
        }
        
        for (Product2 prd : [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :productSKUs]) {
            prodMap.put(prd.StockKeepingUnit, prd.Id);
        }
        
        for (Target_Commit_Stats__c tcStats : targetCommitList) {
            if (busUnitMap.containsKey(tcStats.Product_Business_Unit__c)) {
                tcStats.Business_Unit__c = busUnitMap.get(tcStats.Product_Business_Unit__c);
            }
            if (prodMap.containsKey(tcStats.Product_SKU__c)) {
                tcStats.Product__c = prodMap.get(tcStats.Product_SKU__c);
            }
        }
        
        try{
            Insert targetCommitList;
            if(targetCommitList.size() < 5000){
                ProcessTargetCommitRecords batch  = new ProcessTargetCommitRecords();
                Database.executeBatch(batch);
            }           	
        }
        catch(DmlException e){
            System.debug('Error==>'+e.getMessage());
        }
    }

    
    
    
      public class BDMAccount {
        @AuraEnabled
        public Id userId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String accId {get; set;}
        @AuraEnabled
        public Decimal actualAmount {get; set;}
        @AuraEnabled
        public Decimal targetAmount {get; set;}
        @AuraEnabled
        public Decimal varianceAmount {get; set;}
        @AuraEnabled
        public Decimal actual {get; set;}
        @AuraEnabled
        public Decimal target {get; set;}
        @AuraEnabled
        public Decimal variance {get; set;}
       
        public BDMAccount(Id userId, String name, String accId, Decimal actualAmount,Decimal targetAmount,Decimal varianceAmount,Decimal actual, Decimal target, Decimal variance) {
            this.userId = userId;
            this.name = name;
            this.accId = accId;
            this.actualAmount = actualAmount;
            this.targetAmount = targetAmount;
            this.varianceAmount = varianceAmount;
            this.actual = actual;
            this.target = target;
            this.variance =variance;
        }
          
    }
    
    public class TargetCommitWrapper {
        @AuraEnabled
        public Id targetCommitId { get; set; }
        @AuraEnabled
        public Id productId { get; set; }
        @AuraEnabled
        public String productCode { get; set; }
        @AuraEnabled
        public String finish { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String businessUnit { get; set; }
        @AuraEnabled
        public Decimal January { get; set; }
        @AuraEnabled
        public Decimal February { get; set; }
        @AuraEnabled
        public Decimal March { get; set; }
        @AuraEnabled
        public Decimal April { get; set; }
        @AuraEnabled
        public Decimal May { get; set; }
        @AuraEnabled
        public Decimal June { get; set; }
        @AuraEnabled
        public Decimal July { get; set; }
        @AuraEnabled
        public Decimal August { get; set; }
        @AuraEnabled
        public Decimal September { get; set; }
        @AuraEnabled
        public Decimal October { get; set; }
        @AuraEnabled
        public Decimal November { get; set; }
        @AuraEnabled
        public Decimal December { get; set; }
        @AuraEnabled
        public Decimal unitPrice { get; set; }
        @AuraEnabled
        public Date startDate { get; set; }
        @AuraEnabled
        public boolean nonAvailableProduct{ get;set; }
    }
    
}