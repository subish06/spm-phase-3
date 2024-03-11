@IsTest
public class XC_SalesProjectionControllerTest {
    
    @TestSetup
    public static void createTestData(){
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' Limit 1];
        
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
         
        Account testAccount = new Account(Name = 'test account', XC_CustomerId__c = 'test111');
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
        
        Product2 testProduct = new Product2(
            Name = 'test product',
            StockKeepingUnit = 'tst123',
            IsActive = TRUE,
            Business_Unit__c = 'Epiphone'
        );
        insert testProduct;
        
        insert new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = pricebookId,
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
        
        BuyerGroup bg = new BuyerGroup(Name = String.valueOf(System.today()) + 'group');
        insert bg;
        
        insert new CommerceEntitlementBuyerGroup(BuyerGroupId = bg.Id, PolicyId = testPolicy.Id);
        
        insert new BuyerGroupMember(BuyerGroupId = bg.Id, BuyerId = testAccount.Id);
        
        insert new CommerceEntitlementProduct(
            ProductId = testProduct.Id,
            PolicyId = testPolicy.Id,
            CurrencyIsoCode = 'USD'
        );
        
        Order ord = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = System.today().addYears(-1),
            Status = 'Draft'
        );
        insert ord;
        
        insert new OrderItem(
            OrderId = ord.Id,
            Product2Id = testProduct.Id,
            ListPrice = 30.00,
            UnitPrice = 30.00,
            TotalLineAmount = 30.00,
            Quantity = 1
        );
        
        XC_SalesProjection__c sp = new XC_SalesProjection__c(
            XC_Account__c = testAccount.Id,
            AccountTarget__c = 60.00,
            XC_Admin_Account_Target_Qty__c = 2,
            BusinessUnit__c = 'Epiphone',
            XC_Fiscal_Period__c = 1,
            XC_Fiscal_Year__c = 2023
        );
        insert sp;
        
        System.debug(testAccount.XC_CustomerId__c + '_' + testProduct.StockKeepingUnit + '_' + '2023' + '_' + '1');
        
        insert new XC_SalesProjectionItem__c(
            Sales_Projection__c = sp.Id,
            Historical_Quantity__c = 1,
            Historical_Total__c = 30.00,
            PlannedSales__c = 60.00,
            Product__c = testProduct.Id,
            External_Id__c = testAccount.XC_CustomerId__c + '_' + testProduct.StockKeepingUnit + '_' + '2023' + '_' + '1',
            PlannedQuantity__c = 2
        );
    }
    
    @IsTest
    public static void getAllValidBusinessUnitsTest(){
        List<String> businessUnits = XC_SalesProjectionController.getAllValidBusinessUnits();
        System.assert(businessUnits.contains('Epiphone'));
    }
    
    @IsTest
    public static void updateSalesProjectionItemsTest(){
        List<Object> excelInput = new List<Object>();
        Object externalId = 'test111_tst123_2023';
        excelInput.add(new Map<String,Object>{
            'External Id' => externalId,
            'Planned Quantity P1' => 6
          }
        );
        
        List<XC_SalesProjectionItem__c> spis = XC_SalesProjectionController.updateSalesProjectionItems(excelInput);
        System.debug(spis);
        System.assert(spis.size() != 0);
        System.assert(spis[0].PlannedQuantity__c == 6);
        System.assert(spis[0].PlannedSales__c == 180.00);
    }
    
    @IsTest
    public static void initiateSalesProjectionBatchTest(){
        List<String> accounts = new List<String>{
            'test111'
        };
        List<String> bdmList = new List<String>{
            'test111@test.com'
        };
        List<Object> excelInput = new List<Object>();
        Object externalId = 'test111_tst123_2023';
        excelInput.add(new Map<String,Object>{
            'InvoiceAccount' => 'test111',
            'BusinessUnit' => 'Epiphone',
            'FiscalPeriod' => 2,
            'FiscalYear' => 2023,
            'Sales Target Amount' => 300,
            'SalesTargetQty' => 10,
            'BDM' => 'test111@test.com'
          }
        );
        Test.startTest();
            String batchId = XC_SalesProjectionController.initiateSalesProjectionBatch(excelInput, accounts, bdmList);
            System.debug(batchId);
        Test.stopTest();
    }

}