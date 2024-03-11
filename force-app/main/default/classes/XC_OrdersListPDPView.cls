public without sharing class XC_OrdersListPDPView {
    @AuraEnabled(cacheable=true)
    public static  List<XC_OrderPDPWrapper> getOrderListByProductId(String recordId){
      Contact cont = [SELECT AccountId,Id from Contact WHERE Id IN (SELECT ContactId  from User where Id=: UserInfo.getUserId())];
      Id accountId = cont.AccountId;
      //Definitions of Maps for Aggregate results of Order and Invoice Item Data..
      Map<String, Object> orderItemList = getOrderItemList(accountId, recordId);
      // Map<String, AggregateResult> invoiceItemList = getInvoiceItemList(accountId, recordId);
        List<XC_OrderPDPWrapper> orderPDPList = new List<XC_OrderPDPWrapper>();           

        
        for (String key : orderItemList.keySet()) {
          XC_OrderPDPWrapper opdpw = new XC_OrderPDPWrapper();
          Map<String,Object> orderItemMap = (Map<String,Object>) orderItemList.get(key);
          
          Decimal qtyOpen = orderItemMap.get('orderQty') != null ? (Decimal)orderItemMap.get('orderQty') : 0;
         
          String orderReferenceNumber = (String)orderItemMap.get('orderReferenceNumber');
          

          opdpw.unFilledQuantity = qtyOpen;
         
          opdpw.orderNumber = orderItemMap.get('orderReferenceNumber') != null ? (String)orderItemMap.get('orderReferenceNumber') : '';
          opdpw.orderedDate = ((DateTime)orderItemMap.get('orderDate')).format('MM/dd/YYYY');     

           if(opdpw.orderNumber != ''){
          orderPDPList.add(opdpw);
           }
      }     
        return orderPDPList;      
  }

  public static Map<String,Object> getOrderItemList(String accountId, String recordId){        
    Map<String,Object> resultMap = new Map<String,Object>();   
    List<OrderItemSummary> orderItems = [SELECT OrderSummary.OriginalOrderId, OrderSummary.OriginalOrder.OrderReferenceNumber, OriginalOrderItem.Product2Id, OrderSummary.OriginalOrder.OrderedDate, OrderSummary.OriginalOrder.OrderNumber, Quantity	 FROM OrderItemSummary WHERE OriginalOrderItem.Product2Id =: recordId AND OrderSummary.OriginalOrder.AccountId =: accountId];
    
    for(OrderItemSummary oi : orderItems){        
      Decimal orderQty = oi.Quantity;
      Map<String,Object> orderItemMap = new Map<String,Object>{
        'orderQty' => orderQty,
        'orderReferenceNumber' => (oi.OrderSummary.OriginalOrder.OrderReferenceNumber != null ? oi.OrderSummary.OriginalOrder.OrderReferenceNumber : ''),
        'orderDate' => oi.OrderSummary.OriginalOrder.OrderedDate,
        'orderNumber' => oi.OrderSummary.OriginalOrder.OrderNumber
      };

      if(resultMap.containsKey(oi.OrderSummary.OriginalOrderId)){
        Map<String,Object> existingMap = (Map<String,Object>) resultMap.get(oi.OrderSummary.OriginalOrderId);
        orderQty = orderQty + (Decimal)existingMap.get('orderQty');          
      }

      orderItemMap.put('orderQty', orderQTY);
      resultMap.put(oi.OrderSummary.OriginalOrderId, orderItemMap);
    }

   
    return resultMap;
  }

      
}