public with sharing class XC_B2BGetInfo 
{
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(String communityId, String effectiveAccountId, String activeCartOrId) 
    {
        String webstoreId = XC_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        return Test.isRunningTest() ? getTestSummary() : ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, activeCartOrId);
    }

    private static ConnectApi.CartSummary getTestSummary()
    {
        WebCart curCart = [SELECT Id, AccountId FROM WebCart WHERE OwnerId = :XC_B2BGetInfoTest.userId LIMIT 1];

        System.debug(XC_B2BGetInfoTest.IS_CHECKOUT);
        ConnectApi.CartSummary newSum = new ConnectApi.CartSummary();
        newSum.accountId = curCart.AccountId;
        newSum.cartId = curCart.Id;
        newSum.status = XC_B2BGetInfoTest.IS_CHECKOUT ? ConnectApi.CartStatus.Checkout : ConnectApi.CartStatus.Active;
        newSum.totalProductCount = XC_B2BGetInfoTest.IS_CART_EMPTY ? '0' : '2';
        newSum.grandTotalAmount = '2000.00';
        System.debug(newSum);

        return newSum;
    }
}