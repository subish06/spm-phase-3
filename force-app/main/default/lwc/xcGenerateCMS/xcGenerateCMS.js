import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createProductImages from '@salesforce/apex/XC_GenerateCMSController.createProductImages';
 
export default class xcGenerateCMS extends LightningElement {
    _title = 'Error Messages';
    message = '';
    variant = 'error';
    mode = 'dismissable';
    variantOptions = [
        { label: 'error', value: 'error' },
        { label: 'warning', value: 'warning' },
        { label: 'success', value: 'success' },
        { label: 'info', value: 'info' },
    ];

    handleMessage(notiTitle,notiType, notiMessage,mode){       
        this._title = notiTitle;
        this.variant = notiType;
        this.message = notiMessage;
        this.mode = mode;
        this.showNotification();
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant,
            mode: this.mode
        });
        this.dispatchEvent(evt);

    }    
  


    handleCreateCMSLink(event){
        createProductImages({})
        .then(result => {
            this.handleMessage('Success', 'success','Batch job to create product images has started','dismissable');
        })
        .catch(error => {
            console.error(error);
            this.handleMessage('Error', 'error','The system encountered an error while starting the batch job to create product images','dismissable');
        })
    }
}