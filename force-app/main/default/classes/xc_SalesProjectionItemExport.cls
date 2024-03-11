public with sharing class xc_SalesProjectionItemExport {

    @AuraEnabled
    public static Id callSPBatch(String invoiceAcct, String businessUnit,Decimal fiscalYear){
             Id jobId = Database.executeBatch(new XC_SalesProjectionExportBatch(invoiceAcct, businessUnit, fiscalYear));
            return jobId;
     } 

    /**
     * Commented below code as it is not in use anymore. Used for importing csv and exporting on UI
     */
    
//     @AuraEnabled(cacheable=true)
//     public static List<XC_SalesProjectionItem__c> getSalesProjectionItemExport(Id recordId){
//         List<XC_SalesProjectionItem__c> salesPI = new List<XC_SalesProjectionItem__c>();
//         System.debug('recordId'+recordId);
//         salesPI = [SELECT Id, Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c, Product__r.Description,Product__r.StockKeepingUnit, Product__r.XC_Color__c,Sales_Projection__r.BusinessUnit__c, Sales_Projection__r.Status__C, Historical_Quantity__c,Historical_Total__c,Target_Quantity__c,Target_Sales__c,PlannedQuantity__c,PlannedSales__c FROM XC_SalesProjectionItem__c where Sales_Projection__c=:recordId AND Sales_Projection__r.Status__c = 'Draft'];
        
//         System.debug('salesPIIIIIIIIIIIIII'+salesPI);
//         return salesPI;
//     }

// @AuraEnabled
// public static String importSalesProjectionItems(List<XC_SalesProjectionItem__c> csvMap,Id spRecordId){
//      try{
//              system.debug('csvInptttttt'+csvMap+'size'+csvMap.size());
//         for(Integer i=0;i<csvMap.size();i++){
//             system.debug('csvMap[i].Idddddddddddd'+csvMap[i].Id);
//             List<XC_SalesProjectionItem__c> spi  = [SELECT Id, PlannedQuantity__c,PlannedSales__c from XC_SalesProjectionItem__c where Id=:csvMap[i].Id and Sales_Projection__c = :spRecordId]; 
//            if(spi.size()==0){
//             return 'Wrong SPI';
//            }
//            else{
//             spi[0].PlannedQuantity__c = csvMap[i].PlannedQuantity__c;
//             spi[0].PlannedSales__c = csvMap[i].PlannedSales__c;
//             update spi;  
//            }
//         }
//         return 'Success';
//      }
//      catch (Exception e){
//         return 'Failure';
//      }
//     }

//     @AuraEnabled
//     public static List<XC_SalesProjectionExportWrapper> getSalesProjectionItemExcelExport(String invoiceAcct, String businessUnit, Decimal fiscalYear){
//         List<XC_SalesProjectionItem__c> salesPI = new List<XC_SalesProjectionItem__c>();
//         List<XC_SalesProjectionExportWrapper> salesPExport = new List<XC_SalesProjectionExportWrapper>();
//         salesPI = [SELECT Id, 
//                           Sales_Projection__r.XC_Account__r.Name,
//                           Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c, 
//                           Product__r.Description, Product__r.StockKeepingUnit, 
//                           Product__r.XC_Color__c, Sales_Projection__r.BusinessUnit__c, 
//                           Sales_Projection__r.Status__C, Historical_Quantity__c,
//                           Historical_Total__c, Target_Quantity__c, Target_Sales__c,
//                           PlannedQuantity__c, PlannedSales__c, Sales_Projection__r.XC_Fiscal_Year__c,
//                           Sales_Projection__r.XC_Fiscal_Period__c
//                           FROM XC_SalesProjectionItem__c 
//                           where Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c=:invoiceAcct 
//                           AND Sales_Projection__r.BusinessUnit__c =:businessUnit
//                           AND Sales_Projection__r.XC_Fiscal_Year__c =:fiscalYear
//                           AND Sales_Projection__r.Status__c = 'Draft' 
//                         ORDER BY Product__r.StockKeepingUnit, Sales_Projection__r.XC_Fiscal_Period__c];
//         System.debug('salesPIIIIIIIIIIIIII'+salesPI);

//         XC_SalesProjectionExportWrapper salesPIExp = new XC_SalesProjectionExportWrapper();
//         String fpfieldName = 'xc_Planned_Quantity_P';
//         String ftfieldName = 'xc_Target_Quantity_P';
//         String sku = salesPI[0].Product__r.StockKeepingUnit;

//          for(Integer i=0;i<salesPI.size();i++){
//             System.debug('iiiiiiiiiiiiii111111 = '+i); 
//             System.debug('salesPI.size()11111111 = '+salesPI.size()); 

//             if(sku == salesPI[i].Product__r.StockKeepingUnit){

//                 salesPIExp.xc_BusinessUnit = salesPI[i].Sales_Projection__r.BusinessUnit__c;
//                 salesPIExp.Color = salesPI[i].Product__r.XC_Color__c;
//                 salesPIExp.Description = salesPI[i].Product__r.Description;
//                 salesPIExp.Fiscal_Year = salesPI[i].Sales_Projection__r.XC_Fiscal_Year__c;
//                 salesPIExp.XC_Historical_Quantity = salesPI[i].Historical_Quantity__c;
//                 salesPIExp.XC_Account_Name= salesPI[i].Sales_Projection__r.XC_Account__r.Name;
//                 salesPIExp.xC_InvoiceAccountId = salesPI[i].Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c;
//                 salesPIExp.StockKeepingUnit = salesPI[i].Product__r.StockKeepingUnit;
//                 salesPIExp.External_Id = salesPI[i].Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c + '_' + 
//                                             salesPI[i].Sales_Projection__r.BusinessUnit__c + '_'+
//                                             salesPI[i].Product__r.StockKeepingUnit + '_'+
//                                             salesPI[i].Sales_Projection__r.XC_Fiscal_Year__c;
//                 Decimal ftfield = Math.Round(salesPI[i].Target_Quantity__c);
//                 Decimal fpfield = Math.Round(salesPI[i].PlannedQuantity__c);
//                 Integer fPeriod = Integer.valueOf(salesPI[i].Sales_Projection__r.XC_Fiscal_Period__c); 
//                 switch on fPeriod{
//                     when 1{
//                         salesPIExp.xc_Planned_Quantity_P1 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P1 = ftfield;   
//                     }
//                     when 2{
//                         salesPIExp.xc_Planned_Quantity_P2 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P2 = ftfield;   
//                     }
//                     when 3{
//                         salesPIExp.xc_Planned_Quantity_P3 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P3 = ftfield;   
//                     }
//                     when 4{
//                         salesPIExp.xc_Planned_Quantity_P4 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P4 = ftfield;   
//                     }
//                     when 5{
//                         salesPIExp.xc_Planned_Quantity_P5 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P5 = ftfield;   
//                     }
//                     when 6{
//                         salesPIExp.xc_Planned_Quantity_P6 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P6 = ftfield;   
//                     }
//                     when 7{
//                         salesPIExp.xc_Planned_Quantity_P7 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P7 = ftfield;   
//                     }
//                     when 8{
//                         salesPIExp.xc_Planned_Quantity_P8 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P8 = ftfield;   
//                     }
//                     when 9{
//                         salesPIExp.xc_Planned_Quantity_P9 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P9 = ftfield;   
//                     }
//                     when 10{
//                         salesPIExp.xc_Planned_Quantity_P10 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P10 = ftfield;   
//                     }
//                     when 11{
//                         salesPIExp.xc_Planned_Quantity_P11 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P11 = ftfield;   
//                     }
//                     when 12{
//                         salesPIExp.xc_Planned_Quantity_P12 = fpfield;
//                         salesPIExp.xc_Target_Quantity_P12 = ftfield;   
//                     }
//                  when else{}
//                 }
//                 System.debug('iiiiiiiiiiiiii = '+i); 
//                 System.debug('salesPI.size() = '+salesPI.size()); 
//                 If (i==salesPI.size()-1){
//                 System.debug('salesPIExppppppppIFfff = '+salesPIExp);     
//                 salesPExport.add(salesPIExp);
//                 }
//                 }
//                 else{
//                     salesPExport.add(salesPIExp);
//                     System.debug('salesPIExpppppppp = '+salesPIExp);
//                     salesPIExp = new XC_SalesProjectionExportWrapper();
//                     System.debug('skuuuuuuuu1 = '+sku);
//                     sku = salesPI[i].Product__r.StockKeepingUnit;
//                     System.debug('skuuuuuuuuuu2222 = '+sku);
//                      i--;
//                 }
//             }
//          return salesPExport;
//     }     

// public without sharing class XC_SalesProjectionExportWrapper {
//     @AuraEnabled
//     public String External_Id;
//     @AuraEnabled
//     public String xC_InvoiceAccountId;
//     @AuraEnabled
//     public String XC_Account_Name;
//     @AuraEnabled
//     public String xc_BusinessUnit;
//     @AuraEnabled
//     public Decimal Fiscal_Year;
//     @AuraEnabled
//     public String StockKeepingUnit;
//     @AuraEnabled
//     public String Description;
//     @AuraEnabled
//     public String Color;
//     @AuraEnabled
//     public Decimal XC_Historical_Quantity;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P1;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P1;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P2;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P2;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P3;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P3;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P4;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P4;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P5;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P5;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P6;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P6;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P7;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P7;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P8;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P8;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P9;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P9;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P10;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P10;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P11;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P11;
//     @AuraEnabled
//     public Decimal xc_Target_Quantity_P12;
//     @AuraEnabled
//     public Decimal xc_Planned_Quantity_P12;
// }
   
}