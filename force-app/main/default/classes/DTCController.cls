public class DTCController {
    @AuraEnabled(cacheable=true)
    public static List<Hierarchy_Config__c> getUserInfo(Id currentUser) {
        return [SELECT ID, Name, User__c, User__r.Name, Role__c, Manager__c FROM Hierarchy_Config__c WHERE User__c =: currentUser];
    }
    
    @AuraEnabled
    public static Map<String, Object> getDTCStats(String selYear) {
        String prevYear = 'FY-'+String.valueOf(Integer.valueOf(selYear.substring(3)) - 1);
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>(); 
        Map<Id,Id> AccountMap = new map<Id,Id>();
        
        for (Account acc : [Select id,ownerId from account where XC_Channel__c = 'DTC']){
            AccountMap.put(acc.ownerId,acc.id);
        }
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        AggregateResult agrResult = [SELECT CurrencyIsoCode,SUM(Target__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND account__r.XC_Channel__c = 'DTC' 
                                     GROUP BY CurrencyIsoCode]; // BDD__c =: UserInfo.getUserId()
        system.debug('agrResult'+ agrResult);
        String currencyIsoCode = (String)agrResult.get('CurrencyISOCode');
        Decimal curYearTarget = (Decimal) agrResult.get('totalAmount') * currTypeMap.get(currencyIsoCode);
        curYearTarget = curYearTarget.setScale(2, System.RoundingMode.HALF_UP);
        curYearTarget = curYearTarget != null ? curYearTarget : 0;
        
        agrResult = [SELECT SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND account__r.XC_Channel__c = 'DTC'];
        Decimal curYearActual = (Decimal) agrResult.get('totalAmount');
        curYearActual = curYearActual != null ? curYearActual : 0;
        
        agrResult = [SELECT currencyIsoCode,SUM(Variance_Amount__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND account__r.XC_Channel__c = 'DTC'
                     GROUP BY CurrencyIsoCode];
        String currencyIsoCodeVar = (String)agrResult.get('CurrencyISOCode');
        Decimal curYearVariance = (Decimal) agrResult.get('totalAmount') * currTypeMap.get(currencyIsoCodeVar);
        curYearVariance = curYearVariance.setScale(2, System.RoundingMode.HALF_UP);
        curYearVariance = curYearVariance != null ? curYearVariance : 0;
        
        agrResult = [SELECT SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: prevYear AND account__r.XC_Channel__c = 'DTC'];
        Decimal prevYearActual = (Decimal) agrResult.get('totalAmount');
        prevYearActual = prevYearActual != null ? prevYearActual : 0;
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('prevYear', prevYear);
        result.put('curYearTarget', curYearTarget);
        result.put('curYearActual', curYearActual);
        result.put('prevYearActual', prevYearActual);
        result.put('curYearVariance', curYearVariance);
        
        return result;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String,Object> getSubChannelStats(String financialYear, Id currentUser, Boolean isBDM) {
        
        Map<String, Object> accMap = new Map<String, Object>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();
        Map<String, Decimal> targetMap = new Map<String, Decimal>();
        Map<String, Decimal> actualMap = new Map<String, Decimal>();
        Map<String, Decimal> varianceMap = new Map<String, Decimal>();
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);   
        }        
        if(isBDM){
            
            for(Account acc : [Select Sub_Channel__c from account where XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND OwnerId = :currentUser]) {
                accMap.put(acc.Sub_Channel__c, new Map<String, Object>());
            }
            
            for(
                AggregateResult aggr : 
                [SELECT Sub_Channel__c, SUM(Target__c) FROM Target_Config__c  
                 WHERE Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = True AND 
                 BDM__c =: currentUser AND Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear
                 GROUP BY Sub_Channel__c]
            ) { 
                targetMap.put((String)aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
            }
            
            for(
                AggregateResult aggr : 
                [SELECT Sub_Channel__c, SUM(Actual_Amount__c) FROM SPM_Stats__c    
                 WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
                 BDM__c =: currentUser AND Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear
                 GROUP BY Sub_Channel__c]
            ) { 
                actualMap.put((String) aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
            }
            
            for(
                AggregateResult aggr : 
                [SELECT Sub_Channel__c,  SUM(Variance_Amount__c) FROM Target_Config__c        
                 WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
                 BDM__c =: currentUser AND  Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear
                 GROUP BY Sub_Channel__c]
            ) { 
                varianceMap.put((String) aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
            }
        }
        else{
            
            for(Account acc : [Select Sub_Channel__c from account where XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL]) {
                accMap.put(acc.Sub_Channel__c, new Map<String, Object>());
            }
            for(
                AggregateResult aggr : 
                [SELECT Sub_Channel__c, SUM(Target__c) FROM Target_Config__c  
                 WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
                 BDD__c =: currentUser AND Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear
                 GROUP BY Sub_Channel__c]
            ) { 
                targetMap.put((String)aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
            }
            
            for(
                AggregateResult aggr : 
                [SELECT Sub_Channel__c, SUM(Actual_Amount__c) FROM SPM_Stats__c    
                 WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
                 BDD__c =: currentUser AND Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear
                 GROUP BY Sub_Channel__c]
            ) { 
                actualMap.put((String) aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
            }
            
            for(
                AggregateResult aggr : 
                [SELECT Sub_Channel__c,  SUM(Variance_Amount__c) FROM Target_Config__c        
                 WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
                 BDD__c =: currentUser AND  Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear
                 GROUP BY Sub_Channel__c]
            ) { 
                varianceMap.put((String) aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
            }
        }
        
        for (String key : accMap.keySet()) {
            Map<String, Object> values = new Map<String, Object>();
            values.put('Target', targetMap.get(key) != null ? targetMap.get(key) : 0);
            values.put('Actual', actualMap.get(key) != null ? actualMap.get(key): 0);
            values.put('Variance', varianceMap.get(key) != null ? varianceMap.get(key): 0);
            
            accMap.put(key, values);                    
        }
        
        return accMap;                
    }
    
    @AuraEnabled(cacheable=true)
    public static String getBDMTargetDist(Id currentUser, String financialYear, String prevFinancialYear) {
        Decimal DBBTarget = 0;
        String currencyVal = 'USD';
        String prevFYCurrencyVal = 'USD';
        
        Map<String, BDMTargetDist> BDMTargetDistMap = new Map<String, BDMTargetDist>();
        for(Account acc : [SELECT Id, ownerId, sub_channel__c, XC_Channel__c FROM Account WHERE XC_Channel__c = 'DTC' AND sub_channel__c != null]) {
            BDMTargetDistMap.put(acc.sub_channel__c, new BDMTargetDist(acc.Id, acc.sub_channel__c,acc.XC_Channel__c, 0));
        }
        
        for(Target_Distribution__c targetDist : [SELECT Id, Allocated_Percentage__c, BDM__c, CurrencyIsoCode, Sub_channel__c FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND BDD__c =: currentUser AND Sub_channel__c IN : BDMTargetDistMap.keySet()]) {
            currencyVal = targetDist.CurrencyIsoCode;
            BDMTargetDistMap.get(targetDist.sub_channel__c).disPercent = targetDist.Allocated_Percentage__c;
        }
        
        List<Target_Distribution__c> targetDistList = [SELECT Id, Overall_Target__c FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND BDD__c =: currentUser AND Overall_Target__c > 0];
        
        if(!targetDistList.isEmpty()) {
            DBBTarget = targetDistList[0].Overall_Target__c;
        }
        
        List<SPM_Stats__c> actualList = [SELECT CurrencyIsoCode FROM SPM_Stats__c WHERE BDD__c =: currentUser AND Financial_Year__c =: prevFinancialYear LIMIT 1];
        if(!actualList.isEmpty()) {
            prevFYCurrencyVal = actualList[0].CurrencyIsoCode;
        }
        system.debug('BDMTargetDistMap.values()===>'+BDMTargetDistMap.values());
        return '{"currencyVal" : "'+currencyVal+'","prevFYCurrencyVal" : "'+prevFYCurrencyVal+'","BDDTarget" : "'+DBBTarget+'", "BDMList" : '+JSON.serialize(BDMTargetDistMap.values())+'}';
    }
    
    @AuraEnabled
    public static Boolean saveBDMTargetConfigs(Id currentUser, Decimal BDDTarget, String financialYear, String BDMDistData, String currencyVal, List<String> bdmList) {
        List<Target_Distribution__c> targetDistList = new List<Target_Distribution__c>();
        Map<string, Target_Distribution__c> BDMTargetDistMap = new Map<string, Target_Distribution__c>();
        
        for(BDMTargetDist BDMTargetDist : (List<BDMTargetDist>) JSON.deserialize(BDMDistData, List<BDMTargetDist>.class)) {
            BDMTargetDistMap.put(
                BDMTargetDist.Name, 
                new Target_Distribution__c(
                    Financial_Year__c = financialYear, BDD__c = currentUser, BDM__c = currentUser, sub_channel__c = BDMTargetDist.Name,
                    Allocated_Percentage__c = BDMTargetDist.disPercent, CurrencyIsoCode = currencyVal
                )
            );
        }
        
        
        for(
            Target_Distribution__c targetDist : 
            [SELECT Id, Allocated_Percentage__c, BDM__c,sub_channel__c FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND 
             BDD__c =: currentUser  And BDM__c =: currentUser And channel__c = null]
        ) {
            if(BDMTargetDistMap.containsKey(targetDist.sub_channel__c)) {
                BDMTargetDistMap.get(targetDist.sub_channel__c).Id = targetDist.Id;
            }
        }
        
        List<Target_Distribution__c> BDDTargetDistList = [SELECT Id, Overall_Target__c FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND BDD__c =: currentUser AND BDD__c =: currentUser And Overall_Target__c != null And channel__c = 'DTC'];
        if(!BDDTargetDistList.isEmpty()) {
            BDDTargetDistList[0].Overall_Target__c = BDDTarget;
            BDDTargetDistList[0].CurrencyIsoCode = currencyVal;
            targetDistList.add(BDDTargetDistList[0]);
        }
        
        else {
            targetDistList.add(new Target_Distribution__c(Financial_Year__c =financialYear , BDD__c=currentUser,BDM__c=currentUser, Overall_Target__c=BDDTarget,CurrencyIsoCode = currencyVal,channel__c = 'DTC'));
        }
        
        if(!BDMTargetDistMap.keyset().isEmpty()) {
            system.debug('BDMTargetDistMap==>'+BDMTargetDistMap);
            targetDistList.addAll(BDMTargetDistMap.values());
        }
        
        if(!targetDistList.isEmpty()) {
            upsert targetDistList;
            updateBDMTargets(currentUser, financialYear, BDDTarget, BDMTargetDistMap, currencyVal);
            //if(!Test.isRunningTest()){
            // UpdateSubchannelBatch myBatch = new UpdateSubchannelBatch(currentUser, financialYear, BDDTarget, null, currencyVal,bdmList);
            //Database.executeBatch(myBatch, 1);
            //}
            return true;
        }
        return false;
    }
    
    public static void updateBDMTargets(Id currentUser, String financialYear, Decimal BDDTarget, Map<String, Target_Distribution__c> BDMTargetDistMap, String currencyVal) {
        Map<String, Decimal> BDMActualsMap = new Map<String, Decimal>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();
        Map<Id, Decimal> missingBDMActualsMap = new Map<Id, Decimal>();
        Map<String, Target_Config__c> targetMap = new Map<String, Target_Config__c>();
        Map<String, Order_Commitment__c> orderCommitMap = new Map<String, Order_Commitment__c>();
        Map<String, Pending_Targets__c> pendingJobMap = new Map<String, Pending_Targets__c>();
        
        String prevYear = 'FY-'+String.valueOf(Integer.valueOf(financialYear.substring(3)) - 1);
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT sub_channel__c, SUM(Actual_Amount__c) totalAmount FROM SPM_Stats__c WHERE Financial_Year__c =: prevYear AND BDD__c =: currentUser AND sub_channel__c IN : BDMTargetDistMap.keySet() And Actual_Amount__c > 0 GROUP BY sub_channel__c]
        ) {
            string BDMId = (string) aggr.get('sub_channel__c');
            Decimal actualsAchieved = (Decimal) aggr.get('totalAmount') * currTypeMap.get(currencyVal);
            Decimal targetCal = BDDTarget * (BDMTargetDistMap.get(BDMId).Allocated_Percentage__c / 100);
            Decimal computeIncrease = ((targetCal - actualsAchieved) / actualsAchieved);
            BDMActualsMap.put(BDMId, computeIncrease);
            
        }
        
        for(SPM_Stats__c actual : [SELECT Id, Financial_Year__c, Month__c, Account__c, Business_Unit__c, BDD__c, BDM__c, Actual_Amount__c,sub_channel__c FROM SPM_Stats__c
                                   WHERE Financial_Year__c =: prevYear AND BDD__c =: currentUser AND sub_channel__c IN : BDMActualsMap.keySet() AND BDM__c =: currentUser ])
        { 
            Decimal finalTarget = (BDMActualsMap.get(actual.sub_channel__c) * actual.Actual_Amount__c) + actual.Actual_Amount__c;
            
            if(currTypeMap.containsKey(currencyVal)) {
                finalTarget = (BDMActualsMap.get(actual.sub_channel__c) * actual.Actual_Amount__c * currTypeMap.get(currencyVal)) + (actual.Actual_Amount__c * currTypeMap.get(currencyVal));
            }
            
            String key = financialYear + '-' + String.valueOf(actual.BDD__c).substring(0, 15) + '-' 
                + String.valueOf(actual.BDM__c).substring(0, 15) + '-' + String.valueOf(actual.Account__c).substring(0, 15) + '-' 
                + String.valueOf(actual.Business_Unit__c).substring(0, 15) + '-' 
                + actual.Month__c;
            
            if(targetMap.containsKey(key)) {
                finalTarget += targetMap.get(key).Target__c;
            }
            
            
            targetMap.put(key, new Target_Config__c(
                Financial_Year__c = financialYear, Month__c = actual.Month__c, Account__c = actual.Account__c,
                Business_Unit__c = actual.Business_Unit__c, BDD__c = actual.BDD__c, BDM__c = actual.BDM__c,sub_channel__c = actual.Sub_Channel__c,
                Target__c = finalTarget, Level__c='BDM', CurrencyIsoCode = currencyVal,Year_Stats__c = 'a2V02000000QRTPEA4'
            ));
        }
        
        
        
        if(!targetMap.keySet().isEmpty()) {
            for(Target_Config__c tConfig : [SELECT Id, Target_Key__c FROM Target_Config__c WHERE Target_Key__c IN : targetMap.keySet()]) {
                if(targetMap.containsKey(tConfig.Target_Key__c)) {
                    targetMap.get(tConfig.Target_Key__c).Id = tConfig.Id;
                }
            }
            Upsert targetMap.values();
        }
    }
    
    public class BDMTargetDist {
        @AuraEnabled
        public String userId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Decimal disPercent {get; set;}
        @AuraEnabled
        public string channel {get; set;}
        
        public BDMTargetDist(Id userId, String name,string channel, Decimal disPercent) {
            this.userId = userId;
            this.name = name;
            this.disPercent = disPercent;
            this.channel = channel;
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Object> getBDMstats(String selYear) {
        
        String currencyVal = 'USD';
        Decimal targetAchieved = 0;
        Map<Id,Id> AccountMap = new map<Id,Id>();
        
        for (Account acc : [Select id,ownerId from account where XC_Channel__c = 'DTC' and sub_channel__c != null]){
            AccountMap.put(acc.ownerId,acc.id);
        }
        
        AggregateResult agrResult = [SELECT SUm(Target__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId() AND Account__r.XC_Channel__c = 'DTC' AND Account__r.XC_AccountStatus__c ='Active' AND Sub_Channel__c != null];
        Decimal curYearTarget = (Decimal) agrResult.get('totalAmount');
        curYearTarget = curYearTarget != null ? curYearTarget : 0;
        
        agrResult = [SELECT SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c WHERE  Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId() AND Account__r.XC_Channel__c = 'DTC' AND Account__r.XC_AccountStatus__c ='Active' AND Sub_Channel__c != null];
        Decimal curYearActual = (Decimal) agrResult.get('totalAmount');
        curYearActual = curYearActual != null ? curYearActual : 0;
        
        agrResult = [SELECT SUM(Variance_Amount__c) totalAmount FROM Target_Config__c WHERE  Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId() AND Account__r.XC_Channel__c = 'DTC' AND Account__r.XC_AccountStatus__c ='Active' AND Sub_Channel__c != null];
        Decimal curYearvariance = (Decimal) agrResult.get('totalAmount');
        curYearvariance = curYearvariance != null ? curYearvariance : 0;
        
        agrResult = [SELECT COUNT(OwnerId) totalAmount FROM Account WHERE OwnerId =: UserInfo.getUserId() AND Authorized_Business_Units__c != NULL AND ParentId = NULL AND XC_AccountStatus__c = 'Active'];
        Decimal totalAccount = (Decimal) agrResult.get('totalAmount');
        totalAccount = totalAccount != null ? totalAccount : 0;
        
        if (curYearTarget != 0) {
            targetAchieved = (curYearActual/curYearTarget)*100;
            targetAchieved = targetAchieved != null ? targetAchieved : 0;
        }
        
        for(Target_Config__c tarConfig : [SELECT CurrencyIsoCode FROM Target_Config__c
                                          WHERE Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId()]){
                                              currencyVal = tarConfig.CurrencyIsoCode;      
                                          }
        Map<String, Object> result = new Map<String, Object>();
        
        result.put('curYearTarget', curYearTarget);
        result.put('curYearActual', curYearActual);
        result.put('curYearVariance', curYearvariance);
        result.put('totalAccount', totalAccount);
        result.put('targetAchieved', targetAchieved);  
        result.put('currencyVal', currencyVal);
        return result;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String,Object> getSubChannelBDMStats(String financialYear, Id currentUser) {
        
        Map<String, Object> accMap = new Map<String, Object>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();
        Map<String, Decimal> targetMap = new Map<String, Decimal>();
        Map<String, Decimal> actualMap = new Map<String, Decimal>();
        Map<String, Decimal> varianceMap = new Map<String, Decimal>();
        Map<Id,Id> AccountMap = new map<Id,Id>();
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);   
        }
        
        for(Account acc : [Select Sub_Channel__c from account where XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL]) {
            accMap.put(acc.Sub_Channel__c, new Map<String, Object>());
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Sub_Channel__c, SUM(Target__c) FROM Target_Config__c  
             WHERE Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear AND account__c = : AccountMap.get(UserInfo.getUserId())
             GROUP BY Sub_Channel__c]
        ) { 
            targetMap.put((String)aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Sub_Channel__c, SUM(Actual_Amount__c) FROM SPM_Stats__c    
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear AND account__c = : AccountMap.get(UserInfo.getUserId())
             GROUP BY Sub_Channel__c]
        ) { 
            actualMap.put((String) aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Sub_Channel__c,  SUM(Variance_Amount__c) FROM Target_Config__c        
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND  Account__r.XC_Channel__c = 'DTC' AND Sub_Channel__c != NULL AND Financial_Year__c =: financialYear AND account__c = : AccountMap.get(UserInfo.getUserId())
             GROUP BY Sub_Channel__c]
        ) { 
            varianceMap.put((String) aggr.get('Sub_Channel__c'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for (String key : accMap.keySet()) {
            Map<String, Object> values = new Map<String, Object>();
            values.put('Target', targetMap.get(key) != null ? targetMap.get(key) : 0);
            values.put('Actual', actualMap.get(key) != null ? actualMap.get(key): 0);
            values.put('Variance', varianceMap.get(key) != null ? varianceMap.get(key): 0);
            
            accMap.put(key, values);                    
        }
        return accMap;                
    }
    
    
}