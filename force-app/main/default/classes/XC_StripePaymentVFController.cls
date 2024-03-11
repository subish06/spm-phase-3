public with sharing class XC_StripePaymentVFController 
{
    public XC_StripePaymentVFController() 
    {
        Map<String, String> urlParams = Apexpages.currentPage().getParameters();
        //this.cartId = (Id)Apexpages.currentPage().getParameters().get('cartId');
        this.commId = Apexpages.currentPage().getParameters().get('commId');

        this.cartId = urlParams.containsKey('cartId') ? urlParams.get('cartId') : null;
        this.invoiceId = urlParams.containsKey('invoiceId') ? urlParams.get('invoiceId') : null;

        setInitData(this.commId, this.cartId);
    }

    //private ConnectApi.CartSummary cartData;
    //private XC_Invoice__c InvoiceData;
    public String payIntent {get; set;}
    public String publicKey {get; set;}
    public String temp {get; set;}
    public Decimal totalFee {get; set;}
    public String isError {get; set;}
    private Id cartId;
    private Id invoiceId;
    private Id commId;
    private String errorMessage;
    private Integer statusCode;

    

    public void setInitData(String communityId, String cartId)
    {
        Decimal payAmount;
        if(Test.isRunningTest())
        {
            // ConnectApi.CartSummary cartSum = new ConnectApi.CartSummary();
            // cartSum.grandTotalAmount = '200.00';
            //this.cartData = cartSum;
            payAmount = 200.00;
        }
        else 
        {
            if(this.cartId != null)
            {
                String webstoreId = XC_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                //this.cartData = ConnectApi.CommerceCart.getCartSummary(webstoreId, null, cartId);
                ConnectApi.CartSummary cartData = ConnectApi.CommerceCart.getCartSummary(webstoreId, null, cartId);
                payAmount = Decimal.valueOf(cartData.grandTotalAmount);
            }
            else if(this.invoiceId != null)
            {
                XC_Invoice__c curInvoice = [SELECT Id, XC_Total__c, XC_Status__c FROM XC_Invoice__c WHERE Id = :invoiceId AND XC_Status__c = 'Unpaid' LIMIT 1];
                payAmount = curInvoice.XC_Total__c;
                //XC_Invoice__c curInvoice = [SELECT Id, XC_Total__c, XC_OrderSummary__r.GrandTotalAmount, XC_Status__c FROM XC_Invoice__c WHERE Id = :invoiceId AND XC_Status__c = 'Unpaid' LIMIT 1];
                //payAmount = curInvoice.XC_OrderSummary__r.GrandTotalAmount;
            }
        }
        
        createPaymentIntent(payAmount);
        this.publicKey = Label.XC_StripePublicKey;
    }

    public void checkError()
    {
        if(this.isError == 'true')
        {
            XC_ErrorLog__c newError = new XC_ErrorLog__c();
            newError.XC_Cart__c = this.cartId;
            newError.XC_Invoice__c = this.invoiceId;
            newError.XC_StatusCode__c = String.valueOf(this.statusCode);
            newError.XC_ResponseBody__c = this.errorMessage;

            insert newError;
        }
        
    }

    private void createPaymentIntent(Decimal payAmount)
    {
        Map<String, Object> resultMap = XC_StripeUtilities.createPaymentIntent(payAmount);

        if(resultMap.containsKey('XC_isError'))
        {
            this.statusCode = (Integer)resultMap.get('XC_statusCode');
            resultMap.remove('XC_statusCode');
            resultMap.remove('XC_isError');
            this.errorMessage = JSON.serialize(resultMap);
            this.isError = 'true';
            //return '';
            this.payIntent = '';
            this.totalFee = 0.00;
        }
        else 
        {
            this.isError = '';
            //return (String)resultMap.get('client_secret');
            this.payIntent = (String)resultMap.get('client_secret');
            this.temp = (String)resultMap.get('id');
            String tempAmount = String.valueOf((Integer)resultMap.get('amount'));
            String convertAmount = tempAmount.substring(0, tempAmount.length() - 2) + '.' + tempAmount.substring(tempAmount.length() - 2);
            Decimal currAmount = Decimal.valueOf(convertAmount);

            this.totalFee = currAmount;
        }
        
    }
}