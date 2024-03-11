@isTest
public class TestDataFactory {
    
    public static Hierarchy_Config__c createHierarchyConfig(Id userId, String role) {
        return new Hierarchy_Config__c(
            User__c = userId,
            Role__c = role
        );
    }
    
    public static User createUser(String name) {
        return new User(
            FirstName = name,
            LastName = 'Lastname',
            Email = name + '@Gibson23.com',
            Username = name + '@google.com',
            Alias = name,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'en_US',
            CurrencyISOCode = 'USD'
        );
    }
    
    public static Hierarchy_Config__c createHierarchyConf(Id userId, String role, Id managerId) {
        Hierarchy_Config__c hierarchyConfig = new Hierarchy_Config__c();
        hierarchyConfig.User__c = userId;
        hierarchyConfig.Role__c = role;
        hierarchyConfig.Manager__c = managerId;
        return hierarchyConfig;
    }
    
    public static User createBDMUser(String name) {
        return new User(
            FirstName = name,
            LastName = 'Lastname',
            Email = name + '@Gibson23.com',
            Username = name + '@google.com',
            Alias = name,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'en_US',
            CurrencyISOCode = 'USD'
        );
    }
    
    public static Business_Unit__c createBusinessUnit(String name, Boolean availableForTarget, String uniqueName) {
        return new Business_Unit__c(
            Name = name,
            Available_for_Target__c = availableForTarget,
            Unique_Name__c = uniqueName
        );
    }
    
    public static Target_Config__c createTargetConfig(Id bddId, Id bdmId, Id businessUnitId, Decimal target, String financialYear,String Month,String level,Id account) {
        return new Target_Config__c(
            BDD__c = bddId,
            BDM__c = bdmId,
            Business_Unit__c = businessUnitId,
            Account__c = account,
            Target__c = target,
            Financial_Year__c = financialYear,
            Month__c = Month,
            CurrencyISOCode = 'USD',
            Level__c = level
        );
    }
    
    public static SPM_Stats__c createSPMStats(Id bddId, Id bdmId, Id businessUnitId, Decimal actualAmount, String financialYear,Id targetConfig,string Month,Id Account) {
        return new SPM_Stats__c(
            BDD__c = bddId,
            BDM__c = bdmId,
            Business_Unit__c = businessUnitId,
            Actual_Amount__c = actualAmount,
            Financial_Year__c = financialYear,
            Target_Config__c = targetConfig,
            Month__c = Month,
            CurrencyIsoCode = 'USD',
            Account__c =Account   
        );
    }
    
    public static Account createAccount(String name, Id ownerId,String BU) {
        return new Account(Name = name, OwnerId = ownerId,Authorized_Business_Units__c = BU,XC_AccountStatus__c = 'Active',XC_PricingGroup__c = 'NA_Dlr_Net'); 
    }
    
    public static BuyerGroup createBuyerGroup(String name) {
        return new BuyerGroup(Name = name);
    }
    
    public static  BuyerGroupPricebook createBuyerPriceBook(Id BuyerGroupId ,Id priceBookId) {
        return new BuyerGroupPricebook(BuyerGroupId = BuyerGroupId, priceBook2Id = priceBookId);  
    }
    
    public static  BuyerGroupMember createBuyerGroupMember(Id BuyerGroupId ,Id BuyerId) {
        return new BuyerGroupMember(BuyerGroupId = BuyerGroupId, BuyerId = BuyerId);   
    }   
    
    public static Pricebook2 createPricebook(String name) {
        return new Pricebook2(Name = name);
    }
    
    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Decimal unitPrice) {
        return new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            UseStandardPrice = false,
            IsActive = true
        );
    }
    
    public static Product2 createProduct(String productName, String businessUnit) {
        return new Product2(
            Name = productName,
            Business_Unit__c = businessUnit,
            Available_for_commitment__c = true,
            Start_Date__c = System.today()
        );
    }
    
    public static Product2 createProductWithoutDate(String productName, String businessUnit) {
        return new Product2(
            Name = productName,
            Business_Unit__c = businessUnit,
            Available_for_commitment__c = true
        );
    }
    
    public static Contract createContract(Id accountId) {
        Contract testContract = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );
        return testContract;
    } 
    
    public static Order createOrder(Id accountId,Id pricebookId,Id contractId) {
        return new Order(
            AccountId = accountId,
            ContractId = contractId,
            OrderedDate =   Datetime.now(),
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pricebookId,
            XC_Order_Status__c = 'invoiced'
        );
    }
    
    public static OrderItem createOrderItem(Id orderId, Id productId, Id pricebookEntryId, Decimal unitPrice, Decimal quantity) {
        return new OrderItem(
            OrderId = orderId,
            Product2Id = productId,
            PricebookEntryId = pricebookEntryId,
            UnitPrice = unitPrice, 
            Quantity = quantity     
        );
    }
    
    public static Target_Distribution__c createTargetDistribution(Id bddId, Id bdmId, String financialYear, Decimal allocatedPercentage, String currencyIsoCode) {
        return new Target_Distribution__c(
            BDD__c = bddId,
            BDM__c = bdmId,
            Financial_Year__c = financialYear,
            Allocated_Percentage__c = allocatedPercentage,
            CurrencyIsoCode = currencyIsoCode
        );
    }
    
    public static Target_Distribution__c createBDDTargetDistribution(Id bddId, String financialYear, Decimal overallTarget, String currencyIsoCode) {
        return new Target_Distribution__c(
            BDD__c = bddId,
            Overall_Target__c = overallTarget,
            Financial_Year__c = financialYear,
            CurrencyIsoCode = currencyIsoCode
        );
    }
    
    public static Order_Commitment__c createOrderCommitment(Id bdmId,Id accountId, Id businessUnitName, String financialYear, String month, Decimal Quantity,Decimal unitPrice,Id Product) {
        Order_Commitment__c orderCommit = new Order_Commitment__c(
            BDM__c = bdmId,
            Account__c = accountId,
            Business_Unit__c = businessUnitName,
            Financial_Year__c = financialYear,
            Month__c = month,
            Quantity__c = Quantity,
            Unit_Price__c =unitPrice,
            Product__c = Product
        );
        return orderCommit;
    }
    
    public static List<Target_Config__c> createTargetConfigs(Id bddId, Id bdmId, String financialYear, List<Map<String, Object>> targetData) {
        List<Target_Config__c> targetConfigs = new List<Target_Config__c>();
        
        for (Map<String, Object> target : targetData) {
            String busUnit = (String) target.get('busUnit');
            Boolean isTotal = busUnit == 'Total';
            if (String.isBlank(busUnit) || isTotal) {
                continue;
            }
            Business_Unit__c bu = createBusinessUnit(busUnit, true,'');
            insert bu;
            
            Target_Config__c targetConfig = new Target_Config__c(
                BDD__c = bddId,
                BDM__c = bdmId,
                Business_Unit__c = bu.Id,
                Financial_Year__c = financialYear,
                level__c = 'BDM',
                Target__c = isTotal ? null : (Decimal) target.get('Jan')  
            );
            targetConfigs.add(targetConfig);
        }  
        return targetConfigs;
    }
    
    public static Target_Acknowledgement__c createTargetAcknowledgement(Id bddId, Id bdmId, String financialYear, String comments, String status) {
        Target_Acknowledgement__c tarAcknowledge = new Target_Acknowledgement__c(
            BDD__c = bddId,
            BDM__c = bdmId,
            Status__c = status,
            Comments__c = comments,
            Financial_Year__c = financialYear
        );
        return tarAcknowledge;
    }
    
    public static Target_Commit_Stats__c createTargetCommitStats(Id accountId, String financialYear,Integer quantity,Integer unitPrice,Id productId,Id bdmId,Id busUnitId) {
        
        Target_Commit_Stats__c tarComStats = new Target_Commit_Stats__c(
            Account__c = accountId,
            Financial_Year__c = financialYear,
            Product__c = productId,
            Status__c = 'Pending',
            BDM__c = bdmId,
            Business_Unit__c = busUnitId,
            IsUpload__c = true,
            Jan__c = quantity,
            Feb__c = quantity,
            Mar__c = quantity,
            Apr__c = quantity,
            May__c = quantity,
            Jun__c = quantity,
            Jul__c = quantity,
            Aug__c = quantity,
            Sep__c = quantity,
            Oct__c = quantity,
            Nov__c = quantity,
            Dec__c = quantity,
            Unit_Price__c = unitPrice
        );
        return tarComStats;
    }
    
    public static Target_Commit_Stats__c downCreateTargetCommitStats(Id accountId, String financialYear,Integer quantity,Integer unitPrice,Id productId,Id bdmId,Id busUnitId) {
        
        String uniqueKey = financialYear + '-' + String.valueOf(bdmId).substring(0, 15) + '-' + String.valueOf(accountId).substring(0, 15) + '-'
            + String.valueOf(busUnitId).substring(0, 15) + '-' + String.valueOf(productId).substring(0, 15) ;
        
        Target_Commit_Stats__c tarComStats = new Target_Commit_Stats__c(
            Account__c = accountId,
            Financial_Year__c = financialYear,
            Product__c = productId,
            BDM__c = bdmId,
            Business_Unit__c = busUnitId,
            IsUpload__c = false,
            Jan__c = quantity,
            Feb__c = quantity,
            Mar__c = quantity,
            Apr__c = quantity,
            May__c = quantity,
            Jun__c = quantity,
            Jul__c = quantity,
            Aug__c = quantity,
            Sep__c = quantity,
            Oct__c = quantity,
            Nov__c = quantity,
            Dec__c = quantity,
            Unit_Price__c = unitPrice,
            Unique_key__c = uniqueKey
        );
        return tarComStats;
    }
    
}