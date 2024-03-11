@isTest
public without sharing class XC_OrderSummaryCreationCtrlTest {
   @isTest(SeeAllData=true)
    static void main(){
        createData();
        XC_OrderSummaryCreationCtrl myBatchObject = new XC_OrderSummaryCreationCtrl(); 
        Id batchId = Database.executeBatch(myBatchObject);
    }
    
    
    static void createData(){
        Product2 pr = new Product2 (
            Name = 'Test Productxx',
            Body_Style__c = 'Short'
        );
        insert pr;
        
        Account acc1 = [SELECT Id, Name from Account LIMIT 1];
        
        OrderDeliveryMethod orderDeLMethod = new OrderDeliveryMethod(
            Name = 'Shipping Estimate',
            IsActive = true
        );    
        
        insert orderDelMethod;
        
        Order newOrder = new Order();
        newOrder.AccountId = acc1.Id;
        newOrder.Status = 'Draft';
        newOrder.OrderReferenceNumber = '1212121';
        newOrder.effectiveDate = Date.today();
        insert newOrder;
        
        OrderItem newItem = new OrderItem();
        newItem.OrderId = newOrder.Id;
        newItem.TotalLineAmount = 100;
        newItem.UnitPrice = 100;
        newItem.ListPrice = 100;
        newItem.Quantity = 1;
        newItem.Product2Id = pr.Id;
            
        insert newItem;
        
        Order o = [SELECT Id FROM Order WHERE OrderReferenceNumber != null AND ActivatedDate = null AND Status = 'Draft' AND Id =: newOrder.Id];
        system.debug('order: ' + 0);
        
    }

}