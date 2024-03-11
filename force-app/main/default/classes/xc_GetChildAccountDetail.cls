public without sharing class xc_GetChildAccountDetail {
    
    @AuraEnabled
    public static List<accountDetailsWrapper> getChildAccountAddress(String accId){
        system.debug('Parent Account Id :'+accId);
        List<accountDetailsWrapper> wrapperList = new List<accountDetailsWrapper>();
        if(accId.left(3) == '001'){
            for(Account acc : [Select id,name,BillingStreet,BillingCity,BillingCountry,BillingState,BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry from Account where ParentId =: accId ]){
                system.debug('Child Account Id :'+acc);
                accountDetailsWrapper obj = new accountDetailsWrapper();
                obj.accountName = acc.name;
                obj.billingAddress = acc.BillingStreet + ',' + acc.BillingCity + ',' + acc.BillingState + ',' + acc.BillingPostalCode + ',' + acc.BillingCountry;
                obj.shippingAddress = acc.ShippingStreet + ',' + acc.ShippingCity + ',' + acc.ShippingState + ',' + acc.ShippingPostalCode + ',' + acc.ShippingCountry;
                wrapperList.add(obj);
            }
        }
        system.debug('wrapperList:'+wrapperList);
        return wrapperList;
        
    }
    
    public class accountDetailsWrapper{
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String billingAddress;
        @AuraEnabled
        public String shippingAddress;
    }    
}