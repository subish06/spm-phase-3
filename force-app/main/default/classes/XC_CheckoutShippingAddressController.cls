public without sharing class XC_CheckoutShippingAddressController 
{
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getBillingAddresses(String cartId){
        Map<String,Object> returnMap = new Map<String,Object>();
        try {
            system.debug('CartId '+cartId);
            WebCart curCart = [Select Id, AccountId from WebCart Where Id=:cartId];
            
            Account acc = [Select Id,Name, ParentId, BillingCity, BillingCountryCode, BillingPostalCode,BillingStateCode, BillingStreet FROM Account WHERE Id = :curCart.AccountId Limit 1];
            List<Account> accList = new List<Account>();
            if(acc.ParentId != null){
                accList = [Select Id,Name, ParentId, BillingCity, BillingCountryCode, BillingPostalCode,BillingStateCode, BillingStreet FROM Account WHERE Id = :acc.ParentId];
            }else{
                accList.add(acc);
            }
            returnMap.put(('billingAddressList'), accList);
        } catch (Exception e) {
            system.debug(e.getMessage() + ' '+e.getLineNumber() );
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }

    @AuraEnabled
    public static Map<String, Object> getShippingAddresses(String cartId)
    {
        Map<String, Object> returnMap = new Map<String, Object>();
        try 
        {

            WebCart curCart = [SELECT Id,XC_Order_Type__c,XC_RequestedShipDate__c,AccountId FROM WebCart WHERE Id = :cartId];

            Account acc = [SELECT Id, Name, ParentId, ShippingCity, ShippingCountryCode, ShippingPostalCode, ShippingStateCode, ShippingStreet FROM Account WHERE Id = :curCart.AccountId];
            BuyerGroup myBG = new BuyerGroup();
            Integer i = 0;
            List<BuyerGroup> bgs = XC_B2BUtils.getUserBuyerGroup(acc.Id);
            for(BuyerGroup bg : bgs){
              
                if(i== 0 || (bg.XC_Pre_Order_End_Date__c != null && bg.XC_Pre_Order_Start_Date__c != null)){
                    myBG = bg;
                }
                i++;
            }        
            List<Account> accList = new List<Account>();
            
            accList = [SELECT Id, Name, ParentId, ShippingCity, ShippingCountryCode, ShippingPostalCode, ShippingStateCode, ShippingStreet FROM Account WHERE ParentId = :acc.Id AND ShippingStreet != null ORDER BY Name];
            if(accList.isEmpty())
            {
                accList.add(acc);
            }

            CartDeliveryGroup curDelGrp = [SELECT Id, ShippingInstructions, DeliverToName, DeliverToStreet, DeliverToCity, DeliverToPostalCode, DeliverToStateCode, DeliverToCountryCode FROM CartDeliveryGroup WHERE CartId = :cartId];
            returnMap.put(('shippingInstructions'), curDelGrp.ShippingInstructions);
            returnMap.put('orderType', curCart.XC_Order_Type__c);
            returnMap.put('startOfSeasonDate', myBG.XC_Start_of_Season__c);
            returnMap.put('requestDeliveryDate', curCart.XC_RequestedShipDate__c);

            if(String.isNotBlank(curDelGrp.DeliverToName))
            {
                Integer index;
                Boolean addressFound = false;
                for(index = 0; index < accList.size(); index++)
                {
                    if(accList[index].Name == curDelGrp.DeliverToName)
                    {
                        addressFound = true;
                        break;
                    }
                }

                if(addressFound)
                {
                    Account tempAcc = accList[index];
                    accList.remove(index);
                    accList.add(0, tempAcc);
                }
                else 
                {
                    curDelGrp.DeliverToName = null;
                    curDelGrp.DeliverToStreet = null;
                    curDelGrp.DeliverToCity = null;
                    curDelGrp.DeliverToPostalCode = null;
                    curDelGrp.DeliverToStateCode = null;
                    curDelGrp.DeliverToCountryCode = null;

                    update curDelGrp;
                }
            }

            returnMap.put(('shippingAddressList'), accList);
        } 
        catch (Exception e) 
        {   
            system.debug(e.getMessage() + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }

        return returnMap;
    }

    // public class addressWrapper implements Comparable
    // {
    //     @AuraEnabled
    //     public String accName;

    //     @AuraEnabled
    //     public String accId;

    //     @AuraEnabled
    //     public String accId;

    //     @AuraEnabled
    //     public String accId;

    //     @AuraEnabled
    //     public String accId;

    //     @AuraEnabled
    //     public String accId;

    //     @AuraEnabled
    //     public String accId;

    //     public Integer compareTo(Object compareTo) 
    //     {
    //         XC_ProductWrapper otherWrapper = (XC_ProductWrapper)compareTo;

    //         if(Decimal.valueOf(unitPrice) < Decimal.valueOf(otherWrapper.unitPrice))
    //         {
    //             return -1;
    //         }
    //         else if(Decimal.valueOf(unitPrice) > Decimal.valueOf(otherWrapper.unitPrice))
    //         {
    //             return 1;
    //         }
    //         else
    //         {
    //             return prodName.compareTo(otherWrapper.prodName);
    //         }
    //     }
    // }
}