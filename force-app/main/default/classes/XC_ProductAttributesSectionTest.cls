@isTest
public without sharing class XC_ProductAttributesSectionTest {
    @isTest(SeeAllData=true)
    public static void getRecordListPassCheck(){
        Product2 prod = XC_TestDataFactory.createProducts(1)[0];
        String prodStr= XC_ProductAttributesSectionController.getAttributeSection(prod.Id);
        System.assertEquals(prodStr!='',true);
    }
}