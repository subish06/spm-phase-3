import { LightningElement, api, track } from 'lwc';
import getOrderDetails from '@salesforce/apex/XC_OrderController.getOrderDetails';
import LOCALE from "@salesforce/i18n/currency";

export default class XcShowOrderDetails extends LightningElement {
    @api recordId;
    isShowSpinner = true;
    ownerName;
    status;
    totalAmount;
    LOCALE=LOCALE;

    connectedCallback() {
        this.isShowSpinner = true;
        var orderSumId = this.recordId.split('-')[0];
        console.log('Order Id :', orderSumId);
        getOrderDetails({orderSumId : orderSumId})
        .then(result => {
            this.ownerName = result.Owner.Name;
            this.status = result.Status;
            this.totalAmount = result.GrandTotalAmount;
            console.log('orderSummaryDetails :', this.ownerName + this.status + this.totalAmount);
            this.isShowSpinner = false;
        })
        .catch(error => {
            console.log('Error in getting Order Details :', error);
            this.isShowSpinner = false;
        })
    }
}