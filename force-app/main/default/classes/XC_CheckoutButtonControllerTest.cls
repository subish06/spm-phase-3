@isTest(SeeAllData=true)
public class XC_CheckoutButtonControllerTest 
{
    private static final String TEST_USERNAME = 'test@testClassUsername.com';
    private static final String TEST_ACCOUNT_NAME = 'testClassAccount';
    
    @isTest
    public static void getInitDataTest_AllowCheckout()
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
            Account acc = (Account)storeDataMap.get('account');
            User u = (User)storeDataMap.get('user');

            XC_B2BGetInfoTest.userId = u.Id;
            XC_B2BGetInfoTest.IS_CHECKOUT = false;

            Map<String,Object> returnMap = XC_CheckoutButtonController.getInitData(curCart.Id, acc.Id, null);

            System.debug(returnMap);
            System.assertEquals(true, (Boolean)returnMap.get('allowCheckout'));
            System.assertEquals(false, (Boolean)returnMap.get('showCreditHold'));

            CartDeliveryGroup curDelGrp = [SELECT Id, DeliverToName FROM CartDeliveryGroup WHERE CartId =: curCart.Id LIMIT 1];
            curDelGrp.DeliverToName = 'Test';
            update curDelGrp;

            Integer cartItemLeft = XC_CheckoutButtonController.removeLowInventoryItems(curCart.Id);
            Map<String,Object> billingMap = XC_CheckoutShippingAddressController.getBillingAddresses(curCart.Id);
            Map<String,Object> shipMap = XC_CheckoutShippingAddressController.getShippingAddresses(curCart.Id);


        }

        Test.stopTest();
    }

    @isTest
    public static void getInitDataTest_HasCreditHold()
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
            
            Account acc = (Account)storeDataMap.get('account');
            Account tempAcc = [SELECT Id, XC_InvoicingAndDeliveryOnHold__c FROM Account WHERE Id = :acc.Id];
            tempAcc.XC_InvoicingAndDeliveryOnHold__c = 'All';
            update tempAcc;
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
            XC_B2BGetInfoTest.IS_CHECKOUT = false;

            Map<String,Object> returnMap = XC_CheckoutButtonController.getInitData(curCart.Id, acc.Id, null);

            System.debug(returnMap);
            System.assertEquals(false, (Boolean)returnMap.get('allowCheckout'));
            System.assertEquals(true, (Boolean)returnMap.get('showCreditHold'));
        }

        Test.stopTest();
    }

    @isTest
    public static void getInitDataTest_InCheckout()
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
            Account acc = (Account)storeDataMap.get('account');
            User u = (User)storeDataMap.get('user');

            

            XC_B2BGetInfoTest.userId = u.Id;
            XC_B2BGetInfoTest.IS_CHECKOUT = true;
            XC_B2BGetInfoTest.IS_CART_EMPTY = true;

            Map<String,Object> returnMap = XC_CheckoutButtonController.getInitData(curCart.Id, acc.Id, null);

            System.debug(returnMap);
            System.assertEquals(false, (Boolean)returnMap.get('allowCheckout'));
            System.assertEquals(false, (Boolean)returnMap.get('showCreditHold'));
        }

        Test.stopTest();
    }
    
}