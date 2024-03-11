@IsTest
public class XC_UserControllerTest {
    
    @TestSetup
    static void makeData(){
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Chief Commercial Officer'];
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        insert new User(
            ProfileId = prof.Id,
            UserRoleId = ur.Id, 
            Alias = 'tst123',
            LastName = 'Test',
            Email = 'test@fakexcemail.com',
            Username = getEmail() + 'z@fakexcemail.com', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            CustomerView__c = FALSE
        );
    }
    
    @IsTest
    static void changeViewTest(){
        User u = [SELECT Id FROM User WHERE Alias = 'tst123'];
        User userFromMethod;
        System.runAs(u){
            userFromMethod = XC_UserController.getUserInfo();
            User updatedUser = XC_UserController.changeView(TRUE);
            System.assert(updatedUser.CustomerView__c);
        }
    }
    
    private static String getEmail(){
        List<String> possibleChars = new List<String>{'a','b','c','d','e','f','g','h','i','k', 'l'};
        String emailPrefix = '';
        for(String b : possibleChars){
            emailPrefix = emailPrefix + possibleChars[Math.round(Math.random() * 10)];
        }
        return emailPrefix;
    }

}