global class XC_OrderSummaryCreationCtrl implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query = 'SELECT Id FROM Order WHERE OrderReferenceNumber != null AND ActivatedDate = null AND Status = \'Draft\' AND XC_Summary_Created__c = false'; 
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM Order WHERE OrderReferenceNumber != null AND ActivatedDate = null AND Status = \'Draft\' AND XC_Summary_Created__c = false AND OrderReferenceNumber = \'1212121\' LIMIT 1'; 
        }
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Order> orderList) {

        set<Id> allSetIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderIdsNoDeliveryGroup = new Set<Id>();
    
        for(Order re : orderList){
            allSetIds.add(re.id);
        }

        List<OrderItem> orderItemList =[SELECT Id,Order.XC_Summary_Created__c,OrderId,OrderDeliveryGroupId FROM OrderItem where OrderId IN :allSetIds];
        List<Order> updateToDraft = new List<Order>();
               
        for(OrderItem oi : orderItemList){
            if(!orderIds.contains(oi.OrderId)){
                if(oi.OrderDeliveryGroupId == null){
                    orderIdsNoDeliveryGroup.add(oi.OrderId);
                }
                orderIds.add(oi.OrderId);
                Order draftOrder = new Order( 
                    Id = oi.OrderId,
                    Status = 'Draft',
                    XC_Summary_Created__c = oi.Order.XC_Summary_Created__c
                );

                updateToDraft.add(draftOrder);
            }
            
        }

        //update updateToDraft;  
        if(orderIdsNoDeliveryGroup.size()>0){
            Id orderDeLMethod = [SELECT Id,IsActive,Name FROM OrderDeliveryMethod WHERE Name = 'Shipping Estimate' LIMIT 1].id;

            list<OrderDeliveryGroup> ordgroup = new list<OrderDeliveryGroup>();
            Map<String,String> orderDeliveryGroupMap = new Map<String,String>();
        
            for(Id orderId:orderIdsNoDeliveryGroup){
                OrderDeliveryGroup odg = new OrderDeliveryGroup();
                odg.OrderId=orderId;
                odg.OrderDeliveryMethodId=orderDeLMethod;
                odg.DeliverToName='The Shipping Address';
                ordgroup.add(odg);

            }
            upsert ordgroup;

            for(OrderDeliveryGroup og : ordgroup){
                orderDeliveryGroupMap.put(og.OrderId, og.Id);
            }

            for(OrderItem oi : orderItemList){
                oi.OrderDeliveryGroupId = orderDeliveryGroupMap.get(oi.OrderId);
            }

            update orderItemList;    
                
        }              
        
        for(Order o : updateToDraft){
            o.Status = 'Activated';
        }          

        update updateToDraft;

        for(Id orderId:orderIds){  // to create OrderSummary
            ConnectApi.OrderSummaryInputRepresentation newSum = new ConnectApi.OrderSummaryInputRepresentation();
            newSum.orderLifeCycleType = 'UNMANAGED';
            newSum.Status = 'Created';
            newSum.orderId = orderId;
            ConnectApi.OrderSummaryOutputRepresentation retSum = ConnectApi.OrderSummaryCreation.createOrderSummary(newSum);
            
        }
        
        for(Order o : updateToDraft){
            o.Status = 'Draft';
            o.XC_Summary_Created__c = true;

        }          

        update updateToDraft;
   
    }  
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}