public without sharing class XC_RMARequestController 
{
    private final static String DEFAULT_CASE_QUEUE = 'XC_CaseDefaultQueue';

    @AuraEnabled
    public static Map<String, Object> getOrderData(String orderSummId)
    {
        Map<String, Object> returnMap = new Map<String, Object>();

        OrderSummary curSumm = [SELECT Id, OrderNumber, CreatedDate, (SELECT Id, Quantity, Name, Product2.StockKeepingUnit, Product2.Name FROM OrderItemSummaries WHERE Type = 'Order Product') FROM OrderSummary WHERE Id = :orderSummId];
        //List<OrderItemSummary> orderItems = curSumm.OrderItemSummaries;

        returnMap.put('order', curSumm);
        //returnMap.put('items', orderItems);

        //List<String> pickListValuesList= new List<String>();
        Map<String, String> picklistLabelToValueMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = XC_RMA__c.XC_ReturnReason__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            //pickListValuesList.add(pickListVal.getLabel());
            picklistLabelToValueMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        returnMap.put('rmaReasons', picklistLabelToValueMap);

        Boolean showReturnDisclaimer = curSumm.CreatedDate > Date.today().addDays(45) ? true : false;

        returnMap.put('showReturnDisclaimer', showReturnDisclaimer);

        return returnMap;
    }

    @AuraEnabled
    public static Map<String, Object> createRMA(String orderSummId, Map<String, String> qtyMap, String returnReason)
    {
        Savepoint sp = Database.setSavepoint();
        Map<String, Object> returnMap = new Map<String, Object>();
        //Set<Id> orderItemIds = qtyMap.keySet();

        // for(String key : qtyMap.keySet())
        // {
        //     System.debug(key);
        //     System.debug(qtyMap.get(key));

        // }

        // System.debug(returnReason);

        try 
        {
            OrderSummary orderSumm = [SELECT Id, OrderNumber FROM OrderSummary WHERE Id = :orderSummId LIMIT 1];
            Map<Id, OrderItemSummary> orderItemMap = new Map<Id, OrderItemSummary>([SELECT Id, Quantity, Product2.StockKeepingUnit FROM OrderItemSummary WHERE Id IN :qtyMap.keySet()]);

            Case newCase = new Case();
            newCase.Subject = 'RMA Request ' + orderSumm.OrderNumber;
            newCase.Origin = 'Web';
            newCase.Status = 'New';
            newCase.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :DEFAULT_CASE_QUEUE LIMIT 1].Id;
            newCase.ContactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;

            insert newCase;

            XC_RMA__c rma = new XC_RMA__c();
            rma.XC_ReturnReason__c = returnReason;
            rma.XC_OrderSummary__c = orderSumm.Id;
            rma.XC_Case__c = newCase.Id;

            insert rma;

            List<XC_RMAItem__c> rmaItemList = new List<XC_RMAItem__c>();

            for(String key : qtyMap.keySet())
            {
                if(orderItemMap.containsKey(key))
                {
                    XC_RMAItem__c rmaItem = new XC_RMAItem__c();
                    rmaItem.XC_RMA__c = rma.Id;
                    rmaItem.XC_Quantity__c = Integer.valueof(qtyMap.get(key)) <= orderItemMap.get(key).Quantity ? Integer.valueof(qtyMap.get(key)) : orderItemMap.get(key).Quantity;
                    rmaItem.XC_OrderProductSummary__c = orderItemMap.get(key).Id;
                    rmaItem.XC_SKU__c = orderItemMap.get(key).Product2.StockKeepingUnit;

                    rmaItemList.add(rmaItem);

                    System.debug(rmaItem);

                    System.debug(key);
                    System.debug(qtyMap.get(key));
                }
            }
            
            if(!rmaItemList.isEmpty())
            {
                insert rmaItemList;
            }
            else 
            {
                throw new NoDataFoundException();
            }
        } 
        catch(Exception e) 
        {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            Database.rollback(sp);
            //throw new AuraHandledException(e.getMessage());
            returnMap.put('error', true);
        }

        return returnMap;
    }
}