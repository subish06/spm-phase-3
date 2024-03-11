public with sharing class XC_CheckoutButtonController 
{
    @AuraEnabled
    public static Integer removeLowInventoryItems(String cartId){
        List<CartItem> cartItems = [SELECT Id, Quantity, Product2.XC_Available_Inventory__c,Product2.StockKeepingUnit FROM CartItem WHERE CartId =: cartId AND Product2.Name != 'Shipping Charge'];
        List<CartItem> deleteItems = new List<CartItem>();
        Integer cartItemsLeft = 0;
        for(CartItem item : cartItems){
            cartItemsLeft += 1;
            Decimal availQty = (item.Product2.XC_Available_Inventory__c != null ? item.Product2.XC_Available_Inventory__c : 0);
            
            if(item.Quantity > availQty){
                deleteItems.add(item);
                cartItemsLeft -= 1;
            }
        }

        delete deleteItems;
        return cartItemsLeft;
    }

    @AuraEnabled
    public static Map<String, Object> getInitData(String cartId, String effectiveAccountId, String communityId)
    {
        Map<String, Object> returnMap = new Map<String, Object>();

        try 
        {
            //String webstoreId = XC_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            //Boolean isPreOrder = XC_B2BUtils.isPreOrderAvailable();
            //Boolean productsQtyAvail = XC_B2BUtils.productsQtyAvailable(cartId);
            //String orderType = XC_B2BUtils.cartOrderType(cartId);

            List<CartItem> cartItems = [SELECT Id, Quantity, Product2.XC_Available_Inventory__c,Product2.StockKeepingUnit FROM CartItem WHERE CartId =: cartId AND Product2.Name != 'Shipping Charge'];
            //Boolean hasNonPreOrderItems = false;
            Boolean hasNonAvailItems = false;
            //String nonPreOrderItems = '';
            String unavailableQtyItems = '';
            for(CartItem item : cartItems){
                Decimal availQty = (item.Product2.XC_Available_Inventory__c != null ? item.Product2.XC_Available_Inventory__c : 0);
                /*if(item.Product2.XC_Available_Inventory__c > 0){
                    hasNonPreOrderItems = true;
                    nonPreOrderItems += item.Product2.StockKeepingUnit + ',';
                }*/
                if(item.Quantity > availQty){
                    hasNonAvailItems = true;
                    unavailableQtyItems += item.Product2.StockKeepingUnit + ',';
                }
            }

            unavailableQtyItems = unavailableQtyItems.removeEnd(',');
            //nonPreOrderItems = nonPreOrderItems.removeEnd(',');

            //returnMap.put('preorder', isPreOrder);
            returnMap.put('hasNonAvailItems', hasNonAvailItems);
            //returnMap.put('hasNonPreOrderItems', hasNonPreOrderItems);
            //returnMap.put('nonPreOrderItems', nonPreOrderItems);
            returnMap.put('unavailableQtyItems', unavailableQtyItems);
            //returnMap.put('orderType', orderType);

            ConnectApi.CartSummary cartSumm = XC_B2BGetInfo.getCartSummary(communityId, effectiveAccountId, cartId);

            if(cartSumm.status == ConnectApi.CartStatus.Checkout || cartSumm.status == ConnectApi.CartStatus.Active)
            {
                Account acc = [SELECT Id, XC_InvoicingAndDeliveryOnHold__c FROM Account WHERE Id = :cartSumm.accountId LIMIT 1];

                if(acc.XC_InvoicingAndDeliveryOnHold__c == 'All')
                {
                    returnMap.put('allowCheckout', false);
                    returnMap.put('showCreditHold', true);
                }
                else 
                {
                    if(cartSumm.totalProductCount == '0')
                    {
                        returnMap.put('allowCheckout', false);
                    }
                    else 
                    {
                        returnMap.put('allowCheckout', true);
                    }
                    returnMap.put('showCreditHold', false);

                } 
            }
            else 
            {
                returnMap.put('allowCheckout', false);
                returnMap.put('showCreditHold', false);
            }
        } 
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            returnMap.put('error', true);
        }

        return returnMap;
    }

    /*@AuraEnabled
    public static void saveCartOrderType(String cartId, String orderType){
        XC_B2BUtils.saveCartOrderType(cartId, orderType);
    }*/
    
}