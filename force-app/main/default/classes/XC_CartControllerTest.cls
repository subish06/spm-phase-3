@IsTest
public class XC_CartControllerTest {
    
    public static final String TEST_STOREFRONT_NAME = 'testStorefront';
    private static final String LOCALE_STRING = 'en_US';
    private static final String TIME_ZONE = 'America/New_York';
    private static final String EMAIL_ENCODING = 'UTF-8';
    
    @IsTest(SeeAllData = true)
    public static void uploadCartFromCsvTest(){
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' Limit 1];
        
        Profile profile1 = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        String contactEmail = 'XCCartControllerTest@fakeemail.com'; 
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = acc.Id, Email = contactEmail + '.invalid');
        insert testContact;
        
        User u = new User(
            UserName = testContact.Email, 
            ProfileId = profile1.Id, 
            LastName = 'tester', 
            Email = testContact.Email, 
            Alias = 'tstxc', 
            TimeZoneSidKey = TIME_ZONE, 
            LocaleSidKey = LOCALE_STRING, 
            EmailEncodingKey = EMAIL_ENCODING, 
            LanguageLocaleKey = LOCALE_STRING
        );
        insert u;
        
        insert new BuyerAccount(BuyerId = acc.Id, Name = 'Test Buyer', IsActive = TRUE);
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            Name = 'Standard Price Book',
            IsActive = TRUE
        );
        upsert standardPricebook;
        
        WebStore ws = new WebStore(Name = TEST_STOREFRONT_NAME);
        insert ws;
        
        Product2 prod = new Product2(
            StockKeepingUnit = 'tst123',
            Name = 'test product',
            IsActive = TRUE
        );
        insert prod;
        
        insert new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = pricebookId,
            IsActive = TRUE,
            UnitPrice = 200 
        );
        
        Community com = [SELECT Id FROM Community LIMIT 1];
        
        CommerceEntitlementPolicy testPolicy = new CommerceEntitlementPolicy(
            CanViewPrice = TRUE,
            CanViewProduct = TRUE,
            IsActive = TRUE,
            Name = 'test policy'
        );
        insert testPolicy;
        
        BuyerGroup bg = new BuyerGroup(Name = String.valueOf(System.now()) + 'test group');
        insert bg;
        
        insert new CommerceEntitlementBuyerGroup(BuyerGroupId = bg.Id, PolicyId = testPolicy.Id);
        
        insert new BuyerGroupMember(BuyerGroupId = bg.Id, BuyerId = acc.Id);
        
        insert new CommerceEntitlementProduct(
            ProductId = prod.Id,
            PolicyId = testPolicy.Id,
            CurrencyIsoCode = 'USD'
        );
        
        Webcart wc = new Webcart(
            AccountId = acc.Id,
            WebStoreId = ws.Id,
            Name = (String)acc.Id + ws.Id
        );
        insert wc;
        String csvInput = 'SKU,Product Name,Quantity\n';
        csvInput = csvInput + 'tst123,test product,5';
        
        XC_CartController.uploadCartFromCsv(csvInput, null, wc.Id);
    }

}