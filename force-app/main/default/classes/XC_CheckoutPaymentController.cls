public with sharing class XC_CheckoutPaymentController 
{
    private static final String PAYMENT_STATE = 'Payment And Billing Address';
    
    @AuraEnabled
    public static Map<String, Object> getPaymentInfo(String cartId) 
    {
        // Get the effectiveAccountId
        String accountId = XC_B2BUtils.getUserAccountID();

        /////////////////////////////////////////////////////////////////////////////////////
        // When debugging within the flow, calls to this controller cannot be impersonated,
        // meaning the buyer won't be used. Therefore, the getUserAccountID() will not return
        // correctly. For debugging purposes, one can temporarily specify the account ID of
        // the buyer under test to get around this limitation. This will impact any user
        // trying to use this method, so this is only suggested on non-production orgs.
        // 
        // Example:
        // String accountId = '001xx000003GZBjAAO';
        /////////////////////////////////////////////////////////////////////////////////////
        
        // Get the 'purchaseOrderNumber' from the WebCart
        WebCart webCart = [SELECT Id, BillingAddress, PoNumber, XC_Order_Type__c FROM WebCart WHERE Id=:cartId
                           WITH SECURITY_ENFORCED];

        Map<String, Object> paymentInfo = new Map<String, Object>();
        paymentInfo.put('purchaseOrderNumber', webCart.PoNumber);
        paymentInfo.put('orderType', webCart.XC_Order_Type__c);

        return paymentInfo;
    }

    
    /**
    * Tokenizes the payment information, returns a paymentMethod that is then saved to the current WebCart.
    * It also updates the WebCart with the selected billing address.
    **/
    @AuraEnabled
    public static void setPayment(String paymentType, String cartId, Map<String, Object> paymentInfo) 
    {
        try 
        {
            String queryFields = 'XC_Order_Type__c,PONumber, PaymentMethodId, WebStoreId, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude, AccountId';

            String soqlQuery = 'SELECT ' + queryFields + ' FROM WebCart WHERE Id=:cartId LIMIT 1';
            WebCart cart = Database.query(soqlQuery);

            CartCheckoutSession ccs = [SELECT Id, OrderId FROM CartCheckoutSession WHERE WebCartId = :cartId AND IsArchived = false LIMIT 1];

            Order curOrder = [SELECT Id,Type, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude, PoNumber FROM Order WHERE Id = :ccs.OrderId LIMIT 1];

            String webStoreId = cart.WebStoreId;

            Account acc = [SELECT Id, ParentId, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude FROM Account WHERE Id = :cart.AccountId LIMIT 1];

            if(acc.ParentId != null)
            {
                acc = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude FROM Account WHERE Id = :acc.ParentId LIMIT 1];
            }

            // Update the billingAddress
            // If it was not set, then set the cart.BillingAddress to empty
            cart.BillingStreet = acc.BillingStreet;
            cart.BillingCity = acc.BillingCity;
            cart.BillingState = acc.BillingState;
            cart.BillingCountry = acc.BillingCountry;
            cart.BillingPostalCode = acc.BillingPostalCode;
            cart.BillingLatitude = acc.BillingLatitude;
            cart.BillingLongitude = acc.BillingLongitude;

            curOrder.BillingStreet = acc.BillingStreet;
            curOrder.BillingCity = acc.BillingCity;
            curOrder.BillingState = acc.BillingState;
            curOrder.BillingCountry = acc.BillingCountry;
            curOrder.BillingPostalCode = acc.BillingPostalCode;
            curOrder.BillingLatitude = acc.BillingLatitude;
            curOrder.BillingLongitude = acc.BillingLongitude;

            curOrder.Type = cart.XC_Order_Type__c;
                        
            // Update the payment information
            if (paymentType == 'PurchaseOrderNumber') 
            {
                cart.PONumber = (String) paymentInfo.get('poNumber');
                cart.paymentMethodId = null;
                
                curOrder.PoNumber = cart.PONumber;
            } 
            else 
            {
                cart.PONumber = null;
                curOrder.PoNumber = cart.PONumber;
            }

           update cart;   
           update curOrder; 
        }
         catch (AuraHandledException e) 
        {
            throw e;
        } 
        catch (DmlException e) 
        {
            throw new AuraHandledException('Unexpected error occurred while updating the cart: ' + e.getMessage());
        } 
        catch (ConnectApi.ConnectApiException e) 
        {
            throw new AuraHandledException('Unexpected error occurred while processing payment: ' + e.getMessage());
        } 
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}