global class XC_CreateProductMediasBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Integer pageNo;
    private Integer pageSize;
    private Boolean nextPageURL;

    public XC_CreateProductMediasBatch(Integer pgNo, Integer pgSize) {
        pageNo = pgNo;
        pageSize = pgSize;
        nextPageURL = false;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Product2 LIMIT 100';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product2> scope) {
        nextPageURL = XC_CreateProductMediasFromCMS.createProductMedias(pageNo, pageSize);
    }   

    global void finish(Database.BatchableContext BC) {
        if(nextPageURL){
            Database.executeBatch(new XC_CreateProductMediasBatch(pageNo+1,pageSize));
        }
    }
}