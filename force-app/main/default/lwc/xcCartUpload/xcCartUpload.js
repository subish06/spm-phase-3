import { LightningElement, api } from 'lwc';
import communityId from '@salesforce/community/Id';
import uploadCartFromCsv from '@salesforce/apex/XC_CartController.uploadCartFromCsv';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 

export default class XcCartUpload extends LightningElement {

    @api fileUploaded;
    @api cartId;
    @api disabledButton;

    connectedCallback(){
        this.disabledButton = true;
    }

    handleUploadFinished(event) {
        const uploadedFile = event.target.files[0];
        this.fileUploaded = uploadedFile;
        if(this.fileUploaded != null){
            this.disabledButton = false;
        }
        console.log(uploadedFile);
    }

    handleClick(event){
        if(this.fileUploaded != null){
            this.readFile(this.fileUploaded);
        }
    }

    readFile(file){

        new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onloadend = () => {
                const csvBody = atob((reader.result).replace('data:text/csv;base64,',''));
                //console.log(csvBody);
                console.log(this.cartId);
                uploadCartFromCsv({csvInput: csvBody, communityId: communityId, cartId: this.cartId})
                .then((result) => {
                    console.log('result', result);  
                    location.reload();   
                })
                .catch((error) => {
                    console.log(error);
                    const errorMessage = error.body.message == 'Regex too complicated' ? 'Table has too many rows; can only add up to 500 items per cart.' : error.body.message;
                    this.showErrorToast(errorMessage);
                });
            }
            reader.onerror = (error) => reject(error);
        });
        toBase64(file)
        .then((result) => {
            const base64Constant = 'base64,';
            const base64Value = result.indexOf(base64Constant) + base64Constant.length;
            this.base64Data = result.substring(base64Value);
        });
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