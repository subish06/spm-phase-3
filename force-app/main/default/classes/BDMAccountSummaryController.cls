public class BDMAccountSummaryController {
    
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetBDM(String financialYear,Id accountId,Id currentUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,name from Business_Unit__c where Available_for_Target__c = true]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.name, monthSalesTarMap);
        }        
        getTargetValues(financialYear, accountId, currentUser, busUnitMonthSalesTarMap);
        System.debug('BDM Id'+busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
    private static void getTargetValues(String financialYear,Id accountId,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        
        for(
            AggregateResult aggr : 
            [select Business_Unit__r.Name, Month__c, SUM(Target__c) from Target_Config__c 
             where Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = true AND Account__c =: accountId AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
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
    public static Map<String, Map<String, Decimal>> getActualsBDM(String financialYear,Id accountId,Id currentUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,name from Business_Unit__c where Available_for_Target__c = True]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.name, monthSalesTarMap);
        }
        
        getActualValues(financialYear, accountId, currentUser, busUnitMonthSalesTarMap);
        System.debug('BDM Id'+busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
    private static void getActualValues(String financialYear,Id accountId,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        
        for(
            AggregateResult aggr : 
            [select Business_Unit__r.Name, Month__c, SUM(Actual_Amount__c) from Actuals__c 
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND Account__c =: accountId AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
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
    public static Map<String, Map<String, Decimal>> getVarianceBDM(String financialYear,Id accountId,Id currentUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
        
        for(Business_Unit__c busUnit : [select id,name from Business_Unit__c where Available_for_Target__c = True]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0); 
            }
            busUnitMonthSalesTarMap.put(busUnit.name, monthSalesTarMap);
        }
        
        getVarianceValues(financialYear, accountId, currentUser, busUnitMonthSalesTarMap);
        System.debug('BDM Id'+busUnitMonthSalesTarMap);
        
        return busUnitMonthSalesTarMap;
    }
    
    private static void getVarianceValues(String financialYear,Id accountId,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        
        for(
            AggregateResult aggr : 
            [select Business_Unit__r.Name, Month__c, SUM(Variance_Amount__c) from Variance__c 
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND Account__c =: accountId AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
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
}