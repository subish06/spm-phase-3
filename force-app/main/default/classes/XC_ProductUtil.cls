public without sharing class XC_ProductUtil {
    public static List<XC_Product_Fieldset_Mapping__mdt> returnProductFieldSets(){
        List<XC_Product_Fieldset_Mapping__mdt> fieldSets = [SELECT MasterLabel,XC_Sort_Order__c FROM XC_Product_Fieldset_Mapping__mdt ORDER BY XC_Sort_Order__c];
        return fieldSets;    
    }

    public static Product2 returnProductFromFieldSets(String productId, String fields){
        String query = 'SELECT ' + fields + ' Id, Name FROM Product2 WHERE Id =: productId';
        Product2 prod = Database.query(query);
        return prod;
    }

    public static String returnFieldsFromFieldSets(List<XC_Product_Fieldset_Mapping__mdt> fieldSets){
        String fields = '';

        for(XC_Product_Fieldset_Mapping__mdt f : fieldSets){
            List<Schema.FieldSetMember> fs = Schema.SObjectType.Product2.fieldSets.getMap().get(f.MasterLabel).getFields();
            for(Schema.FieldSetMember member : fs) {
                fields += member.getFieldPath() + ', ';
            }
        }

        return fields;        
    }

    public static List<ProductAttribute> getProductAttributes(Set<String> parentIds){
        List<ProductAttribute> productAttributes = [SELECT VariantParentId, ProductId FROM ProductAttribute WHERE VariantParentId IN : parentIds ORDER BY VariantParentId];
        return productAttributes;
    }

    public static List<PriceBookEntry> getPriceBookEntries(Set<String> prodIds){
        List<PriceBookEntry> priceBookEntries = [SELECT Id, Pricebook2Id, Pricebook2.IsStandard, Product2Id, UnitPrice, CurrencyIsoCode FROM PriceBookEntry WHERE Product2Id IN : prodIds ORDER BY Product2Id];
        return priceBookEntries;
    }

    public static void assignParentProductsImages(Set<String> parentProdIds){
        List<ProductMedia> parentProdMedias = [SELECT Id, ProductId FROM ProductMedia WHERE ProductId IN : parentProdIds];
        Map<String,Object> childParentMap = new Map<String,Object>();
        for(ProductMedia pm : parentProdMedias){
            if(parentProdIds.contains(pm.ProductId)){
                parentProdIds.remove(pm.ProductId);
            }
        }

        List<ProductAttribute> productAttributes = getProductAttributes(parentProdIds);

        //get child parent map
        for(ProductAttribute pa : productAttributes){
            childParentMap.put(pa.ProductId, pa.VariantParentId);
        }

        List<ProductMedia> childProdMedias = [SELECT Id, ProductId,ElectronicMediaGroupId, ElectronicMediaId FROM ProductMedia WHERE ProductId IN : childParentMap.keySet()];
        Set<String> insertProdMediaKeys = new Set<String>();
        List<ProductMedia> newProductMedias = new List<ProductMedia>();

        for(ProductMedia pm : childProdMedias){
            if(childParentMap.containsKey(pm.ProductId)){
                String parentProdId = (String)childParentMap.get(pm.ProductId);
                String key = parentProdId + pm.ElectronicMediaGroupId;
                if(!insertProdMediaKeys.contains(key)){
                    ProductMedia newPM = new ProductMedia( 
                        ElectronicMediaGroupId = pm.ElectronicMediaGroupId,
                        ElectronicMediaId = pm.ElectronicMediaId,
                        ProductId = parentProdId
                    );

                    newProductMedias.add(newPM);
                    insertProdMediaKeys.add(key);
                }
            }
        }

        if(newProductMedias.size()>0){
            insert newProductMedias;
        }

    }

    public static void handleParentProductsPricing(Set<String> parentProdIds){
        List<ProductAttribute> productAttributes = getProductAttributes(parentProdIds);
        Map<String,Object> parentPriceMap = new Map<String,Object>();
        Map<String,String> childParentMap = new Map<String,String>();
        Map<String,String> existingParentPriceMap = new Map<String,String>();
        List<PriceBookEntry> childPriceBookEntries = new List<PriceBookEntry>();
        Set<String> prodIds = new Set<String>();
        prodIds.addAll(parentProdIds);
        String standardPriceBookId = '';
        
        //get child parent map
        for(ProductAttribute pa : productAttributes){
            childParentMap.put(pa.ProductId, pa.VariantParentId);
            prodIds.add(pa.ProductId);
        }

        childPriceBookEntries = getPriceBookEntries(prodIds);

        for(PriceBookEntry pe : childPriceBookEntries){
            if(pe.Pricebook2.IsStandard && standardPriceBookId == ''){
                standardPriceBookId = pe.Pricebook2Id;
            }
            
            if(parentProdIds.contains(pe.Product2Id)){
                String key = pe.Product2Id + '-' + pe.Pricebook2Id + '-' + pe.CurrencyIsoCode;
                existingParentPriceMap.put(key,pe.Id);
            }else{
                String parentId = (childParentMap.containsKey(pe.Product2Id) ? childParentMap.get(pe.Product2Id) : null);
                Decimal unitPrice = pe.UnitPrice;
                String priceBookId = pe.Pricebook2Id;            
                Map<String,Object> priceMap = new Map<String,Object>();
                
                
                if(parentId != null){
                    String parentKey = parentId + '-' + pe.Pricebook2Id + '-' + pe.CurrencyIsoCode;
                    parentPriceMap.put(parentKey,pe);
                    if(parentPriceMap.containsKey(parentKey)){                       
                        PriceBookEntry pbe = (PriceBookEntry) parentPriceMap.get(parentKey);
                        if(unitPrice > pbe.UnitPrice){
                            parentPriceMap.put(parentKey, pbe);
                        }                              
                    }
                }
            }
            
        }

        List<PriceBookEntry> parentStandardPrices = new List<PriceBookEntry>();
        List<PriceBookEntry> parentNonStandardPrices = new List<PriceBookEntry>();

        for(String key : parentPriceMap.keySet()){            
            PriceBookEntry pbe = (PriceBookEntry) parentPriceMap.get(key);
            PriceBookEntry parentPBE = new PriceBookEntry();
            List<String> keyList = key.split('-');

            parentPBE.UnitPrice = pbe.UnitPrice;
            
            if(existingParentPriceMap.containsKey(key)){
                String existPEId = existingParentPriceMap.get(key);
                parentPBE.Id = existPEId;                
            }else{
                parentPBE.isActive = true;
                parentPBE.Pricebook2Id = pbe.PriceBook2Id;
                parentPBE.Product2Id = keyList[0];
                parentPBE.CurrencyIsoCode = pbe.CurrencyIsoCode;
            }

            if(standardPriceBookId == pbe.PriceBook2Id){
                parentStandardPrices.add(parentPBE);
            }else{
                parentNonStandardPrices.add(parentPBE);
            }
        }

        if(parentStandardPrices.size()>0){
            upsert parentStandardPrices;
        }

        if(parentNonStandardPrices.size()>0){
            upsert parentNonStandardPrices;
        }

    }
   

}