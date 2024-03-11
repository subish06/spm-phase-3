public inherited sharing class XC_PDPSectionWrapper {
    public class PDPSection{
        public List<Section> sections;

        public PDPSection(List<XC_Product_Fieldset_Mapping__mdt> fieldSets, Product2 prod){
            sections = new List<Section>();
            for(XC_Product_Fieldset_Mapping__mdt f : fieldSets){
                String fieldSetName = f.MasterLabel;
                
                List<Schema.FieldSetMember> fs = Schema.SObjectType.Product2.fieldSets.getMap().get(fieldSetName).getFields();
                List<Item> secItems = new List<Item>();

                for (FieldSetMember member : fs){
                    String fieldValue = String.valueOf(prod.get(member.getFieldPath()));
                    system.debug('fieldValue: ' + fieldValue);
                    if(String.isNotBlank(fieldValue)){
                        secItems.add(new Item(member.getLabel(), fieldValue));  
                    }                                      
                }
                
                if(secItems.size()>0){
                    system.debug('fieldsetname: ' + fieldSetName);
                    system.debug('secItems: ' + secItems);
                    sections.add(new Section(fieldSetName, 1, secItems));
                }
            }
        }
        
    }

    public class Section{
        public String Name;
        public Integer SortOrder;
        public List<Item> SectionItems;

        public Section(String name, Integer sortOrder, List<Item> sectionItems){
            this.Name = name;
            this.SortOrder = sortOrder;
            this.SectionItems = sectionItems;
        }
    }

    public class Item{
        String Label;
        String Value;

        public Item(String label, String value){
            this.Label = label;
            this.Value = value;
        }
    }

}