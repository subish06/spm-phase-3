import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateSalesProjectionItems from '@salesforce/apex/XC_SalesProjectionController.updateSalesProjectionItems';
import { loadScript } from 'lightning/platformResourceLoader';
import sheetjs from '@salesforce/resourceUrl/sheetjs';

export default class XcSalesProjectionItemImport extends LightningElement {
    @api fileUploaded;
    @api disabledButton;
    @api recordId;
    @api isLoading = false;
    @track inputContainer;
    @track inputElement;
    version = '???'

    connectedCallback(){
        this.disabledButton = true;
        console.log('init');
        console.log(this.handleUploadFinished);
        // load XLS script
        loadScript(this, sheetjs)
            .then(() => {
                console.log('loaded');
            })
            .catch(error => {
                console.log('excel Error: ' + error);
                this.error = error;
            });
    }

    handleUploadFinished(event) {
        this.inputContainer = this.template.querySelector('.uploadContainer') // this will get cleared out after upload
        this.inputElement = this.inputContainer.innerHTML; // keep this for later
        const uploadedFile = event.target.files[0];
        this.fileUploaded = uploadedFile;
        if(this.fileUploaded != null){
            this.disabledButton = false;
        }
        console.log(uploadedFile);
    }

    handleClick(){
        if(this.fileUploaded != null){
            this.toggleSpinner();
            this.excelToJSON(this.fileUploaded);
            this.inputContainer.innerHTML = '';
            let newInputElement = this.inputElement;
            //newInputElement.addEventListener('change', function(){window.reload()}, false);
            this.inputContainer.innerHTML = this.inputElement;
        }
    }

    excelToJSON(file){
        var reader = new FileReader();
        console.log(typeof file);
        reader.onload = () => {
            try {              
                let data = new Uint8Array(reader.result);       
                let workbook = XLSX.read(data, { type: "array" });
                console.log(workbook);
                let sheetName = workbook.SheetNames[0];
                let excelValues = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]);
                console.log(excelValues);
                updateSalesProjectionItems({excelInput: excelValues})
                .then((result) => {
                    console.log(result);
                    this.toggleSpinner();
                    this.showSuccessToast('Sales Projections are being updated.');
                    this.fileUploaded = null;
                    this.disabledButton = true;
                })
                .catch(error => {
                    console.log(error);
                    this.toggleSpinner();
                    this.showErrorToast(error.message);
                    this.fileUploaded = null;
                    this.disabledButton = true;
                });

            } catch(err) {
                console.log('error: ' + err);
            }
        };
        reader.onerror = function(ex) {
            this.error = ex;
        };
        try{
            reader.readAsArrayBuffer(file);
        }catch(err){
            console.log(err);
        }
    }

    paginate(array, pageSize) {
        let payload = [];
        for(let i = 0 ; i < array.length ; i += pageSize){
            payload.push(array.slice(i, i+pageSize));
        }
        return payload;
    }

    toggleSpinner(){
        this.isLoading = !this.isLoading;
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success!',
            variant: 'success',
            message: message
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