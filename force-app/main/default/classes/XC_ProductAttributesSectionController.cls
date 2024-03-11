public with sharing class XC_ProductAttributesSectionController {
    @AuraEnabled(cacheable = true)
    public static String getAttributeSection(String recordId){
        String productSectionStr = '';
        List<XC_Product_Fieldset_Mapping__mdt> fieldSets = XC_ProductUtil.returnProductFieldSets();
        String fields = XC_ProductUtil.returnFieldsFromFieldSets(fieldSets);
        Product2 prod = XC_ProductUtil.returnProductFromFieldSets(recordId, fields);

        XC_PDPSectionWrapper.PDPSection sectionWrapper = new XC_PDPSectionWrapper.PDPSection(fieldSets, prod);
        
        return JSON.serialize(sectionWrapper);
    }

}