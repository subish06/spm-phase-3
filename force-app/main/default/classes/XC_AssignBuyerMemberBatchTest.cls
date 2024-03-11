@isTest
public class XC_AssignBuyerMemberBatchTest {
    @testSetup
    private static void loadData(){
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' Limit 1];
        
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
         
        Account testAccount = new Account(Name = 'test account', Authorized_Business_Units__c = 'Epiphone;Kramer', XC_PricingGroup__c ='NA_Dlr_Net');
        insert testAccount;
        
        String contactEmail = 'contemail@fakeemail.com.invalid'; 
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = testAccount.Id, Email = contactEmail);
        insert testContact;    
        
        BuyerGroup bg = new BuyerGroup(Name = 'Epiphone - NA_Dlr_Net');
        insert bg;

        BuyerGroup bg2 = new BuyerGroup(Name = 'Kramer - NA_Dlr_Net');
        insert bg2;   
      
    }
        
    @istest
    public static void assignBuyerMemberBatch(){
        Test.startTest();
        Database.executeBatch(new XC_AssignBuyerMembersBatch(), 50);
        Test.stopTest();
    }

    @isTest
    public static void assignBuyerMemberSchedule() {
        Test.startTest();
        XC_AssignAccountBuyerGroupSchedule ors = new XC_AssignAccountBuyerGroupSchedule();
        System.schedule('testBasicScheduledApex','0 0 0 15 3 ? 2023', new XC_AssignAccountBuyerGroupSchedule());
        Test.stopTest();
    }
        
}