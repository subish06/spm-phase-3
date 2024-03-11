public class OrderItemController {
    public static void createActuals(Map<Id, OrderItem> newOrderMap) {
        try {
            List<SPM_Stats__c> actualList = new List<SPM_Stats__c>();
            Map<String, Id> buMap = new Map<String, Id>();
            Map<Id, Id> configMap = new Map<Id, Id>();
            Map<String, Id> tConfigMap = new Map<String, Id>();
            
            for(Business_Unit__c bu : [SELECT Id, Unique_Name__c FROM Business_Unit__c]) {
                buMap.put(bu.Unique_Name__c, bu.Id);
            }
            
            for(Hierarchy_Config__c hConfig : [SELECT Id, User__c, Manager__c FROM Hierarchy_Config__c WHERE Role__c = 'BDM' AND Manager__c != null]) {
                configMap.put(hConfig.User__c, hConfig.Manager__c);
            }
            
            for(
                OrderItem ordItem : 
                [SELECT Id, OrderId, Order.OrderedDate, Order.AccountId, Order.Account.OwnerId,Order.XC_Order_Status__c, Product2Id, Product2.Business_Unit__c, TotalPrice 
                 FROM OrderItem WHERE Id IN :newOrderMap.keySet() AND Order.OrderedDate != null AND Order.XC_Order_Status__c != 'Canceled']
            ) {
                if(ordItem.Order == null || ordItem.Order.OrderedDate == null || ordItem.Order.Account == null || ordItem.Order.Account.OwnerId == null || ordItem.Product2 == null || ordItem.Product2.Business_Unit__c == null) {
                    continue;
                }
                
                String monthName = getMonthName(ordItem.Order.OrderedDate);
                String key = 'FY-' + String.valueOf(ordItem.Order.OrderedDate.year()).substring(2, 4)  
                    + '-' + String.valueOf(configMap.get(ordItem.Order.Account.OwnerId)).substring(0, 15) + '-' + String.valueOf(ordItem.Order.Account.OwnerId).substring(0, 15) 
                    + '-' + String.valueOf(ordItem.Order.AccountId).substring(0, 15) + '-' + String.valueOf(buMap.get(ordItem.Product2.Business_Unit__c)).substring(0, 15) 
                    + '-' + monthName;
                
                Id tConfigId = tConfigMap.get(key);
                
                if(tConfigId == null) {
                    Target_Config__c tConfig = [SELECT Id FROM Target_Config__c WHERE Target_Key__c = :key LIMIT 1];
                    if(tConfig != null) {
                        tConfigMap.put(key, tConfig.Id);
                        tConfigId = tConfig.Id;
                    }
                }
                
                SPM_Stats__c actual = new SPM_Stats__c(
                    Order__c = ordItem.OrderId,
                    Order_Product__c = ordItem.Id,
                    Product__c = ordItem.Product2Id,
                    Business_Unit__c = buMap.get(ordItem.Product2.Business_Unit__c),
                    Account__c = ordItem.Order.AccountId,
                    Financial_Year__c = 'FY-' + String.valueOf(ordItem.Order.OrderedDate.year()).substring(2, 4),
                    Month__c = monthName,
                    BDM__c = ordItem.Order.Account.OwnerId,
                    BDD__c = configMap.get(ordItem.Order.Account.OwnerId),
                    Target_Config__c = tConfigId,
                    currencyISOcode = 'USD'   
                );
                
                if(ordItem.Order.XC_Order_Status__c == 'Invoiced'){
                    actual.Actual_Amount__c = ordItem.TotalPrice;
                    actualList.add(actual);
                }
                else{
                    actual.Open_Actual_Amount__c = ordItem.TotalPrice;
                    actualList.add(actual);
                }   
            }
            
            if(!actualList.isEmpty()) {
                insert actualList;
            }
        } catch(Exception e) {
            System.debug('Error occurred: ' + e.getMessage());
        }
    }
    
    public static void updateActualsOnOrderItemUpdate(Map<Id, OrderItem> newOrderItemMap, Map<Id, OrderItem> oldOrderItemMap) {     
        try {
            Set<Id> orderItemIds = new Set<Id>();
            List<SPM_Stats__c> statsList = new List<SPM_Stats__c>();
            List<SPM_Stats__c> actualListToUpdate = new List<SPM_Stats__c>();
            Map<Id,SPM_Stats__c > statsOrderItemMap = new Map<Id, SPM_Stats__c>();
            
            for (OrderItem updatedOrderItem : newOrderItemMap.values()) {
                OrderItem oldOrderItem = oldOrderItemMap.get(updatedOrderItem.Id);
                if ((updatedOrderItem.TotalPrice != oldOrderItem.TotalPrice) || (updatedOrderItem.Order.XC_Order_Status__c != oldOrderItem.Order.XC_Order_Status__c)) {
                    orderItemIds.add(updatedOrderItem.Id);                    
                }
            } 
			statsList = [SELECT Id, Order_Product__c,Order__r.XC_Order_Status__c,Actual_Amount__c,Open_Actual_Amount__c FROM SPM_Stats__c 
                         WHERE Order_Product__c IN :orderItemIds];
            for (SPM_Stats__c stat : statsList) {
                statsOrderItemMap.put(stat.Order_Product__c, stat);
            }
            for (OrderItem updatedOrderItem : newOrderItemMap.values()) {
                SPM_Stats__c actual = statsOrderItemMap.get(updatedOrderItem.Id);
                if (actual != null) {
                    if (actual.Order__r.XC_Order_Status__c == 'Invoiced') {
                        actual.Actual_Amount__c = updatedOrderItem.TotalPrice;
                        actual.Open_Actual_Amount__c = 0;
                        actualListToUpdate.add(actual);   
                    } else {
                        actual.Actual_Amount__c = 0;
                        actual.Open_Actual_Amount__c = updatedOrderItem.TotalPrice;
                        actualListToUpdate.add(actual);
                    }
                }
            }
            if (!actualListToUpdate.isEmpty()) {
                update actualListToUpdate;
            }
        } catch (Exception e) {
            System.debug('Error occurred: ' + e.getMessage());
        }
    }
   
    public static String getMonthName(Datetime datetimeValue) {
        Date dateValue = datetimeValue.date();
        String orderedDateStr = String.valueOf(dateValue);
        String monthNumber = orderedDateStr.substring(5, 7);
        Integer monthValue = Integer.valueOf(monthNumber);
        String[] monthNames = new String[] { 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
            if (monthValue >= 1 && monthValue <= 12) {
                return monthNames[monthValue - 1];
            }
        return '';
    }   
}