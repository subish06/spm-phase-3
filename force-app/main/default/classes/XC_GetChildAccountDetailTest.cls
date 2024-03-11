@isTest
private class XC_GetChildAccountDetailTest {
	
    @isTest
    private static void getChildAccountAddressTest(){
        List<XC_GetChildAccountDetail.accountDetailsWrapper> accountDetails = new List<XC_GetChildAccountDetail.accountDetailsWrapper>();
        
        Account parentAccount = new Account();
        parentAccount.Name = 'Test Parent Account';
        parentAccount.XC_CustomerId__c = '12345';
        parentAccount.XC_InvoiceAccountId__c = '12345';
        insert parentAccount;
        
        Account childAccount = new Account();
        childAccount.Name = 'Test Child Account';
        childAccount.XC_CustomerId__c = '67890';
        childAccount.XC_InvoiceAccountId__c = '12345';
        insert childAccount;
        
        Test.startTest();
		accountDetails = XC_GetChildAccountDetail.getChildAccountAddress(parentAccount.Id);
        Test.stopTest();
        
        System.assert(accountDetails.size()>0);
    }
}