public without sharing class XC_CreateProductMediasFromCMS {
    public static Set<String> getExistingProductImageKeys(Set<String> skus){
        String productListGroupId=[SELECT Id from ElectronicMediaGroup where name='Product List Image'].Id;
        List<ProductMedia> productMediaList = [SELECT Id, ElectronicMediaGroupId, ElectronicMediaId,SortOrder,Product.StockKeepingUnit FROM ProductMedia WHERE Product.StockKeepingUnit in : skus ORDER BY Product.StockKeepingUnit];
        Set<String> resultSet = new Set<String>();
        for(ProductMedia pm : productMediaList){
            
            String pmKey = pm.Product.StockKeepingUnit + pm.ElectronicMediaGroupId;
            resultSet.add(pmKey);
        }

        return resultSet;
    }

    public static Map<String,Object> getProductIds(Set<String> skus){
        List<Product2> products = [SELECT Id, StockKeepingUnit FROM Product2 WHERE isActive = true AND StockKeepingUnit in : skus];
        Map<String,Object> productsMap = new Map<String,Object>();

        for(Product2 prod : products){
            productsMap.put(prod.StockKeepingUnit, prod.Id);
        }

        return productsMap;
    }

    /*public static Boolean createProductMedias(Integer pageNo, Integer pageSize) {
        Boolean resultBool = false;
        String communityId = [SELECT Id FROM Network WHERE Name = 'All Axcess'].Id;
        String productListGroupId=[SELECT Id from ElectronicMediaGroup where name='Product List Image'].Id;
        String productDetailGroupId=[SELECT Id from ElectronicMediaGroup where name='Product Detail Images'].Id;       
        
        ConnectApi.ManagedContentVersionCollection collection = ConnectApi.ManagedContent.getAllManagedContent(communityId, pageNo, pageSize,null, 'cms_image');

        Map<String, String> titleWithContentId = new Map<String, String>();
        List<ConnectApi.ManagedContentVersion> items = collection.items;
        if (items.isEmpty()) {
            return false;
        }
        List<ProductMedia> medias = new List<ProductMedia>();
        Set<String> existProdIds = new Set<String>();
        Map<String,Integer> mediaSkuSort = new Map<String,Integer>();
        List<Map<String,Object>> mediaList = new List<Map<String,Object>>();
        Set<String> skus = new Set<String>();
        for (ConnectApi.ManagedContentVersion item : items) { 
            ConnectApi.ManagedContentMediaSourceNodeValue nodeValue = (ConnectApi.ManagedContentMediaSourceNodeValue)item.contentNodes.get('source');
            String itemURL = nodeValue.url;       
            if (String.isNotEmpty(item.title) && item.title.contains('_')) {
                List<String> splittedTitle = item.title.split('_');
                if (splittedTitle.size() > 0) {
                    String tempSku = splittedTitle[0];
                    String type = splittedTitle[1];
                    Map<String,Object> mediaMap = new Map<String,Object>();
                    skus.add(tempSku);
             
                        if(type == 'front'){
                            mediaMap.put('sku', tempSku);
                            mediaMap.put('ElectronicMediaGroupId', productDetailGroupId);
                            mediaMap.put('ElectronicMediaId', item.managedContentId);
                            mediaMap.put('sortOrder', 1);

                            mediaList.add(mediaMap);
                            mediaList.add(new Map<String,Object>{'sku' => tempSku, 'ElectronicMediaGroupId' => productListGroupId, 'ElectronicMediaId' => item.managedContentId, 'sortOrder' => 1});
                           
                            if(!mediaSkuSort.containsKey(tempSku)){
                                mediaSkuSort.put(tempSku, 1);
                            }
                         
                        }else{
                            Integer tempSort = 2;
                            if(mediaSkuSort.containsKey(tempSku)){
                                tempSort = mediaSkuSort.get(tempSku) + 1;                                
                            }

                            mediaMap.put('sku', tempSku);
                            mediaMap.put('ElectronicMediaGroupId', productDetailGroupId);
                            mediaMap.put('ElectronicMediaId', item.managedContentId);
                            mediaMap.put('sortOrder', tempSort);
                            mediaSkuSort.put(tempSku, tempSort);
                            mediaList.add(mediaMap);
                        }
                }
                
            }
        }

        Set<String> existingProdImageKeys = getExistingProductImageKeys(skus);
        Map<String,Object> prodMap = getProductIds(skus);

        for(Map<String,Object> mediaMap : mediaList){
            String sku = (String) mediaMap.get('sku');
            String electronicMediaGroupId = (String) mediaMap.get('ElectronicMediaGroupId');
            String electronicMediaId = (String) mediaMap.get('ElectronicMediaId');
            Integer sortOrder = (Integer) mediaMap.get('sortOrder');
            String mediaKey = sku + electronicMediaGroupId + electronicMediaId;

            if(!existingProdImageKeys.contains(mediaKey)){
                if(prodMap.containsKey(sku)){
                    String prodId = (String) prodMap.get(sku);
                    medias.add(
                        new ProductMedia(
                            ProductId = prodId,
                            ElectronicMediaGroupId = electronicMediaGroupId,
                            ElectronicMediaId = electronicMediaId,                               
                            SortOrder = sortOrder
                        )
                    );

                }
            }
        }

        if(medias.size()>0){ 
            Database.SaveResult[] SR =  Database.insert(medias,false);
            for(Integer i=0; i<SR.size(); i++){
                String sourceId = (String)medias[i].get('ProductId');					
                if(!SR[i].isSuccess()){
                    system.debug('failedId: ' + SR[i] + ' ' + sourceId);
                }
            }        
            if (collection.nextPageUrl != null) {
                resultBool = true;
            }
        } 

        return resultBool;
    }*/

     public static Boolean createProductMedias(Integer pageNo, Integer pageSize) {
         system.debug('pageno: ' + pageNo + ' pageSize: ' + pageSize);
        Boolean resultBool = false;
        String communityId = [SELECT Id FROM Network WHERE Name = 'All Axcess'].Id;
        String productListGroupId=[SELECT Id from ElectronicMediaGroup where name='Product List Image'].Id;
        String productDetailGroupId=[SELECT Id from ElectronicMediaGroup where name='Product Detail Images'].Id;       
        
        ConnectApi.ManagedContentVersionCollection collection = ConnectApi.ManagedContent.getAllManagedContent(communityId, pageNo, pageSize,null, 'cms_image');

        Map<String, String> titleWithContentId = new Map<String, String>();
        List<ConnectApi.ManagedContentVersion> items = collection.items;
        system.debug('collection: ' + collection.nextPageUrl);
        system.debug('item size: ' + items.size());
        if (items.isEmpty()) {
            return false;
        }
        List<ProductMedia> medias = new List<ProductMedia>();
        Set<String> existProdIds = new Set<String>();
        List<Map<String,Object>> mediaList = new List<Map<String,Object>>();
        Set<String> skus = new Set<String>();
        
        for (ConnectApi.ManagedContentVersion item : items) { 
            ConnectApi.ManagedContentMediaSourceNodeValue nodeValue = (ConnectApi.ManagedContentMediaSourceNodeValue)item.contentNodes.get('source');
            String itemURL = nodeValue.url;       
            if (String.isNotEmpty(item.title)) {
                
                String tempSku = item.title;
                Map<String,Object> mediaMap = new Map<String,Object>();
                skus.add(tempSku);             
                    
                mediaMap.put('sku', tempSku);
                mediaMap.put('ElectronicMediaGroupId', productDetailGroupId);
                mediaMap.put('ElectronicMediaId', item.managedContentId);
                mediaMap.put('sortOrder', 1);

                mediaList.add(mediaMap);
                mediaList.add(new Map<String,Object>{'sku' => tempSku, 'ElectronicMediaGroupId' => productListGroupId, 'ElectronicMediaId' => item.managedContentId, 'sortOrder' => 1});
                  
            }
        }

        Set<String> existingProdImageKeys = getExistingProductImageKeys(skus);
        Map<String,Object> prodMap = getProductIds(skus);
        system.debug('existimages count: ' + existingProdImageKeys.size());
        system.debug('prodMap count: '  + prodMap.size());
        for(Map<String,Object> mediaMap : mediaList){
            String sku = (String) mediaMap.get('sku');
            String electronicMediaGroupId = (String) mediaMap.get('ElectronicMediaGroupId');
            String electronicMediaId = (String) mediaMap.get('ElectronicMediaId');
            Integer sortOrder = (Integer) mediaMap.get('sortOrder');
            String mediaKey = sku + electronicMediaGroupId;
            String plpKey = sku + productListGroupId;

            if(!existingProdImageKeys.contains(mediaKey) && !existingProdImageKeys.contains(plpKey)){
                if(prodMap.containsKey(sku)){
                    String prodId = (String) prodMap.get(sku);
                    system.debug('prodname: ' + sku);
                    system.debug('mediaKey: ' + mediaKey);
                    if(productListGroupId == electronicMediaGroupId){
                        existingProdImageKeys.add(plpKey);
                    }else{
                        existingProdImageKeys.add(mediaKey);
                    }
                    
                    medias.add(
                        new ProductMedia(
                            ProductId = prodId,
                            ElectronicMediaGroupId = electronicMediaGroupId,
                            ElectronicMediaId = electronicMediaId,                               
                            SortOrder = sortOrder
                        )
                    );

                }
            }
        }
    
        if(medias.size()>0){ 
            Database.SaveResult[] SR =  Database.insert(medias,false);
            for(Integer i=0; i<SR.size(); i++){
                String sourceId = (String)medias[i].get('ProductId');					
                if(!SR[i].isSuccess()){
                    system.debug('failedId: ' + SR[i] + ' ' + sourceId);
                }
            }        
            
        } 

        if (collection.nextPageUrl != null) {
                resultBool = true;
        }

        return resultBool;
    }

}