public class SPMController {
    
    @AuraEnabled(cacheable=true)
    public static List<Hierarchy_Config__c> getUserInfo(Id currentUser) {
        return [SELECT ID, Name, User__c, User__r.Name, Role__c, Manager__c FROM Hierarchy_Config__c WHERE User__c =: currentUser];
    }
    
    @AuraEnabled(Cacheable = true)
    Public static Boolean prepareBDMStats(Id currentUser, String financialYear) {
        return true;
    }
    
    @AuraEnabled
    public static List<BDMActuals> getBDMStats(Id currentUser, String financialYear) {
        Map<Id, BDMActuals> BDMActualsMap = new Map<Id, BDMActuals>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            Hierarchy_Config__c hConfig : 
            [SELECT  Id,User__c,User__r.Name, User__r.FullPhotoUrl, Manager__c FROM Hierarchy_Config__c 
             WHERE Manager__c = : currentUser AND Role__c = 'BDM']
        ) {
            BDMActualsMap.put(
                hConfig.User__c,  
                new BDMActuals(hConfig.User__c, hConfig.user__r.name, hConfig.user__r.FullPhotoUrl,0,0,0,0,0,0)
            );
        }
        
        for(
            AggregateResult aggr : 
            [SELECT BDM__c,CurrencyISOCode, SUM(Target__c) FROM Target_Config__c WHERE BDD__c =: currentUser 
             AND Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             Financial_Year__c =: financialYear AND BDM__c IN : BDMActualsMap.keySet() GROUP BY BDM__c,CurrencyISOCode]
        ) {
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal target = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            target = target.setScale(2, System.RoundingMode.HALF_UP);
            Id BDMId = (Id) aggr.get('BDM__c');
            
            if(BDMActualsMap.containsKey(BDMId)) {
                BDMActualsMap.get(BDMId).targetAmount = target;
            }
        }
        
        for(
            AggregateResult aggr : 
            [SELECT BDM__c,CurrencyISOCode, SUM(Actual_Amount__c) FROM SPM_Stats__c WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND Financial_Year__c =: financialYear AND BDM__c IN : BDMActualsMap.keySet() GROUP BY BDM__c,CurrencyISOCode]
        ) {
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal actual = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            actual = actual.setScale(2, System.RoundingMode.HALF_UP);
            Id BDMId = (Id) aggr.get('BDM__c');
            
            if(BDMActualsMap.containsKey(BDMId)) {
                BDMActualsMap.get(BDMId).actualAmount = actual;
            }  
        }
        
        for(
            AggregateResult aggr : 
            [SELECT BDM__c,CurrencyISOCode, SUM(Variance_Amount__c) FROM Target_Config__c WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND Financial_Year__c =: financialYear AND BDM__c IN : BDMActualsMap.keySet() GROUP BY BDM__c,CurrencyISOCode]
        ) {
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal variance = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            variance = variance.setScale(2, System.RoundingMode.HALF_UP);
            Id BDMId = (Id) aggr.get('BDM__c');
            
            if(BDMActualsMap.containsKey(BDMId)) {
                BDMActualsMap.get(BDMId).varianceAmount = variance;
            }
        }  
        return BDMActualsMap.values();
    }
    
    @AuraEnabled
    public static List<BDDActuals> getBDDStats(String financialYear) {
        Map<Id, BDDActuals> BDDActualsMap = new Map<Id, BDDActuals>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>(); 
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            Hierarchy_Config__c hConfig : 
            [SELECT  Id,User__c,User__r.Name, User__r.FullPhotoUrl, Manager__c FROM Hierarchy_Config__c 
             WHERE Role__c = 'BDD' ]
        ) {
            BDDActualsMap.put(
                hConfig.User__c,  
                new BDDActuals(hConfig.User__c, hConfig.user__r.name, hConfig.user__r.FullPhotoUrl,0,0,0,0,0,0)
            );
        }
        
        for(
            AggregateResult aggr : 
            [SELECT BDD__c, CurrencyISOCode,SUM(Target__c) FROM Target_Config__c WHERE 
             Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             Financial_Year__c =: financialYear AND BDD__c IN : BDDActualsMap.keySet() GROUP BY BDD__c,CurrencyISOCode]
        ) {
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal target = (Decimal) aggr.get('expr0') * currTypeMap.get(UserInfo.getDefaultCurrency());
            target = target.setScale(2, System.RoundingMode.HALF_UP);
            Id BDDId = (Id) aggr.get('BDD__c');
            
            if(BDDActualsMap.containsKey(BDDId)) {
                BDDActualsMap.get(BDDId).targetAmount = target;
            }
        }
        
        for(
            AggregateResult aggr : 
            [SELECT BDD__c, SUM(Actual_Amount__c) FROM SPM_Stats__c WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             Financial_Year__c =: financialYear AND BDD__c IN : BDDActualsMap.keySet() GROUP BY BDD__c]
        ) {
            Decimal actuals = (Decimal) aggr.get('expr0') * currTypeMap.get(UserInfo.getDefaultCurrency());
            Id BDDId = (Id) aggr.get('BDD__c');
            
            if(BDDActualsMap.containsKey(BDDId)) {
                BDDActualsMap.get(BDDId).actualAmount = actuals;
            }  
        }
        
        for(
            AggregateResult aggr : 
            [SELECT BDD__c,CurrencyISOCode, SUM(Variance_Amount__c) FROM Target_Config__c WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             Financial_Year__c =: financialYear AND BDD__c IN : BDDActualsMap.keySet() GROUP BY BDD__c,CurrencyISOCode]
        ) {
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal variance = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            variance = variance.setScale(2, System.RoundingMode.HALF_UP);
            Id BDDId = (Id) aggr.get('BDD__c');
            
            if(BDDActualsMap.containsKey(BDDId)) {
                BDDActualsMap.get(BDDId).varianceAmount = variance;
            }
        }  
        return BDDActualsMap.values();
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetBDM(String financialYear,Id currentUser,Id selectedUser) {
        return getBDMTargetData(financialYear, currentUser, selectedUser);
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getBDMTargetData(String financialYear,Id currentUser,Id selectedUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = True ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        getTargetValues(financialYear, currentUser, selectedUser, busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
    private static void getTargetValues(String financialYear,Id currentUser,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, Month__c,CurrencyISOCode, SUM(Target__c) from Target_Config__c 
             where Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = True AND BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
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
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getActualsBDM(String financialYear,Id currentUser,Id selectedUser) {
        return getBDMActualData(financialYear, currentUser, selectedUser); //, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getBDMActualData(String financialYear,Id currentUser,Id selectedUser) {
        
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = True ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        getActualValues(financialYear, currentUser, selectedUser, busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;        
    }
    
    
    private static void getActualValues(String financialYear,Id currentUser,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [select Business_Unit__r.Name, Month__c,CurrencyISOCode, SUM(Actual_Amount__c) from SPM_Stats__c 
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c,CurrencyISOCode]
        ) { 
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal actual = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            actual = actual.setScale(2, System.RoundingMode.HALF_UP);
            
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), actual
            );
        }
    }
    
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getVarianceBDM(String financialYear,Id currentUser,Id selectedUser) {
        return getVarianceBDMData(financialYear, currentUser, selectedUser);
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getVarianceBDMData(String financialYear,Id currentUser,Id selectedUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = True ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        getVarianceValues(financialYear, currentUser, selectedUser, busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
    private static void getVarianceValues(String financialYear,Id currentUser,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [select Business_Unit__r.Name, Month__c,CurrencyISOCode, SUM(Variance_Amount__c) from Target_Config__c 
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c,CurrencyISOCode]
        ) { 
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal variance = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            variance = variance.setScale(2, System.RoundingMode.HALF_UP);
            
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), variance
            );
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetQuatBDM(String financialYear,Id currentUser,Id selectedUser) {
        
        Set<String> monthSet = new Set<String>{'Q1','Q2','Q3','Q4'};
            Map<String, Map<String, Decimal>> busUnitMonthTarMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c WHERE Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, Quarterly_Type__c,CurrencyISOCode, SUM(Target__c) FROM Target_Config__c  
             WHERE Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             GROUP BY Business_Unit__r.Name, Quarterly_Type__c,CurrencyISOCode]
        ) { 
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal target = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            target = target.setScale(2, System.RoundingMode.HALF_UP);
            
            busUnitMonthTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Quarterly_Type__c'), target
            );
        }
        return busUnitMonthTarMap;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getActualQuatBDM(String financialYear,Id currentUser,Id selectedUser) {
        Set<String> monthSet = new Set<String>{'Q1','Q2','Q3','Q4'};
            Map<String, Map<String, Decimal>> busUnitMonthTarMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c WHERE Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, Quarterly_Type__c,CurrencyISOCode, SUM(Actual_Amount__c) FROM SPM_Stats__c    
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             GROUP BY Business_Unit__r.Name, Quarterly_Type__c,CurrencyISOCode]
        ) { 
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal actual = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            actual = actual.setScale(2, System.RoundingMode.HALF_UP);
            
            busUnitMonthTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Quarterly_Type__c'), actual
            );
        }
        return busUnitMonthTarMap;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getVarianceQuatBDM(String financialYear,Id currentUser,Id selectedUser) {
        
        Set<String> monthSet = new Set<String>{'Q1','Q2','Q3','Q4'};
            Map<String, Map<String, Decimal>> busUnitMonthTarMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c WHERE Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, Quarterly_Type__c,CurrencyISOCode,  SUM(Variance_Amount__c) FROM Target_Config__c        
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             GROUP BY Business_Unit__r.Name, Quarterly_Type__c,CurrencyISOCode]
        ) { 
            String currencyIsoCode = (String)aggr.get('CurrencyISOCode');
            Decimal variance = (Decimal) aggr.get('expr0') * currTypeMap.get(currencyIsoCode);
            variance = variance.setScale(2, System.RoundingMode.HALF_UP);
            
            busUnitMonthTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Quarterly_Type__c'), variance
            );
        }
        return busUnitMonthTarMap;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String,Object> getYearlyStatsBDM(String financialYear, Id currentUser, Id selectedUser) {
        
        Map<String, Object> busUnitStatsMap = new Map<String, Object>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();
        Map<String, Decimal> targetMap = new Map<String, Decimal>();
        Map<String, Decimal> actualMap = new Map<String, Decimal>();
        Map<String, Decimal> openActualMap = new Map<String, Decimal>();
        Map<String, Decimal> varianceMap = new Map<String, Decimal>();
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);   
        }
        
        for(Business_Unit__c busUnit : [SELECT Id, Unique_Name__c from Business_Unit__c WHERE Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            busUnitStatsMap.put(busUnit.Unique_Name__c, new Map<String, Object>());
        }
         
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, SUM(Target__c) FROM Target_Config__c  
             WHERE Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             GROUP BY Business_Unit__r.Name]
        ) { 
            targetMap.put((String)aggr.get('Name'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, SUM(Actual_Amount__c) FROM SPM_Stats__c    
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             GROUP BY Business_Unit__r.Name]
        ) { 
            actualMap.put((String) aggr.get('Name'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, SUM(Open_Actual_Amount__c) FROM SPM_Stats__c    
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             GROUP BY Business_Unit__r.Name]
        ) { 
            openActualMap.put((String) aggr.get('Name'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name,  SUM(Variance_Amount__c) FROM Target_Config__c        
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             GROUP BY Business_Unit__r.Name]
        ) { 
            varianceMap.put((String) aggr.get('Name'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for (String key : busUnitStatsMap.keySet()) {
            Map<String, Object> values = new Map<String, Object>();
            values.put('Target', targetMap.get(key) != null ? targetMap.get(key) : 0);
            values.put('Actual', actualMap.get(key) != null ? actualMap.get(key): 0);
            values.put('OpenActual', actualMap.get(key) != null ? openActualMap.get(key): 0);
            values.put('Variance', varianceMap.get(key) != null ? varianceMap.get(key): 0);
            
            busUnitStatsMap.put(key, values);                    
        }
        return busUnitStatsMap;                
    }
    
    
    @AuraEnabled
    public static void saveBDMTargets(Id bddId, Id bdmId, String financialYear, List<Map<String, Object>> updatedRecords,Boolean isAcknowledge) {
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
        
      for (Target_Acknowledgement__c tAcknowledge : [SELECT Id, BDD__c, BDM__c, Status__c, Comments__c FROM Target_Acknowledgement__c WHERE BDD__c = :bddId AND BDM__c = :bdmId AND Financial_Year__c = :financialYear]) {
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
             AND Financial_Year__c =: financialYear AND BDM__c =: bdmId GROUP BY Business_Unit__r.Name, Month__c]
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
             Business_Unit__r.Name IN : busUnitTargetMap.keySet() AND Financial_Year__c =: financialYear AND BDM__c =: bdmId]
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
            List<Account> accList = [SELECT Id FROM Account WHERE OwnerId =: bdmId];
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
                            BDM__c = bdmId,
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
    
     @AuraEnabled
    public static String acknowledgementStatus(Id bddId, Id bdmId, String financialYear) {
        String status = '';
        List<Target_Acknowledgement__c> tAcknowledgeList = [SELECT Status__c FROM Target_Acknowledgement__c 
                                                            WHERE BDD__c = :bddId AND BDM__c = :bdmId AND Financial_Year__c = :financialYear]; 
        if (!tAcknowledgeList.isEmpty()) {
            status = tAcknowledgeList[0].Status__c;
        }  
        return status;
    }
    
    @AuraEnabled
    public static List<HistoryWrapper> ackHistoryData(Id currentUser, Id selectedUser, String financialYear) {
        List<HistoryWrapper> historyList = new List<HistoryWrapper>();
        
        List<Target_Acknowledgement_History__c> historyRecords = [SELECT Status__c, Comments__c, CreatedDate FROM Target_Acknowledgement_History__c
                                                                WHERE Target_Acknowledgement__r.BDD__c =: currentUser AND
                                                              	Target_Acknowledgement__r.BDM__c =:selectedUser AND
                                                                Target_Acknowledgement__r.Financial_Year__c =:financialYear ORDER BY CreatedDate Desc];
        
        
        
        for(Target_Acknowledgement_History__c record : historyRecords){
            
            String recComments = String.valueOf(record.Comments__c);
            String recStatus = String.valueOf(record.Status__c);
            Datetime recCreDate = Datetime.valueOf(record.CreatedDate);
            
           // Datetime newCreDate = recCreDate.addYears(1);
            
            HistoryWrapper historyWrap = new HistoryWrapper(
                recComments,recStatus,recCreDate
            );
            historyList.add(historyWrap);
        }
        return historyList;
    }

    
    public class HistoryWrapper {
        @AuraEnabled
        public String comments {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public DateTime createdDate {get; set;}
        
        public HistoryWrapper(String comments,String status,DateTime createdDate) {
            this.comments = comments;
            this.status = status;
            this.createdDate = createdDate;
        }
    }
    
    public static Decimal convertToEUR(Decimal valueInUSD) {
        Decimal conversionRate = 0.85;
        return valueInUSD * conversionRate;
    }
    
    public class BDMActuals {
        @AuraEnabled
        public Id userId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String url {get; set;}
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
        
        public BDMActuals(Id userId, String name, String url, Decimal actualAmount,Decimal targetAmount,Decimal varianceAmount, Decimal actual, Decimal target, Decimal variance) {
            this.userId = userId;
            this.name = name;
            this.url = url;
            this.actualAmount = actualAmount;
            this.targetAmount = targetAmount;
            this.varianceAmount = varianceAmount;
            this.actual = actual;
            this.target = target;
            this.variance =variance;
        }
    }
    
    public class BDDActuals {
        @AuraEnabled
        public Id userId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String url {get; set;}
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
        
        public BDDActuals(Id userId, String name, String url, Decimal actualAmount,Decimal targetAmount,Decimal varianceAmount, Decimal actual, Decimal target, Decimal variance) {
            this.userId = userId;
            this.name = name;
            this.url = url;
            this.actualAmount = actualAmount;
            this.targetAmount = targetAmount;
            this.varianceAmount = varianceAmount;
            this.actual = actual;
            this.target = target;
            this.variance =variance;
        }
    }
    
}