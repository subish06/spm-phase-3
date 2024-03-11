@isTest
public without sharing class XC_CheckoutDeliveryMethodTest 
{
    private static final String TEST_USERNAME = 'test@testClassUsername.com';
    private static final String TEST_ACCOUNT_NAME = 'testClassAccount';

    @isTest
    public static void populateShipping()
    {

        Test.startTest();

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
            System.assertEquals(0, [SELECT Count() FROM CartItem WHERE Type = 'Charge' AND CartId = :curCart.Id]);
            XC_CheckoutDeliveryMethod.populateShipping(new List<Id>{curCart.Id});
            System.assertEquals(1, [SELECT Count() FROM CartItem WHERE Type = 'Charge' AND CartId = :curCart.Id]);
        }

        Test.stopTest();
    }
}