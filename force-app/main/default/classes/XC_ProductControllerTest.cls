@IsTest
public  class XC_ProductControllerTest {
    @TestSetup
    public static void makeData(){
        
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' Limit 1];
        
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
         
        Account testAccount = new Account(Name = 'test account');
        insert testAccount;
        
        String contactEmail = 'contemail@fakeemail.com.invalid'; 
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = testAccount.Id, Email = contactEmail);
        insert testContact;
        
        insert new BuyerAccount(BuyerId = testAccount.Id, Name = 'Test Buyer', IsActive = TRUE);
        
        Id pricebookId = Test.getStandardPricebookId();
        System.debug(pricebookId);
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            Name = 'Standard Price Book',
            IsActive = TRUE
        );
        upsert standardPricebook;
        Pricebook2 nadtc = new Pricebook2(
            Name = 'NA_DTC',
            IsActive = TRUE
        );
        insert nadtc;
        
        Product2 testProduct = new Product2(
            Name = 'test product',
            StockKeepingUnit = 'tst123',
            IsActive = TRUE
        );
        insert testProduct;
        
        Product2 testProduct2 = new Product2(
            Name = 'test product',
            StockKeepingUnit = 'tst234',
            IsActive = TRUE,
            Type = 'Base'
        );
        insert testProduct2;
        
        /*insert new ProductAttribute(
            ProductId = testProduct.Id,
            VariantParentId = testProduct2.Id,
            CurrencyIsoCode = 'USD',
            XC_Color__c = 'Ebony', 
            Sequence = 1,
            XC_Handedness__c = 'Right-handed', 
            Size__c = 'Large'
        );*/
        
        insert new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = standardPricebook.Id,
            IsActive = TRUE,
            UnitPrice = 210        
        );
        
        insert new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = nadtc.Id,
            IsActive = TRUE,
            UnitPrice = 200        
        );
        
        CommerceEntitlementPolicy testPolicy = new CommerceEntitlementPolicy(
            CanViewPrice = TRUE,
            CanViewProduct = TRUE,
            IsActive = TRUE,
            Name = 'test policy'
        );
        insert testPolicy;
        
        BuyerGroup bg = new BuyerGroup(Name = 'test group');
        insert bg;
        
        insert new CommerceEntitlementBuyerGroup(BuyerGroupId = bg.Id, PolicyId = testPolicy.Id);
        
        insert new BuyerGroupMember(BuyerGroupId = bg.Id, BuyerId = testAccount.Id);
        
        insert new CommerceEntitlementProduct(
            ProductId = testProduct.Id,
            PolicyId = testPolicy.Id,
            CurrencyIsoCode = 'USD'
        );
        
    }
    
    @IsTest
    public static void getStandardPriceTest(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        String price = XC_ProductController.getStandardPrice(prod.Id).get('price');
        String priceUnavailable = XC_ProductController.getStandardPrice('fakeId').get('price');
        System.assert(price == '200.00');
    }
    
    @IsTest
    public static void getCommerceEntitlementProductsAsCsvTest(){
        XC_ProductController.triggerCsvJob();
    }
  
}