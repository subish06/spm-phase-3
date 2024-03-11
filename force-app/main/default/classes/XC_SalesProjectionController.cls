public without sharing class XC_SalesProjectionController {   
    
    @AuraEnabled
    public static List<XC_SalesProjectionItem__c> updateSalesProjectionItems(List<Object> excelInput){
        List<XC_SalesProjectionItem__c> spisToUpdate = new List<XC_SalesProjectionItem__c>();
        Map<String,Integer> planValuesByExternalId = new Map<String,Integer>();
        
        System.debug(excelInput);
        
        for(Object row : excelInput){
            Map<String, Object> rowData = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(row));
            System.debug(rowData);
            for(Integer i = 0 ; i < 12 ; i+=1){
                Integer period = i + 1; 
                
                String planColumn = 'Planned Quantity P' + String.valueOf(period);
                
                String extId = String.valueOf(rowData.get('External Id')) + '_' + String.valueOf(period);
                Integer plannedQty = Integer.valueOf(rowData.get(planColumn));
                planValuesByExternalId.put(extId, plannedQty);
            }

        }
        
        System.debug(planValuesByExternalId.keySet());
        
        for(XC_SalesProjectionItem__c spi : [SELECT Id, PlannedQuantity__c, PlannedSales__c, External_Id__c FROM XC_SalesProjectionItem__c WHERE External_Id__c IN :planValuesByExternalId.keySet()]){
            Integer previousQuantity = Integer.valueOf(spi.PlannedQuantity__c);
            System.debug('found matching SPI with Id: ' + spi.Id);
            spi.PlannedQuantity__c = planValuesByExternalId.get(spi.External_Id__c);
            if(spi.PlannedSales__c != null){
                Decimal unitPrice = spi.PlannedSales__c / previousQuantity;
                Decimal newPlannedSales = (spi.PlannedQuantity__c * unitPrice);
                spi.PlannedSales__c = newPlannedSales;
            }
            spisToUpdate.add(spi);
        }
        List<Database.SaveResult> result = Database.update(spisToUpdate, false);
        System.debug(result);
        return spisToUpdate;
    }

    @AuraEnabled
    public static List<String> getAllValidBusinessUnits(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Authorized_Business_Units__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }

    @AuraEnabled
    public static String initiateSalesProjectionBatch(List<Object> excel, List<String> accountNumbers, List<String> bdms){
        System.debug('init');
        try {
            XC_SalesProjectionBatch spb = new XC_SalesProjectionBatch(excel, accountNumbers, bdms);
            Id batchId = Database.executeBatch(spb);
            return batchId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<XC_SalesProjection__c> uploadSalesProjections(List<Object> excel, Map<String, String> accountIdsByCustomerNumber, String[] bdms){
        Map<String, Object> response = new Map<String, Object>();
        List<String> inputAsTable = new List<String>();
        List<XC_SalesProjection__c> salesProjections = new List<XC_SalesProjection__c>();
        Map<String, String> bdmIdsByEmail = new Map<String, String>();

        for(User u : [SELECT Id, Email FROM User WHERE Email IN :bdms]){
            bdmIdsByEmail.put(u.Email, u.Id);
        }

        for(Object row : excel){
            Map<String, Object> rowData = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(row));
            XC_SalesProjection__c sp = new XC_SalesProjection__c();
            
            String accountId = String.valueOf(rowData.get('InvoiceAccount'));
            System.debug('account ID: ' + accountIdsByCustomerNumber.get(accountId));

            if(accountIdsByCustomerNumber.get(accountId) != null){
                sp.XC_Account__c = accountIdsByCustomerNumber.get(accountId);
                sp.XC_Admin_Account_Target_Qty__c = ((Integer)rowData.get('SalesTargetQty'));
                sp.AccountTarget__c = (Decimal)rowData.get('Sales Target Amount');
                sp.BusinessUnit__c = (String)rowData.get('BusinessUnit');
                sp.XC_Fiscal_Period__c = (Integer)rowData.get('FiscalPeriod');
                sp.XC_Fiscal_Year__c = (Integer)rowData.get('FiscalYear');
                sp.BDM__c = bdmIdsByEmail.get(String.valueOf(rowData.get('BDM'))) != null ? bdmIdsByEmail.get(String.valueOf(rowData.get('BDM'))) : UserInfo.getUserId() ;
                salesProjections.add(sp);
            } else {
                System.debug('Account #' + accountId + ' could not be found.');
                if(bdmIdsByEmail.get(String.valueOf(rowData.get('BDM'))) == null){
                    System.debug('No user with email ' + rowData.get('BDM') + ' could not be found in this instance.');
                }
            }
        }

        Database.SaveResult[] srList = Database.insert(salesProjections, false);
        System.debug('Save Result in Sales Projection');
        System.debug(srList);
        return salesProjections;
    }

    public static void createSalesProjectionItems(List<XC_SalesProjection__c> salesProjections, Double yearlyProjectionTotal){
        System.debug('Yearly projected total is: ' + yearlyProjectionTotal);
        Set<String> buyerGroupIds = new Set<String>();
        Set<String> policyIds = new Set<String>();
        Map<String,Decimal> quantitiesBySku = new Map<String,Decimal>();
        Map<String,Decimal> totalsBySku = new Map<String,Decimal>();
        List<XC_SalesProjectionItem__c> items = new List<XC_SalesProjectionItem__c>();
        Integer numberOfProjections = salesProjections.size();
        Decimal historicalTotalQty = 0;
        Decimal historicalTotalSales = 0;
        //get account id
        String accountId = salesProjections[0].XC_Account__r.Id;
        String businessUnit = salesProjections[0].BusinessUnit__c;
        String invoiceAccountId = salesProjections[0].XC_Account__r.XC_InvoiceAccountId__c;

        for(AggregateResult result : [
            SELECT SUM(TotalPrice) TotalPrice, SUM(Quantity) Quantity, COUNT(Id) num, Product2.StockKeepingUnit, Order.AccountId
            FROM OrderItem  
            WHERE Order.EffectiveDate = LAST_N_MONTHS:12
            AND Order.Account.XC_InvoiceAccountId__c = :invoiceAccountId 
            GROUP BY Product2.StockKeepingUnit, Order.AccountId]){
                Decimal totalPrice = Decimal.valueOf(String.valueOf(result.get('TotalPrice')));
                Decimal totalQuantity = Decimal.valueOf(String.valueOf(result.get('Quantity')));
                String sku = String.valueOf(result.get('StockKeepingUnit'));
                quantitiesBySku.put(sku, totalQuantity);
                totalsBySku.put(sku, totalPrice);
            }

        for(BuyerGroupMember bgm : [SELECT Id, BuyerGroupId FROM BuyerGroupMember WHERE BuyerId = :accountId]){
            buyerGroupIds.add(bgm.BuyerGroupId);
        } 

        if(buyerGroupIds.size()>0){
            for(CommerceEntitlementBuyerGroup cbg : [SELECT Id, PolicyId FROM CommerceEntitlementBuyerGroup WHERE BuyerGroupId IN : buyerGroupIds]){
                policyIds.add(cbg.PolicyId);
            }
        }
        
        Map<String,XC_SalesProjection__c> projectionsById = new Map<String,XC_SalesProjection__c>();
       
        Map<String,Integer> yearlyQuantityBySku = new Map<String,Integer>();
        Map<String,List<XC_SalesProjectionItem__c>> projectionItemsByProjectionId = new Map<String,List<XC_SalesProjectionItem__c>>();
        Map<String,Double> splitsByExtId = new Map<String,Double>();
        List<CommerceEntitlementProduct> ceps = new List<CommerceEntitlementProduct>();
        
        if(policyIds.size()>0){
            for(CommerceEntitlementProduct cItem : [
                SELECT Id, Policy.Name, Product.Id, Product.Name, Product.StockKeepingUnit, Policy.CanViewProduct, Product.Business_Unit__c
                FROM CommerceEntitlementProduct 
                WHERE PolicyId IN :policyIds
                AND Policy.CanViewProduct = TRUE
                AND Policy.CanViewPrice = TRUE
                AND Product.IsActive = TRUE
                AND Product.StockKeepingUnit != NULL
                AND Product.Name != NULL
                AND Product.Name != 'X' 
                AND Product.Business_Unit__c = :businessUnit
                AND Product.StockKeepingUnit IN :quantitiesBySku.keySet()
            ]){
                ceps.add(cItem);
                // add this item's total to the entire historical total for the account, within the business unit
                historicalTotalQty = historicalTotalQty + quantitiesBySku.get(cItem.Product.StockKeepingUnit);
                historicalTotalSales = historicalTotalSales + totalsBySku.get(cItem.Product.StockKeepingUnit);
            }
            
            System.debug('Historical Total is: ' + historicalTotalQty);
            
            // now that we have valid skus, we can start finding our totals and splits
            for(CommerceEntitlementProduct cItem: ceps){
                for(XC_SalesProjection__c salesProjection : salesProjections){
                    Double split = (quantitiesBySku.get(cItem.Product.StockKeepingUnit) / historicalTotalQty );
                    System.debug('The split for SKU ' + cItem.Product.StockKeepingUnit + ' is: ' + split);
                    
                    String externalId = salesProjection.XC_Account__r.XC_CustomerId__c + '_' + salesProjection.BusinessUnit__c + '_' + cItem.Product.StockKeepingUnit + '_' + Integer.valueOf(salesProjection.XC_Fiscal_Year__c) + '_' + Integer.valueOf(salesProjection.XC_Fiscal_Period__c);
                    splitsByExtId.put(externalId, split);
                    projectionsById.put(salesProjection.Id, salesProjection);
                    XC_SalesProjectionItem__c spi = new XC_SalesProjectionItem__c(
                        Product__c = cItem.Product.Id,
                        Sales_Projection__c = salesProjection.Id,
                        Historical_Quantity__c = quantitiesBySku.get(cItem.Product.StockKeepingUnit),
                        Historical_Total__c = totalsBySku.get(cItem.Product.StockKeepingUnit),
                        External_Id__c = externalId
                    );
                    if(projectionItemsByProjectionId.containsKey(salesProjection.Id)){
                        List<XC_SalesProjectionItem__c> spiList = projectionItemsByProjectionId.get(salesProjection.Id);
                        spiList.add(spi);
                        projectionItemsByProjectionId.put(salesProjection.Id, spiList);
                    } else {
                        List<XC_SalesProjectionItem__c> spiList = new List<XC_SalesProjectionItem__c>();
                        spiList.add(spi);
                        projectionItemsByProjectionId.put(salesProjection.Id, spiList);
                    }
                }
            }
            
            Map<String, Integer> monthlyTotalsBySku = new Map<String, Integer>();
            
            //get yearly and monthly totals by sku
            for(String extId : splitsByExtId.keySet()){
                String sku = extId.split('_')[2];
                System.debug('SKU is: ' + sku);
                
                Integer yearlyTotal = Math.round(splitsByExtId.get(extId) * yearlyProjectionTotal);
                Decimal unroundedMonthlyTotal = (Decimal)yearlyTotal / (Decimal)numberOfProjections;
                Integer monthlyTotal;
                if(yearlyTotal <= numberOfProjections){
                    monthlyTotal = 1;
                } else {
                    monthlyTotal = Math.round(unroundedMonthlyTotal);
                    yearlyTotal = monthlyTotal * numberOfProjections;
                }
                System.debug('Yearly total is: ' + yearlyTotal);
                yearlyQuantityBySku.put(sku, yearlyTotal);
                monthlyTotalsBySku.put(sku, (Integer)monthlyTotal);
            }
            
            // build items list and assign planned values
            for(String projectionId : projectionsById.keySet()){
                XC_SalesProjection__c salesProjection = projectionsById.get(projectionId);
                for(XC_SalesProjectionItem__c item : projectionItemsByProjectionId.get(projectionId)){
                    // get sku
                    String sku = item.External_Id__c.split('_')[2];
                    System.debug('SKU is: ' + sku);
                    
                    Decimal yearlyQty = (Decimal)yearlyQuantityBySku.get(sku);
                    Integer itemQty = monthlyTotalsBySku.get(sku);
                    System.debug('Item Quantity is: ' + itemQty);
                    
                    // find how much is left of the yearly after we subtract this item's qty
                    Integer leftoverQty = Integer.valueOf(yearlyQty) - Integer.valueOf(itemQty);
                    System.debug('Leftover Quantity is: ' + leftoverQty);
                    
                    // update yearly total with leftover value
                    System.debug('Remaing Quantity was: ' + yearlyQty);
                    yearlyQuantityBySku.put(sku, leftoverQty);
                    System.debug('Remaing Quantity is now: ' + leftoverQty);
                    
                    // find sku values
                    Decimal productTotal = totalsBySku.get(sku);
                    Decimal productQuantity = quantitiesBySku.get(sku);
                    Decimal productValue = productTotal/productQuantity;
                    
                    // decide how much should be assigned to planned values
                    if(leftoverQty < 0){
                        item.PlannedQuantity__c = 0;
                        item.PlannedSales__c = 0;
                        System.debug('yearly total is ' + leftoverQty + ' so Planned Quantity and Sales are 0');
                    } else {
                        item.PlannedSales__c = productValue * itemQty;
                        item.PlannedQuantity__c = itemQty;
                        System.debug('yearly total is ' + leftoverQty + ' so Planned Quantity is: ' + itemQty + ' and planned Sales is: ' + item.PlannedSales__c);
                    }
                    items.add(item);
                }
            }     
         
            Database.SaveResult[] srList = Database.insert(items, false);
            System.debug('Save Result in Sales Projection Item');
            System.debug(srList);

        } else {
            //throw new XC_ProductController.NoEntitlementException('User does not have any entitlements.');
            System.debug('no entitled products match the criteria');
        }
    }

    public class TooManyRowsException extends Exception{}
}