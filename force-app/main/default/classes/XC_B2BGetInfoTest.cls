@isTest(SeeAllData=true)
public without sharing class XC_B2BGetInfoTest 
{
    private static final String TEST_USERNAME = 'test@testClassUsername.com';
    private static final String TEST_ACCOUNT_NAME = 'testClassAccount';

    public static Boolean IS_CHECKOUT = false;
    public static Boolean IS_CART_EMPTY = false;
    public static Id userId;

    @isTest
    public static void testGetCartSummary()
    { 
        Map<String,Object> storeDataMap = new Map<String,Object>();

        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = TRUE AND UserRoleId != null LIMIT 1][0])
        {
            storeDataMap.putAll(XC_B2BTestDataFactory.setupAccountAndUser(TEST_ACCOUNT_NAME, 'firstName', 'lastName', 'email@fake.com123', 'email@fake.com123', XC_B2BTestDataFactory.TEST_PROFILE_NAME, null));
            storeDataMap.putAll(XC_B2BTestDataFactory.setupStoreData(XC_B2BTestDataFactory.TEST_STOREFRONT_NAME, XC_B2BTestDataFactory.TEST_STOREFRONT_SUPPORTED_LANG, XC_B2BTestDataFactory.TEST_STOREFRONT_DEF_LANG, XC_B2BTestDataFactory.TEST_STOREFRONT_PRICE_STRATEGY, (Account)storeDataMap.get('account')));
            
            List<XC_B2BTestDataFactory.ProductData> prodDataList = new List<XC_B2BTestDataFactory.ProductData>();
            XC_B2BTestDataFactory.ProductData prodData = new XC_B2BTestDataFactory.ProductData();
            prodData.name = 'product1';
            prodData.productCode = 'prod111';
            prodData.sku = 'prod111';
            prodData.price = 123.45;

            prodDataList.add(prodData);

            prodData = new XC_B2BTestDataFactory.ProductData();
            prodData.name = 'product2';
            prodData.productCode = 'prod222';
            prodData.sku = 'prod222';
            prodData.price = 999.99;

            prodDataList.add(prodData);

            storeDataMap.putAll(XC_B2BTestDataFactory.setupCatalogAndEntitlementAndPriceBookAndProducts(prodDataList, (WebStore)storeDataMap.get('store'), (BuyerGroup)storeDataMap.get('buyerGroup'), 'USD'));

        }

        System.runAs((User)storeDataMap.get('user'))
        {
            storeDataMap.putAll(XC_B2BTestDataFactory.createCart((User)storeDataMap.get('user'), (WebStore)storeDataMap.get('store')));

            System.debug(storeDataMap.get('productList'));
            XC_B2BTestDataFactory.createCartItems((WebCart)storeDataMap.get('cart'), (List<Product2>)storeDataMap.get('productList'), (CartDeliveryGroup)storeDataMap.get('cartDeliveryGroup'));
            //storeDataMap.putAll(XC_B2BTestDataFactory.convertToOrder((User)storeDataMap.get('user'), (WebCart)storeDataMap.get('cart')));

            WebCart curCart = (WebCart)storeDataMap.get('cart');
            Account acc = (Account)storeDataMap.get('account');
            User u = (User)storeDataMap.get('user');

            XC_B2BGetInfoTest.userId = u.Id;
            ConnectApi.CartSummary cartSumm = XC_B2BGetInfo.getCartSummary(null, acc.Id, curCart.Id);

            System.assertEquals(curCart.Id, cartSumm.cartId);
        }




















        // System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = TRUE AND UserRoleId != null LIMIT 1][0])
        // {
        //     XC_B2BTestDataFactory.setupStoreData(TEST_ACCOUNT_NAME, TEST_USERNAME, TEST_PROFILE_NAME);
        //     XC_B2BTestDataFactory.createCartItems(TEST_USERNAME);
            
        // }
        // Test.startTest();
        // WebCart curCart;
        // ConnectApi.CartSummary cartSumm;
        // User u = [SELECT Id, AccountId FROM User WHERE Username = :TEST_USERNAME LIMIT 1][0];
        // System.runAs(u)
        // {
        //     Id commId = [SELECT Id, Name FROM Network WHERE Name = :XC_B2BTestDataFactory.COMMUNITY_NAME LIMIT 1].Id;

        //     curCart = [SELECT Id FROM WebCart WHERE OwnerId = :u.Id AND Status = 'active'];

        //     XC_B2BGetInfoTest.userId = u.Id;
        //     cartSumm = XC_B2BGetInfo.getCartSummary(commId, u.AccountId, curCart.Id);
            
            

        // }
        // Test.stopTest();
        // System.assertEquals(curCart.Id, cartSumm.cartId);
    }
}