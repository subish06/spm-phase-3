import { LightningElement,wire } from 'lwc';
import getParentCategoriesDeatil from '@salesforce/apex/XC_CategoryController.getParentCategoriesDeatil'
export default class XcCategoryList extends LightningElement {

    parentCategoryData; 

     @wire(getParentCategoriesDeatil)
    wireParentCategory({ error, data }) {
        if (data != null) {
            this.parentCategoryData = data;

            console.log('datta ' , JSON.stringify(this.parentCategoryData))
            
        }
        else {
            
            console.log('Error getParentCategoriesDeatil ', JSON.stringify(error))
        }
    }


}