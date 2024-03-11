import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadSalesProjections from '@salesforce/apex/XC_SalesProjectionController.initiateSalesProjectionBatch';
import { loadScript } from 'lightning/platformResourceLoader';
import sheetjs from '@salesforce/resourceUrl/sheetjs';

export default class XcSalesProjectionUpload extends LightningElement {

    @api fileUploaded;
    @api disabledButton;
    @api recordId;
    @api isLoading = false;
    @track inputContainer;
    @track inputElement;
    version = '???';

    connectedCallback(){
        this.disabledButton = true;
        console.log('init');
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

    handleDownloadClick(){
        const csv = 'InvoiceAccount,SubRegion,BusinessUnit,FiscalYear,FiscalPeriod,SalesTargetActive,Sales Target Amount,SalesTargetQty,BDM\n';
        var hiddenElement = document.createElement('a');  
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);  
        hiddenElement.target = '_blank';  
        hiddenElement.download = 'SalesProjectionTemplate.csv';  
        hiddenElement.click();
    }

    toggleSpinner(){
        this.isLoading = !this.isLoading;
    }

    handleClick(){
        if(this.fileUploaded != null){
            this.toggleSpinner();
            this.excelToJSON(this.fileUploaded);
            this.inputContainer.innerHTML = '';
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
                let pageSize = 12000;
                let sheetName = workbook.SheetNames[0];
                let excelValues = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]);

                let payload = this.paginate(excelValues, pageSize);
                
                console.log('payload', payload);
                payload.forEach((salesProjectionGroup, index) =>{
                    let accountAndBDMObject = this.gatherAccountNumbersAndBDMs(salesProjectionGroup);
                    let jsonObject = {excel: salesProjectionGroup, accountNumbers: accountAndBDMObject.accountNumbers, bdms: accountAndBDMObject.bdmList};
                    uploadSalesProjections(jsonObject)
                    .then((result) => {
                        console.log(result);
                        this.fileUploaded = null;
                        this.disabledButton = true;
                        // cancel spinner and display toast message when we reach the end of this array
                        if((index + 1) >= payload.length){
                            this.toggleSpinner();
                            this.showSuccessToast('A background job with ID ' + result + ' has been created. You can monitor its progress in Apex Jobs.');
                        }
                    })
                    .catch(error => {
                        console.log(error);
                        this.showErrorToast(error.message);
                        this.toggleSpinner();
                        this.fileUploaded = null;
                        this.disabledButton = true;
                    });
                })

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

    arrayRemove(arr, value) { 
        return arr.filter(function(element){ 
            return element != value; 
        });
    }

    paginate(array, pageSize) {
        let payload = [];
        for(let i = 0 ; i < array.length ; i += pageSize){
            payload.push(array.slice(i, i+pageSize));
        }
        return payload;
    }

    gatherAccountNumbersAndBDMs(data){
        let payload = {};
        let accountNumberSet = new Set();
        let bdmSet = new Set();
        data.forEach((val) =>{
            accountNumberSet.add(val.InvoiceAccount.toString());
            bdmSet.add(val.BDM);
        })
        let accountNumberList = Array.from(accountNumberSet);
        let bdmList = Array.from(bdmSet);
        console.log('BDMs', bdmList);
        console.log('account numbers', accountNumberList);
        payload.accountNumbers = accountNumberList;
        payload.bdmList = bdmList;
        return payload;
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success! Sales Projections are being created.',
            variant: 'success',
            message: message
        });
        this.dispatchEvent(event);
    }

    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Something went wrong',
            variant: 'error',
            message: message
        });
        this.dispatchEvent(event);
    }
}