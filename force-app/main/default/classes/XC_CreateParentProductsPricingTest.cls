@isTest
public class XC_CreateParentProductsPricingTest {
    // usage of Connect Api
    @IsTest (seeAllData = true)
	static void createParentPricing() {  
        Test.startTest();  
		    Database.executeBatch(new XC_CreateParentProductsPricing());
        Test.stopTest(); 
        
        }
}