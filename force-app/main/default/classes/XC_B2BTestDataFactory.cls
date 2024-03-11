@isTest(SeeAllData=true)
public without sharing class XC_B2BTestDataFactory 
{
    public static final String TEST_PROFILE_NAME = 'All Axcess Community User';
    public static final String TEST_STOREFRONT_NAME = 'testStorefront';
    //public static final String TEST_STOREFRONT_TYPE = 'B2B';
    public static final String TEST_STOREFRONT_SUPPORTED_LANG = 'en_US';
    public static final String TEST_STOREFRONT_DEF_LANG = 'en_US';
    public static final String TEST_STOREFRONT_PRICE_STRATEGY = 'LowestPrice';

    //public static final String TEST_PRODUCT_NAME = 'testClassProduct';
    public static final String TEST_PRICEBOOK_NAME = 'testClassPriceBook';
    //public static final String TEST_CATEGORY_NAME = 'testClassCategory';

    //public static final String COMMUNITY_NAME = 'Revenera Store';

    private static final String LOCALE_STRING = 'en_US';
    private static final String TIME_ZONE = 'America/New_York';
    private static final String EMAIL_ENCODING = 'UTF-8';

    //public static final String TEST_PERM_SET_NAME = 'B2BBuyer';


    private XC_B2BTestDataFactory() {}

    // public static void setupStorefront()
    // {
    //     WebStore testStore = new WebStore();
    //     testStore.Name = TEST_STOREFRONT_NAME;
    //     //testStore.Type = TEST_STOREFRONT_TYPE;
    //     testStore.SupportedLanguages = TEST_STOREFRONT_SUPPORTED_LANG;
    //     testStore.DefaultLanguage = TEST_STOREFRONT_DEF_LANG;
    //     testStore.PricingStrategy = TEST_STOREFRONT_PRICE_STRATEGY;

    //     insert testStore;

    //     WebStore qryStore = [SELECT Id, Name, Type, DefaultLanguage, SupportedLanguages, MaxValuesPerFacet, PaginationSize, StrikethroughPricebookId, OptionsGuestBrowsingEnabled, PricingStrategy, CheckoutTimeToLive, CheckoutValidAfterDate, LocationId, Description 
    //         FROM WebStore WHERE Name = :TEST_STOREFRONT_NAME];

    //     System.debug(qryStore);
    // }

    public static String getWebStoreId(String storeName)
    {
        return [SELECT Id FROM WebStore WHERE Name = :storeName].Id;
    }

    public static Account setupAccount(String accountName)
    {
        Account acc = new Account();
        acc.Name = accountName;

        insert acc;

        BuyerAccount buyAcc = new BuyerAccount();
        buyAcc.BuyerId = acc.Id;
        buyAcc.IsActive = true;
        buyAcc.BuyerStatus = 'Active';
        buyAcc.Name = acc.Name;
        
        insert buyAcc;
        
        return acc;
    }

    //all lists must be the same length, each index is a single contact
    public static Contact setupContact(String firstName, String lastName, String email, String accountId, Boolean doInsert)
    {
        Contact con = new Contact();
        con.FirstName = firstName;
        con.LastName = lastName;
        con.Email = email;
        con.AccountId = accountId;

        if(doInsert)
        {
            insert con;
        }

        return con;
    }

    //public static List<Contact> setupContacts(List<String> firstNameList, List<String> lastNameList, List<String> emailList, List<Id> accountIdList)
    // {
        // List<Contact> conList = new List<Contact>();

        // for(Integer i = 0; i < firstNameList.size(); i++)
        // {
        //     Contact con = new Contact();
        //     con.FirstName = firstNameList[i];
        //     con.LastName = lastNameList[i];
        //     con.Email = emailList[i];
        //     con.AccountId = accountIdList[i];

        //     conList.add(con);
        // }
    // }
    
    //pass in null for permissionSetName if one isnt being used, will also be ingnored if doInsert == false
    public static User setupUser(Contact con, String profileName, String permissionSetName, Boolean doInsert)
    {
        User curUser = new User();
            
        curUser.TimeZoneSidKey = TIME_ZONE;
        curUser.LanguageLocaleKey = LOCALE_STRING;
        curUser.LocaleSidKey = LOCALE_STRING;
        curUser.EmailEncodingKey = EMAIL_ENCODING;
        curUser.IsActive = true;
        curUser.FirstName = con.FirstName;
        curUser.LastName = con.LastName;
        curUser.Email = con.Email;

        String alias = con.Email.substringBefore('@');
        alias = alias.length() > 8 ? alias.substring(0, 8) : alias;
        curUser.Alias = alias;

        curUser.Username = con.Email;
        //curUser.CommunityNickname = 'fac34eseve@vvevrr.testcdeb';
        curUser.ContactId = con.Id;
        curUser.ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;

        if(doInsert)
        {
            insert curUser;
        }

        if(String.isNotBlank(permissionSetName) && doInsert)
        {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = curUser.Id;
            //psa.IsActive = true;
            psa.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1].Id;
            insert psa;
        }

        curUser = [SELECT Id, ContactId, AccountId, FirstName, LastName, Email FROM User WHERE Id = :curUser.Id];

        return curUser;
    }

    public static Map<String, Object> setupAccountAndUser(String accountName, String firstName, String lastName, String email, String username, String profileName, String permissionSetName)
    {
        Map<String,Object> returnMap = new Map<String,Object>();

        Account acc = setupAccount(accountName);
        Contact con = setupContact(firstName, lastName, email, acc.Id, true);
        User u = setupUser(con, profileName, permissionSetName, true);

        returnMap.put('account', acc);
        returnMap.put('contact', con);
        returnMap.put('user', u);

        return returnMap;
    }

    

    public static Map<String, Object> setupStoreData(String storefrontName, String supportedLanguages, String defaultLanguage, String pricingStrategy, Account acc)
    {
        Map<String,Object> returnMap = new Map<String,Object>();

        WebStore curStore = new WebStore();
        curStore.Name = storefrontName;
        //curStore.Type = TEST_STOREFRONT_TYPE;
        curStore.SupportedLanguages = supportedLanguages;
        curStore.DefaultLanguage = defaultLanguage;
        curStore.PricingStrategy = pricingStrategy;

        insert curStore;

        returnMap.put('store', curStore);

        //WebStore curStore = [SELECT Id FROM WebStore WHERE Name = :TEST_STOREFRONT_NAME LIMIT 1];

        if(acc != null)
        {
            BuyerGroup buyGrp = new BuyerGroup();
            buyGrp.Name = 'test Buy Group';

            insert buyGrp;

            returnMap.put('buyerGroup', buyGrp);

            BuyerGroupMember bgm = new BuyerGroupMember();
            bgm.BuyerId = acc.Id;
            bgm.BuyerGroupId = buyGrp.Id;

            insert bgm;

            WebStoreBuyerGroup webBuyGrp = new WebStoreBuyerGroup();
            webBuyGrp.BuyerGroupId = buyGrp.Id;
            webBuyGrp.WebStoreId = curStore.Id;

            insert webBuyGrp;
        }
        
        return returnMap;
    }

    
    public static Map<String,Object> setupCatalogAndEntitlementAndPriceBookAndProducts(List<ProductData> productDataList, WebStore curStore, BuyerGroup buyGrp, String currencyIsoCode)
    {
        Map<String,Object> returnMap = new Map<String,Object>();

        List<Product2> prodList = new List<Product2>();

        for(ProductData prodData : productDataList)
        {
            Product2 prod = new Product2();
            prod.isActive = true;
            //prod.Family = 'Commercial';
            prod.Name = prodData.name;
            prod.ProductCode = prodData.productCode;
            prod.StockKeepingUnit = prodData.sku;

            prodList.add(prod);
        }
        

        insert prodList;

        returnMap.put('productList', prodList);

        ProductCatalog pc = new ProductCatalog();
        pc.Name = 'TestCatalog';

        insert pc;

        WebStoreCatalog wsc = new WebStoreCatalog();
        wsc.SalesStoreId = curStore.Id;
        wsc.ProductCatalogId = pc.Id;

        insert wsc;

        returnMap.put('catalog', pc);
        

        Pricebook2 newPriceBook = new Pricebook2();
        newPriceBook.IsActive = true;
        newPriceBook.Name = TEST_PRICEBOOK_NAME;
        //newPriceBook.IsStandard = true;
        // newPriceBook.ValidFrom = Date.today().addDays(-7);
        // newPriceBook.ValidTo = Date.today().addDays(7);

        insert newPriceBook;

        WebStorePricebook wspb = new WebStorePricebook();
        wspb.WebStoreId = curStore.Id;
        wspb.Pricebook2Id = newPriceBook.Id;
        wspb.IsActive = true;

        insert wspb;


        Pricebook2 standPB = new Pricebook2(Id = Test.getStandardPricebookId());//= [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        update standPB;
        
        CommerceEntitlementPolicy cep = new CommerceEntitlementPolicy();
        cep.isActive = true;
        cep.Name = 'testCEP';
        cep.CanViewPrice = true;
        cep.CanViewProduct = true;

        insert cep;

        CommerceEntitlementBuyerGroup cebg = new CommerceEntitlementBuyerGroup();
        cebg.BuyerGroupId = buyGrp.Id;
        cebg.PolicyId = cep.Id;

        insert cebg;
        
        BuyerGroupPricebook bgpb = new BuyerGroupPricebook();
        bgpb.Pricebook2Id = newPriceBook.Id;
        bgpb.BuyerGroupId = buyGrp.Id;
        bgpb.IsActive = true;
        bgpb.Priority = 2;

        insert bgpb;

        List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
        List<CommerceEntitlementProduct> cepList = new List<CommerceEntitlementProduct>();

        for(Product2 prod : prodList)
        {
            PricebookEntry pbe = new PricebookEntry();
            pbe.IsActive = true;
            pbe.UnitPrice = 5.00;
            pbe.Product2Id = prod.Id;
            pbe.Pricebook2Id = standPB.Id;
            //pbe.CurrencyIsoCode = currencyIsoCode; //only used if multicurrency is enabled
            pbe.UseStandardPrice = false;

            pbEntryList.add(pbe); 
            
            pbe = new PricebookEntry();
            pbe.IsActive = true;
            pbe.UnitPrice = 5.00;
            pbe.Product2Id = prod.Id;
            pbe.Pricebook2Id = newPriceBook.Id;
            //pbe.CurrencyIsoCode = currencyIsoCode; //only used if multicurrency is enabled
            pbe.UseStandardPrice = false;

            pbEntryList.add(pbe); 

            CommerceEntitlementProduct entitleProd = new CommerceEntitlementProduct();
            entitleProd.ProductId = prod.Id;
            entitleProd.PolicyId = cep.Id;

            cepList.add(entitleProd);
        }
        
        insert pbEntryList;
        insert cepList;

        return returnMap;
    }

    public static void setupCategorys(Map<String, List<Product2>> categoryNameToProductList, ProductCatalog prodCatalog)
    {
        List<ProductCategory> prodCatList = new List<ProductCategory>();
        for(String key : categoryNameToProductList.keySet())
        {
            ProductCategory prodCat = new ProductCategory();
            //prodCat.CurrencyIsoCode = currencyIsoCode; //only used if multicurrency is enabled
            prodCat.Name = key;
            prodCat.CatalogId = prodCatalog.Id;

            prodCatList.add(prodCat);

            
        }
        
        insert prodCatList;

        List<ProductCategoryProduct> prodCatProdList = new List<ProductCategoryProduct>();
        for(ProductCategory prodCat : prodCatList)
        {
            for(Product2 prod : categoryNameToProductList.get(prodCat.Name))
            {
                ProductCategoryProduct prodCatProd = new ProductCategoryProduct();
                prodCatProd.ProductId = prod.Id;
                //prodCatProd.CatalogId = pc.Id;
                //prodCatProd.CurrencyIsoCode = currencyIsoCode; //only used if multicurrency is enabled
                prodCatProd.ProductCategoryId = prodCat.Id;

                prodCatProdList.add(prodCatProd);
            }
        }

        insert prodCatProdList;       
    }

    public static Map<String, Object> createCart(User u, WebStore store)
    {
        Map<String,Object> returnMap = new Map<String,Object>();

        WebCart curCart = new WebCart();
        curCart.AccountId = u.AccountId;
        curCart.Name = 'Cart';
        curCart.OwnerId = u.Id;
        curCart.Status = 'Active';
        curCart.WebStoreId = store.Id;

        insert curCart;

        returnMap.put('cart', curCart);

        OrderDeliveryMethod odm = new OrderDeliveryMethod();
        odm.Name = 'placeholder';
        odm.Carrier = 'placeholder';
        odm.isActive = true;
        odm.ClassOfService = 'placeholder';
    
        insert odm;

        CartDeliveryGroup newDelGrp = new CartDeliveryGroup();
        newDelGrp.CartId = curCart.Id;
        newDelGrp.Name = 'Default Delivery';
        newDelGrp.DeliveryMethodId = odm.Id;
        newDelGrp.DeliverToStreet = '123 fake st';
        newDelGrp.DeliverToCity = 'Grapevine';
        newDelGrp.DeliverToState = 'Texas';
        newDelGrp.DeliverToPostalCode = '76051';
        newDelGrp.DeliverToCountry = 'United States';
        insert newDelGrp;

        returnMap.put('cartDeliveryGroup', newDelGrp);

        return returnMap;
    }

    public static void createCartItems(WebCart curCart, List<Product2> prodList, CartDeliveryGroup newDelGrp)
    {
        //List<PricebookEntry> pbEntryList = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN :prodList AND Pricebook2.IsStandard = false];
        Map<Id, PricebookEntry> productToPriceBookEntryMap = new Map<Id, PricebookEntry>();

        for(PricebookEntry pbe : [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Product2Id IN :prodList AND Pricebook2.IsStandard = false])
        {
            productToPriceBookEntryMap.put(pbe.Product2Id, pbe);
        }

        List<CartItem> cartItemList = new List<CartItem>();

        // List<ConnectApi.BatchInput> batchInput = new List<ConnectApi.BatchInput>();


        for(Product2 prod : prodList)
        {
            // ConnectApi.CartItemInput cii = new ConnectApi.CartItemInput();

            // cii.productId = prod.Id;
            // cii.quantity = '2';
            // cii.type = ConnectApi.CartItemType.Product;

            // batchInput.add(new ConnectApi.BatchInput(cii));

            PricebookEntry pbe = productToPriceBookEntryMap.get(prod.Id);

            CartItem newItem = new CartItem();
            newItem.cartId = curCart.Id;
            newItem.Name = 'Cart Item';
            newItem.Product2Id = prod.Id;
            newItem.Sku = Prod.StockKeepingUnit;
            newItem.SalesPrice = pbe.UnitPrice;
            newItem.ListPrice = pbe.UnitPrice;
            newItem.UnitAdjustedPrice = pbe.UnitPrice;
            newItem.Type = (String)ConnectApi.CartItemType.PRODUCT.name();
            newItem.CartDeliveryGroupId = newDelGrp.Id;
            newItem.Quantity = 5;
            newItem.TotalPrice = (newItem.SalesPrice * newItem.Quantity).setScale(2);
            newItem.TotalLineAmount = newItem.TotalPrice;

            cartItemList.add(newItem);
        }
        insert cartItemList;
        // List<ConnectApi.BatchResult> addResults = ConnectApi.CommerceCart.addItemsToCart(curCart.WebStoreId, curCart.AccountId, 'active', batchInput);
            
        // for(ConnectApi.BatchResult curResult : addResults)
        // {
        //     System.debug(curResult);
        //     if(!curResult.isSuccess())
        //     {
        //         System.debug('error in add to cart');
        //         System.debug(addResults);
        //         throw new TestDataException();
        //     }
        // }
        
    }

    public static Map<String, Object> convertToOrder(User u, WebCart curCart)
    {
        Map<String,Object> returnMap = new Map<String,Object>();

        Order newOrder = new Order();
        newOrder.OwnerId = u.Id;
        newOrder.AccountId = curCart.AccountId;
        newOrder.SalesStoreId = curCart.WebStoreId;
        //newOrder.CurrencyIsoCode = curCart.CurrencyIsoCode; //only used if multicurrency is enabled
        newOrder.EffectiveDate = Date.today();
        newOrder.Status = 'Draft';

        insert newOrder;
        CartDeliveryGroup cdg = [SELECT Id, DeliveryMethodId, DeliverToName, DeliverToStreet, DeliverToState, DeliverToCity, DeliverToPostalCode, DeliverToCountry FROM CartDeliveryGroup WHERE CartId = :curCart.Id LIMIT 1];
        

        CartCheckoutSession newSession = new CartCheckoutSession();
        newSession.WebCartId = curCart.Id;
        newSession.Name = curCart.Id;
        newSession.State = 'Start';
        newSession.NextState = '';
        newSession.IsProcessing = false;
        newSession.IsArchived = false;
        newSession.OrderId = newOrder.Id;
        //newSession.CurrencyIsoCode = newOrder.CurrencyIsoCode; //only used if multicurrency is enabled

        insert newSession;

        //CartDeliveryGroup cdg = [SELECT Id, DeliveryMethodId FROM CartDeliveryGroup WHERE CartId = :curCart.Id LIMIT 1];

        CartDeliveryGroupMethod cdgm = new CartDeliveryGroupMethod();
        cdgm.WebCartId = curCart.Id;
        cdgm.CartCheckoutSessionId = newSession.Id;
        cdgm.CartDeliveryGroupId = cdg.Id;
        cdgm.DeliveryMethodId = cdg.DeliveryMethodId;
        cdgm.Name = 'test cdgm';
        cdgm.ShippingFee = 0.00;

        insert cdgm;

        System.debug(cdg.DeliveryMethodId);
        
        OrderDeliveryGroup odg = new OrderDeliveryGroup();
        //odg.CurrencyIsoCode = cdg.CurrencyIsoCode;
        odg.OrderId = newOrder.Id;
        System.debug(cdg.DeliveryMethodId);
        odg.OrderDeliveryMethodId = cdg.DeliveryMethodId;
        odg.DeliverToName = 'test';
        odg.DeliverToStreet = cdg.DeliverToStreet;
        odg.DeliverToCity = cdg.DeliverToCity;
        odg.DeliverToState = cdg.DeliverToState;
        odg.DeliverToPostalCode = cdg.DeliverToPostalCode;
        odg.DeliverToCountry = cdg.DeliverToCountry;

        insert odg;

        List<OrderItem> orderItemList = new List<OrderItem>();

        for(CartItem curCartItem : [SELECT Id, Quantity, Product2Id, TotalPrice, UnitAdjustedPrice, ListPrice FROM CartItem WHERE CartId = :curCart.Id])
        {
            OrderItem newItem = new OrderItem();
            newItem.OrderId = newOrder.Id;
            newItem.TotalLineAmount = curCartItem.TotalPrice;
            newItem.UnitPrice = curCartItem.UnitAdjustedPrice;
            newItem.ListPrice = curCartItem.ListPrice;
            newItem.Quantity = curCartItem.Quantity;
            newItem.Product2Id = curCartItem.Product2Id;
            newItem.OrderDeliveryGroupId = odg.Id;

            orderItemList.add(newItem);
        }

        insert orderItemList;

        returnMap.put('order', newOrder);
        returnMap.put('orderItemList', orderItemList);

        return returnMap;
    }

    public static Map<String, Object> convertToOrderSummary(Order newOrder)
    {
        Map<String, Object> returnMap = new Map<String, Object>();

        newOrder.Status = 'Activated';

        update newOrder;

        ConnectApi.OrderSummaryInputRepresentation newSum = new ConnectApi.OrderSummaryInputRepresentation();
        newSum.orderLifeCycleType = 'UNMANAGED';
        newSum.Status = 'Created';
        newSum.orderId = newOrder.Id;
        ConnectApi.OrderSummaryOutputRepresentation retSum = ConnectApi.OrderSummaryCreation.createOrderSummary(newSum);

        returnMap.put('orderSummaryId', retSum.orderSummaryId);

        return returnMap;
    }

    // public static ConnectApi.ProductSummaryPage getSearchProds()
    // {
    //     ConnectApi.ProductSummaryPage returnPage = new ConnectApi.ProductSummaryPage();
    //     List<ConnectApi.ProductSummary> searchProds = new List<ConnectApi.ProductSummary>();
    //     String currCode = '';

    //     for(Product2 prod : [SELECT Id, Name,  CurrencyIsoCode, XC_SubscriptionLength__c, Description, XC_ProductFeatures__c FROM Product2 WHERE Name = :TEST_PRODUCT_NAME])
    //     {
    //         ConnectApi.ProductSummary prodSum = new ConnectApi.ProductSummary();
    //         prodSum.name = prod.Name;
    //         prodSum.id = prod.Id;
    //         prodSum.fields = new Map<String, ConnectApi.FieldValue>();
    //         ConnectApi.FieldValue curField = new ConnectApi.FieldValue();
    //         curField.value = prod.Id;
    //         prodSum.fields.put('Id', curField);
    //         //curField = new ConnectApi.FieldValue();
    //         //curField.value = prod.CurrencyIsoCode; //only used if multicurrency is enabled
    //         //prodSum.fields.put('CurrencyIsoCode', curField);
    //         curField = new ConnectApi.FieldValue();
    //         curField.value = prod.XC_SubscriptionLength__c;
    //         prodSum.fields.put('XC_SubscriptionLength__c', curField);
    //         curField = new ConnectApi.FieldValue();
    //         curField.value = prod.Description;
    //         prodSum.fields.put('Description', curField);
    //         curField = new ConnectApi.FieldValue();
    //         curField.value = prod.XC_ProductFeatures__c;
    //         prodSum.fields.put('XC_ProductFeatures__c', curField);

    //         ConnectApi.PricingResultLineItem curPrice = new ConnectApi.PricingResultLineItem();
    //         curPrice.listPrice = '100.00';
    //         curPrice.pricebookEntryId = prod.Id;
    //         curPrice.productId = prod.Id;
    //         curPrice.success = true;
    //         curPrice.unitPrice = '100.00';

    //         prodSum.prices = curPrice;

    //         currCode = 'USD'; //prod.CurrencyIsoCode; //only used if multicurrency is enabled
    //         searchProds.add(prodSum);
    //     }

    //     returnPage.currencyIsoCode = currCode;
    //     returnPage.pageSize = searchProds.size();
    //     returnPage.total = searchProds.size();
    //     returnPage.products = searchProds;

    //     return returnPage;
    // }

    public class ProductData
    {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String productCode;

        @AuraEnabled
        public String sku;

        @AuraEnabled
        public Double price;
    }

    public class TestDataException extends Exception{}
}