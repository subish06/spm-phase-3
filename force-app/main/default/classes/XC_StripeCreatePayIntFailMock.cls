global with sharing class XC_StripeCreatePayIntFailMock implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"client_secret":"testSecret"}');
        res.setStatusCode(400);
        return res;
    }
}