public with sharing class XC_StripePaymentLWCController 
{
    public XC_StripePaymentLWCController() {}

    @AuraEnabled
    public static Boolean verifyCartData(String communityId, String cartId)
    {
        try 
        {
            cartId = (Id)cartId;
            //String webstoreId = XC_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

            ConnectApi.CartSummary curSumm = XC_B2BGetInfo.getCartSummary(communityId, null, cartId);//ConnectApi.CommerceCart.getCartSummary(webstoreId, null, cartId);
            

            // Boolean returnBool = curSumm.status == ConnectApi.CartStatus.CHECKOUT ? true : false;

            // return returnBool;

            return curSumm.status == ConnectApi.CartStatus.CHECKOUT ? true : false;
        } 
        catch (Exception e) 
        {
            return false;
        }
        
    }

    @AuraEnabled
    public static Boolean verifyInvoiceData(String invoiceId)
    {
        try 
        {
            XC_Invoice__c curInvoice = [SELECT Id FROM XC_Invoice__c WHERE Id = :invoiceId AND XC_Status__c = 'Unpaid' LIMIT 1];

            if(curInvoice != null)
            {
                return true;
            }
            else 
            {
                return false;
            }
        } 
        catch (Exception e) 
        {
            return false;
        }
    }

    // @AuraEnabled
    // public static Map<String, Object> handleCartPayment(String communityId, String cartId, String payIntentId)
    // {
    //     //cartId = (Id)cartId;
    //     String webstoreId = XC_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    //     Map<String, Object> resultMap = XC_StripeUtilities.getPaymentIntent(payIntentId); 

    //     ConnectApi.CartSummary curCartSummary = ConnectApi.CommerceCart.getCartSummary(webstoreId, null, cartId);

    //     WebCart curCart = [SELECT Id, PaymentMethodId, AccountId FROM WebCart WHERE Id = :cartId LIMIT 1];
    //     CartCheckoutSession curSession = [SELECT Id, OrderId FROM CartCheckoutSession WHERE WebCartId = :cartId AND isArchived = false LIMIT 1];
    //     Order curOrder = [SELECT Id FROM Order WHERE Id = :curSession.OrderId LIMIT 1];

    //     String tempAmount = String.valueOf((Integer)resultMap.get('amount_capturable'));
    //     tempAmount = tempAmount.substring(0, tempAmount.length() - 2) + '.' + tempAmount.substring(tempAmount.length() - 2, tempAmount.length());
    //     Decimal authAmount = Decimal.valueOf(tempAmount);
        
    //     if(authAmount == Decimal.valueOf(curCartSummary.grandTotalAmount))
    //     {
    //         Map<String, Object> chargeMap = (Map<String, Object>)resultMap.get('charges');
    //         List<Object> cardList = (List<Object>)chargeMap.get('data');
    //         Map<String, Object> cardMap = (Map<String, Object>)cardList[0];

    //         Map<String, Object> billingDetailsMap = (Map<String, Object>)cardMap.get('billing_details');

    //         Map<String, Object> paymentMethodDetailsMap = (Map<String, Object>)cardMap.get('payment_method_details');
    //         Map<String, Object> cardDetailsMap = (Map<String, Object>)paymentMethodDetailsMap.get('card');

    //         CardPaymentMethod myCard = new CardPaymentMethod();
            
    //         if((String)cardDetailsMap.get('funding') == 'credit')
    //         {
    //             myCard.CardCategory = ConnectApi.CardCategory.CreditCard.name();//'Credit Card';
    //         }
    //         else
    //         {
    //             myCard.CardCategory = ConnectApi.CardCategory.DebitCard.name();//'Debit Card';
    //         }
            
    //         myCard.CardHolderName = (String)billingDetailsMap.get('name');
    //         myCard.CardLastFour = Integer.valueOf((String)cardDetailsMap.get('last4'));
            
    //         String brand = (String)cardDetailsMap.get('brand');
    //         if(brand == 'visa')
    //         {
    //             myCard.CardType = 'Visa';//ConnectApi.CardType.Visa.name();
    //         }
    //         else if(brand == 'master')
    //         {
    //             myCard.CardType = 'Master Card';//ConnectApi.CardType.MasterCard.name();
    //         }
    //         else if(brand == 'amex')
    //         {
    //             myCard.CardType = 'American Express';//ConnectApi.CardType.AmericanExpress.name();
    //         }
    //         else if(brand == 'discover')
    //         {
    //             myCard.CardType = 'Discover';
    //         }
    //         myCard.ExpiryMonth = (Integer)cardDetailsMap.get('exp_month');
    //         myCard.ExpiryYear = (Integer)cardDetailsMap.get('exp_year');
    //         myCard.InputCardNumber = '#############' + (String)cardDetailsMap.get('last4');
    //         myCard.ProcessingMode = 'External';
    //         myCard.Status = 'Active';

    //         insert myCard;
    //         curCart.PaymentMethodId = myCard.Id;
    //         update curCart;

    //         PaymentGroup newGroup = new PaymentGroup();
    //         newGroup.SourceObjectId = curOrder.Id;
    //         //newGroup.CurrencyIsoCode = curOrder.CurrencyIsoCode;
    //         insert newGroup;

    //         PaymentAuthorization newAuth = new PaymentAuthorization();
    //         newAuth.Amount = authAmount;//curOrder.TotalAmount;
    //         //newAuth.Balance = newAuth.Amount;
    //         //newAuth.AccountId = curCart.AccountId;
    //         newAuth.GatewayRefDetails = 'Stripe';
    //         //newAuth.CurrencyIsoCode = curOrder.CurrencyIsoCode;
    //         newAuth.GatewayAuthCode = payIntentId;
    //         //newAuth.GatewayRefNumber = payIntentId
    //         newAuth.PaymentGroupId = newGroup.Id;
    //         newAuth.PaymentMethodId = curCart.PaymentMethodId;
    //         newAuth.ProcessingMode = 'External';
    //         newAuth.Status = 'Processed';

    //         insert newAuth;
    //     }

    //     // Payment newPayment = new Payment();
    //     // //newPayment.XC_Cart__c = (Id)curCartSummary.cartId;
    //     // newPayment.Amount = currAmount;
    //     // newPayment.AccountId = (Id)curCartSummary.accountId;
    //     // //newPayment.XC_StripePaymentIntentId__c = payIntentId;
    //     // newPayment.ProcessingMode = 'External';
    //     // newPayment.Status = 'Processed';
    //     // newPayment.Type = 'Sale';

    //     // insert newPayment;

    //     // Map<String,Object> returnMap = new Map<String, Object>();
    //     // returnMap.put('success', true);
    //     // returnMap.put('payId', newPayment.Id);

    //     // return returnMap;

    //     // //----------------------------------------------------------------------

    //     // CardPaymentMethod myCard = new CardPaymentMethod();
    //     // myCard.CardCategory = ConnectApi.CardCategory.CreditCard.name();//'CreditCard';
    //     // myCard.CardHolderName = (String)dataMap.get('Holder');
    //     // myCard.CardLastFour = Integer.valueOf((String)dataMap.get('Last4'));
        
    //     // String brand = (String)dataMap.get('Brand');
    //     // if(brand == 'visa')
    //     // {
    //     //     myCard.CardType = 'Visa';//ConnectApi.CardType.Visa.name();
    //     // }
    //     // else if(brand == 'master')
    //     // {
    //     //     myCard.CardType = 'Master Card';//ConnectApi.CardType.MasterCard.name();
    //     // }
    //     // else if(brand == 'amex')
    //     // {
    //     //     myCard.CardType = 'American Express';//ConnectApi.CardType.AmericanExpress.name();
    //     // }
    //     // //myCard.CardTypeCategory = 'Visa';
    //     // myCard.ExpiryMonth = Integer.valueOf((String)dataMap.get('expiryMonth'));
    //     // myCard.ExpiryYear = Integer.valueOf((String)dataMap.get('expiryYear'));
    //     // //myCard.GatewayToken = 'tst124';
    //     // myCard.InputCardNumber = '#############' + (String)dataMap.get('Last4');
    //     // myCard.ProcessingMode = 'External';
    //     // myCard.Status = 'Active';

    //     // insert myCard;
    //     // curCart.PaymentMethodId = myCard.Id;
    //     // update curCart;

    //     // PaymentGroup newGroup = new PaymentGroup();
    //     // newGroup.SourceObjectId = curOrder.Id;
    //     // newGroup.CurrencyIsoCode = curOrder.CurrencyIsoCode;
    //     // insert newGroup;

    //     // PaymentAuthorization newAuth = new PaymentAuthorization();
    //     // newAuth.Amount = curCart.GrandTotalAmount;//curOrder.TotalAmount;
    //     // //newAuth.Balance = newAuth.Amount;
    //     // newAuth.AccountId = curCart.AccountId;
    //     // newAuth.GatewayRefDetails = 'Chase - EMEA';
    //     // newAuth.CurrencyIsoCode = curOrder.CurrencyIsoCode;
    //     // newAuth.GatewayAuthCode = (String)dataMap.get('ConnectorTxID2');
    //     // newAuth.GatewayRefNumber = (String)dataMap.get('ConnectorTxID1');
    //     // newAuth.PaymentGroupId = newGroup.Id;
    //     // newAuth.PaymentMethodId = curCart.PaymentMethodId;
    //     // newAuth.ProcessingMode = 'External';
    //     // newAuth.Status = 'Processed';

    //     // insert newAuth;

    //     return null;
    // }

    @AuraEnabled
    public static Map<String, Object> handlePayment(String communityId, String cartId, String invoiceId, String payIntentId)
    {
        Map<String, Object> returnMap = new Map<String, Object>();
        try 
        {
            Map<String, Object> resultMap = XC_StripeUtilities.getPaymentIntent(payIntentId);

            Decimal compareAmount;
            WebCart curCart;
            CartCheckoutSession curSession;
            Order curOrder;
            XC_Invoice__c curInvoice;

            if(cartId != null)
            {
                //String webstoreId = XC_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

                ConnectApi.CartSummary curCartSummary = XC_B2BGetInfo.getCartSummary(communityId, null, cartId);

                curCart = [SELECT Id, PaymentMethodId, AccountId FROM WebCart WHERE Id = :cartId LIMIT 1];
                curSession = [SELECT Id, OrderId FROM CartCheckoutSession WHERE WebCartId = :cartId AND isArchived = false LIMIT 1];
                curOrder = [SELECT Id FROM Order WHERE Id = :curSession.OrderId LIMIT 1];

                compareAmount = Decimal.valueOf(curCartSummary.grandTotalAmount);
            }
            else if(invoiceId != null)
            {
                curInvoice = [SELECT Id, XC_Status__c, XC_Payment_Id__c FROM XC_Invoice__c WHERE Id = :invoiceId AND XC_Status__c = 'Unpaid' LIMIT 1];
                //curInvoice = [SELECT Id, XC_OrderSummary__r.GrandTotalAmount, XC_Status__c FROM XC_Invoice__c WHERE Id = :invoiceId AND XC_Status__c = 'Unpaid' LIMIT 1];
                //compareAmount = curInvoice.XC_OrderSummary__r.GrandTotalAmount;
            }

            String tempAmount = String.valueOf((Integer)resultMap.get('amount_capturable'));
            tempAmount = tempAmount.substring(0, tempAmount.length() - 2) + '.' + tempAmount.substring(tempAmount.length() - 2, tempAmount.length());
            Decimal authAmount = Decimal.valueOf(tempAmount);
            
            System.debug(authAmount);
            System.debug(compareAmount);
            if(authAmount == compareAmount || invoiceId != null)
            {
                Map<String, Object> chargeMap = (Map<String, Object>)resultMap.get('charges');
                List<Object> cardList = (List<Object>)chargeMap.get('data');
                Map<String, Object> cardMap = (Map<String, Object>)cardList[0];

                Map<String, Object> billingDetailsMap = (Map<String, Object>)cardMap.get('billing_details');

                Map<String, Object> paymentMethodDetailsMap = (Map<String, Object>)cardMap.get('payment_method_details');
                Map<String, Object> cardDetailsMap = (Map<String, Object>)paymentMethodDetailsMap.get('card');

                CardPaymentMethod myCard = new CardPaymentMethod();
                
                if((String)cardDetailsMap.get('funding') == 'credit')
                {
                    myCard.CardCategory = ConnectApi.CardCategory.CreditCard.name();//'Credit Card';
                }
                else
                {
                    myCard.CardCategory = ConnectApi.CardCategory.DebitCard.name();//'Debit Card';
                }
                
                myCard.CardHolderName = (String)billingDetailsMap.get('name');
                myCard.CardLastFour = Integer.valueOf((String)cardDetailsMap.get('last4'));
                
                String brand = (String)cardDetailsMap.get('brand');
                if(brand == 'visa')
                {
                    myCard.CardType = 'Visa';//ConnectApi.CardType.Visa.name();
                }
                else if(brand == 'master')
                {
                    myCard.CardType = 'Master Card';//ConnectApi.CardType.MasterCard.name();
                }
                else if(brand == 'amex')
                {
                    myCard.CardType = 'American Express';//ConnectApi.CardType.AmericanExpress.name();
                }
                else if(brand == 'discover')
                {
                    myCard.CardType = 'Discover';
                }
                myCard.ExpiryMonth = (Integer)cardDetailsMap.get('exp_month');
                myCard.ExpiryYear = (Integer)cardDetailsMap.get('exp_year');
                myCard.InputCardNumber = '#############' + (String)cardDetailsMap.get('last4');
                myCard.ProcessingMode = 'External';
                myCard.Status = 'Active';

                insert myCard;

                PaymentGroup newGroup;

                if(cartId != null)
                {
                    curCart.PaymentMethodId = myCard.Id;
                    update curCart;  
                    
                    newGroup = new PaymentGroup();
                    newGroup.SourceObjectId = curOrder.Id;
                    //newGroup.CurrencyIsoCode = curOrder.CurrencyIsoCode;
                    insert newGroup;
                }

                PaymentAuthorization newAuth = new PaymentAuthorization();
                newAuth.Amount = authAmount;//curOrder.TotalAmount;
                //newAuth.Balance = newAuth.Amount;
                //newAuth.AccountId = curCart.AccountId;
                newAuth.GatewayRefDetails = 'Stripe';
                //newAuth.CurrencyIsoCode = curOrder.CurrencyIsoCode;
                newAuth.GatewayAuthCode = payIntentId;
                //newAuth.GatewayRefNumber = payIntentId
                
                newAuth.PaymentMethodId = myCard.Id;
                newAuth.ProcessingMode = 'External';
                newAuth.Status = 'Processed';
                
                if(cartId != null)
                {
                    newAuth.PaymentGroupId = newGroup.Id;
                }
                else if(invoiceId != null)
                {
                    newAuth.XC_Invoice__c = invoiceId;
                    curInvoice.XC_Payment_Id__c = payIntentId;
                    //curInvoice.XC_Status__c = 'Paid';
                    update curInvoice;
                }

                insert newAuth;
            }

            returnMap.put('success', true);

            return returnMap;
        } 
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            returnMap.put('success', false);
            return returnMap;
        }
        
    }
}