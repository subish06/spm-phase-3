import { LightningElement, api, wire, track } from 'lwc';
import getAttributeSection from '@salesforce/apex/XC_ProductAttributesSectionController.getAttributeSection';
 
export default class XcProductAttributesSection extends LightningElement {
    @api recordId;
    @track section;

    connectedCallback() {
        this.getSection();
    }

    getSection() {
        console.log('recordId: ' + this.recordId);
        getAttributeSection({recordId: this.recordId})
            .then((result) => {
                console.log('result: ' + result);
                let resultSection  = JSON.parse(result);   
                this.section = resultSection.sections;
            })
            .catch((error) => {
                console.log(error);
            });            
    }
}