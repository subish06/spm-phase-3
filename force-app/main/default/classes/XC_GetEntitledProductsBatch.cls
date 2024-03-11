public class XC_GetEntitledProductsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public final Set<String> policyIds;
    public final String emailAddress;
    public final String emailSubject;
    public final String fileName;
    private Map<String, CommerceEntitlementProduct> entitledProductsBySku = new Map<String, CommerceEntitlementProduct>();
    
    public XC_GetEntitledProductsBatch(Set<String> ids, String email, String subj, String file){
        policyIds = ids;
        emailAddress = email;
        emailSubject = subj;
        fileName = file;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
                SELECT Id, Product.Id, Policy.Name, Product.Name, Product.StockKeepingUnit, Policy.CanViewProduct, Product.Business_Unit__c 
                FROM CommerceEntitlementProduct 
                WHERE PolicyId IN :policyIds
                AND Policy.CanViewProduct = TRUE
                AND Policy.CanViewPrice = TRUE
                AND Product.IsActive = TRUE
                AND Product.StockKeepingUnit != NULL
                AND Product.Name != NULL
                AND Product.Name != 'X' 
            ]);
    }   

    public void execute(Database.BatchableContext info, List<CommerceEntitlementProduct> products){
        for(CommerceEntitlementProduct cep : products){
            entitledProductsBySku.put(cep.Product.StockKeepingUnit, cep);
        }
       
    } 

    public void finish(Database.BatchableContext info){    
        XC_EntitledProductExportBatch exportBatch = new XC_EntitledProductExportBatch(entitledProductsBySku, emailAddress, emailSubject, fileName);
        Database.executeBatch(exportBatch, 50);
        
    } 
}