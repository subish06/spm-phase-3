public with sharing class XC_StripeUtilities 
{
    private XC_StripeUtilities() {}

    public static Map<String, Object> getPaymentIntent(String payIntentId)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:XC_StripePaymentGateway/v1/payment_intents/' + payIntentId);
        request.setMethod('GET');
        //request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer {!$Credential.Password}');


        //Decimal convertAmount = Decimal.valueOf(cartData.grandTotalAmount);
        // Decimal convertAmount = payAmount * 100;

        // Map<String, String> params = new Map<String, String>();
        // params.put('currency', 'usd');
        // params.put('amount', String.valueOf(convertAmount.intValue()));
        // params.put('capture_method', 'manual');
        // //params.put('confirm', 'true');

        // request.setBody(urlEncodedParams(params));

        HttpResponse response = http.send(request);

        System.debug(response);

        Map<String, Object> resultMap;
        if(response.getStatusCode() == 200)
        {
            resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
        }
        else 
        {
            resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            resultMap.put('XC_statusCode', response.getStatusCode());
            resultMap.put('XC_isError', true);
        }
        return resultMap;
    }

    public static Map<String, Object> createPaymentIntent(Decimal payAmount)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:XC_StripePaymentGateway/v1/payment_intents');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization', 'Bearer {!$Credential.Password}');


        //Decimal convertAmount = Decimal.valueOf(cartData.grandTotalAmount);
        Decimal convertAmount = payAmount * 100;

        Map<String, String> params = new Map<String, String>();
        params.put('currency', 'usd');
        params.put('amount', String.valueOf(convertAmount.intValue()));
        params.put('capture_method', 'manual');
        //params.put('confirm', 'true');

        request.setBody(urlEncodedParams(params));

        HttpResponse response = http.send(request);

        Map<String, Object> resultMap;
        if(response.getStatusCode() == 200)
        {
            resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
        }
        else 
        {
            resultMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            resultMap.put('XC_statusCode', response.getStatusCode());
            resultMap.put('XC_isError', true);
        }
        return resultMap;
    }

    private static String urlEncodedParams(Map<String, String> params) 
    {
        String body = '';
        Boolean first = true;
        for (String key: params.keySet()) 
        {
            if (first) 
            {
                first = false;
            } 
            else 
            {
                body += '&';
            }
            // NOTE: do not encode values to allow PaymentsNamedConnection to replace the secure fields
            // values that need to be encoded should be encoded by this method's caller
            body += urlEncode(key) + '=' + params.get(key);
        }
        return body;
    }
    
    private static String urlEncode(String str) 
    {
        return EncodingUtil.urlEncode(str, 'UTF-8');
    }
}