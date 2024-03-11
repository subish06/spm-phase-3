public without sharing class XC_CheckoutPostOrderProcessing 
{
    @InvocableMethod(label='Post Order Processing')
    public static void XC_CheckoutFlowPostOrderProcessing(List<CartCheckoutSession> curSessionList) 
    {
        CartCheckoutSession curSession = curSessionList[0];
        curSession = [SELECT Id, OrderId, WebCartId FROM CartCheckoutSession WHERE Id = :curSession.Id LIMIT 1];

        OrderSummary curSummary = [SELECT Id, Status, XC_InvoicingAndDeliveryOnHold__c, Account.XC_InvoicingAndDeliveryOnHold__c, XC_RequestedShipDate__c, OriginalOrder.EffectiveDate FROM OrderSummary WHERE OriginalOrderId = :curSession.OrderId LIMIT 1];

        if(curSummary.Status == 'Created')
        {
            //Id orderId = curSession.OrderId;
            WebCart curCart = [SELECT Id, XC_RequestedShipDate__c FROM WebCart WHERE Id = :curSession.WebCartId LIMIT 1];
            Date requestShipDate = curCart.XC_RequestedShipDate__c != null ? curCart.XC_RequestedShipDate__c : Date.today();    
            Date orderCreatedDate = curSummary.OriginalOrder.EffectiveDate;
            orderCreatedDate = orderCreatedDate.addDays(7);


            List<OrderItem> orderItemList = [SELECT Id, XC_Estimated_Ship_Date__c FROM OrderItem WHERE OrderId = :curSession.OrderId];
            
            for(OrderItem curItem : orderItemList)
            {
                curItem.XC_Estimated_Ship_Date__c = (orderCreatedDate > requestShipDate ? orderCreatedDate : requestShipDate);
            }

            update orderItemList;

            curSummary.XC_InvoicingAndDeliveryOnHold__c = curSummary.Account.XC_InvoicingAndDeliveryOnHold__c;
            curSummary.XC_RequestedShipDate__c = requestShipDate;
            
            //do this last
            curSummary.Status = 'Processed';
            update curSummary;

            Order o = new Order( 
                Id = curSession.OrderId,
                Status = 'Draft',
                XC_Order_Status__c = 'Submitted'
            );

            update o;
        }

        deductInventories(curSession.OrderId);
    }

    public static void deductInventories(String orderId) 
    {
        system.debug('deduct inv');

        List<OrderItem> orderItems =   [SELECT Id,Quantity,Product2Id, Product2.XC_Available_Inventory__c FROM OrderItem WHERE OrderId =: orderId AND Type != 'Delivery Charge'];
        List<Product2> prods = new List<Product2>();
        for(OrderItem oi : orderItems){
            if(oi.Product2.XC_Available_Inventory__c >0){
                Decimal newQty = oi.Product2.XC_Available_Inventory__c - oi.Quantity;
                Product2 p = new Product2(
                    Id = oi.Product2Id,
                    XC_Available_Inventory__c = (newQty > 0 ? newQty : 0)
                );

                prods.add(p);
            }
        }

        if(prods.size()>0){
            system.debug('prodsize update inv: ' +prods);
            update prods;
        }

       
    }

}