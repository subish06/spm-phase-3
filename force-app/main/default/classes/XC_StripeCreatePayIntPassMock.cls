global with sharing class XC_StripeCreatePayIntPassMock implements HttpCalloutMock
{
    public final static String TEST_CLIENT_SECRET = 'pi_123SecretTestClass';
    public static Decimal captureAmount = 200000;
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"client_secret":"'+ TEST_CLIENT_SECRET +'", "amount":2000, "amount_capturable":' + captureAmount + ',"charges":{"data":[ {"billing_details": {"name": null}, "payment_method_details": {"card": {"brand": "visa","checks": {"address_line1_check": null,"address_postal_code_check": null,"cvc_check": null},"country": "US","exp_month": 5,"exp_year": 2020,"fingerprint": "Xt5EWLLDS7FJjR1c","funding": "credit","installments": null,"last4": "4242","network": "visa","three_d_secure": null,"wallet": null},"type": "card"}} ]}}');
        res.setStatusCode(200);
        return res;
    }
}