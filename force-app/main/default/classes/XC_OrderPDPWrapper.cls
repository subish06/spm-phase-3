public without sharing class XC_OrderPDPWrapper {
    @AuraEnabled
    public String orderedDate;
    @AuraEnabled
    public String orderNumber;
    @AuraEnabled
    public Decimal filledQuantity;
    @AuraEnabled
    public Decimal unFilledQuantity;
    @AuraEnabled
    public String XC_SalesOrderNumber;
}