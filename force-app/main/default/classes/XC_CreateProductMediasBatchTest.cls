@isTest
public class XC_CreateProductMediasBatchTest {
    // usage of Connect Api
    @IsTest (seeAllData = true)
	static void createProductMedias() {  
        Test.startTest();  
		    Database.executeBatch(new XC_CreateProductMediasBatch(0,200));
        Test.stopTest(); 
        
    }

    @IsTest (seeAllData = true)
	static void createParentProductMedias() {  
        Test.startTest();  
		    Database.executeBatch(new XC_AssignParentProductsImages());
        Test.stopTest(); 
        
    }
    
    @IsTest (seeAllData = true)
    static void generateCMS() {  
        Test.startTest();  
            XC_GenerateCMSController.createProductImages();
        Test.stopTest(); 
    
    }
}