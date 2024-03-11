public without sharing class XC_SalesProjectionExportBatch implements Database.Batchable<sObject>, Database.Stateful {
    public List<String> lines;
    public String generatedcsv ='';
    public String invoiceAcct;
    public String businessUnit;
    public Decimal fiscalYear;
    public String fileHeader;
    public String currentSKU='';
    public String fileName;
    public String fileLine='';
    public List<sObject> finalList = new List<sObject>();

    public XC_SalesProjectionExportBatch( String invacct,String bunit, Decimal fyear){
        invoiceAcct = invacct;
        businessUnit = bunit;
        fiscalYear= fyear;
    }

// Start Batchable Context
    public Database.QueryLocator start(Database.BatchableContext BC){
  
        return Database.getQueryLocator([SELECT Id, Sales_Projection__r.XC_Account__r.Name,
        Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c, 
        Product__r.Description, Product__r.StockKeepingUnit, 
        Product__r.XC_Color__c, Sales_Projection__r.BusinessUnit__c, 
        Sales_Projection__r.Status__C, Historical_Quantity__c,
        Historical_Total__c, Target_Quantity__c, Target_Sales__c,
        PlannedQuantity__c, PlannedSales__c, Sales_Projection__r.XC_Fiscal_Year__c,
        Sales_Projection__r.XC_Fiscal_Period__c
        FROM XC_SalesProjectionItem__c 
        where Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c=:invoiceAcct 
        AND Sales_Projection__r.BusinessUnit__c =:businessUnit
        AND Sales_Projection__r.XC_Fiscal_Year__c =:fiscalYear
        AND Sales_Projection__r.Status__c = 'Draft' 
      ORDER BY Product__r.StockKeepingUnit, Sales_Projection__r.XC_Fiscal_Period__c]);   
    }    
// Execute Batchable Context
    public void execute(Database.BatchableContext info, List<sObject> scope){
        for(sObject s: scope){
            finalList.add(s);
        }
    }    
// Finish Batchable Context
    public void finish(Database.BatchableContext info){        
        lines = new List<String>();
        fileHeader = '';
        fileHeader = fileHeader + '\t'+ 'External Id';
        fileHeader = fileHeader + '\t'+ 'Invoice Account Id';
        fileHeader = fileHeader + '\t'+ 'Account Name';
        fileHeader = fileHeader + '\t'+ 'Business Unit';
        fileHeader = fileHeader + '\t'+ 'Fiscal Year';
        fileHeader = fileHeader + '\t'+ 'SKU';
        fileHeader = fileHeader + '\t'+ 'Description';
        fileHeader = fileHeader + '\t'+ 'Color';
        fileHeader = fileHeader + '\t'+ 'Historical Qty';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P1';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P1';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P2';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P2';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P3';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P3';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P4';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P4';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P5';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P5';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P6';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P6';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P7';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P7';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P8';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P8';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P9';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P9';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P10';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P10';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P11';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P11';
        fileHeader = fileHeader + '\t'+ 'Target Quantity P12';
        fileHeader = fileHeader + '\t'+ 'Planned Quantity P12';
        fileHeader = fileHeader.replaceFirst('\t','');

        for(Integer i=0;i<finalList.size();i++){
            XC_SalesProjectionItem__c spi = (XC_SalesProjectionItem__c) finalList[i];
            Integer fPeriod = Integer.valueOf(spi.Sales_Projection__r.XC_Fiscal_Period__c); 
           
             Decimal TargetQuantity;
             If(spi.Target_Quantity__c != null){
               TargetQuantity  = spi.Target_Quantity__c.Round();
             }

            Decimal PlannedQuantity;
            If(spi.PlannedQuantity__c != null){
                PlannedQuantity  = spi.PlannedQuantity__c.Round();
              }

            if(currentSKU!=spi.Product__r.StockKeepingUnit && fPeriod==1){
                if(fileLine!=''){
                fileLine = fileLine.replaceFirst('\t','');
                    lines.add(fileLine);
                 }
          
                currentSKU = spi.Product__r.StockKeepingUnit;
                string fileRow = '';
                fileRow = fileRow +'\t'+ spi.Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c + '_' + spi.Sales_Projection__r.BusinessUnit__c + '_'+ spi.Product__r.StockKeepingUnit + '_'+ Integer.valueOf(spi.Sales_Projection__r.XC_Fiscal_Year__c);           
                fileRow = fileRow +'\t'+ spi.Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c;
                fileRow = fileRow +'\t'+ spi.Sales_Projection__r.XC_Account__r.Name;
                fileRow = fileRow +'\t'+ spi.Sales_Projection__r.BusinessUnit__c;
                fileRow = fileRow +'\t'+ spi.Sales_Projection__r.XC_Fiscal_Year__c;
                fileRow = fileRow +'\t'+ spi.Product__r.StockKeepingUnit;
                fileRow = fileRow +'\t'+ spi.Product__r.Description;
                fileRow = fileRow +'\t'+ spi.Product__r.XC_Color__c;
                fileRow = fileRow +'\t'+ spi.Historical_Quantity__c;
                fileRow = fileRow +'\t'+ TargetQuantity;
                fileRow = fileRow +'\t'+ PlannedQuantity;
                fileLine = fileRow;
                continue;
            }
            if(currentSKU==spi.Product__r.StockKeepingUnit){
                switch on fPeriod{
                    when 2{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;
                    }
                    when 3{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;
                    }
                    when 4{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;
                    }
                    when 5{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                        
                    }
                    when 6{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                        
                    }
                    when 7{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                        
                    }
                    when 8{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                        
                    }
                    when 9{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                        
                    }
                    when 10{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                        
                    }
                    when 11{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                          
                    }
                    when 12{
                        fileLine = fileLine +'\t'+ TargetQuantity;
                        fileLine = fileLine +'\t'+ PlannedQuantity;                          
                    }
                 when else{
                 }
                }                
            }
            if(i==finalList.size()-1){
                fileName = spi.Sales_Projection__r.XC_Account__r.XC_InvoiceAccountId__c + '_' + spi.Sales_Projection__r.BusinessUnit__c + '_' + Integer.valueOf(spi.Sales_Projection__r.XC_Fiscal_Year__c);
                fileLine = fileLine.replaceFirst('\t','');
                    lines.add(fileLine);
            }
        }
        
        String userEmail = UserInfo.getUserEmail();
        lines.add(0,fileHeader);
        generatedcsv = generatedcsv + string.join(lines, '\n').replaceAll('null','');
        String today = Datetime.now().format('MM-dd-yyyy');
        Blob csvBlob = blob.valueOf(generatedcsv);
        String csvName = fileName + ' on ' +today+'.xls';
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
        String[] toAddresses = new String[]{userEmail};       
        String subject = 'SPI Data of '+fileName+' on ' +today+'';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('SPI Data of '+fileName+' on ' +today+'');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});  
    } 
 }