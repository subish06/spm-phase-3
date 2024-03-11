public without sharing class XC_B2BUtils 
{
    private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();
    private static Map<String, ConnectApi.CartItemSortOrder> sortOrderCache = new Map<String, ConnectApi.CartItemSortOrder>();

    public static String resolveCommunityIdToWebstoreId(String communityId) 
    {
        if (communityIdToWebStoreIdCache.containsKey(communityId)) 
        {
            return communityIdToWebStoreIdCache.get(communityId);
        } 
        else 
        {
            List<WebStoreNetwork> wsnList = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1];
            String webStoreId = Test.isRunningTest() && communityId == null ? XC_B2BTestDataFactory.getWebStoreId(XC_B2BTestDataFactory.TEST_STOREFRONT_NAME) : wsnList[0].WebStoreId;//[SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].WebStoreId;
            communityIdToWebStoreIdCache.put(communityId, webStoreId);
            return webStoreId;
        }
    }

    // public static ConnectApi.CartItemSortOrder resolveSortParam(String sortParam) 
    // {
    //     if (sortOrderCache.isEmpty()) 
    //     {
    //         for (ConnectApi.CartItemSortOrder sortOrder : ConnectApi.CartItemSortOrder.values()) 
    //         {
    //             sortOrderCache.put(sortOrder.name(), sortOrder);
    //         }
    //     }
    //     return sortOrderCache.get(sortParam);
    // }
        
    public static String getUserAccountID() 
    {
        String userId = UserInfo.getUserId();
        return [SELECT AccountId FROM User WHERE Id = :userId].AccountId;
    }

    public static List<BuyerGroup> getUserBuyerGroup(String accountId){
        //String buyerGroupId = [SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: accountId LIMIT 1].BuyerGroupId;
        List<BuyerGroup> bg = [SELECT Id, XC_Pre_Order_End_Date__c, XC_Pre_Order_Start_Date__c, XC_Start_of_Season__c FROM BuyerGroup WHERE Id in (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: accountId)];

        return bg;
    }

    /*public static Boolean isPreOrderAvailable(){
        String accountId = getUserAccountID();
        List<BuyerGroup> bgs = getUserBuyerGroup(accountId);
        system.debug('buyer group: ' + bgs);
        Boolean isPreOrder = false;
        for(BuyerGroup bg : bgs){
            if(bg.XC_Pre_Order_End_Date__c != null && bg.XC_Pre_Order_Start_Date__c != null){
                if(bg.XC_Pre_Order_Start_Date__c <= Date.today() && bg.XC_Pre_Order_End_Date__c >= Date.today()){
                    isPreOrder = true;
                }
            }
        }        

        system.debug('ispreorder: ' + isPreOrder);

        return isPreOrder;
    }

    public static String cartOrderType(String cartId){
        String orderType = [SELECT XC_Order_Type__c FROM WebCart WHERE Id=: cartId LIMIT 1].XC_Order_Type__c;
        return orderType;
    }

    public static void saveCartOrderType(String cartId, String orderType){
        Webcart cart = new WebCart(
            Id = cartId, 
            XC_Order_Type__c = orderType
        );

        update cart;        
    }

    public static Boolean productsQtyAvailable(String cartId){
        List<CartItem> cartItems = [SELECT Id, Quantity, Product2.XC_Available_Inventory__c FROM CartItem WHERE CartId =: cartId];
        Boolean availableQty = true;

        for(CartItem item : cartItems){
            Decimal availQty = (item.Product2.XC_Available_Inventory__c != null ? item.Product2.XC_Available_Inventory__c : 0);
            if(item.Quantity > availQty){
                availableQty = false;
            }
        }
        return availableQty;
    }*/
}