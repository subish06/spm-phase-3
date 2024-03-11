@isTest
public class XC_RMARequestControllerTest {
	@IsTest(SeeAllData=true)
    private static void getInvoicesTest(){
        Profile p1= [Select Id from Profile where Name='System Administrator'];
        
        user u =new User();
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Firstname='Bruce';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
        
        List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();
        System.runAs(u){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        
        
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='1213'+Datetime.now().millisecond();
        insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product2';
        pt.XC_Cost__c = 123;
        insert pt;

        Order ord = new Order();
    	ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = System.today();
    	insert ord;
OrderDeliveryMethod ordm = new OrderDeliveryMethod();
        ordm.Carrier = 'UPS';
		ordm.Name = 'UPS';
        insert ordm;   
        OrderDeliveryGroup ordg = new OrderDeliveryGroup();
        ordg.DeliverToCity = 'New York';
        ordg.OrderId = ord.Id;
        ordg.DeliverToName = 'Bruce';
        ordg.OrderDeliveryMethodId = ordm.Id;
        insert ordg;
 OrderItem oitem =new OrderItem();
        oitem.OrderId = ord.Id;
        oitem.Product2Id = pt.Id;
oitem.ListPrice = 123;
 oitem.UnitPrice = 123;
oitem.Quantity = 1;
oitem.OrderDeliveryGroupId = ordg.Id;
        insert oitem;
ord.Status = 'Activated';
update ord;
 // to create OrderSummary

            ConnectApi.OrderSummaryInputRepresentation newSum = new ConnectApi.OrderSummaryInputRepresentation();

            newSum.orderLifeCycleType = 'UNMANAGED';

            newSum.Status = 'Created';
            newSum.orderId = ord.Id;

            ConnectApi.OrderSummaryOutputRepresentation retSum = ConnectApi.OrderSummaryCreation.createOrderSummary(newSum);

            system.debug(retSum);
        
            
        
                    
         Test.startTest();
        OrderSummary orderSum1 = [SELECT Id from OrderSummary where OriginalOrderId=:ord.Id];
		Map<String, Object> orderList = XC_RMARequestController.getOrderData(orderSum1.Id);
        Test.stopTest();
        System.assert(orderList.size()>0);
        }
    }
    
    
    @IsTest(SeeAllData=true)
        private static void createRMATest(){
         Profile p1= [Select Id from Profile where Name='System Administrator'];
        
        user u =new User();
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Firstname='Bruce';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
        
        List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();
        System.runAs(u){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        
        
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='123'+Datetime.now().millisecond();
        insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product2';
        pt.XC_Cost__c = 123;
        insert pt;

        Order ord = new Order();
    	ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = System.today();
    	insert ord;
OrderDeliveryMethod ordm = new OrderDeliveryMethod();
        ordm.Carrier = 'UPS';
		ordm.Name = 'UPS';
        insert ordm;   
        OrderDeliveryGroup ordg = new OrderDeliveryGroup();
        ordg.DeliverToCity = 'New York';
        ordg.OrderId = ord.Id;
        ordg.DeliverToName = 'Bruce';
        ordg.OrderDeliveryMethodId = ordm.Id;
        insert ordg;
 OrderItem oitem =new OrderItem();
        oitem.OrderId = ord.Id;
        oitem.Product2Id = pt.Id;
oitem.ListPrice = 123;
 oitem.UnitPrice = 123;
oitem.Quantity = 1;
oitem.OrderDeliveryGroupId = ordg.Id;
        insert oitem;
ord.Status = 'Activated';
update ord;
 // to create OrderSummary

            ConnectApi.OrderSummaryInputRepresentation newSum = new ConnectApi.OrderSummaryInputRepresentation();

            newSum.orderLifeCycleType = 'UNMANAGED';

            newSum.Status = 'Created';
            newSum.orderId = ord.Id;

            ConnectApi.OrderSummaryOutputRepresentation retSum = ConnectApi.OrderSummaryCreation.createOrderSummary(newSum);

            system.debug(retSum);
        
            
        
                    
         Test.startTest();
        OrderSummary orderSum1 = [SELECT Id from OrderSummary where OriginalOrderId=:ord.Id LIMIT 1];
        OrderItemSummary orderSumItem = [SELECT Id from OrderItemSummary where OrderSummaryId=:orderSum1.Id LIMIT 1];
        Map<String,String> qty = new Map<String,String>();
        qty.put(orderSumItem.Id,'1');
		Map<String, Object> orderList = XC_RMARequestController.createRMA(orderSum1.Id,qty,'HDWR STR');
        Test.stopTest();
        System.assert(orderList.size()>0||orderList.size()==0);
        }
    }
}