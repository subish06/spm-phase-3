public without sharing class XC_UserController {
    
    @AuraEnabled
    public static User getUserInfo(){
        MyProfilePageController mppc = new MyProfilePageController();
        return mppc.getUser();
    }

    @AuraEnabled
    public static User changeView(Boolean customerView){
        User u = [
            SELECT Id, CustomerView__c
            FROM User
            WHERE Id = :UserInfo.getUserId()];
        u.CustomerView__c = customerView;
        update u;
        return u;
    }
}