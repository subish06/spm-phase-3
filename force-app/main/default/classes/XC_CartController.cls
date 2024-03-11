global class XC_CartController {
    @AuraEnabled
    public static Map<String, Object> uploadCartFromCsv(String csvInput, String communityId, String cartId) {
        Map<String, Object> response = new Map<String, Object>();
        List<String> inputAsTable = new List<String>();
        // remove charge return
        try{
            String cleanedInput = csvInput.contains('\r') ? csvInput.replace('\r', '') : csvInput;
            inputAsTable = cleanedInput.split('\n');
        } catch (Exception e){
            throw new TooManyRowsException('Table has too many rows; can only add up to 500 items per cart.');
        }
        List<String> tableHeader;
        String webstoreId = Test.isRunningTest() ? [SELECT Id FROM WebStore WHERE Name = :XC_B2BTestDataFactory.TEST_STOREFRONT_NAME].Id : XC_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        Integer skuIndex;
        Integer quantityIndex;
        Integer headerSize;
        try{
            tableHeader = inputAsTable.remove(0).split(',');
            headerSize = tableHeader.size();
            skuIndex = tableHeader.indexOf('SKU');
            quantityIndex = tableHeader.indexOf('Quantity');
        } catch (ListException e){
            System.debug(e.getMessage());
            System.debug('Input csv does not have header');
        }
        Map<String, Integer> quantitiesBySku = new Map<String, Integer>();
        WebCart wc = [SELECT Id, AccountId FROM WebCart WHERE Id = :cartId];
        String accountId = wc.AccountId;
        // add or update quantities 
        for(String row : inputAsTable){
            List<String> orderItemData = row.split(',');
            String sku = orderItemData[skuIndex]; 
            // make sure there is a quantity present
            Integer quantity;
            if(orderItemData.size() == headerSize){
                quantity = Integer.valueOf(orderItemData[quantityIndex]);
            }
            // if we gave quantity a value above, then add that sku to the collection
            if(quantity != null){
                if(quantitiesBySku.get(sku) != null){
                    Integer startingQuantity = quantitiesBySku.get(sku);
                    Integer newQuantity = startingQuantity + quantity;
                    quantitiesBySku.put(sku, newQuantity);
                } else {
                    quantitiesBySku.put(sku, quantity);
                }
            }
        }
        Boolean isValid = inputAsTable.size() > 0 ? validateInput(new List<String>(quantitiesBySku.keyset())) : false;
        List<Product2> products;
        if(isValid){
            products = [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :quantitiesBySku.keySet()];
        }
        Map<String, String> skusById = new Map<String, String>();
        List<ConnectApi.BatchInput> batchItemInputList = new List<ConnectApi.BatchInput>();
        if(products.size() != 0){
            for(Product2 product : products){
                skusById.put(String.valueOf(product.Id).substring(0,15), product.StockKeepingUnit);
                ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
                cartItemInput.quantity = String.valueOf(quantitiesBySku.get(product.StockKeepingUnit));
                cartItemInput.productId = product.Id;
                cartItemInput.type =  ConnectApi.CartItemType.PRODUCT;
                ConnectApi.BatchInput batchItemInput = new ConnectApi.BatchInput(cartItemInput);
                batchItemInputList.add(batchItemInput);
            }
        }
        List<ConnectApi.BatchResult> batchResult;
        if(!Test.isRunningTest()){
            batchResult = ConnectApi.CommerceCart.addItemsToCart(webstoreId,accountId,wc.Id,batchItemInputList);
        } else {
            batchResult = new List<ConnectApi.BatchResult>();
        }
        response.put('results', batchResult);
        List<Object> items = new List<Object>();
        List<String> errors =  new List<String>();
        for(ConnectApi.BatchResult item : batchResult){
            if (item.isSuccess()) {
                System.debug('SUCCESS');
                System.debug(item.getResult());
                items.add(item.getResult());
            } else {
                // Operation failed. Print errors.
                System.debug('FAILURE');

                //find ID in error message and replace it with SKU
                List<String> deconstructedErrorMessage = item.getErrorMessage().split(' ');
                String productId = deconstructedErrorMessage[deconstructedErrorMessage.size() - 1].replace('.','');
                deconstructedErrorMessage[deconstructedErrorMessage.size() - 1] = skusById.get(productId);
                String errorMessage = String.join(deconstructedErrorMessage, ' ');
                errors.add(item.getErrorMessage());
                items.add(item);
            }
        }
        response.put('items', items);
        response.put('errors', errors);
        return response;

    }

    private static Boolean validateInput(List<String> input){
        Boolean isValid = (input.size() < 500);
        if(isValid){
            return isValid;
        } else {
            throw new TooManyRowsException('Table has too many rows; can only add up to 500 items per cart.');
        }
    }

    public class TooManyRowsException extends Exception{}
}