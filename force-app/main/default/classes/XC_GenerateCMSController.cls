public with sharing class XC_GenerateCMSController {
    @AuraEnabled
    public static void createProductImages(){
        Database.executeBatch(new XC_CreateProductMediasBatch(0,200));
        
    }

}