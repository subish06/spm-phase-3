public without sharing class XC_TestDataFactory {
    /*public static List<Account> createAccounts(Integer num){
        List<Account> accts = new List<Account>();
        for( Integer i = 0; i< num;i++){
            Account acc = new Account (
                Name = 'Test Account' + num,
                BillingCity = 'City',
                BillingStreet = 'Street'
            );
            accts.add(acc);
        }
        insert accts;
        return accts;
    }*/
    public static List<Product2> createProducts(Integer num){
        List<Product2> prods = new List<Product2>();
        for( Integer i = 0; i< num;i++){
            Product2 pr = new Product2 (
                Name = 'Test Product' + num,
                Body_Style__c = 'Short'
            );
            prods.add(pr);
        }
        insert prods;
        return prods;
    }
}