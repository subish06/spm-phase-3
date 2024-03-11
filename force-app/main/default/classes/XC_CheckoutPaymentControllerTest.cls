@isTest(SeeAllData=true)
public without sharing class XC_CheckoutPaymentControllerTest 
{
    private static final String TEST_USERNAME = 'test@testClassUsername.com';
    private static final String TEST_ACCOUNT_NAME = 'testClassAccount';
    
    @isTest 
    static void testGetPaymentInfo() 
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
            WebCart tempCart = [SELECT Id, PoNumber FROM WebCart WHERE Id = :curCart.Id];
            tempCart.PoNumber = 'abc123';
            update tempCart;

            Map<String, Object> returnMap = XC_CheckoutPaymentController.getPaymentInfo(curCart.Id);

            System.assertEquals(tempCart.PoNumber, (String)returnMap.get('purchaseOrderNumber'));
        }

        Test.stopTest();
    }

    @isTest 
    static void testSetPayment() 
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
            WebCart tempCart = [SELECT Id, PoNumber FROM WebCart WHERE Id = :curCart.Id];
            tempCart.PoNumber = 'abc123';
            update tempCart;

            Map<String, Object> paymentInfo = new Map<String, Object>{
                'poNumber' => '12345abc'
            };

            storeDataMap.putAll(XC_B2BTestDataFactory.convertToOrder((User)storeDataMap.get('user'), (WebCart)storeDataMap.get('cart')));

            XC_CheckoutPaymentController.setPayment('PurchaseOrderNumber', curCart.Id, paymentInfo);

            System.assert(tempCart.PoNumber != [SELECT Id, PoNumber FROM WebCart WHERE Id = :curCart.Id].PoNumber);
        }

        Test.stopTest();
    }

    @isTest 
    static void testSetPayment_CreditCard() 
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
            WebCart tempCart = [SELECT Id, PoNumber FROM WebCart WHERE Id = :curCart.Id];
            tempCart.PoNumber = 'abc123';
            update tempCart;

            Map<String, Object> paymentInfo = new Map<String, Object>{
                'poNumber' => '12345abc'
            };

            storeDataMap.putAll(XC_B2BTestDataFactory.convertToOrder((User)storeDataMap.get('user'), (WebCart)storeDataMap.get('cart')));

            XC_CheckoutPaymentController.setPayment('creditCard', curCart.Id, paymentInfo);

            System.assertEquals(null, [SELECT Id, PoNumber FROM WebCart WHERE Id = :curCart.Id].PoNumber);
        }

        Test.stopTest();
    }





    //     WebCart curCart;
    //     User u;
    //     System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null AND isActive = true LIMIT 1][0]) 
    //     {
    //         List<String> dphhServiceKeys = new List<String>{'visaAcquirerBIN','visaMerchantID','visaRequestorID','visaRequestorName','masterAcquirerBIN','masterMerchantID','masterRequestorID','masterRequestorName','amexAcquirerBIN','amexMerchantID','amexRequestorID','amexRequestorName','securityToken','merchantName','merchantUrl','merchantCountry','merchantCategory','merchantId'};

    //         List<Sys_Info__c> sysList = new List<Sys_Info__c>();

    //         for(String key : dphhServiceKeys)
    //         {
    //             Sys_Info__c sys = new Sys_Info__c();
    //             sys.Group__c = 'DHPP';
    //             sys.Name = key;
    //             sys.Value__c = 'junk';

    //             sysList.add(sys);
    //         }

    //         upsert sysList;

    //         XC_B2BTestDataFactory.setupStoreData(TEST_ACCOUNT_NAME, TEST_USERNAME, TEST_PROFILE_NAME);
    //         XC_B2BTestDataFactory.createCartItems(TEST_USERNAME);
    //         u = [SELECT Id, AccountId FROM User WHERE Username = :TEST_USERNAME LIMIT 1][0];
    //         curCart = [SELECT Id FROM WebCart WHERE OwnerId = :u.Id AND Status = 'active'];
    //         XC_B2BTestDataFactory.convertToOrder(TEST_USERNAME, curCart.Id);

    //         ContactPointAddress cpa = new ContactPointAddress();
    //         cpa.Name = 'Fake Billing - US';
    //         cpa.AddressType = 'Billing';//'Shipping';
    //         cpa.Street = '123 fake st';
    //         cpa.City = 'Fakeville';
    //         cpa.State = 'TX';
    //         cpa.PostalCode = '55555';
    //         cpa.Country = 'US';
    //         cpa.IsPrimary = true;
    //         cpa.ParentId = u.AccountId;

    //         insert cpa;
    //     }
    //     Test.startTest();

        
    //     Map<String, Object> returnMap;
        
    //     System.runAs(u)
    //     {
    //         //WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
    //         ContactPointAddress cpa1 = [SELECT Id, Name, Street, City, State, Country, PostalCode, IsDefault, ParentId, Address
    //                                     FROM ContactPointAddress WHERE ParentId = :u.AccountId LIMIT 1];

    //         String expectedPONumber = 'ImAPoNumber';
    //         String paymentType = 'PurchaseOrderNumber';
    //         String cartId = curCart.Id;
    //         Map<String, Object> billingAddress = createBillingMapFromAddress(cpa1.Address);
    //         Map<String, Object> paymentInfo = new Map<String, Object>();
    //         paymentInfo.put('poNumber', expectedPONumber);

    //         List<Object> fileList = new List<Object>();
    //         Map<Object, Object> curFile = new Map<Object, Object>();
    //         curFile.put('PathOnClient', 'test');
    //         curFile.put('Title', 'test');
    //         curFile.put('VersionData', 'test');
            
    //         fileList.add(curFile);
            
    //         XC_CheckoutPaymentController.setPayment(paymentType, cartId, billingAddress, paymentInfo, fileList);

    //         // Get the updated cart
    //         WebCart updatedCart = [SELECT Id, PaymentMethodId, PONumber FROM WebCart WHERE OwnerId = :u.Id AND Status = 'active'];
    //         System.assertEquals(null, updatedCart.PaymentMethodId);        
    //         System.assertEquals(expectedPONumber, updatedCart.PONumber);
    //     }
        
    //     Test.stopTest();
    // }

    // @isTest
    // public static void testGetPayment()
    // {
    //     WebCart curCart;
    //     User u;
    //     System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null AND isActive = true LIMIT 1][0]) 
    //     {
    //         List<String> dphhServiceKeys = new List<String>{'visaAcquirerBIN','visaMerchantID','visaRequestorID','visaRequestorName','masterAcquirerBIN','masterMerchantID','masterRequestorID','masterRequestorName','amexAcquirerBIN','amexMerchantID','amexRequestorID','amexRequestorName','securityToken','merchantName','merchantUrl','merchantCountry','merchantCategory','merchantId'};

    //         List<Sys_Info__c> sysList = new List<Sys_Info__c>();

    //         for(String key : dphhServiceKeys)
    //         {
    //             Sys_Info__c sys = new Sys_Info__c();
    //             sys.Group__c = 'DHPP';
    //             sys.Name = key;
    //             sys.Value__c = 'junk';

    //             sysList.add(sys);
    //         }

    //         upsert sysList;

    //         XC_B2BTestDataFactory.setupStoreData(TEST_ACCOUNT_NAME, TEST_USERNAME, TEST_PROFILE_NAME);
    //         XC_B2BTestDataFactory.createCartItems(TEST_USERNAME);
    //         u = [SELECT Id, AccountId FROM User WHERE Username = :TEST_USERNAME LIMIT 1][0];
    //         curCart = [SELECT Id, BillingAddress, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM WebCart WHERE OwnerId = :u.Id AND Status = 'active'];
    //         XC_B2BTestDataFactory.convertToOrder(TEST_USERNAME, curCart.Id);

    //         //curCart.BillingAddress = '';
    //         curCart.BillingCity = 'Fake';
    //         curCart.BillingCountry = 'NO';
    //         curCart.BillingPostalCode = '55555';
    //         curCart.BillingState = 'noMatch';
    //         curCart.BillingStreet = '123 mismatch';

    //         update curCart;

    //         ContactPointAddress cpa = new ContactPointAddress();
    //         cpa.Name = 'Fake Billing - US';
    //         cpa.AddressType = 'Billing';//'Shipping';
    //         cpa.Street = '123 fake st';
    //         cpa.City = 'Fakeville';
    //         cpa.State = 'TX';
    //         cpa.PostalCode = '55555';
    //         cpa.Country = 'United States';
    //         cpa.IsPrimary = true;
    //         cpa.ParentId = u.AccountId;

    //         insert cpa;
    //     }
    //     Test.startTest();

        
    //     Map<String, Object> returnMap;
        
    //     System.runAs(u)
    //     {
            
    //         Map<String, Object> paymentInfo = XC_CheckoutPaymentController.getPaymentInfo(curCart.Id);

    //         System.assertEquals(true, (Boolean)paymentInfo.get('allowPO'));
    //         System.assertEquals('HPP', (String)paymentInfo.get('paymentProcessor'));
    //     }
        
    //     Test.stopTest();

        
    // }

    // static Map<String, Object> createBillingMapFromAddress(Address address) {
    //     Map<String, Object> billingMap = new Map<String, Object>();
    //     billingMap.put('street', address.Street);
    //     billingMap.put('city', address.City);
    //     billingMap.put('state', address.State);
    //     billingMap.put('country', address.Country);
    //     billingMap.put('postalCode', address.PostalCode);
    //     billingMap.put('latitude', address.Latitude);
    //     billingMap.put('longitude', address.Longitude);
        
    //     return billingMap;
    // }
}