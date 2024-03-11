global class XC_AssignParentProductsImages implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Product2 WHERE Type = \'Base\' AND isActive = TRUE';
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM Product2 WHERE Type = \'Base\' AND isActive = TRUE LIMIT 10';
        }           
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Product2> prodList) {       
        Set<String> prodIds = new Set<String>();

        for(Product2 p : prodList){
            prodIds.add(p.Id);
        } 
        
        XC_ProductUtil.assignParentProductsImages(prodIds);
   
    }  
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}