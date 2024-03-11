import { LightningElement, track,wire } from 'lwc';
import getParentCategory from '@salesforce/apex/XC_CategoryController.getParentCategory'

export default class XcHeader extends LightningElement {

        parentCat;


    @wire(getParentCategory)
    wireParentCategory({ error, data }) {
        if (data) {
            this.parentCat = data;
            console.log(JSON.stringify(this.parentCat))
        }
        else {
            console.log('Erorr ', JSON.stringify(error))
        }
    }


}