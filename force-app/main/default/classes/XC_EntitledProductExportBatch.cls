public class XC_EntitledProductExportBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public final Map<String, CommerceEntitlementProduct> entitledProductsBySku;
    public final String emailAddress;
    public final String emailSubject;
    public final String fileName;
    private String csvString = 'SKU,Product Name,Business Unit,Price,Attributes\n';
    
    public XC_EntitledProductExportBatch(Map<String, CommerceEntitlementProduct> productMap, String email, String subj, String file){
        entitledProductsBySku = productMap;
        emailAddress = email;
        emailSubject = subj;
        fileName = file;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Product2Id, Product2.StockKeepingUnit, UnitPrice FROM PricebookEntry WHERE Product2.StockKeepingUnit IN :entitledProductsBySku.keySet() AND Pricebook2.Name = 'NA_DTC']);
    }   

    public void execute(Database.BatchableContext info, List<PricebookEntry> pricebookEntries){
        String csvBody = '';
        Map<String, List<ProductAttribute>> attributesBySku = new Map<String, List<ProductAttribute>>();
        Map<String, String> priceBySku = new Map<String, String>();
        
         // get attributes
         if(!Test.isRunningTest()){
            for(ProductAttribute pa : [SELECT Id, Product.StockKeepingUnit, XC_Color__c, XC_Handedness__c, Size__c FROM ProductAttribute WHERE Product.StockKeepingUnit IN :entitledProductsBySku.keySet()]){
                if(attributesBySku.keySet().contains(pa.Product.StockKeepingUnit)){
                    List<ProductAttribute> attrList = attributesBySku.get(pa.Product.StockKeepingUnit);
                    attrList.add(pa);
                    attributesBySku.put(pa.Product.StockKeepingUnit, attrList);
                } else {
                    List<ProductAttribute> newAttrList = new List<ProductAttribute>();
                    newAttrList.add(pa);
                    attributesBySku.put(pa.Product.StockKeepingUnit, newAttrList);                 } 
                } 
            } else {
                    Product2 testProduct = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'tst123'];
                    ProductAttribute testProductAttribute = new ProductAttribute(
                        ProductId = testProduct.Id,
                        CurrencyIsoCode = 'USD',
                        XC_Color__c = 'Ebony', 
                        Sequence = 1,
                        XC_Handedness__c = 'Right-handed', 
                        Size__c = 'Large'
                    );
                    List<ProductAttribute> paList = new List<ProductAttribute>{testProductAttribute};
                    attributesBySku.put('tst123',paList);
                }
    
            // get prices
            // create CSV rows with data we've received 
            for(PricebookEntry pbe : pricebookEntries){
                String csvRow = '';
                CommerceEntitlementProduct prod = entitledProductsBySku.get(pbe.Product2.StockKeepingUnit);
                String price = String.valueOf(pbe.UnitPrice);
                List<ProductAttribute> attrList = attributesBySku.get(pbe.Product2.StockKeepingUnit);
                // put everyting we have so far together
                csvRow = csvRow + prod.Product.StockKeepingUnit + ',' + prod.Product.Name.escapeCsv() + ',' + prod.Product.Business_Unit__c + ',' + (price != null ? price : 'NA') + ',';
                String attributeSection = '';
                if(attrList != null){
                    for(ProductAttribute pa : attrList){
                        // check color
                        if(pa.XC_Color__c != null){
                            attributeSection = attributeSection + '[color:' + pa.XC_Color__c + '] ';
                        }
                        // check size
                        if(pa.Size__c != null){
                            attributeSection = attributeSection + '[size:' + pa.Size__c + '] ';
                        }
                        // check handedness
                        if(pa.XC_Handedness__c != null){
                            attributeSection = attributeSection + '[handedness:' + pa.XC_Handedness__c + '] ';
                        }
                    }
                }
                csvRow = csvRow + attributeSection + '\n';
                csvBody = csvBody + csvRow;
            }
        csvString = csvString + csvBody;
       
    } 

    public void finish(Database.BatchableContext info){    
        
        XC_ProductController.sendEmail(csvString, emailAddress, emailSubject, fileName);
    } 
    
}