public without sharing class XC_CheckoutDeliveryMethod 
{
    public static final String PLACEHOLDER_ORDER_DELIV_METHOD_NAME = 'Shipping Estimate';

    @InvocableMethod(label='Populate Freight Info' description='Populates all of the shipping/freight info for the cart' category='B2B Commerce')
    public static List<Id> populateShipping(List<Id> cartIds) 
    {
        Id cartId = cartIds[0];

        CartDeliveryGroup cdg = [SELECT Id, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry, DeliveryMethodId 
                                        FROM CartDeliveryGroup 
                                        WHERE CartId = :cartId LIMIT 1];
        // List<String> accountNames = new List<String>();
        // List<Account> accounts = [SELECT Name FROM Account WHERE Id in :ids];
        // for (Account account : accounts) 
        // {
        //     accountNames.add(account.Name);
        // }
        Id shipProdId = setOrderDeliveryMethod(cdg, cartId);//curCart.CurrencyIsoCode
        populateEstimatedFreight(shipProdId, cdg, cartId);

        return null;
    }

    @TestVisible
    private static Id setOrderDeliveryMethod(CartDeliveryGroup cdg, Id cartId)//String currIsoCode
    {
        delete [SELECT Id FROM CartDeliveryGroupMethod WHERE WebCartId = :cartId];

        List<OrderDeliveryMethod> odmList = [SELECT Id, IsActive, ProductId FROM OrderDeliveryMethod WHERE Name = :PLACEHOLDER_ORDER_DELIV_METHOD_NAME AND isActive = true AND ProductId != null LIMIT 1];//AND CurrencyIsoCode = :currIsoCode

        if(odmList.isEmpty())
        {
            List<Product2> prodList = [SELECT Id FROM Product2 WHERE Name = 'Shipping Charge' LIMIT 1];
            if(prodList.isEmpty())
            {
                Product2 delivProd = new Product2();
                delivProd.Name = 'Shipping Charge';

                insert delivProd;
                prodList.add(delivProd);
            }
            

            OrderDeliveryMethod odm = new OrderDeliveryMethod();
            odm.Name = PLACEHOLDER_ORDER_DELIV_METHOD_NAME;
            odm.Carrier = PLACEHOLDER_ORDER_DELIV_METHOD_NAME;
            odm.isActive = true;
            odm.ClassOfService = PLACEHOLDER_ORDER_DELIV_METHOD_NAME;
            //odm.CurrencyIsoCode = currIsoCode;
            odm.ProductId = prodList[0].Id;

            insert odm;

            odmList.add(odm);
        }

        // List<CartDeliveryGroupMethod> cdgmList = new List<CartDeliveryGroupMethod>();

        // CartDeliveryGroupMethod cdgm = new CartDeliveryGroupMethod();
        // cdgm.WebCartId = cartId;
        // cdgm.DeliveryMethodId = odmList[0].Id;
        // cdgm.CartDeliveryGroupId = cdg.Id;
        // cdgm.ShippingFee = 10.00;
        // //cdgm.CurrencyIsoCode = currIsoCode;
        // cdgm.Name = PLACEHOLDER_ORDER_DELIV_METHOD_NAME;

        // insert cdgm;

        cdg.DeliveryMethodId = odmList[0].Id;//productToOrderDelMethodMap.values()[0].Id;
        update cdg;
        
        return odmList[0].ProductId;
    }

    @TestVisible
    private static void populateEstimatedFreight(Id shipProdId, CartDeliveryGroup cdg, Id cartId)
    {
        delete [SELECT Id FROM CartItem WHERE Type = 'Charge' AND CartId = :cartId];

        List<CartItem> itemList = [SELECT Id, Product2.XC_ChargesGroup__c, Quantity, TotalPriceAfterAllAdjustments FROM CartItem WHERE CartId = :cartId AND Type = 'Product'];

        Map<String, XC_AllAxcessFreightCharge__mdt> tempMap = XC_AllAxcessFreightCharge__mdt.getAll();
        Map<String, XC_AllAxcessFreightCharge__mdt> freightMap = new Map<String, XC_AllAxcessFreightCharge__mdt>();

        for(XC_AllAxcessFreightCharge__mdt temp : tempMap.values())
        {
            freightMap.put(temp.Label, temp);
        }

        Decimal shipCost = 0;

        for(CartItem item : [SELECT Id, Product2.XC_ChargesGroup__c, Quantity, TotalPriceAfterAllAdjustments FROM CartItem WHERE CartId = :cartId])
        {
            System.debug(item.Product2.XC_ChargesGroup__c);
            if(String.isNotBlank(item.Product2.XC_ChargesGroup__c) && freightMap.containsKey(item.Product2.XC_ChargesGroup__c))
            {
                XC_AllAxcessFreightCharge__mdt curFreight = freightMap.get(item.Product2.XC_ChargesGroup__c);
                System.debug(curFreight);

                if(curFreight.XC_CurrencyOrPercent__c == '%')
                {
                    shipCost += (item.TotalPriceAfterAllAdjustments * (curFreight.XC_Value__c / 100)).setScale(2);
                    shipCost = shipCost.setScale(2);
                }
                else if(curFreight.XC_CurrencyOrPercent__c == '$')
                {
                    shipCost += (item.Quantity * curFreight.XC_Value__c).setScale(2);
                    shipCost = shipCost.setScale(2);
                }
            }
            
            
        }


        CartItem ship = new CartItem();
        ship.Name = 'Shipping Charge';
        ship.Type = 'Charge';
        ship.CartId = cartId;
        ship.SalesPrice = shipCost;
        ship.TotalLineAmount = shipCost;
        ship.TotalPrice = shipCost;
        ship.CartDeliveryGroupId = cdg.Id;
        ship.Product2Id = shipProdId;
        ship.Quantity = 1;

        insert ship;
    }
}