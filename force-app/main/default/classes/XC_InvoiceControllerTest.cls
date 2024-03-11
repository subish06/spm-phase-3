@isTest
private class XC_InvoiceControllerTest {
	
    
    @testSetup
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
        
       /* User u2 = new User();
        u2.FirstName = 'User2';
        u2.ProfileId = p1.Id;
        u2.Username = Integer.valueof((Math.random() * 10000)) + 'test2@test.com';
        u2.Alias = 'batman';
        u2.Email='bruce.wayne@wayneenterprises.com';
        u2.EmailEncodingKey='UTF-8';
        u2.Lastname='Wayne';
        u2.LanguageLocaleKey='en_US';
        u2.LocaleSidKey='en_US';
        u2.TimeZoneSidKey='America/Chicago';
        insert u2; */
        
        XC_Invoice__c inv = new XC_Invoice__c();
        inv.XC_Account__c = acc.Id;
        inv.XC_CustomerId__c = '12345';
        inv.XC_Status__c = 'Unpaid';
        inv.XC_InvoiceNumber__c='123';
        insert inv;
    }

    @isTest
    private static void getFilteredInvoicesTestFail(){
       List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();
    //    List<XC_Invoice__c> invoiceList2 = new List<XC_Invoice__c>();
       
       User u =[SELECT Id, Name from User where FirstName = 'User1' LIMIT 1];
        System.runAs(u){
       Test.startTest();
       
       
       invoiceList = XC_InvoiceController.getFilteredInvoices(null,null);
       Test.stopTest();
       
       System.assert(invoiceList.size()>0);
        }
   }    

   @isTest
   private static void getFilteredInvoicesTestPass(){
      List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();
   //    List<XC_Invoice__c> invoiceList2 = new List<XC_Invoice__c>();
      
      User u =[SELECT Id, Name from User where FirstName = 'User1' LIMIT 1];
       System.runAs(u){
      Test.startTest();
      
      Date endDate = System.today();

      invoiceList = XC_InvoiceController.getFilteredInvoices(endDate,endDate);
      Test.stopTest();
      
      System.assert(invoiceList.size()==0);
       }
  }  

  @isTest
  private static void getInvoicesTestFail(){
     List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();
  //    List<XC_Invoice__c> invoiceList2 = new List<XC_Invoice__c>();
     
     User u =[SELECT Id, Name from User where FirstName = 'User1' LIMIT 1];
      System.runAs(u){
     Test.startTest();
     
     
     invoiceList = XC_InvoiceController.getInvoices();
     Test.stopTest();
     
     System.assert(invoiceList.size()>0);
      }
 }   
 
 @isTest
 private static void getInvoicesTestPass(){
    List<XC_Invoice__c> invoiceList = new List<XC_Invoice__c>();
 //    List<XC_Invoice__c> invoiceList2 = new List<XC_Invoice__c>();
    
    User u =[SELECT Id, Name from User where FirstName = 'User1' LIMIT 1];
     System.runAs(u){
    Test.startTest();
 
    invoiceList = XC_InvoiceController.getInvoices();
    Test.stopTest();
    
    System.assert(invoiceList.size()>0);
     }
}  

}