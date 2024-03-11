public class OrderCommitmentController {
    
    public static void updateTargetCommitStats(List<Order_Commitment__c> orderCommitmentList) {
        Set<String> keys = new Set<String>();
        List<Sobject> targetCommitStatsToUpdate = new List<Sobject>();
        List<String> months = new List<String>{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
        
        Map<String, Order_Commitment__c> orderKeyMap = new Map<String, Order_Commitment__c>();
        
        for (Order_Commitment__c orderCommitment : orderCommitmentList) {
            String key = orderCommitment.Financial_Year__c + '-' + String.valueOf(orderCommitment.BDM__c).substring(0, 15) + '-' + 
                String.valueOf(orderCommitment.Account__c).substring(0, 15) + '-' + String.valueOf(orderCommitment.Business_Unit__c).substring(0, 15) + '-' + 
                String.valueOf(orderCommitment.Product__c).substring(0, 15);
            keys.add(key);
            key += + '-' + orderCommitment.Month__c;
            orderKeyMap.put(key, orderCommitment);
        }
        System.debug('keys==>'+ keys);
        System.debug('keys size==>'+ keys.size());
        
        
        for (
            Target_Commit_Stats__c targetCommitStats :
            [SELECT Id, Unique_key__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, IsUpload__c, Status__c
             FROM Target_Commit_Stats__c WHERE Unique_key__c IN : keys AND IsUpload__c = false]
        ) {
            Sobject sobj = targetCommitStats;
            for (String month : months) {
                String key = targetCommitStats.Unique_key__c + '-' + month;
                
                Order_Commitment__c orderCommitment = orderKeyMap.get(key);
                
                if (orderCommitment != null) {
                    sobj.put(month + '__c', orderCommitment.Quantity__c);
                }
            }
            targetCommitStatsToUpdate.add(sobj);
        }
        
        if (!targetCommitStatsToUpdate.isEmpty()) {
           update targetCommitStatsToUpdate;
        }
    }
}