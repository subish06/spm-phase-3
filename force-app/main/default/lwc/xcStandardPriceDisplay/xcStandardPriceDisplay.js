import { LightningElement, api } from 'lwc';
import getStandardPrice from '@salesforce/apex/XC_ProductController.getStandardPrice';

export default class XcStandardPriceDisplay extends LightningElement {

    @api standardPrice;
    @api productId;
    @api description;

    connectedCallback(){
        getStandardPrice({productId: this.productId})
        .then((data) => {
            console.log(data);
            console.log(this.productId);
            this.standardPrice = data.price;
            this.description = data.description;
        })
        .catch((error) => {
            console.log(error);
        });

    }

    handleToggleSection(event){
        console.log(event.detail);
    }
}