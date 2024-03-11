@isTest
public class SPMTest {
    
    @isTest
    static void testGetUserInfo() {
        User testUser = TestDataFactory.createUser('UserTest');
        Insert testUser;
        
        Hierarchy_Config__c testHierarchyConfig = TestDataFactory.createHierarchyConfig(testUser.Id, 'BDM');
        Insert testHierarchyConfig;
        
        Test.startTest();
        List<Hierarchy_Config__c> result = SPMController.getUserInfo(testUser.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetBDMStats() {
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        Insert new List<User>{ testBDMUser, testManagerUser };
            
        Hierarchy_Config__c hierConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c hierConData = TestDataFactory.createHierarchyConfig(testManagerUser.Id, 'BDD');
        Insert hierConfig;
        Insert hierConData;
        
        Business_Unit__c testBusinessUnit = TestDataFactory.createBusinessUnit('USA', true, 'USA');
        Insert testBusinessUnit;
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount;
        
        Target_Config__c testTargetConfig = TestDataFactory.createTargetConfig(testManagerUser.Id, testBDMUser.Id, testBusinessUnit.Id, 10000.00, 'FY-23','','',ownedAccount.Id);
        Insert testTargetConfig;
        
        SPM_Stats__c testSPMStats = TestDataFactory.createSPMStats(testManagerUser.Id, testBDMUser.Id, testBusinessUnit.Id, 8500.00, 'FY-23', testTargetConfig.Id,'Jul',ownedAccount.Id);
        Insert testSPMStats;
    
        Test.startTest();
        List<SPMController.BDMActuals> result = SPMController.getBDMStats(testManagerUser.Id, 'FY-23');
        Test.stopTest(); 
    }
    
    @isTest
    static void testGetTargetBDM() {
        
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        Insert new List<User>{ testBDMUser, testManagerUser };
            
        Hierarchy_Config__c createHierarchyCon = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c createHierarchyConf = TestDataFactory.createHierarchyConfig(testManagerUser.Id, 'BDD');
        Insert createHierarchyConf;
        Insert createHierarchyCon;
        
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        Insert bu1;
        
        Business_Unit__c bu2 = TestDataFactory.createBusinessUnit('Epiphone', true,'Epiphone');
        Insert bu2;
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount;
        
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id,testBDMUser.Id,  bu1.Id,5000, 'FY-23', 'Apr','BDM',ownedAccount.Id
        );
        Insert targetConfig1;
        
        Target_Config__c targetConfig2 = TestDataFactory.createTargetConfig(
            testManagerUser.Id,testBDMUser.Id,  bu2.Id,6000, 'FY-23', 'May','BDM',ownedAccount.Id
        );
        Insert targetConfig2;
        
        Target_Config__c targetConfig3 = TestDataFactory.createTargetConfig(
            testManagerUser.Id,testBDMUser.Id,  bu1.Id,4500, 'FY-23', 'Apr','BDM',ownedAccount.Id
        );
        Insert targetConfig3;
        
        SPM_Stats__c actual1 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 4500, 'FY-23', targetConfig1.Id, 'Apr',ownedAccount.Id
        );
        Insert actual1;
        
        Test.startTest();
        
        Map<String, Map<String, Decimal>> result = SPMController.getTargetBDM('FY-23',testManagerUser.Id, testBDMUser.Id);
        SPMController.getBDDStats('FY-23');
        SPMController.getTargetQuatBDM('FY-23',testManagerUser.Id,testBDMUser.Id);
        SPMController.getActualQuatBDM('FY-23',testManagerUser.Id,testBDMUser.Id);
        SPMController.getVarianceQuatBDM('FY-23',testManagerUser.Id,testBDMUser.Id);
        SPMController.getYearlyStatsBDM('FY-23',testManagerUser.Id,testBDMUser.Id); 
        
        Test.stopTest();      
    }
    
    @isTest
    static void testGetActualsBDM() {
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        Insert new List<User>{ testBDMUser, testManagerUser };
            
        Hierarchy_Config__c hierConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c hierConfigData = TestDataFactory.createHierarchyConfig(testManagerUser.Id, 'BDD');
        Insert hierConfig;
        Insert hierConfigData;

        Hierarchy_Config__c currentUserHC = TestDataFactory.createHierarchyConfig(UserInfo.getUserId(), 'BDD');
        Insert currentUserHC; 
        
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        Insert bu1;
        
        Business_Unit__c bu2 = TestDataFactory.createBusinessUnit('Epiphone', true,'Epiphone');
        Insert bu2;
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount;
        
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            UserInfo.getUserId(), testBDMUser.Id, bu1.Id, 5000, 'FY-23', 'Apr', 'BDM',ownedAccount.Id
        );
        Insert targetConfig1;
        
        Target_Config__c targetConfig2 = TestDataFactory.createTargetConfig(
            UserInfo.getUserId(), testBDMUser.Id, bu2.Id, 6000, 'FY-23', 'May', 'BDM',ownedAccount.ID
        );
        Insert targetConfig2;
        
        SPM_Stats__c actual1 = TestDataFactory.createSPMStats(
            UserInfo.getUserId(), testBDMUser.Id, bu1.Id, 4500, 'FY-23', targetConfig1.Id, 'Apr',ownedAccount.Id
        );
        Insert actual1;
        
        SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            UserInfo.getUserId(), testBDMUser.Id, bu2.Id, 5500, 'FY-23', targetConfig2.Id, 'May',ownedAccount.Id
        );
        Insert actual2;
        
        Test.startTest();
        
        Map<String, Map<String, Decimal>> result = SPMController.getActualsBDM('FY-23', testManagerUser.Id, testBDMUser.Id);
        Map<String, Map<String, Decimal>> result1 = SPMController.getVarianceBDM('FY-23', testManagerUser.Id, testBDMUser.Id);
        Map<String, Object> result2 = BDDController.getBDDStats('FY-23');
        string getBDMTargetDist = BDDController.getBDMTargetDist(testBDMUser.Id,'FY-23','FY-22');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetBDMTargetDist() {
        User testBDMUser = TestDataFactory.createUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        Insert new List<User>{ testBDMUser, testManagerUser };
            
		Hierarchy_Config__c hierConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Insert hierConfig;
        
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        Insert bu1;
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount;
        
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-22', 'Apr', 'BDM',ownedAccount.Id
        );
        Insert targetConfig1;
        
        SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 66500, 'FY-22', targetConfig1.Id, 'Apr',ownedAccount.Id
        );
        Insert actual2;
        
        Target_Distribution__c targetDist = TestDataFactory.createTargetDistribution(
            testManagerUser.Id, testBDMUser.Id, 'FY-23', 50, 'USD'
        );
        Insert targetDist;
        
        Target_Distribution__c overallTargetDist = TestDataFactory.createBDDTargetDistribution(
            testManagerUser.Id, 'FY-23', 100000, 'USD'
        );
        Insert overallTargetDist;
        
        Test.startTest();
        
        String result = BDDController.getBDMTargetDist(testManagerUser.Id, 'FY-23', 'FY-22');
        
        Test.stopTest();
    }
    
    @isTest
    static void testSaveBDMTargetConfigs() {
        List<String> strBdmId = new List<string>();
        
        User testBDMUser = TestDataFactory.createUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        Insert new List<User>{ testBDMUser, testManagerUser };
            
		Hierarchy_Config__c hierConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Insert hierConfig;
        
        String strbdm = String.valueOf(testBDMUser.Id);
        strBdmId.add(strbdm);
        
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        Insert bu1; 
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount;
        
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-22', 'Apr', 'BDM',ownedAccount.Id
        );
        Insert targetConfig1;
        
        SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 66500, 'FY-22', targetConfig1.Id, 'Apr',ownedAccount.Id
        );
        Insert actual2;
        
        Target_Distribution__c targetDist = TestDataFactory.createTargetDistribution(
            testManagerUser.Id, testBDMUser.Id, 'FY-23', 50, 'USD'
        );
        Insert targetDist;
        
        String BDMDistData = '[{"userId":"' + testBDMUser.Id + '","disPercent":60}]';
        
        Target_Config__c targetConfig = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-23', 'Apr', 'BDM',ownedAccount.Id
        );
        Insert targetConfig;
        
        Target_Acknowledgement__c tarAcknowledge = TestDataFactory.createTargetAcknowledgement(testManagerUser.Id, testBDMUser.Id, 'FY-23','Testing','Target sent');
        Insert tarAcknowledge;
        
        Test.startTest();
        Boolean result = BDDController.saveBDMTargetConfigs(testManagerUser.Id, 100000, 'FY-23', BDMDistData, 'USD',true,strBdmId);
        Test.stopTest();
    }
    
     @isTest
    static void testUpdateBDMTargetsBatch() {
        List<String> strBdmId = new List<string>();
        Integer currentYear = Date.today().year();
        
        if(Date.today().month() > 3){
            currentYear = Date.today().year() + 1;
        }
        
        Integer prevYear = currentYear - 1;
    
        String currentYearString = String.valueOf(currentYear);
        String currentFY = 'FY-' + currentYearString.substring(2);
        
        String prevYearString = String.valueOf(prevYear);
        String prevYearFY = 'FY-' + prevYearString.substring(2);
        
        User testBDMUser = TestDataFactory.createUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        Insert new List<User>{ testBDMUser, testManagerUser };
            
		Hierarchy_Config__c hierConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Insert hierConfig;
        
        String strbdm = String.valueOf(testBDMUser.Id);
        strBdmId.add(strbdm);
        
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        Insert bu1; 
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount;
        
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, currentFY, 'Apr', 'BDM',ownedAccount.Id
        );
        Insert targetConfig1;
        
        SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 66500, prevYearFY, targetConfig1.Id, 'Apr',ownedAccount.Id
        );
        Insert actual2;
        
        Target_Distribution__c targetDist = TestDataFactory.createTargetDistribution(
            testManagerUser.Id, testBDMUser.Id, currentFY, 50, 'USD'
        );
        Insert targetDist;
        
        String BDMDistData = '[{"userId":"' + testBDMUser.Id + '","disPercent":60}]';
        
        Target_Config__c targetConfig = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, currentFY, 'Apr', 'BDM',ownedAccount.Id
        );
        Insert targetConfig;
        
        Target_Acknowledgement__c tarAcknowledge = TestDataFactory.createTargetAcknowledgement(testManagerUser.Id, testBDMUser.Id, currentFY,'Testing','Target sent');
        Insert tarAcknowledge;
        
        Test.startTest();
        UpdateBDMTargetsBatch myBatch = new UpdateBDMTargetsBatch(testManagerUser.Id, currentFY, 100000, null, 'USD',true,strBdmId);
        Database.executeBatch(myBatch, 1);
        Test.stopTest();
    }
    
    @isTest
    static void testSaveBDMTargets() {
        
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        Insert new List<User>{ testBDMUser, testManagerUser };
            
            
		Hierarchy_Config__c hierConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c hierConfigData = TestDataFactory.createHierarchyConfig(testManagerUser.Id, 'BDD');
        Insert hierConfig;
        Insert hierConfigData;
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount;
        Account ownedAccount1 = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        Insert ownedAccount1;
        
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        Insert bu1;
        Business_Unit__c bu2 = TestDataFactory.createBusinessUnit('Epiphone', true,'Epiphone');
        Insert bu2;
        
        List<Map<String, Object>> targetData = new List<Map<String, Object>>();
        
        targetData.add(new Map<String, Object>{
            'busUnit' => 'USA',
                'accountId' => ownedAccount.Id,
                'Jan' => 1000,  
                'Feb' => 1500
                });
        targetData[0].put('Jan', 1200);
        
        Product2 testProduct = TestDataFactory.createProduct('Test Product', bu1.Name);
        Insert testProduct;
		Product2 testProduct1 = TestDataFactory.createProduct('Test Product',bu2.Name );
        Insert testProduct1;
        
        Product2 testProductWithoutDate = TestDataFactory.createProductWithoutDate('Test Product', bu1.Name);
        Insert testProductWithoutDate;

        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100.0
        );
        Insert standardPricebookEntry;
        
        Pricebook2 testPricebook = TestDataFactory.createPricebook('Test Pricebook');
        Insert testPricebook;
        
        PricebookEntry testPricebookEntry = TestDataFactory.createPricebookEntry(testPricebook.Id, testProduct.Id, 110.0);
        Insert testPricebookEntry;
        
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-22', 'Apr', 'BDM',ownedAccount.Id
        );
        Insert targetConfig1;
        
        SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 500, 'FY-22', targetConfig1.Id, 'Apr',ownedAccount.Id
        );
        Insert actual2;
        
        Order_Commitment__c orderCommit  = TestDataFactory.createOrderCommitment(
            testBDMUser.Id,ownedAccount.Id,bu1.Id , 'FY-22', 'Apr',20,20,testProduct.Id
        );
        Insert orderCommit;
        List<Order_Commitment__c> ordCommitList = new List<Order_Commitment__c>{orderCommit};
        
        List<String> monthList = new List<String>{'Apr','May','Jun'};
        List<Target_Config__c> targetConfigs = TestDataFactory.createTargetConfigs(testManagerUser.Id, testBDMUser.Id, 'FY-22', targetData);
        Insert targetConfigs;
        
        Target_Acknowledgement__c tarAcknowledge = TestDataFactory.createTargetAcknowledgement(testManagerUser.Id, testBDMUser.Id, 'FY-23','Testing','Target sent');
        Insert tarAcknowledge;
        
        List<Target_Commit_Stats__c> tarCommitList = new List<Target_Commit_Stats__c>();
        Target_Commit_Stats__c tarComStats = TestDataFactory.createTargetCommitStats(ownedAccount.Id,'FY-22',20,5,testProduct.id,testBDMUser.Id,bu1.Id);
        tarCommitList.add(tarComStats);
        
        Target_Commit_Stats__c downloadTarComStats = TestDataFactory.downCreateTargetCommitStats(ownedAccount.Id,'FY-22',20,5,testProduct.id,testBDMUser.Id,bu1.Id);
        tarCommitList.add(downloadTarComStats);
        Target_Commit_Stats__c downloadTarComStats1 = TestDataFactory.downCreateTargetCommitStats(ownedAccount1.Id,'FY-22',20,5,testProduct.id,testBDMUser.Id,bu1.Id);
        tarCommitList.add(downloadTarComStats1);
        Target_Commit_Stats__c downloadTarComStats2 = TestDataFactory.downCreateTargetCommitStats(ownedAccount1.Id,'FY-22',20,5,testProduct1.id,testBDMUser.Id,bu1.Id);
        tarCommitList.add(downloadTarComStats2);
        
        Target_Commit_Stats__c tarComStatsWithoutDate = TestDataFactory.createTargetCommitStats(ownedAccount.Id,'FY-22',20,5,testProductWithoutDate.id,testBDMUser.Id,bu1.Id);
        tarCommitList.add(tarComStatsWithoutDate);
        Insert tarCommitList;
        
        Test.startTest();
        
        SPMController.saveBDMTargets(testManagerUser.Id, testBDMUser.Id, 'FY-23', targetData,true);
        SPMController.saveBDMTargets(testManagerUser.Id, testBDMUser.Id, 'FY-23', targetData,false);
        SPMController.acknowledgementStatus(testManagerUser.Id, testBDMUser.Id, 'FY-23');
        SPMController.ackHistoryData(testManagerUser.Id, testBDMUser.Id, 'FY-23');
        
        String upsertOrdCommitResult = BDMController.upsertOrdCommit(ordCommitList, '', '',true);
        String upsertOrdCommitResult1 = BDMController.upsertOrdCommit(ordCommitList, '', '',false);
        Boolean monthTarActVarResult = BDMController.MonthTarActVar('FY-22', ownedAccount.Id, bu1.Name, 'Apr');
        
        Map<String, Object> getBDMstatsresult = BDMController.getBDMstats('FY-22');
        Map<String, Map<String, Decimal>> getTargetBDMresult = BDMController.getTargetBDM('FY-22',ownedAccount.id,testBDMUser.Id);
        Map<String, Map<String, Decimal>> getActualsBDMresult = BDMController.getActualsBDM('FY-22',ownedAccount.id,testBDMUser.Id);
        Map<String, Map<String, Decimal>> getVarianceBDMresult = BDMController.getVarianceBDM('FY-22',ownedAccount.id,testBDMUser.Id);
        List<String> getBusinessUnitsresult = BDMController.getBusinessUnits(ownedAccount.Id);
        List<Account> resultAccounts = BDMController.getBDMAccounts(ownedAccount.Id);
        BDMController.getBusUnitTarActVar('FY-22', ownedAccount.Id, bu1.Name);
        BDMController.getMonthTarActVar('FY-22', ownedAccount.Id, bu1.Name, 'Apr');
        BDMController.prepareBUProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','','',true);
        BDMController.prepareBUProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','','',false);
        BDMController.getBDMAccountStats(testBDMUser.Id,'FY-22','');
        BDMController.getBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','','',true);
        BDMController.getBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','','',false);
        BDMController.getBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','ABCD','TEST',true);
        BDMController.getBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','ABCD','TEST',false);
        BDMController.downloadBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22',monthList,'','');
        BDMController.downloadBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22',monthList,'ABCD','TEST');
        BDMController.downloadTargetCommitStats(ownedAccount.Id,testBDMUser.Id,'FY-22','USA');
        BDMController.pendingTargetUpload(testBDMUser.Id);
        BDMController.changeTargetAcknowledge(testBDMUser.Id,'',true,false);
        BDMController.changeTargetAcknowledge(testBDMUser.Id,'TEST',false,true);
        BDMController.updateTargetCommit(tarCommitList);
        
        OrderCommitmentController.updateTargetCommitStats(ordCommitList);
        
        ProcessYearlyCommitment ba= new ProcessYearlyCommitment();
        Id jobid= Database.executeBatch(ba,5);
        ProcessTargetCommitRecords bc= new ProcessTargetCommitRecords();
        Id jobids= Database.executeBatch(bc,5);
        Test.stopTest();
        List<Target_Config__c> updatedTargets = [SELECT Id, Target__c FROM Target_Config__c WHERE BDD__c = :testBDMUser.Id AND Financial_Year__c = 'FY-23'];
    }
    
    @isTest
    static void testCreateActuals() {
        try{
            User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
            User testManagerUser = TestDataFactory.createUser('TestBDD');
            Insert new List<User>{ testBDMUser, testManagerUser };
                
            Hierarchy_Config__c createHierarchyCon = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
            Hierarchy_Config__c createHierarchyConf = TestDataFactory.createHierarchyConfig(testManagerUser.Id, 'BDD');
            Insert createHierarchyConf;
            Insert createHierarchyCon;
            
            Business_Unit__c testBusinessUnit = TestDataFactory.createBusinessUnit('USA', true, 'USA');
            Insert testBusinessUnit;
            
            Product2 testProduct = TestDataFactory.createProduct('Test Product', testBusinessUnit.Name);
            Insert testProduct;
            
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct.Id,
                UnitPrice = 100.0
            );
            Insert standardPricebookEntry;
            
            Pricebook2 testPricebook = TestDataFactory.createPricebook('Test Pricebook');
            Insert testPricebook;
            
            PricebookEntry testPricebookEntry = TestDataFactory.createPricebookEntry(testPricebook.Id, testProduct.Id, 110.0);
            Insert testPricebookEntry;
            
            Account testAccount = TestDataFactory.createAccount('TestAccount1', testBDMUser.Id,'');
            Insert testAccount;
            
            Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
                testManagerUser.Id, testBDMUser.Id, testBusinessUnit.Id, 5000, 'FY-24', 'Jan', 'BDM',testAccount.Id
            );
            Insert targetConfig1;
            
            Contract testContract = TestDataFactory.createContract(testAccount.Id);
            Insert testContract;
            
            Order testOrder = TestDataFactory.createOrder(testAccount.Id,testPricebook.Id,testContract.Id);
            Insert testOrder;
            
            OrderItem testOrderItem = TestDataFactory.createOrderItem(testOrder.Id, testProduct.Id,testPricebookEntry.Id,100,2);
            Insert testOrderItem;
            
            Map<Id, OrderItem> newOrderMap = new Map<Id, OrderItem>{ testOrderItem.Id => testOrderItem };
                Map<Id, OrderItem> oldOrderItemMap = new Map<Id, OrderItem>{ testOrderItem.Id => testOrderItem };
                    testOrderItem.unitprice = 100;
            testOrderItem.Quantity =3;    
            Update testOrderItem;
             
            Test.startTest();
            
            OrderItemController.createActuals(newOrderMap);
            OrderItemController.updateActualsOnOrderItemUpdate(newOrderMap, oldOrderItemMap);
            
            //OrdItemController.createActuals(newOrderMap);
            //OrdItemController.updateActualsOnOrderItemUpdate(newOrderMap, oldOrderItemMap);
            //OrderItemController.getMonthName(System.now());
            
            Test.stopTest();
        }
        catch(Exception e) {
            throw e;
        }
    }   
}