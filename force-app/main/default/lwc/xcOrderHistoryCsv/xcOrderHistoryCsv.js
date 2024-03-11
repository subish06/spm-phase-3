import { LightningElement, api } from 'lwc';
import triggerCsvJob from '@salesforce/apex/XC_ProductController.triggerCsvJob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class XcOrderHistoryCsv extends LightningElement {

    handleDownloadClick(){
        triggerCsvJob()
        .then((data) => {
            console.log(data);
            console.log('download click');
            this.showSuccessToast();
        })
        .catch((error) => {
            console.log(error);
            this.showErrorToast(error.body.message);
        });
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            variant: 'success',
            message: 'Success! Your catalog will be emailed to you shortly. This may take 5 to 10 minutes.'
        });
        this.dispatchEvent(event);
    }

    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message: message
        });
        this.dispatchEvent(event);
    }
}