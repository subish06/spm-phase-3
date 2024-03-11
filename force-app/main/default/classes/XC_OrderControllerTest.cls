@IsTest
public class XC_OrderControllerTest {
	@IsTest(SeeAllData=true)
    private static void loadData(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        Profile p1= [Select Id from Profile where Name LIKE 'All Axcess Community User'];
        Contact c = new Contact();
        c.FirstName = 'Contact1';
        c.LastName ='Last';
        c.AccountId = acc.Id;
        insert c;
        
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='1213'+ Datetime.now().millisecond();
        insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product2';
        pt.XC_Cost__c = 123;
        pt.StockKeepingUnit = '1234';
        insert pt;
         Order ord = new Order();
    	ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = System.today();
            ord.OrderReferenceNumber = '12345';
            ord.OrderedDate = System.today();
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
        OrderItemSummary ordSum = new OrderItemSummary();
       ordSum.Product2Id = pt.Id;
        ordSum.OrderSummaryId = [SELECT Id, OriginalOrderId from OrderSummary where OriginalOrderId=:ord.Id].Id;
        User u = new User();
        u.ContactId = c.Id;
        u.FirstName = 'User1';
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
    
  
        System.runAs(u){      
         Test.startTest();
		List<XC_OrderProductWrapper> orderList = XC_OrderController.getOrderListByDateAndSKUForExport(null,null,'');
        Test.stopTest();
        System.assert(orderList.size()>0);
                //System.assert(reorderList.size()>0);
        }
        }
    
    @IsTest(SeeAllData=true)
    public static void getorderLis2133(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        Profile p1= [Select Id from Profile where Name LIKE 'All Axcess Community User'];
        Contact c = new Contact();
        c.FirstName = 'Contact1';
        c.LastName ='Last';
        c.AccountId = acc.Id;
        insert c;
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='1213'+Datetime.now().millisecond();
        insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product2';
        pt.XC_Cost__c = 123;
        pt.StockKeepingUnit = '1234';
        insert pt;
         Order ord = new Order();
    	ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = System.today();
            ord.OrderReferenceNumber = '12345';
            ord.OrderedDate = System.today();
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
        OrderItemSummary ordSum = new OrderItemSummary();
       ordSum.Product2Id = pt.Id;
        ordSum.OrderSummaryId = [SELECT Id, OriginalOrderId from OrderSummary where OriginalOrderId=:ord.Id].Id;
        User u = new User();
        u.ContactId = c.Id;
        u.FirstName = 'User1';
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
    
  
        System.runAs(u){      
         Test.startTest();
		
        List<XC_OrderProductWrapper>   orderList =    XC_OrderController.getOrderListByDateAndSKU(System.today(),System.today(),'1234',null,null,null);
            Integer   orderListNum =    XC_OrderController.getTotalRecordsNumber(System.today(),System.today(),'1234');
            Integer   orderListNum2 =    XC_OrderController.getTotalRecordsNumber(null,null,'');
            List<ConnectApi.BatchResult> startReorder = XC_OrderController.startReorder(ordSum.Id);
        Test.stopTest();
        System.assert(orderList.size()>0);
                System.assert(orderListNum>0);
        }
        }
    @IsTest(SeeAllData=true)
    public static void getorderLis213(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        Profile p1= [Select Id from Profile where Name LIKE 'All Axcess Community User'];
        Contact c = new Contact();
        c.FirstName = 'Contact1';
        c.LastName ='Last';
        c.AccountId = acc.Id;
        insert c;
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='1213'+Datetime.now().millisecond();
        insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product2';
        pt.XC_Cost__c = 123;
        pt.StockKeepingUnit = '1234';
        insert pt;
         Order ord = new Order();
    	ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = System.today();
            ord.OrderReferenceNumber = '12345';
            ord.OrderedDate = System.today();
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
        OrderItemSummary ordSum = new OrderItemSummary();
       ordSum.Product2Id = pt.Id;
        ordSum.OrderSummaryId = [SELECT Id, OriginalOrderId from OrderSummary where OriginalOrderId=:ord.Id].Id;
        User u = new User();
        u.ContactId = c.Id;
        u.FirstName = 'User1';
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
    
  
        System.runAs(u){      
         Test.startTest();
		
        List<XC_OrderProductWrapper>   orderList =    XC_OrderController.getOrderListByDateAndSKU(null,null,'',null,null,null);
        Test.stopTest();
        System.assert(orderList.size()>0);
                //System.assert(reorderList.size()>0);
        }
        }
        @IsTest(SeeAllData=true)
    public static void getorderLis21(){
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acc.XC_CustomerId__c = '12345';
        acc.XC_InvoiceAccountId__c = '12345';
        insert acc;
        Profile p1= [Select Id from Profile where Name LIKE 'All Axcess Community User'];
        Contact c = new Contact();
        c.FirstName = 'Contact1';
        c.LastName ='Last';
        c.AccountId = acc.Id;
        insert c;
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='1213'+Datetime.now().millisecond();
        insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product2';
        pt.XC_Cost__c = 123;
        pt.StockKeepingUnit = '1234';
        insert pt;
         Order ord = new Order();
    	ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = System.today();
            ord.OrderReferenceNumber = '12345';
            ord.OrderedDate = System.today();
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
        OrderItemSummary ordSum = new OrderItemSummary();
       ordSum.Product2Id = pt.Id;
        ordSum.OrderSummaryId = [SELECT Id, OriginalOrderId from OrderSummary where OriginalOrderId=:ord.Id].Id;
        User u = new User();
        u.ContactId = c.Id;
        u.FirstName = 'User1';
        u.ProfileId = p1.Id;
        u.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u.Alias = 'batman';
        u.Email='bruce.wayne@wayneenterprises.com';
        u.EmailEncodingKey='UTF-8';
        u.Lastname='Wayne';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Chicago';
        insert u;
    
  
        System.runAs(u){      
         Test.startTest();
		
        List<XC_OrderProductWrapper>   orderList =    XC_OrderController.getOrderListByDateAndSKUForExport(System.today(),System.today(),'1234');
        Test.stopTest();
        System.assert(orderList.size()>0);
                //System.assert(reorderList.size()>0);
        }
        }
    
    
}