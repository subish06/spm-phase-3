public without sharing class XC_InvoiceLineItemTriggerHandler {
    
    public static void populateProductRelationship(List<XC_InvoiceLineItem__c> triggerNew){
        Set<String> itemNumber = new Set<String>();
        Map<String,String> productVsProductId = new Map<String,String>();
        for(XC_InvoiceLineItem__c inv : triggerNew){
            if(!String.isBlank(inv.XC_ItemNumber__c)){
                itemNumber.add(inv.XC_ItemNumber__c);
            }
        }
        
        for(product2 prod : [Select id,ProductCode,StockKeepingUnit from product2 where StockKeepingUnit IN : itemNumber AND StockKeepingUnit != null ]){
            productVsProductId.put(prod.StockKeepingUnit,prod.Id);
        }
        
        for(XC_InvoiceLineItem__c inv : triggerNew){
            if(productVsProductId.containsKey(inv.XC_ItemNumber__c)){
                inv.XC_Item__c = productVsProductId.get(inv.XC_ItemNumber__c);
            }
        }
    }

}