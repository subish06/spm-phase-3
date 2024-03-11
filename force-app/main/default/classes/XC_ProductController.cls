public without sharing class XC_ProductController {

    private static final String PRICE_UNAVAILABLE = 'Price Unavailable';
    private static final String PRICEBOOK_NAME = 'NA_DTC';

    @AuraEnabled
    public static Map<String,String> getStandardPrice(String productId){
        Map<String,String> response = new Map<String,String>();
        try {
            List<PricebookEntry> pbe = [
                SELECT Id, UnitPrice, Product2.Description
                FROM PricebookEntry
                WHERE IsActive = TRUE
                AND Product2Id = :productId
                AND Pricebook2.Name = :PRICEBOOK_NAME
                LIMIT 1
            ];
            if(pbe.size() != 0){
                //return String.valueOf(pbe[0].UnitPrice);
                response.put('price', String.valueOf(pbe[0].UnitPrice));
                response.put('description', pbe[0].Product2.Description);
            } else {
                //return PRICE_UNAVAILABLE;
                response.put('price', PRICE_UNAVAILABLE);
                response.put('description', '');
            }
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String triggerCsvJob(){
        try {
            Id userId = UserInfo.getUserId();
            String userEmail = !Test.isRunningTest() ? UserInfo.getUserEmail() : [SELECT Email FROM Contact LIMIT 1].Email;
            Contact cont = Test.isRunningTest() ? [SELECT AccountId,Id,Account.Name FROM Contact LIMIT 1] : [SELECT AccountId,Id,Account.Name FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :userId)];
            Id accountId = cont.AccountId;
            String documentName = cont.Account.Name + '_Catalog_' + String.valueOf(System.Today()) + '.csv';
            String emailSubject = 'Catalog Export - ' + cont.Account.Name;
            Set<String> policyIds = getPolicyIds(cont.AccountId);
            XC_GetEntitledProductsBatch productsBatch = new XC_GetEntitledProductsBatch(policyIds, userEmail, emailSubject, documentName);
            // may need to add email params
            String batchId = Database.executeBatch(productsBatch);
            return 'Apex method fired asyncronously with batch ID: '; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Set<String> getPolicyIds(Id accountId){
        Set<String> buyerGroupIds = new Set<String>();
        Set<String> policyIds = new Set<String>();
        
        for(BuyerGroupMember bgm : [SELECT Id, BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: accountId]){
            buyerGroupIds.add(bgm.BuyerGroupId);
        }

        if(buyerGroupIds.size()>0){

            for(CommerceEntitlementBuyerGroup cbg : [SELECT Id, PolicyId FROM CommerceEntitlementBuyerGroup WHERE BuyerGroupId IN : buyerGroupIds]){
                policyIds.add(cbg.PolicyId);
            }
        }
        return policyIds;
    }

    public static void sendEmail(String csvString, String emailAddress, String emailSubject, String fileName){
        try{
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(csvString);
            String csvName = fileName; 
            csvAttachment.setFileName(csvName); 
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{emailAddress};
            String subject = emailSubject;
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Your catalog is attached as a CSV - Thank you.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            if (r[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + r[0].errors[0].message);
            }
        }
        catch(Exception Ex){
            System.debug('The email failed to send: ' + Ex.getMessage());
        }
    }

    private static void getCommerceEntitlementProducts(Set<String> policyIds, String email, String subject, String docName){
        Map<String, CommerceEntitlementProduct> entitledProductsBySku = new Map<String, CommerceEntitlementProduct>();

        if(policyIds.size()>0){
            for(CommerceEntitlementProduct cItem : [
                SELECT Id, Product.Id, Policy.Name, Product.Name, Product.StockKeepingUnit, Policy.CanViewProduct, Product.Business_Unit__c 
                FROM CommerceEntitlementProduct 
                WHERE PolicyId IN :policyIds
                AND Policy.CanViewProduct = TRUE
                AND Policy.CanViewPrice = TRUE
                AND Product.IsActive = TRUE
                AND Product.StockKeepingUnit != NULL
                AND Product.Name != NULL
                AND Product.Name != 'X' 
                LIMIT 10000
            ]){
                if(!entitledProductsBySku.keySet().contains(cItem.Product.StockKeepingUnit)){
                    entitledProductsBySku.put(cItem.Product.StockKeepingUnit, cItem);
                }
            }
            XC_EntitledProductExportBatch epeb = new XC_EntitledProductExportBatch(entitledProductsBySku, email, subject, docName);
            Database.executeBatch(epeb, 100);
            
        } else {
            throw new NoEntitlementException('User does not have any entitlements.');
        }
    }

    public class NoEntitlementException extends Exception{}
}