import { LightningElement, api } from 'lwc';
import getInvoiceListByIds from '@salesforce/apex/XC_ARAgingController.getInvoiceListByIds';
const columns = [{
    label: 'Invoice Number',
    fieldName: 'XC_InvoiceNumber__c',
    type: 'text',
    //cellAttributes: { alignment: 'center' },
    fixedWidth: 150
  },
  {
    label: 'Invoice Date',
    fieldName: 'XC_InvoiceDate__c',
    type: 'date',
    //cellAttributes: { alignment: 'center' },
    fixedWidth: 150
  },
  {
    label: 'Invoice Due Date',
    fieldName: 'XC_DueDate__c',
    type: 'date',
    fixedWidth: 150
  },
  {
    label: 'Total',
    fieldName: 'XC_Total__c',
    type: 'currency',
    cellAttributes: { alignment: 'center' },
    fixedWidth: 150
 }
];

export default class XcInvoiceListPopup extends LightningElement {
    @api invoiceids;
    @api header;
    invoiceData=[];
    showNull =false;
    columns = columns;
    totalInvoices;
    visibleInvoices;
    showSpinner = false;
    
    connectedCallback(){
        this.getInvoiceList(this.invoiceids);
    }
   

    @api getInvoiceList(invoiceids){
        this.showSpinner = true;
        this.showNull =false;
        if(invoiceids.length>0){
        getInvoiceListByIds({invoiceIds:invoiceids})
        .then(result => {
            this.invoiceData = result;
            console.log(result);
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('in catch', error);
        })
    }
    else{
        this.showNull =true
        this.showSpinner = false;
    }
    }

    updateInvoiceHandler(event){
        this.showSpinner = false;
        this.visibleInvoices=[...event.detail.records]
        console.log(event.detail.records)
    }
}