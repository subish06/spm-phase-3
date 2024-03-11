public class DemoMonth {
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetBDM(String financialYear,Id currentUser,String selectedSubChannel) {
        return getBDMTargetData(financialYear, currentUser, selectedSubChannel);
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getBDMTargetData(String financialYear,Id currentUser,String selectedSubChannel) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = True ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        getTargetValues(financialYear, currentUser, selectedSubChannel, busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
    private static void getTargetValues(String financialYear,Id currentUser,String selectedSubChannel, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, Month__c,CurrencyISOCode, SUM(Target__c) from Target_Config__c 
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND BDD__c =: currentUser 
             AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.XC_Channel__c = 'DTC'
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
            System.debug('busUnitMonthSalesTarMap===>'+busUnitMonthSalesTarMap);
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getActualsBDM(String financialYear,Id currentUser,String selectedSubChannel) {
        return getBDMActualData(financialYear, currentUser, selectedSubChannel); //, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getBDMActualData(String financialYear,Id currentUser,String selectedSubChannel) {
        
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = True ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        getActualValues(financialYear, currentUser, selectedSubChannel, busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;        
    }
    
    
    private static void getActualValues(String financialYear,Id currentUser,String selectedSubChannel, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [select Business_Unit__r.Name, Month__c,CurrencyISOCode, SUM(Actual_Amount__c) from SPM_Stats__c 
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND BDD__c =: currentUser 
             AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.XC_Channel__c = 'DTC'
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
    public static Map<String, Map<String, Decimal>> getVarianceBDM(String financialYear,Id currentUser,String selectedSubChannel) {
        return getVarianceBDMData(financialYear, currentUser, selectedSubChannel);
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getVarianceBDMData(String financialYear,Id currentUser,String selectedSubChannel) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = True ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
        
        getVarianceValues(financialYear, currentUser, selectedSubChannel, busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
    private static void getVarianceValues(String financialYear,Id currentUser,String selectedSubChannel, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [select Business_Unit__r.Name, Month__c,CurrencyISOCode, SUM(Variance_Amount__c) from Target_Config__c 
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND BDD__c =: currentUser 
             AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.XC_Channel__c = 'DTC'
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
            System.debug('busUnitMonthSalesTarMap===>'+busUnitMonthSalesTarMap);
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetQuatBDM(String financialYear,Id currentUser,String selectedSubChannel) {
        
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
             BDD__c =: currentUser AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.XC_Channel__c = 'DTC'
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
    public static Map<String, Map<String, Decimal>> getActualQuatBDM(String financialYear,Id currentUser,String selectedSubChannel) {
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
             BDD__c =: currentUser AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.XC_Channel__c = 'DTC'
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
    public static Map<String, Map<String, Decimal>> getVarianceQuatBDM(String financialYear,Id currentUser,String selectedSubChannel) {
        
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
             BDD__c =: currentUser AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.XC_Channel__c = 'DTC'
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
    public static Map<String,Object> getYearlyStatsBDM(String financialYear, Id currentUser, String selectedSubChannel) {
        
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
             BDD__c =: currentUser AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.Xc_Channel__c = 'DTC'
             GROUP BY Business_Unit__r.Name]
        ) { 
            targetMap.put((String)aggr.get('Name'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, SUM(Actual_Amount__c) FROM SPM_Stats__c    
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.Xc_Channel__c = 'DTC'
             GROUP BY Business_Unit__r.Name]
        ) { 
            actualMap.put((String) aggr.get('Name'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name, SUM(Open_Actual_Amount__c) FROM SPM_Stats__c    
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.Xc_Channel__c = 'DTC'
             GROUP BY Business_Unit__r.Name]
        ) { 
            openActualMap.put((String) aggr.get('Name'),(Decimal) aggr.get('expr0')!= null ? (Decimal) aggr.get('expr0') : 0);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT Business_Unit__r.Name,  SUM(Variance_Amount__c) FROM Target_Config__c        
             WHERE Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND 
             BDD__c =: currentUser AND Sub_Channel__c =: selectedSubChannel AND Financial_Year__c =: financialYear AND Account__r.Xc_Channel__c = 'DTC'
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
    public static void saveBDMTargets(Id bddId, String subChannel, String financialYear, List<Map<String, Object>> updatedRecords) {
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
        Decimal percentage = 0 ;
        
        for(Map<String, Object> busObj : updatedRecords) {
            Map<String, Decimal> monthTargetMap = new Map<String, Decimal>();
            
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
            List<Account> accList = [SELECT Id FROM Account WHERE Sub_Channel__c =: subChannel AND OwnerId =: bddId];
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
                            BDM__c = bddId,
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
    }
    
    @AuraEnabled(Cacheable = true)
    public static BDMBusUnitTarActVar getBusUnitTarActVar(String financialYear, Id accountId, String businessUnitName) {
        BDMBusUnitTarActVar BDMBusUnitTarActVar = new BDMBusUnitTarActVar(0, 0, 0);
        
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Target__c) totalAmount FROM Target_Config__c
             WHERE Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId  GROUP by Account__c,Business_Unit__c]
        ) {
            BDMBusUnitTarActVar.targetAmt = (Decimal) aggr.get('totalAmount');
        }
        
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId  GROUP by Account__c,Business_Unit__c]
        ) {
            BDMBusUnitTarActVar.actualAmt = (Decimal) aggr.get('totalAmount');
        }
        
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Variance_Amount__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId GROUP by Account__c,Business_Unit__c]
        ) {
            BDMBusUnitTarActVar.varianceAmt = (Decimal) aggr.get('totalAmount');
        }
        return BDMBusUnitTarActVar;
    }  
    
    @AuraEnabled(Cacheable = true)
    public static boolean MonthTarActVar(String financialYear, Id accountId, String businessUnitName,String selectedMonth) {
        return true;
    }
    
    @AuraEnabled
    public static BDMMonthTarActVar getMonthTarActVar(String financialYear, Id accountId, String businessUnitName,String selectedMonth) {
        BDMMonthTarActVar BDMMonthTarActVar = new BDMMonthTarActVar(0, 0, 0, 0);
        
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Target__c) totalAmount FROM Target_Config__c
             WHERE Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId  AND Month__c =: selectedMonth GROUP by Account__c,Business_Unit__c]
        ) {
            BDMMonthTarActVar.monthTarAmt = (Decimal) aggr.get('totalAmount');
        }
        
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId AND Month__c =: selectedMonth  GROUP by Account__c,Business_Unit__c]
        ) {
            BDMMonthTarActVar.monthActAmt = (Decimal) aggr.get('totalAmount');
        }
        
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Variance_Amount__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId AND Month__c =: selectedMonth GROUP by Account__c,Business_Unit__c]
        ) {
            BDMMonthTarActVar.monthVarAmt = (Decimal) aggr.get('totalAmount');
        }
        
        for(
            AggregateResult aggr :
            [SELECT SUM(Commited_Order__c) totalAmount FROM Order_Commitment__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId AND Month__c =: selectedMonth]
        ) {
            BDMMonthTarActVar.monthOrdCommit = (Decimal) aggr.get('totalAmount');
        }
        
        return BDMMonthTarActVar;
    } 
    
    @AuraEnabled
    Public static List<TargetCommitWrapper> downloadTargetCommitStats(Id accountId,Id selectedUser, String financialYear, String businessUnitName) {
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
    
    @AuraEnabled
    public static Map<String, Object> pendingTargetUpload(Id currentUser) {
        Map<String, Object> result = new Map<String, Object>();
        
        List<Target_Commit_Stats__c> tCommitList = [SELECT Id FROM Target_Commit_Stats__c WHERE BDM__C = :currentUser
                                                    AND Status__c = 'Pending' AND IsUpload__c = true];
        
        boolean isPendingUpload = tCommitList.isEmpty();
        result.put('isPendingUpload', isPendingUpload);
        result.put('size', tCommitList.size());
        
        return result;
    }
    
    @AuraEnabled(Cacheable = true)
    Public static Boolean prepareBUProducts(Id busId, String businessUnit, String accountId, String financialYear, String selectedMonth, String ProdCode, String ProdDescription,Boolean commitmentAvailable) {
        return true;
    }
    
    @AuraEnabled
    Public static List<ProductWrapper> getBusUnitProducts(
        Id busId, String businessUnit, String accountId, String financialYear, 
        String selectedMonth, String ProdCode, String ProdDescription,Boolean commitmentAvailable
    ) {
        List<Product2> productsList = new List<Product2>();
        Map<Id, InvoiceWrapper> prdInvMap = new Map<Id, InvoiceWrapper>();
        Map<Id, ProductWrapper> resultMap = new Map<Id, ProductWrapper>();
        Map<String, Integer> monthMap = new Map<String, Integer>{  'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
            'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12};       
                Integer monthNumber = monthMap.get(selectedMonth);
        
        String numericPart = financialYear.substring(3);
        Integer baseYear = 2000; 
        Integer fullYear = baseYear + Integer.valueOf(numericPart);
        if (monthNumber > 3) {
            fullYear--;
        }
        String formattedYear = String.valueOf(fullYear);
        Integer currentMonth = System.today().month();
        Integer currentDay = System.today().day();       
        
        List<Business_Unit__c> buList = [SELECT Id FROM Business_Unit__c WHERE Unique_Name__c =: businessUnit LIMIT 1];
        if(!buList.isEmpty()) {
            busId = buList[0].Id;
        }
        else {
            buList = [SELECT Unique_Name__c FROM Business_Unit__c WHERE Id =: busId];
            if(!buList.isEmpty()) {
                businessUnit = buList[0].Unique_Name__c;
                busId =  buList[0].Id;
            }
        }
        
        List<Account> accList = [SELECT Id, XC_PricingGroup__c,OwnerId FROM Account WHERE Id =: accountId];
        if(accList.isEmpty()) {
            throw new AuraHandledException('Account is Empty');
        }
        
        Id priceBookId;
        
        for(
            BuyerGroup bgroup :
            [SELECT Id, (SELECT PriceBook2Id FROM BuyerGroupPricebooks WHERE IsActive = true AND PriceBook2.Name =: accList[0].XC_PricingGroup__c LIMIT 1) FROM BuyerGroup
             WHERE Id IN (SELECT BuyerGroupId FROM BuyerGroupMember where BuyerId =: accountId) AND Business_Unit__c like :'%'+businessUnit+'%' LIMIT 1]
        ) {
            if(!bgroup.BuyerGroupPricebooks.isEmpty()) {
                priceBookId = bgroup.BuyerGroupPricebooks[0].PriceBook2Id;
            }
        }
        
        if(String.isBlank(ProdCode) && String.isBlank(ProdDescription)) {
            productsList = [SELECT Id, Business_Unit__c, StockKeepingUnit , Description,Finish__c,Start_Date__c,
                            (SELECT Id, Financial_Year__c, Month__c, Quantity__c, Unit_Price__c, Commited_Order__c, Business_Unit__c, Account__c,BDM__c
                             FROM Order_Commitments__r WHERE Financial_Year__c = :financialYear  AND Month__c = :selectedMonth  AND
                             Business_Unit__c =: busId AND Account__c =: accountId ORDER BY CreatedDate DESC LIMIT 1) FROM Product2
                            WHERE Business_Unit__c =: businessUnit AND Available_for_commitment__c = True];       
        }
        else {
            productsList = [SELECT Id, Business_Unit__c, StockKeepingUnit , Description,Finish__c,Start_Date__c,
                            (SELECT Id, Financial_Year__c, Month__c, Quantity__c, Unit_Price__c, Commited_Order__c, Business_Unit__c, Account__c,BDM__c
                             FROM Order_Commitments__r WHERE Financial_Year__c = :financialYear AND Month__c = :selectedMonth AND
                             Business_Unit__c =: busId AND Account__c =: accountId ORDER BY CreatedDate DESC LIMIT 1) FROM Product2
                            WHERE Business_Unit__c = :businessUnit AND StockKeepingUnit LIKE :(ProdCode + '%') AND
                            Description LIKE :('%' + ProdDescription + '%') AND Available_for_commitment__c = True]; 
        }
        
        for (Product2 product : productsList) {
            prdInvMap.put(product.Id, new InvoiceWrapper(0, 0, 0, 0));
        }
        
        for (
            OrderItem ordItem : 
            [SELECT order.AccountId, Product2Id, Quantity, TotalPrice, order.XC_Order_Status__c FROM OrderItem 
             WHERE Order.AccountId =: accountId AND order.XC_Order_Status__c != 'Cancelled' AND 
             Product2Id IN : prdInvMap.keySet() AND Month__c =: selectedMonth and Financial_Year__c = :financialYear ]
        ) {
            if(ordItem.order.XC_Order_Status__c == 'Invoiced') {
                prdInvMap.get(ordItem.Product2Id).invoicedQty += (Integer) ordItem.Quantity;
                prdInvMap.get(ordItem.Product2Id).invoicedPrice += ordItem.TotalPrice;
                continue;
            }
            
            prdInvMap.get(ordItem.Product2Id).openQty += (Integer) ordItem.Quantity;
            prdInvMap.get(ordItem.Product2Id).openPrice += ordItem.TotalPrice;
        }
        
        for (Product2 product : productsList) {
            Date itemStartDate = Date.newInstance(Integer.valueOf(formattedYear), monthNumber, 1);
            if(product.Start_Date__c != null){
                if (currentMonth == monthNumber && currentDay >= product.Start_Date__c.day() && 
                    itemStartDate.month() == product.Start_Date__c.month() && itemStartDate.year() == product.Start_Date__c.year()
                   ) {
                       itemStartDate = product.Start_Date__c;
                   }
                
                if(commitmentAvailable && itemStartDate < product.Start_Date__c) {
                    continue;
                }
            }
            
            ProductWrapper prdWrapper = new ProductWrapper();
            prdWrapper.productCode = product.StockKeepingUnit ;
            prdWrapper.description = product.Description;
            prdWrapper.ordCommitsQuantity = 0;
            prdWrapper.committedOrder = 0;
            prdWrapper.productId = product.Id;
            prdWrapper.orderCommitId = null;
            prdWrapper.buId = busId;
            prdWrapper.accId = accountId;
            prdWrapper.financialYear = financialYear;
            prdWrapper.month = selectedMonth;
            prdWrapper.ordCommitsUnitPrice = 0;
            prdWrapper.finish = product.Finish__c;    
            prdWrapper.accountOwnerId = accList[0].OwnerId;
            prdWrapper.ordCommitMonth = '';
            prdWrapper.startDateField = product.Start_Date__c;
            //prdWrapper.endDateField = product.End_Date__c;
            prdWrapper.startDateWrapper = itemStartDate;
            // prdWrapper.endDateWrapper = endDate;
            
            if(product.Order_Commitments__r != null && !product.Order_Commitments__r.isEmpty()) {
                Order_Commitment__c commitment = product.Order_Commitments__r[0];
                
                prdWrapper.orderCommitId = commitment.Id;
                prdWrapper.ordCommitsQuantity = commitment.Quantity__c;
                prdWrapper.ordCommitsUnitPrice = commitment.Unit_Price__c;
                prdWrapper.committedOrder = commitment.Commited_Order__c;
                prdWrapper.accountOwnerId = commitment.BDM__c;
                prdWrapper.ordCommitMonth = commitment.Month__c;
            }
            
            prdWrapper.invoicedQty = prdInvMap.get(product.Id).invoicedQty;
            prdWrapper.invoicedPrice = prdInvMap.get(product.Id).invoicedPrice;
            prdWrapper.openQty = prdInvMap.get(product.Id).openQty;
            prdWrapper.openPrice = prdInvMap.get(product.Id).openPrice;
            
            resultMap.put(product.Id, prdWrapper);
        }
        
        if(priceBookId == null) {
            return resultMap.values();
        }
        
        for(
            PricebookEntry pbEntry :
            [SELECT Id,Product2Id,UnitPrice FROM PricebookEntry  WHERE Pricebook2Id =: priceBookId AND Product2Id IN : resultMap.keySet()]
        ) {
            if(resultMap.containsKey(pbEntry.Product2Id)) {
                resultMap.get(pbEntry.Product2Id).ordCommitsUnitPrice = pbEntry.UnitPrice;
            }
        }
        
        return resultMap.values();
    }  
    
    @AuraEnabled
    Public static String upsertOrdCommit(List<Order_Commitment__c> ordCommitList, String ProdCode, String ProdDescription,Boolean commitmentAvailable) {
        Decimal monthTarAmt = 0;
        Decimal monthOrdCommit = 0;
        try{            
            Upsert ordCommitList;  
            
            for(
                AggregateResult aggr :
                [SELECT SUM(Commited_Order__c) totalAmount FROM Order_Commitment__c
                 WHERE Financial_Year__c =: ordCommitList[0].Financial_Year__c AND Business_Unit__c =: ordCommitList[0].Business_Unit__c AND
                 Account__c =: ordCommitList[0].Account__c AND Month__c =: ordCommitList[0].Month__c]
            ) {
                monthOrdCommit = (Decimal) aggr.get('totalAmount');
            }
            
            for(
                AggregateResult aggr :
                [SELECT Account__c,Business_Unit__c, SUM(Target__c) totalAmount FROM Target_Config__c
                 WHERE Financial_Year__c =: ordCommitList[0].Financial_Year__c AND Business_Unit__c =: ordCommitList[0].Business_Unit__c AND
                 Account__c =: ordCommitList[0].Account__c AND Month__c =: ordCommitList[0].Month__c GROUP by Account__c,Business_Unit__c]
            ) {
                monthTarAmt = (Decimal) aggr.get('totalAmount');
            }
            
            List<ProductWrapper> prdWrapList = getBusUnitProducts(
                ordCommitList[0].Business_Unit__c, '', ordCommitList[0].Account__c,
                ordCommitList[0].Financial_Year__c, ordCommitList[0].Month__c, ProdCode, ProdDescription,commitmentAvailable
            );
        }
        catch(DmlException e){
            System.debug('Error==>'+e.getMessage());
        }
        return '{"monthOrdCommit" : "'+monthOrdCommit+'", "monthTarAmt" : "'+monthTarAmt+'"}';
    }
    
    public class BDMMonthTarActVar {
        @AuraEnabled
        public Decimal monthTarAmt {get; set;}
        @AuraEnabled
        public Decimal monthActAmt {get; set;}
        @AuraEnabled
        public Decimal monthVarAmt {get; set;}
        @AuraEnabled
        public Decimal monthOrdCommit {get; set;}
        
        public BDMMonthTarActVar(Decimal monthTarAmt, Decimal monthActAmt, Decimal monthVarAmt,Decimal monthOrdCommit) {
            this.monthTarAmt = monthTarAmt;
            this.monthActAmt = monthActAmt;
            this.monthVarAmt = monthVarAmt;  
            this.monthOrdCommit = monthOrdCommit;
        }
    }
    
    public class ProductWrapper {
        @AuraEnabled
        public String productCode { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public Decimal ordCommitsQuantity { get; set; }
        @AuraEnabled
        public Decimal ordCommitsUnitPrice { get; set; }
        @AuraEnabled
        public Decimal committedOrder { get; set; }
        @AuraEnabled
        public Id productId { get; set; }
        @AuraEnabled
        public Id orderCommitId { get; set; }
        @AuraEnabled
        public Id buId { get; set; }
        @AuraEnabled
        public Id accId { get; set; }
        @AuraEnabled
        public String financialYear { get; set; }
        @AuraEnabled
        public String month { get; set; }
        @AuraEnabled
        public String finish { get; set; }
        @AuraEnabled
        public Id accountOwnerId { get; set; }
        @AuraEnabled
        public String ordCommitMonth { get; set; }
        @AuraEnabled
        public Integer invoicedQty { get; set; }
        @AuraEnabled
        public Decimal invoicedPrice { get; set; }
        @AuraEnabled
        public Integer openQty { get; set; }
        @AuraEnabled
        public Decimal openPrice { get; set; }
        @AuraEnabled
        public Boolean commitAvailable { get; set;}
        @AuraEnabled
        public Date startDateField { get; set; }
        @AuraEnabled
        public Date endDateField { get; set; }
        @AuraEnabled
        public Date startDateWrapper { get; set; }
        @AuraEnabled
        public Date endDateWrapper { get; set; }
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
    
    public class BDMBusUnitTarActVar {
        @AuraEnabled
        public Decimal targetAmt {get; set;}
        @AuraEnabled
        public Decimal actualAmt {get; set;}
        @AuraEnabled
        public Decimal varianceAmt {get; set;}
        
        public BDMBusUnitTarActVar(Decimal targetAmt, Decimal actualAmt, Decimal varianceAmt) {
            this.targetAmt = targetAmt;
            this.actualAmt = actualAmt;
            this.varianceAmt = varianceAmt;            
        }
    }
    
    public class InvoiceWrapper {
        public Integer invoicedQty;
        public Decimal invoicedPrice;
        public Integer openQty;
        public Decimal openPrice;
        
        public InvoiceWrapper(Integer invoicedQty, Decimal invoicedPrice, Integer openQty, Decimal openPrice) {
            this.invoicedQty = invoicedQty;
            this.invoicedPrice = invoicedPrice;
            this.openQty = openQty;
            this.openPrice = openPrice;
        }
    }
    
}