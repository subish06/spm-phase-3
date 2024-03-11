@isTest
public class XC_OrdersListPDPViewTest {         
    @istest(SeeAllData=true)
    public static void testPoductList(){
        Account acc = new Account();
        acc.Name = 'TestAccount';
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
        
        // List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();        
        // XC_Invoice__c inv = new XC_Invoice__c();
        // inv.XC_Account__c = acc.Id;
        // inv.XC_CustomerId__c = '12345';
        // inv.XC_Status__c = 'Unpaid';
        // inv.XC_InvoiceNumber__c='1213'+Datetime.now().millisecond();
        // insert inv;
        
        Product2 pt = new Product2();
        pt.Name = 'Product21';
        pt.XC_Cost__c = 123;
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

        OrderSummary ordSum = new OrderSummary();
         OrderItemSummary ordItmSum = new OrderItemSummary();
         ordItmSum.Product2Id = pt.Id;

        ConnectApi.OrderSummaryInputRepresentation ordSumTest = new ConnectApi.OrderSummaryInputRepresentation();
        ordSumTest.orderLifeCycleType = 'UNMANAGED';
        ordSumTest.Status = 'Created';
        ordSumTest.orderId = ord.Id;
        ConnectApi.OrderSummaryOutputRepresentation retSum = ConnectApi.OrderSummaryCreation.createOrderSummary(ordSumTest);
        
            System.runAs(u){
                Test.startTest();
                Product2 p2 = [SELECT Id, Name from Product2 where Name = 'Product21' LIMIT 1];
                
                List<XC_OrderPDPWrapper> prodList =  XC_OrdersListPDPView.getOrderListByProductId(p2.Id);
                System.assert(prodList.size()>0);
                Test.stopTest();
            }
    }
}