public without sharing class XC_OrderProductWrapper {
    // @AuraEnabled
    // public DateTime orderedDate;
    @AuraEnabled
    public String orderedDate;
    @AuraEnabled
    public String orderNumber;
    @AuraEnabled
    public String poNumber;
    @AuraEnabled
    public String shippingAddress;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Decimal totalAmount;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String sku;
    @AuraEnabled
    public String businessUnit;
    @AuraEnabled
    public String attributes;
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Decimal quantity;
    @AuraEnabled
    public String productCode;
    @AuraEnabled
    public Date estimatedShipDate; 
    @AuraEnabled
    public Date requestedShipDate;
}