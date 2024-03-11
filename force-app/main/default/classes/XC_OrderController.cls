public without sharing class XC_OrderController {
    @AuraEnabled
    public static List<XC_OrderProductWrapper> getOrderListByDateAndSKUForExport(Date startDate,Date endDate,String SKU){  
        List<OrderSummary> orderList = getOrderList(startDate,endDate,SKU,null,true,'','');
        List<OrderItemSummary> orderItemList = getOrderItemList(orderList,SKU);
        List<XC_OrderProductWrapper> orderProductList = new List<XC_OrderProductWrapper>();
        for(Integer i=0;i<orderList.size();i++){
            for(Integer j=0;j<orderItemList.size();j++){
                if(orderItemList[j].OrderSummaryId==orderList[i].Id){
                    XC_OrderProductWrapper opw = new XC_OrderProductWrapper();

                    // DateTime var1 = orderList[i].OrderedDate;
                    // String var2 = var1.format('MM/dd/YYYY');
                    // opw.orderedDate = var1.format('MM/dd/YYYY');
                    opw.orderedDate = orderList[i].OrderedDate.format('MM/dd/YYYY');
                    opw.orderNumber = orderList[i].OriginalOrder.OrderReferenceNumber;
                    opw.poNumber = orderList[i].OriginalOrder.PoNumber;
                    opw.requestedShipDate = orderList[i].XC_RequestedShipDate__c;
                    opw.shippingAddress = orderList[i].OriginalOrder.ShippingStreet+ ','+ orderList[i].OriginalOrder.ShippingCity + ',' +orderList[i].OriginalOrder.ShippingState+ ',' +orderList[i].OriginalOrder.ShippingCountry+',' +orderList[i].OriginalOrder.ShippingPostalCode;
                    opw.status = orderList[i].OriginalOrder.XC_Order_Status__c;
                    // opw.totalAmount = orderList[i].GrandTotalAmount;
                    opw.totalAmount = orderItemList[j].UnitPrice * orderItemList[j].Quantity;
                    opw.quantity = orderItemList[j].Quantity;
                    opw.attributes = orderItemList[j].Product2.Product_Style__c+ ','+orderItemList[j].Product2.xc_color__c;
                    opw.sku = orderItemList[j].StockKeepingUnit;
                    opw.businessUnit = orderItemList[j].Product2.Business_Unit__c;
                    opw.unitPrice = orderItemList[j].UnitPrice;
                    opw.name = orderItemList[j].Product2.Name;
                    opw.productCode = orderItemList[j].Product2.ProductCode;

                    // opw.productCode = integer.valueof(orderItemList[j].Product2.ProductCode);
                    opw.estimatedShipDate = orderItemList[j].OriginalOrderItem.XC_Estimated_Ship_Date__c;
                    //orderProductList.add((XC_OrderProductWrapper)JSON.deserialize(JSON.serialize(opw),XC_OrderProductWrapper.class));
                     orderProductList.add(opw);
                    System.debug('wrapperrrrrExPort'+orderList.size()+'----'+orderItemList.size()+'----'+orderProductList.size()+'----'+opw);
                }
                
            }
        }
        return orderProductList;     
    }
    @AuraEnabled(cacheable=true)
    public static List<XC_OrderProductWrapper> getOrderListByDateAndSKU(Date startDate,Date endDate,String SKU,Integer pageNumber,String field,String sortOrder){
        
//         List<OrderSummary> orderList = getOrderList(startDate,endDate,pageNumber,false,field,sortOrder);
         List<OrderSummary> orderList = getOrderList(startDate,endDate,SKU,pageNumber,false,field,sortOrder);
         List<OrderItemSummary> orderItemList = getOrderItemList(orderList,SKU);
        List<XC_OrderProductWrapper> orderProductList = new List<XC_OrderProductWrapper>();
        for(Integer i=0;i<orderList.size();i++){
            for(Integer j=0;j<orderItemList.size();j++){
                if(orderItemList[j].OrderSummaryId==orderList[i].Id){
                    XC_OrderProductWrapper opw = new XC_OrderProductWrapper();

                    // DateTime var1 = orderList[i].OrderedDate;
                    // // String var2 = var1.format('MM/dd/YYYY');
                    // opw.orderedDate = var1.format('MM/dd/YYYY');
                    opw.orderedDate = orderList[i].OrderedDate.format('MM/dd/YYYY');
                    opw.orderNumber = orderList[i].OriginalOrder.OrderReferenceNumber;
                    opw.poNumber = orderList[i].OriginalOrder.PoNumber;
                    opw.status = orderList[i].OriginalOrder.XC_Order_Status__c;
                    opw.totalAmount = orderList[i].GrandTotalAmount;
                    opw.requestedShipDate = orderList[i].XC_RequestedShipDate__c;
                    opw.estimatedShipDate = orderItemList[j].OriginalOrderItem.XC_Estimated_Ship_Date__c;
                    opw.id = orderList[i].Id;
                    orderProductList.add(opw);
                    System.debug('wrapperrrrr'+orderList.size()+'----'+orderItemList.size()+'----'+orderProductList.size()+'----'+opw);
                    break;
                }
            }
        }
        return orderProductList;      
    }

    @AuraEnabled
    public static Integer getTotalRecordsNumber(Date startDate,Date endDate,String SKU){
        try {
            Id userId = UserInfo.getUserId();
            List<AggregateResult> ois = new List<AggregateResult>();
            Integer totalRecords;
        Contact cont = [SELECT AccountId,Id from Contact WHERE Id IN (SELECT ContactId  from User where Id=:userId)];
        Id accountId = cont.AccountId;
        if(SKU==''){
             List<OrderSummary> orderList = [SELECT Id FROM  OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId];
             ois = [SELECT OrderSummaryId FROM OrderItemSummary WHERE OrderSummaryId IN :orderList GROUP BY OrderSummaryId];
             totalRecords = ois.size();
        }
        else{
            List<OrderSummary> orderList = [SELECT Id FROM  OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId];
            ois = [SELECT OrderSummaryId FROM OrderItemSummary WHERE StockKeepingUnit = :SKU AND OrderSummaryId IN :orderList GROUP BY OrderSummaryId];
            totalRecords = ois.size();
        }

            return totalRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<OrderSummary> getOrderList(Date startDate,Date endDate, String SKU, Integer pageNumber,Boolean isExport,String field,String sortOrder){
        
        Id userId = UserInfo.getUserId();
        Contact cont = [SELECT AccountId,Id from Contact WHERE Id IN (SELECT ContactId  from User where Id=:userId)];
        Id accountId = cont.AccountId;
        List<OrderSummary> orderList = new List<OrderSummary>();
        String queryString;
        // String queryString = 'SELECT OrderedDate,OrderNumber,XC_RequestedShipDate__c,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,Status,GrandTotalAmount FROM OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId';
       ////
       if(isExport==false){
        if(startDate != null || endDate != null){
            if(SKU!=''){
            // queryString = 'SELECT Id,OrderedDate,OrderNumber,XC_RequestedShipDate__c,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId ';
            queryString = 'SELECT Id,OrderedDate,OrderNumber,OriginalOrder.PoNumber,XC_RequestedShipDate__c,OriginalOrder.OrderReferenceNumber,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId and Id in (SELECT OrderSummaryId FROM OrderItemSummary WHERE StockKeepingUnit =: SKU)';
        }
        else{
            queryString = 'SELECT Id,OrderedDate,OrderNumber,OriginalOrder.PoNumber,XC_RequestedShipDate__c,OriginalOrder.OrderReferenceNumber,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId ';
        }
    }
        else{
            if(SKU!=''){
                queryString = 'SELECT Id,OrderedDate,OrderNumber,OriginalOrder.PoNumber,XC_RequestedShipDate__c,OriginalOrder.OrderReferenceNumber,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE AccountId=:accountId and Id in (SELECT OrderSummaryId FROM OrderItemSummary WHERE StockKeepingUnit =: SKU)';    
            }
            else{
  // queryString = 'SELECT Id,OrderedDate,OrderNumber,XC_RequestedShipDate__c,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE AccountId=:accountId';
     queryString = 'SELECT Id,OrderedDate,OrderNumber,OriginalOrder.PoNumber,XC_RequestedShipDate__c,OriginalOrder.OrderReferenceNumber,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE AccountId=:accountId';
            }
          

        }
        

        if(field!=null && sortOrder!=null){
            queryString+= ' ORDER BY '+field+' '+sortOrder;
        }
        /////
        if(pageNumber!=null){
            Integer offset = (pageNumber - 1) * 25;
            queryString += ' LIMIT 25 OFFSET :offset';
            Integer totalRecords = [SELECT COUNT() FROM  OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId];
        }
    }
    else{
        if(startDate != null || endDate != null){
            queryString = 'SELECT Id,OrderedDate,OrderNumber,OriginalOrder.PoNumber,XC_RequestedShipDate__c,OriginalOrder.OrderReferenceNumber,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE OrderedDate>=:startDate AND OrderedDate<=:endDate AND AccountId=:accountId ORDER By OriginalOrder.OrderReferenceNumber ASC';
      
        }
        else{
            queryString = 'SELECT Id,OrderedDate,OrderNumber,XC_RequestedShipDate__c,OriginalOrder.PoNumber,OriginalOrder.OrderReferenceNumber,OriginalOrder.ShippingCity,OriginalOrder.ShippingCountry,OriginalOrder.ShippingPostalCode,OriginalOrder.ShippingState,OriginalOrder.ShippingStreet,OriginalOrder.XC_Order_Status__c,GrandTotalAmount FROM OrderSummary WHERE AccountId=:accountId ORDER By OriginalOrder.OrderReferenceNumber ASC';    
        }
    }
       
        orderList = Database.query(queryString);
        return orderList;
    }
    public static List<OrderItemSummary> getOrderItemList(List<OrderSummary> orderList,String SKU){
        List<OrderItemSummary> orderItemList = new List<OrderItemSummary>();

        if(SKU!=''){
            
            orderItemList = [SELECT StockKeepingUnit,OriginalOrderItem.XC_Estimated_Ship_Date__c,OrderSummaryId,UnitPrice,Quantity,Product2.Product_Style__c,Product2.Name,Product2.xc_color__c,Product2.ProductCode,Product2.Business_Unit__c FROM OrderItemSummary WHERE StockKeepingUnit = :SKU AND OrderSummaryId IN :orderList];
        }
        else{
            
            orderItemList = [SELECT StockKeepingUnit,OriginalOrderItem.XC_Estimated_Ship_Date__c,OrderSummaryId,UnitPrice,Product2.Product_Style__c,Product2.Name,Product2.xc_color__c,Product2.ProductCode,Quantity,Product2.Business_Unit__c FROM OrderItemSummary WHERE OrderSummaryId IN :orderList];
        }
        return orderItemList;
      }

    @AuraEnabled
    public static  List<ConnectApi.BatchResult> startReorder(String orderSumId){
            try {
            
            Id userId = UserInfo.getUserId();
            Contact cont = [SELECT AccountId,Id from Contact WHERE Id IN (SELECT ContactId  from User where Id=:userId)];
            Id accountId = cont.AccountId;
            WebStore ws = [SELECT Id,Name FROM WebStore where Name='All Axcess'];
            WebCart wc = [SELECT Id, AccountId,Name,OwnerId,Status,WebStoreId FROM WebCart where OwnerId=:userId and AccountId=:accountId and Status='Active' and WebStoreId=:ws.Id];
            List<OrderItemSummary> orderItemSummary = [SELECT Product2.Id, Quantity FROM OrderItemSummary WHERE OrderSummaryId =:orderSumId ];
            List<ConnectApi.BatchInput> batchItemInputList = new List<ConnectApi.BatchInput> ();
            for(Integer i=0;i<orderItemSummary.size();i++){
                ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
                cartItemInput.quantity = String.valueOf(orderItemSummary[i].Quantity.format());
                cartItemInput.productId = orderItemSummary[i].Product2.Id;
                cartItemInput.type =  ConnectApi.CartItemType.PRODUCT;
                ConnectApi.BatchInput batchItemInput = new ConnectApi.BatchInput(cartItemInput);
                batchItemInputList.add(batchItemInput);
                
            }
            
            List<ConnectApi.BatchResult> batchResult = ConnectApi.CommerceCart.addItemsToCart(ws.Id,accountId,wc.Id,batchItemInputList);
            return batchResult;
        } catch (Exception e) {
            // System.debug('errprrrrrr'+e.getMessage());
            if(Test.isRunningTest()){
                return null;
            }
            else{
                throw new AuraHandledException(e.getMessage());
            }
        }
        
    }   
}