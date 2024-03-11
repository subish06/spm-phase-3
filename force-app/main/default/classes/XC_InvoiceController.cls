public with sharing class XC_InvoiceController 
{
    // private XC_InvoiceController() {}

    @AuraEnabled
    public static List<XC_Invoice__c> getInvoices()
    {
        try 
        {
            Contact cont = [SELECT AccountId,Id from Contact WHERE Id IN (SELECT ContactId  from User where Id=:UserInfo.getUserId())];
            Id accountId = cont.AccountId;

            return [SELECT XC_CustomerId__c, XC_DueDate__c, XC_InvoiceNumber__c, XC_InvoiceDate__c, XC_PackingSlipNumber__c, XC_PaymentTerms__c, XC_BillTo__c, XC_ShipTo__c,
                        XC_PurchaseOrderNumber__c, XC_RequestedShipDate__c, XC_SalesOrderNumber__c, XC_SalespersonId__c, XC_ShippingMethod__c, XC_Status__c, XC_TrackingNumber__c,
                        XC_Total__c, XC_Misc__c, XC_CC225Percent__c, XC_Tax__c, XC_Freight__c, XC_TotalDiscount__c,
                        (SELECT Id, XC_Description__c, XC_ExtPrice__c, XC_Finish__c, XC_Hardware__c, XC_Invoice__c, XC_ItemNumber__c, XC_QuantityBackordered__c, XC_QuantityOrdered__c, XC_QuantityShipped__c, XC_UnitPrice__c FROM InvoiceLineItems__r ORDER BY XC_Description__c)
                            FROM XC_Invoice__c
                            WHERE XC_Account__c = :accountId
                            ORDER BY XC_DueDate__c ASC];
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Ticket No GB-126 (To get the date based on Selected Filtered Date)
    @AuraEnabled(cacheable=true)
    public static List<XC_Invoice__c> getFilteredInvoices(Date startdate, Date enddate)
    {
        try 
        {
            Contact cont = [SELECT AccountId,Id from Contact WHERE Id IN (SELECT ContactId  from User where Id=:UserInfo.getUserId())];
            Id accountId = cont.AccountId;
            
            String dateFormatString = 'yyyy-MM-dd';
            String query = 'Select XC_CustomerId__c, XC_DueDate__c, XC_InvoiceNumber__c, XC_InvoiceDate__c, XC_PackingSlipNumber__c,XC_Payment_Id__c,' ;
                query += 'XC_PaymentTerms__c, XC_BillTo__c, XC_ShipTo__c,XC_PurchaseOrderNumber__c, XC_RequestedShipDate__c, XC_SalesOrderNumber__c, XC_SalespersonId__c,';
                query += 'XC_ShippingMethod__c, XC_Status__c, XC_TrackingNumber__c,XC_Total__c, XC_Misc__c, XC_CC225Percent__c, XC_Tax__c, XC_Freight__c, XC_TotalDiscount__c,';
                query += '(SELECT Id, XC_Description__c, XC_ExtPrice__c, XC_Finish__c, XC_Hardware__c, XC_Invoice__c, XC_ItemNumber__c, XC_QuantityBackordered__c, XC_QuantityOrdered__c, XC_QuantityShipped__c,';
                query += 'XC_UnitPrice__c,XC_Item__c,XC_Item__r.Name FROM InvoiceLineItems__r ORDER BY XC_Description__c)';
                query += 'FROM XC_Invoice__c where XC_Account__c =: accountId';
            if(startdate != null){
                Datetime sdt = Datetime.newInstance(startdate.year(), startdate.month(),startdate.day());
                String sdate = sdt.format(dateFormatString);
                query += ' And XC_DueDate__c >= '+ sdate;
            }
            if(enddate != null){
                Datetime edt = Datetime.newInstance(enddate.year(), enddate.month(),enddate.day());
                String edate = edt.format(dateFormatString);
                query += ' And XC_DueDate__c <= '+ edate;
            }
            // query += ' ORDER BY XC_DueDate__c ASC';
            query += ' ORDER BY XC_DueDate__c DESC';
            system.debug('query :'+query);
            List<XC_Invoice__c> invoiceList = Database.query(query);
            
            return invoiceList;
            
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}