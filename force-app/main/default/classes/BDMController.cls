public class BDMController {
   
    @AuraEnabled(Cacheable = true)
    public static List<Account> getBDMAccounts(Id currentUser){
        return[SELECT Id, Name FROM Account WHERE OwnerId = : currentUser];
    }
   
    @AuraEnabled(Cacheable = true)
    public static Map<String, Object> getBDMstats(String selYear) {
       
        String currencyVal = 'USD';
        Decimal targetAchieved = 0;
       
        AggregateResult agrResult = [SELECT SUM(Target__c) totalAmount FROM Target_Config__c
                                     WHERE Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId()];
        Decimal curYearTarget = (Decimal) agrResult.get('totalAmount');
        curYearTarget = curYearTarget != null ? curYearTarget : 0;
       	
        agrResult = [SELECT SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId()];
        Decimal curYearActual = (Decimal) agrResult.get('totalAmount');
        curYearActual = curYearActual != null ? curYearActual : 0;
       
        agrResult = [SELECT SUM(Variance_Amount__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId()];
        Decimal curYearvariance = (Decimal) agrResult.get('totalAmount');
        curYearvariance = curYearvariance != null ? curYearvariance : 0;
       
        agrResult = [SELECT COUNT(OwnerId) totalAmount FROM Account WHERE OwnerId =: UserInfo.getUserId() AND Authorized_Business_Units__c != NULL AND ParentId = NULL AND XC_AccountStatus__c = 'Active'];
        Decimal totalAccount = (Decimal) agrResult.get('totalAmount');
        totalAccount = totalAccount != null ? totalAccount : 0;
       
        if (curYearTarget != 0) {
            targetAchieved = (curYearActual/curYearTarget)*100;
            targetAchieved = targetAchieved != null ? targetAchieved : 0;
        }
       
        for(Target_Config__c tarConfig : [SELECT CurrencyIsoCode FROM Target_Config__c
                                          WHERE Financial_Year__c =: selYear AND BDM__c =: UserInfo.getUserId()]){
                                              currencyVal = tarConfig.CurrencyIsoCode;      
                                          }
        Map<String, Object> result = new Map<String, Object>();
       
        result.put('curYearTarget', curYearTarget);
        result.put('curYearActual', curYearActual);
        result.put('curYearVariance', curYearvariance);
        result.put('totalAccount', totalAccount);
        result.put('targetAchieved', targetAchieved);  
        result.put('currencyVal', currencyVal);
        return result;
    }
   
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getTargetBDM(String financialYear,Id accountId,Id currentUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
       
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }        
        getTargetValues(financialYear, accountId, currentUser, busUnitMonthSalesTarMap);
       
        return busUnitMonthSalesTarMap;
    }
   
    private static void getTargetValues(String financialYear,Id accountId,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
        for(
            AggregateResult aggr :
            [select Business_Unit__r.Name, Month__c, SUM(Target__c) from Target_Config__c
             where Business_Unit__c != null AND Level__c ='BDM' AND Business_Unit__r.Available_for_Target__c = true AND Account__c =: accountId
             AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
           
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), target
            );
        }
    }
   
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getActualsBDM(String financialYear,Id accountId,Id currentUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
       
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
       
        getActualValues(financialYear, accountId, currentUser, busUnitMonthSalesTarMap);
       
        return busUnitMonthSalesTarMap;
    }
   
    private static void getActualValues(String financialYear,Id accountId,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
       
        for(
            AggregateResult aggr :
            [select Business_Unit__r.Name, Month__c, SUM(Overall_Actuals__c) from Target_Config__c
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND Account__c =: accountId AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
           
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), target
            );
        }
    }
   
    @AuraEnabled(Cacheable = true)
    public static Map<String, Map<String, Decimal>> getVarianceBDM(String financialYear,Id accountId,Id currentUser) {
        Set<String> monthSet = new Set<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};
            Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap = new Map<String, Map<String, Decimal>>();
       
        for(Business_Unit__c busUnit : [SELECT Id,Unique_Name__c from Business_Unit__c where Available_for_Target__c = true ORDER BY Unique_Name__c ASC]) {
            Map<String, Decimal> monthSalesTarMap = new Map<String, Decimal>();
            for(String month : monthSet) {
                monthSalesTarMap.put(month, 0);
            }
            busUnitMonthSalesTarMap.put(busUnit.Unique_Name__c, monthSalesTarMap);
        }
       
        getVarianceValues(financialYear, accountId, currentUser, busUnitMonthSalesTarMap);
       
        return busUnitMonthSalesTarMap;
    }
   
    private static void getVarianceValues(String financialYear,Id accountId,Id selectedUser, Map<String, Map<String, Decimal>> busUnitMonthSalesTarMap) {
       
        for(
            AggregateResult aggr :
            [select Business_Unit__r.Name, Month__c, SUM(Variance_Amount__c) from Target_Config__c
             where Business_Unit__c != null AND Business_Unit__r.Available_for_Target__c = True AND Account__c =: accountId AND BDM__c =: selectedUser AND Financial_Year__c =: financialYear
             group by Business_Unit__r.Name, Month__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
           
            busUnitMonthSalesTarMap.get(
                (String) aggr.get('Name')
            ).put(
                (String) aggr.get('Month__c'), target
            );
        }
    }
   
    @AuraEnabled(Cacheable = true)
    public static List<String> getBusinessUnits(Id accountId) {
        Set<String> availableBUList = new Set<String>();
        List<String> businessUnitList = new List<String>();
       
        List<Account> accList = [Select Id,Authorized_Business_Units__c from Account WHERE Id =: accountId];
        if(!accList.isEmpty() && accList[0].Authorized_Business_Units__c != null) {
            businessUnitList = accList[0].Authorized_Business_Units__c.split(';');
        }
       
        for(Business_unit__c bu : [SELECT Id,name,Unique_Name__c FROM Business_unit__c WHERE Available_for_Target__c = true AND Unique_Name__c IN : businessUnitList ORDER BY Unique_Name__c ASC]) {
            availableBUList.add(bu.name);
        }
       
        return new List<String>(availableBUList);
    }
   
    @AuraEnabled(Cacheable = true)
    public static BDMBusUnitTarActVar getBusUnitTarActVar(String financialYear, Id accountId, String businessUnitName) {
        BDMBusUnitTarActVar BDMBusUnitTarActVar = new BDMBusUnitTarActVar(0, 0, 0);
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Target__c) totalAmount FROM Target_Config__c
             WHERE Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId  GROUP by Account__c,Business_Unit__c]
        ) {
            BDMBusUnitTarActVar.targetAmt = (Decimal) aggr.get('totalAmount');
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId  GROUP by Account__c,Business_Unit__c]
        ) {
            BDMBusUnitTarActVar.actualAmt = (Decimal) aggr.get('totalAmount');
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Variance_Amount__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId GROUP by Account__c,Business_Unit__c]
        ) {
            BDMBusUnitTarActVar.varianceAmt = (Decimal) aggr.get('totalAmount');
        }
        return BDMBusUnitTarActVar;
    }  
   
   
    @AuraEnabled(Cacheable = true)
    public static boolean MonthTarActVar(String financialYear, Id accountId, String businessUnitName,String selectedMonth) {
        return true;
    }
   
    @AuraEnabled
    public static BDMMonthTarActVar getMonthTarActVar(String financialYear, Id accountId, String businessUnitName,String selectedMonth) {
        BDMMonthTarActVar BDMMonthTarActVar = new BDMMonthTarActVar(0, 0, 0, 0);
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Target__c) totalAmount FROM Target_Config__c
             WHERE Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId  AND Month__c =: selectedMonth GROUP by Account__c,Business_Unit__c]
        ) {
            BDMMonthTarActVar.monthTarAmt = (Decimal) aggr.get('totalAmount');
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId AND Month__c =: selectedMonth  GROUP by Account__c,Business_Unit__c]
        ) {
            BDMMonthTarActVar.monthActAmt = (Decimal) aggr.get('totalAmount');
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,Business_Unit__c, SUM(Variance_Amount__c) totalAmount FROM Target_Config__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId AND Month__c =: selectedMonth GROUP by Account__c,Business_Unit__c]
        ) {
            BDMMonthTarActVar.monthVarAmt = (Decimal) aggr.get('totalAmount');
        }
       
        for(
            AggregateResult aggr :
            [SELECT SUM(Commited_Order__c) totalAmount FROM Order_Commitment__c
             WHERE  Financial_Year__c =: financialYear AND Business_Unit__r.Name =: businessUnitName AND
             Account__c =: accountId AND Month__c =: selectedMonth]
        ) {
            BDMMonthTarActVar.monthOrdCommit = (Decimal) aggr.get('totalAmount');
        }
       
        return BDMMonthTarActVar;
    } 
    
    @AuraEnabled
    public static Map<String, Object> pendingTargetUpload(Id currentUser) {
        Map<String, Object> result = new Map<String, Object>();
        
        List<Target_Commit_Stats__c> tCommitList = [SELECT Id FROM Target_Commit_Stats__c WHERE BDM__C = :currentUser
                                                    AND Status__c = 'Pending' AND IsUpload__c = true];
        
        boolean isPendingUpload = tCommitList.isEmpty();
        result.put('isPendingUpload', isPendingUpload);
        result.put('size', tCommitList.size());
        
        return result;
    }
    
    @AuraEnabled
    Public static void updateTargetCommit(List<Target_Commit_Stats__c> targetCommitList) {
        Set<String> businessUnitUniqueNames = new Set<String>();
   		Set<String> productSKUs = new Set<String>();
        Map<String,Id> busUnitMap = new Map<String,Id>();
        Map<String, Id> prodMap = new Map<String,Id>();
        
        for (Target_Commit_Stats__c tcStats : targetCommitList) {
            businessUnitUniqueNames.add(tcStats.Product_Business_Unit__c);
            productSKUs.add(tcStats.Product_SKU__c);
        }
        
        for (Business_Unit__c busUnit : [SELECT Id, Unique_Name__c FROM Business_Unit__c WHERE Unique_Name__c IN :businessUnitUniqueNames]) {
            busUnitMap.put(busUnit.Unique_Name__c, busUnit.Id);
        }
        
        for (Product2 prd : [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :productSKUs]) {
            prodMap.put(prd.StockKeepingUnit, prd.Id);
        }
        
        for (Target_Commit_Stats__c tcStats : targetCommitList) {
            if (busUnitMap.containsKey(tcStats.Product_Business_Unit__c)) {
                tcStats.Business_Unit__c = busUnitMap.get(tcStats.Product_Business_Unit__c);
            }
            if (prodMap.containsKey(tcStats.Product_SKU__c)) {
                tcStats.Product__c = prodMap.get(tcStats.Product_SKU__c);
            }
        }
        
        try{
            Insert targetCommitList;
            if(targetCommitList.size() < 5000){
                ProcessTargetCommitRecords batch  = new ProcessTargetCommitRecords();
                Database.executeBatch(batch);
            }           	
        }
        catch(DmlException e){
            System.debug('Error==>'+e.getMessage());
        }
    }
   
    @AuraEnabled
    Public static String upsertOrdCommit(List<Order_Commitment__c> ordCommitList, String ProdCode, String ProdDescription,Boolean commitmentAvailable) {
        Decimal monthTarAmt = 0;
        Decimal monthOrdCommit = 0;
        try{            
            Upsert ordCommitList;  
           
            for(
                AggregateResult aggr :
                [SELECT SUM(Commited_Order__c) totalAmount FROM Order_Commitment__c
                 WHERE Financial_Year__c =: ordCommitList[0].Financial_Year__c AND Business_Unit__c =: ordCommitList[0].Business_Unit__c AND
                 Account__c =: ordCommitList[0].Account__c AND Month__c =: ordCommitList[0].Month__c]
            ) {
                monthOrdCommit = (Decimal) aggr.get('totalAmount');
            }
           
            for(
                AggregateResult aggr :
                [SELECT Account__c,Business_Unit__c, SUM(Target__c) totalAmount FROM Target_Config__c
                 WHERE Financial_Year__c =: ordCommitList[0].Financial_Year__c AND Business_Unit__c =: ordCommitList[0].Business_Unit__c AND
                 Account__c =: ordCommitList[0].Account__c AND Month__c =: ordCommitList[0].Month__c GROUP by Account__c,Business_Unit__c]
            ) {
                monthTarAmt = (Decimal) aggr.get('totalAmount');
            }
           
            List<ProductWrapper> prdWrapList = getBusUnitProducts(
                ordCommitList[0].Business_Unit__c, '', ordCommitList[0].Account__c,
                ordCommitList[0].Financial_Year__c, ordCommitList[0].Month__c, ProdCode, ProdDescription,commitmentAvailable
            );
        }
        catch(DmlException e){
            System.debug('Error==>'+e.getMessage());
        }
        return '{"monthOrdCommit" : "'+monthOrdCommit+'", "monthTarAmt" : "'+monthTarAmt+'"}';
    }
   
    @AuraEnabled(Cacheable = true)
    Public static Boolean prepareBUProducts(Id busId, String businessUnit, String accountId, String financialYear, String selectedMonth, String ProdCode, String ProdDescription,Boolean commitmentAvailable) {
        return true;
    }
    
    @AuraEnabled
      Public static List<ProductWrapper> getBusUnitProducts(
        Id busId, String businessUnit, String accountId, String financialYear, 
        String selectedMonth, String ProdCode, String ProdDescription,Boolean commitmentAvailable
    ) {
        List<Product2> productsList = new List<Product2>();
        Map<Id, InvoiceWrapper> prdInvMap = new Map<Id, InvoiceWrapper>();
        Map<Id, ProductWrapper> resultMap = new Map<Id, ProductWrapper>();
        Map<String, Integer> monthMap = new Map<String, Integer>{  'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
            'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12};       
		Integer monthNumber = monthMap.get(selectedMonth);
        
        String numericPart = financialYear.substring(3);
        Integer baseYear = 2000; 
        Integer fullYear = baseYear + Integer.valueOf(numericPart);
        if (monthNumber > 3) {
            fullYear--;
        }
        String formattedYear = String.valueOf(fullYear);
        Integer currentMonth = System.today().month();
        Integer currentDay = System.today().day();       
       
        List<Business_Unit__c> buList = [SELECT Id FROM Business_Unit__c WHERE Unique_Name__c =: businessUnit LIMIT 1];
        if(!buList.isEmpty()) {
            busId = buList[0].Id;
        }
        else {
            buList = [SELECT Unique_Name__c FROM Business_Unit__c WHERE Id =: busId];
            if(!buList.isEmpty()) {
                businessUnit = buList[0].Unique_Name__c;
                busId =  buList[0].Id;
            }
        }
       
        List<Account> accList = [SELECT Id, XC_PricingGroup__c,OwnerId FROM Account WHERE Id =: accountId];
        if(accList.isEmpty()) {
            throw new AuraHandledException('Account is Empty');
        }
       
        Id priceBookId;
       
        for(
            BuyerGroup bgroup :
            [SELECT Id, (SELECT PriceBook2Id FROM BuyerGroupPricebooks WHERE IsActive = true AND PriceBook2.Name =: accList[0].XC_PricingGroup__c LIMIT 1) FROM BuyerGroup
             WHERE Id IN (SELECT BuyerGroupId FROM BuyerGroupMember where BuyerId =: accountId) AND Business_Unit__c like :'%'+businessUnit+'%' LIMIT 1]
        ) {
            if(!bgroup.BuyerGroupPricebooks.isEmpty()) {
                priceBookId = bgroup.BuyerGroupPricebooks[0].PriceBook2Id;
            }
        }
        
        if(String.isBlank(ProdCode) && String.isBlank(ProdDescription)) {
            productsList = [SELECT Id, Business_Unit__c, StockKeepingUnit , Description,Finish__c,Start_Date__c,
                            (SELECT Id, Financial_Year__c, Month__c, Quantity__c, Unit_Price__c, Commited_Order__c, Business_Unit__c, Account__c,BDM__c
                             FROM Order_Commitments__r WHERE Financial_Year__c = :financialYear  AND Month__c = :selectedMonth  AND
                             Business_Unit__c =: busId AND Account__c =: accountId ORDER BY CreatedDate DESC LIMIT 1) FROM Product2
                            WHERE Business_Unit__c =: businessUnit AND Available_for_commitment__c = True];       
        }
        else {
            productsList = [SELECT Id, Business_Unit__c, StockKeepingUnit , Description,Finish__c,Start_Date__c,
                            (SELECT Id, Financial_Year__c, Month__c, Quantity__c, Unit_Price__c, Commited_Order__c, Business_Unit__c, Account__c,BDM__c
                             FROM Order_Commitments__r WHERE Financial_Year__c = :financialYear AND Month__c = :selectedMonth AND
                             Business_Unit__c =: busId AND Account__c =: accountId ORDER BY CreatedDate DESC LIMIT 1) FROM Product2
                            WHERE Business_Unit__c = :businessUnit AND StockKeepingUnit LIKE :(ProdCode + '%') AND
                            Description LIKE :('%' + ProdDescription + '%') AND Available_for_commitment__c = True]; 
        }
        
        for (Product2 product : productsList) {
            prdInvMap.put(product.Id, new InvoiceWrapper(0, 0, 0, 0));
        }
        
        for (
            OrderItem ordItem : 
            [SELECT order.AccountId, Product2Id, Quantity, TotalPrice, order.XC_Order_Status__c FROM OrderItem 
             WHERE Order.AccountId =: accountId AND order.XC_Order_Status__c != 'Cancelled' AND 
             Product2Id IN : prdInvMap.keySet() AND Month__c =: selectedMonth and Financial_Year__c = :financialYear ]
        ) {
            if(ordItem.order.XC_Order_Status__c == 'Invoiced') {
                prdInvMap.get(ordItem.Product2Id).invoicedQty += (Integer) ordItem.Quantity;
            	prdInvMap.get(ordItem.Product2Id).invoicedPrice += ordItem.TotalPrice;
                continue;
            }
            
            prdInvMap.get(ordItem.Product2Id).openQty += (Integer) ordItem.Quantity;
            prdInvMap.get(ordItem.Product2Id).openPrice += ordItem.TotalPrice;
        }
       
        for (Product2 product : productsList) {
            Date itemStartDate = Date.newInstance(Integer.valueOf(formattedYear), monthNumber, 1);
            if(product.Start_Date__c != null){
                if (currentMonth == monthNumber && currentDay >= product.Start_Date__c.day() && 
                    itemStartDate.month() == product.Start_Date__c.month() && itemStartDate.year() == product.Start_Date__c.year()
                   ) {
                       itemStartDate = product.Start_Date__c;
                   }
                
                if(commitmentAvailable && itemStartDate < product.Start_Date__c) {
                    continue;
                }
            }
            
            ProductWrapper prdWrapper = new ProductWrapper();
            prdWrapper.productCode = product.StockKeepingUnit ;
            prdWrapper.description = product.Description;
            prdWrapper.ordCommitsQuantity = 0;
            prdWrapper.committedOrder = 0;
            prdWrapper.productId = product.Id;
            prdWrapper.orderCommitId = null;
            prdWrapper.buId = busId;
            prdWrapper.accId = accountId;
            prdWrapper.financialYear = financialYear;
            prdWrapper.month = selectedMonth;
            prdWrapper.ordCommitsUnitPrice = 0;
            prdWrapper.finish = product.Finish__c;    
            prdWrapper.accountOwnerId = accList[0].OwnerId;
            prdWrapper.ordCommitMonth = '';
            prdWrapper.startDateField = product.Start_Date__c;
            //prdWrapper.endDateField = product.End_Date__c;
            prdWrapper.startDateWrapper = itemStartDate;
           // prdWrapper.endDateWrapper = endDate;
            
            if(product.Order_Commitments__r != null && !product.Order_Commitments__r.isEmpty()) {
                Order_Commitment__c commitment = product.Order_Commitments__r[0];
                
                prdWrapper.orderCommitId = commitment.Id;
                prdWrapper.ordCommitsQuantity = commitment.Quantity__c;
                prdWrapper.ordCommitsUnitPrice = commitment.Unit_Price__c;
                prdWrapper.committedOrder = commitment.Commited_Order__c;
                prdWrapper.accountOwnerId = commitment.BDM__c;
                prdWrapper.ordCommitMonth = commitment.Month__c;
            }
            
            prdWrapper.invoicedQty = prdInvMap.get(product.Id).invoicedQty;
            prdWrapper.invoicedPrice = prdInvMap.get(product.Id).invoicedPrice;
            prdWrapper.openQty = prdInvMap.get(product.Id).openQty;
            prdWrapper.openPrice = prdInvMap.get(product.Id).openPrice;
            
            resultMap.put(product.Id, prdWrapper);
        }
       
        if(priceBookId == null) {
            return resultMap.values();
        }
       
        for(
            PricebookEntry pbEntry :
            [SELECT Id,Product2Id,UnitPrice FROM PricebookEntry  WHERE Pricebook2Id =: priceBookId AND Product2Id IN : resultMap.keySet()]
        ) {
            if(resultMap.containsKey(pbEntry.Product2Id)) {
                resultMap.get(pbEntry.Product2Id).ordCommitsUnitPrice = pbEntry.UnitPrice;
            }
        }
       
        return resultMap.values();
    }  
   
    @AuraEnabled(cacheable=true)
    public static List<BDMAccount> getBDMAccountStats(Id currentUser, String financialYear, String searchTerm) {
        Map<Id, BDMAccount> BDMAccountMap = new Map<Id, BDMAccount>();
        string searchKeyword = searchTerm + '%';
       
        for(
            Account bdmAccounts :
            [SELECT Id, Name, OwnerId FROM Account WHERE OwnerId = : currentUser AND ParentId = NULL AND Authorized_Business_Units__c != NULL AND XC_AccountStatus__c = 'Active' AND Name LIKE : searchKeyword ORDER BY Name ASC]
        ) {
            BDMAccountMap.put(
                bdmAccounts.Id,  
                new BDMAccount(bdmAccounts.OwnerId, bdmAccounts.Name, bdmAccounts.Id, 0,0,0,0,0,0)
            );
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c,  SUM(Overall_Actuals__c) FROM Target_Config__c WHERE BDM__c =: currentUser
             AND Financial_Year__c =: financialYear AND Account__c IN : BDMAccountMap.keySet() GROUP BY Account__c]
        ) {
            Decimal actuals = (Decimal) aggr.get('expr0');
            Id accId = (Id) aggr.get('Account__c');
           
            if(BDMAccountMap.containsKey(accId)) {
                BDMAccountMap.get(accId).actualAmount = actuals;
            }  
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c, SUM(Target__c) FROM Target_Config__c WHERE  BDM__c =: currentUser
             AND Financial_Year__c =: financialYear AND Account__c IN : BDMAccountMap.keySet() GROUP BY Account__c]
        ) {
            Decimal target = (Decimal) aggr.get('expr0');
            Id accId = (Id) aggr.get('Account__c');
           
            if(BDMAccountMap.containsKey(accId)) {
                BDMAccountMap.get(accId).targetAmount = target;
            }
        }
       
        for(
            AggregateResult aggr :
            [SELECT Account__c, SUM(Variance_Amount__c) FROM Target_Config__c WHERE BDM__c =: currentUser
             AND Financial_Year__c =: financialYear AND Account__c IN : BDMAccountMap.keySet() GROUP BY Account__c]
        ) {
            Decimal variance = (Decimal) aggr.get('expr0');
            Id accId = (Id) aggr.get('Account__c');
           
            if(BDMAccountMap.containsKey(accId)) {
                BDMAccountMap.get(accId).varianceAmount = variance;
            }
        }  
        return BDMAccountMap.values();
    }
    
   @AuraEnabled
    Public static List<TargetCommitWrapper> downloadTargetCommitStats(Id accountId,Id selectedUser, String financialYear, String businessUnitName) {
        Set<Id> prdIds = new Set<Id>();
        Map<Id, Business_Unit__c> buMap = new Map<Id, Business_Unit__c>();
        List<Target_Commit_Stats__c> targetCommitList = new List<Target_Commit_Stats__c>();
        List<TargetCommitWrapper> targetCommitWrapperList = new List<TargetCommitWrapper>();
        Map<String, TargetCommitWrapper> monthPrdWrap = new Map<String, TargetCommitWrapper>();
        Map<Id, Decimal> productPriceMap = new Map<Id, Decimal>();
        
        
        List<Account> accList = [SELECT Id, XC_PricingGroup__c,OwnerId FROM Account WHERE Id =: accountId];
        if(accList.isEmpty()) {
            throw new AuraHandledException('Account is Empty');
        }
        
        if(businessUnitName != '' && businessUnitName != null){
            for (Business_Unit__c bu : [SELECT ID, Unique_Name__c FROM Business_Unit__c WHERE Unique_Name__c =: businessUnitName]){
                buMap.put(bu.Id, bu);
            }
        }
        Id priceBookId;
        
        for(
            BuyerGroup bgroup :
            [SELECT Id, (SELECT PriceBook2Id FROM BuyerGroupPricebooks WHERE IsActive = true AND PriceBook2.Name =: accList[0].XC_PricingGroup__c LIMIT 1) FROM BuyerGroup
             WHERE Id IN (SELECT BuyerGroupId FROM BuyerGroupMember where BuyerId =: accountId)]
        ) {
            if(!bgroup.BuyerGroupPricebooks.isEmpty()) {
                priceBookId = bgroup.BuyerGroupPricebooks[0].PriceBook2Id;
            }
        }
        
        if(businessUnitName == '' || businessUnitName == null){
            targetCommitList =[Select Id,Account__c,BDM__c,Product__c,Finish__c,SKU__c,Product_Business_Unit__c,Description__c, Jan__c, May__c, Dec__c, Nov__c, Oct__c, Sep__c,
                               Aug__c, Feb__c, Jul__c, Jun__c,Mar__c, Apr__c,IsUpload__c, Product__r.Start_Date__c,Non_Available_Product__c from Target_Commit_Stats__c  
                               WHERE IsUpload__c = false AND Product__r.Available_for_commitment__c = True AND Financial_Year__c =: financialYear AND Account__c =: accountId AND BDM__c =: selectedUser 
                               ORDER BY Product_Business_Unit__c ASC];
        }
        else{
            targetCommitList =[Select Id,Account__c,BDM__c,Product__c,Finish__c,SKU__c,Product_Business_Unit__c,Description__c, Jan__c, May__c, Dec__c, Nov__c, Oct__c, Sep__c,
                               Aug__c, Feb__c, Jul__c, Jun__c,Mar__c, Apr__c,IsUpload__c, Business_Unit__c, Product__r.Start_Date__c,Non_Available_Product__c from Target_Commit_Stats__c  
                               WHERE IsUpload__c = false AND Product__r.Available_for_commitment__c = True AND Financial_Year__c =: financialYear AND Account__c =: accountId
                               AND BDM__c =: selectedUser  AND Business_Unit__c IN: buMap.keySet()
                               ORDER BY Product_Business_Unit__c ASC];
        }
        
        for (Target_Commit_Stats__c targetCommit : targetCommitList) {
            prdIds.add(targetCommit.Product__c);
            
            TargetCommitWrapper targetCommitWrapper = new TargetCommitWrapper();
            targetCommitWrapper.productId =  targetCommit.Product__c;
            targetCommitWrapper.targetCommitId = targetCommit.Id;
            targetCommitWrapper.productCode = targetCommit.SKU__c ;
            targetCommitWrapper.finish = targetCommit.Finish__c;
            targetCommitWrapper.description = targetCommit.Description__c;
            targetCommitWrapper.businessUnit = targetCommit.Product_Business_Unit__c ;
            targetCommitWrapper.January = targetCommit.Jan__c;
            targetCommitWrapper.February = targetCommit.Feb__c;
            targetCommitWrapper.March = targetCommit.Mar__c;
            targetCommitWrapper.April = targetCommit.Apr__c ;
            targetCommitWrapper.May = targetCommit.May__c;
            targetCommitWrapper.June = targetCommit.Jun__c ;
            targetCommitWrapper.July = targetCommit.Jul__c;
            targetCommitWrapper.August = targetCommit.Aug__c ;
            targetCommitWrapper.September = targetCommit.Sep__c;
            targetCommitWrapper.October = targetCommit.Oct__c ;
            targetCommitWrapper.November = targetCommit.Nov__c;
            targetCommitWrapper.December = targetCommit.Dec__c;
            targetCommitWrapper.unitPrice = 0;
            targetCommitWrapper.startDate = targetCommit.Product__r.Start_Date__c;
            targetCommitWrapper.nonAvailableProduct = targetCommit.Non_Available_Product__c;
            
            targetCommitWrapperList.add(targetCommitWrapper);            
        }
        
        if(priceBookId == null) {
            return targetCommitWrapperList;
        }
        
        for (PricebookEntry pbEntry : [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :priceBookId AND Product2Id IN :prdIds]) {
            productPriceMap.put(pbEntry.Product2Id, pbEntry.UnitPrice);
        }
        
        for (TargetCommitWrapper prd : targetCommitWrapperList) {
            if (productPriceMap.containsKey(prd.productId)) {
                prd.unitPrice = productPriceMap.get(prd.productId);
            }
        }
        return targetCommitWrapperList;
    }
    
    
    
    @AuraEnabled
    Public static List<ProductWrapper> downloadBusUnitProducts(Id busId, String businessUnit, String accountId, String financialYear,List<String> selectedMonth,  String ProdCode, String ProdDescription) {
        Set<Id> prdIds = new Set<Id>();
        List<Product2> productsList = new List<Product2>();
        Map<String, ProductWrapper> monthPrdWrap = new Map<String, ProductWrapper>();
        
        List<Business_Unit__c> buList = [SELECT Id FROM Business_Unit__c WHERE Unique_Name__c =: businessUnit LIMIT 1];
        if(!buList.isEmpty()) {
            busId = buList[0].Id;
        }
        else {
            buList = [SELECT Unique_Name__c FROM Business_Unit__c WHERE Id =: busId];
            if(!buList.isEmpty()) {
                businessUnit = buList[0].Unique_Name__c;
                busId =  buList[0].Id;
            }
        }
       
        List<Account> accList = [SELECT Id, XC_PricingGroup__c,OwnerId FROM Account WHERE Id =: accountId];
        if(accList.isEmpty()) {
            throw new AuraHandledException('Account is Empty');
        }
       
        Id priceBookId;
       
        for(
            BuyerGroup bgroup :
            [SELECT Id, (SELECT PriceBook2Id FROM BuyerGroupPricebooks WHERE IsActive = true AND PriceBook2.Name =: accList[0].XC_PricingGroup__c LIMIT 1) FROM BuyerGroup
             WHERE Id IN (SELECT BuyerGroupId FROM BuyerGroupMember where BuyerId =: accountId) AND Business_Unit__c like :'%'+businessUnit+'%' LIMIT 1]
        ) {
            if(!bgroup.BuyerGroupPricebooks.isEmpty()) {
                priceBookId = bgroup.BuyerGroupPricebooks[0].PriceBook2Id;
            }
        }
        
        if(String.isBlank(ProdCode) && String.isBlank(ProdDescription)) {
            productsList = [SELECT Id, Business_Unit__c, StockKeepingUnit , Description,Finish__c,
                            (SELECT Id, Financial_Year__c, Month__c, Quantity__c, Unit_Price__c, Commited_Order__c, Business_Unit__c, Account__c,BDM__c, Product__c
                             FROM Order_Commitments__r WHERE Financial_Year__c = :financialYear  AND  Month__c  IN:selectedMonth AND
                             Business_Unit__c =: busId AND Account__c =: accountId ) FROM Product2
                            WHERE Business_Unit__c =: businessUnit AND Available_for_commitment__c = True];
        }
        else {
            productsList = [SELECT Id, Business_Unit__c, StockKeepingUnit , Description,Finish__c,
                            (SELECT Id, Financial_Year__c, Month__c, Quantity__c, Unit_Price__c, Commited_Order__c, Business_Unit__c, Account__c,BDM__c, Product__c
                             FROM Order_Commitments__r WHERE Financial_Year__c = :financialYear AND Month__c IN:selectedMonth AND
                             Business_Unit__c =: busId AND Account__c =: accountId) FROM Product2
                            WHERE Business_Unit__c = :businessUnit AND StockKeepingUnit LIKE :(ProdCode + '%') AND
                            Description LIKE :('%' + ProdDescription + '%') AND Available_for_commitment__c = True] ;
        }
       
        for (Product2 product : productsList) {
            prdIds.add(product.Id);
            
            for(String month : selectedMonth) {
                ProductWrapper prdWrapper = new ProductWrapper();
                prdWrapper.productCode = product.StockKeepingUnit ;
                prdWrapper.description = product.Description;
                prdWrapper.ordCommitsQuantity = 0;
                prdWrapper.committedOrder = 0;
                prdWrapper.productId = product.Id;
                prdWrapper.orderCommitId = null;
                prdWrapper.buId = busId;
                prdWrapper.accId = accountId;
                prdWrapper.financialYear = financialYear;
                prdWrapper.month = month;
                prdWrapper.ordCommitsUnitPrice = 0;
                prdWrapper.finish = product.Finish__c;    
                prdWrapper.accountOwnerId = accList[0].OwnerId;
                prdWrapper.ordCommitMonth = '';
                
                monthPrdWrap.put(month+'_'+product.Id, prdWrapper);
            }
            
            if(product.Order_Commitments__r == null || product.Order_Commitments__r.isEmpty()) {
                continue;
            }
            
            for(Order_Commitment__c commitment : product.Order_Commitments__r) {
                if(monthPrdWrap.containsKey(commitment.Month__c + '_' + commitment.Product__c)) {
                    ProductWrapper commitmentWrapper = new ProductWrapper();
                    commitmentWrapper.productCode = product.StockKeepingUnit;
                    commitmentWrapper.description = product.Description;
                    commitmentWrapper.productId = product.Id;
                    commitmentWrapper.buId = busId;
                    commitmentWrapper.accId = accountId;
                    commitmentWrapper.financialYear = financialYear;
                    commitmentWrapper.finish = product.Finish__c;
                    commitmentWrapper.accountOwnerId = accList[0].OwnerId;
                    commitmentWrapper.ordCommitMonth = commitment.Month__c;
                    commitmentWrapper.month = commitment.Month__c;
                    
                    commitmentWrapper.orderCommitId = commitment.Id;
                    commitmentWrapper.ordCommitsQuantity = commitment.Quantity__c;
                    commitmentWrapper.ordCommitsUnitPrice = commitment.Unit_Price__c;
                    commitmentWrapper.committedOrder = commitment.Commited_Order__c;
                    commitmentWrapper.accountOwnerId = commitment.BDM__c;
                    
                    monthPrdWrap.put(commitment.Month__c + '_' + commitment.Product__c, commitmentWrapper);
                }
            }
        }
        
        if(priceBookId == null) {
            return monthPrdWrap.values();
            //throw new AuraHandledException('Unable to Proceed: Business Unit/Account Not Linked with Buyer Group');
        }
        
        for(
            PricebookEntry pbEntry :
            [SELECT Id,Product2Id,UnitPrice FROM PricebookEntry  WHERE Pricebook2Id =: priceBookId AND Product2Id IN: prdIds]
        ) {
            for(String month : selectedMonth) {
                monthPrdWrap.get(month+'_'+pbEntry.Product2Id).ordCommitsUnitPrice = pbEntry.UnitPrice;
            }
        }
        
        return monthPrdWrap.values();
    }

     @AuraEnabled
    public static void changeTargetAcknowledge(Id currentUser, String commentMessage, Boolean isAccept, Boolean isReject){
        List<Target_Acknowledgement__c> tAcknowledgeList = new List<Target_Acknowledgement__c>();
        List<Target_Acknowledgement_History__c> ackHistoryList = new List<Target_Acknowledgement_History__c>();
        
        for(Target_Acknowledgement__c tAcknowledge : [SELECT Id, BDD__c, BDM__c, Status__c, Comments__c FROM Target_Acknowledgement__c WHERE BDM__c = :currentUser]){
            if(isAccept){
                tAcknowledge.Status__c = 'Accepted';
                tAcknowledge.Comments__c = commentMessage;
                tAcknowledgeList.add(tAcknowledge);
            }
            else if(isReject){
                tAcknowledge.Status__c = 'Reverted';
                tAcknowledge.Comments__c = commentMessage;
                tAcknowledgeList.add(tAcknowledge);
            }
           
        }
        
        if(!tAcknowledgeList.isEmpty()){
            Update tAcknowledgeList;
            
            for(Target_Acknowledgement__c tAcknowledge : tAcknowledgeList){
                Target_Acknowledgement_History__c newHistory = new Target_Acknowledgement_History__c();
                newHistory.Target_Acknowledgement__c = tAcknowledge.Id;
                newHistory.Status__c = tAcknowledge.Status__c;
                newHistory.Comments__c = tAcknowledge.Comments__c;
                ackHistoryList.add(newHistory);
            }
        }
        
        if(!ackHistoryList.isEmpty()){
            Insert ackHistoryList;
        }
        
    }
    
     public class InvoiceWrapper {
        public Integer invoicedQty;
        public Decimal invoicedPrice;
        public Integer openQty;
        public Decimal openPrice;
        
        public InvoiceWrapper(Integer invoicedQty, Decimal invoicedPrice, Integer openQty, Decimal openPrice) {
            this.invoicedQty = invoicedQty;
            this.invoicedPrice = invoicedPrice;
            this.openQty = openQty;
            this.openPrice = openPrice;
        }
    }
   
    public class ProductWrapper {
        @AuraEnabled
        public String productCode { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public Decimal ordCommitsQuantity { get; set; }
        @AuraEnabled
        public Decimal ordCommitsUnitPrice { get; set; }
        @AuraEnabled
        public Decimal committedOrder { get; set; }
        @AuraEnabled
        public Id productId { get; set; }
        @AuraEnabled
        public Id orderCommitId { get; set; }
        @AuraEnabled
        public Id buId { get; set; }
        @AuraEnabled
        public Id accId { get; set; }
        @AuraEnabled
        public String financialYear { get; set; }
        @AuraEnabled
        public String month { get; set; }
        @AuraEnabled
        public String finish { get; set; }
        @AuraEnabled
        public Id accountOwnerId { get; set; }
        @AuraEnabled
        public String ordCommitMonth { get; set; }
        @AuraEnabled
        public Integer invoicedQty { get; set; }
        @AuraEnabled
        public Decimal invoicedPrice { get; set; }
        @AuraEnabled
        public Integer openQty { get; set; }
        @AuraEnabled
        public Decimal openPrice { get; set; }
        @AuraEnabled
        public Boolean commitAvailable { get; set;}
        @AuraEnabled
        public Date startDateField { get; set; }
        @AuraEnabled
        public Date endDateField { get; set; }
        @AuraEnabled
        public Date startDateWrapper { get; set; }
        @AuraEnabled
        public Date endDateWrapper { get; set; }
    }
    
    public class TargetCommitWrapper {
        @AuraEnabled
        public Id targetCommitId { get; set; }
        @AuraEnabled
        public Id productId { get; set; }
        @AuraEnabled
        public String productCode { get; set; }
        @AuraEnabled
        public String finish { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String businessUnit { get; set; }
        @AuraEnabled
        public Decimal January { get; set; }
        @AuraEnabled
        public Decimal February { get; set; }
        @AuraEnabled
        public Decimal March { get; set; }
        @AuraEnabled
        public Decimal April { get; set; }
        @AuraEnabled
        public Decimal May { get; set; }
        @AuraEnabled
        public Decimal June { get; set; }
        @AuraEnabled
        public Decimal July { get; set; }
        @AuraEnabled
        public Decimal August { get; set; }
        @AuraEnabled
        public Decimal September { get; set; }
        @AuraEnabled
        public Decimal October { get; set; }
        @AuraEnabled
        public Decimal November { get; set; }
        @AuraEnabled
        public Decimal December { get; set; }
        @AuraEnabled
        public Decimal unitPrice { get; set; }
        @AuraEnabled
        public Date startDate { get; set; }
        @AuraEnabled
        public boolean nonAvailableProduct{ get;set; }
    }
   
    public class BDMBusUnitTarActVar {
        @AuraEnabled
        public Decimal targetAmt {get; set;}
        @AuraEnabled
        public Decimal actualAmt {get; set;}
        @AuraEnabled
        public Decimal varianceAmt {get; set;}
       
        public BDMBusUnitTarActVar(Decimal targetAmt, Decimal actualAmt, Decimal varianceAmt) {
            this.targetAmt = targetAmt;
            this.actualAmt = actualAmt;
            this.varianceAmt = varianceAmt;            
        }
    }
   
    public class BDMMonthTarActVar {
        @AuraEnabled
        public Decimal monthTarAmt {get; set;}
        @AuraEnabled
        public Decimal monthActAmt {get; set;}
        @AuraEnabled
        public Decimal monthVarAmt {get; set;}
        @AuraEnabled
        public Decimal monthOrdCommit {get; set;}
       
        public BDMMonthTarActVar(Decimal monthTarAmt, Decimal monthActAmt, Decimal monthVarAmt,Decimal monthOrdCommit) {
            this.monthTarAmt = monthTarAmt;
            this.monthActAmt = monthActAmt;
            this.monthVarAmt = monthVarAmt;  
            this.monthOrdCommit = monthOrdCommit;
        }
    }
   
    public class BDMAccount {
        @AuraEnabled
        public Id userId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String accId {get; set;}
        @AuraEnabled
        public Decimal actualAmount {get; set;}
        @AuraEnabled
        public Decimal targetAmount {get; set;}
        @AuraEnabled
        public Decimal varianceAmount {get; set;}
        @AuraEnabled
        public Decimal actual {get; set;}
        @AuraEnabled
        public Decimal target {get; set;}
        @AuraEnabled
        public Decimal variance {get; set;}
       
        public BDMAccount(Id userId, String name, String accId, Decimal actualAmount,Decimal targetAmount,Decimal varianceAmount,Decimal actual, Decimal target, Decimal variance) {
            this.userId = userId;
            this.name = name;
            this.accId = accId;
            this.actualAmount = actualAmount;
            this.targetAmount = targetAmount;
            this.varianceAmount = varianceAmount;
            this.actual = actual;
            this.target = target;
            this.variance =variance;
        }
    }
}