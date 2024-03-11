import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoices from '@salesforce/apex/XC_InvoiceController.getFilteredInvoices';

export default class XcInvoiceList extends LightningElement 
{
    @api effectiveAccountId;
    @api startDate;//Ticket No GB-126
    @api enddate;//Ticket No GB-126
    isValid;
    calledOnce = false;
    @track invoiceList;
    @track filteredInvoiceLists;
    @track showSelected = false;
    @track selectedPaymentStatus = '-none-';
    paymentStatusOptions = [
        { label: '-none-', value: '-none-' },
        { label: 'Unpaid', value: 'Unpaid' },
        { label: 'Paid', value: 'Paid' },
        { label: 'In Progress', value: 'Payment In Progress' }
    ];

    validateDate(){
        let isValid =true;
        if(this.enddate){
            if(new Date(this.startDate)>new Date(this.enddate)){
                this.isValid = false;
                let startField =this.template.querySelector('.start-date');
                startField.setCustomValidity("Provide an end date that's after the start date.");
                startField.reportValidity();
            }
            else{
                let startField =this.template.querySelector('.start-date');
                startField.setCustomValidity("");
                startField.reportValidity();
            }
        }
    }

    // get filteredInvoiceLists() {
    //     return this.invoiceList.filter(item => item.XC_Status__c == 'Unpaid');
    // }

    handleCheckboxChange(event) {
        this.showSelected = event.target.checked;
    }

    handlePicklistChange(event) {
        this.selectedPaymentStatus = event.detail.value;
        this.showSelected = true;

        if(event.detail.value == '-none-') {
            this.filteredInvoiceLists = this.invoiceList;
        } else {
            this.filteredInvoiceLists = this.invoiceList.filter(item => item.XC_Status__c == event.detail.value);
        }
        // You can perform additional actions based on the selected value
    }

    invoiceList = [];

    connectedCallback()
    {
        //this.getInvoices(null,null);//Ticket No GB-126
    }
    renderedCallback(){
        if(!this.calledOnce && this.startDate){
        this.getInvoices(this.startDate,this.enddate);
        this.calledOnce =true;
        }
    }
    //Ticket No GB-126
    @api getInvoices(fromDate,toDate)
    {
        this.showSpinner = true;
        getInvoices({
            startdate: fromDate,
            enddate: toDate
        })
        .then((result) => {
            //console.log(result);
            let baseURL = 'https://'+location.host+'/AllAxcess/s/product/detail/';
            let dataList;
            dataList = JSON.parse(JSON.stringify(result));
            
            for ( let i = 0; i < dataList.length; i++ ) {  
                if(dataList[i].InvoiceLineItems__r != null){
                    for(let j = 0; j< dataList[i].InvoiceLineItems__r.length; j++){
                        if(dataList[i].InvoiceLineItems__r[j].XC_Item__c != null){
                            dataList[i].InvoiceLineItems__r[j].productURL = baseURL + dataList[i].InvoiceLineItems__r[j].XC_Item__c;
                            dataList[i].InvoiceLineItems__r[j].productName = true;
                        }else{
                            dataList[i].InvoiceLineItems__r[j].productName = false;
                        }
                    }
                }
            }

            this.invoiceList = dataList;
            this.showSpinner = false;
            console.log('isSelected -->',this.showSelected);
            console.log('spinner -->',this.showSpinner);
            console.log('this,invoiceList :'+JSON.stringify(this.invoiceList));
        })
        .catch((e) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Server call failed.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
            console.log(e);
        });
    
    }

    //Ticket No GB-126
    handleClick(event){
        this.getInvoices(this.startDate,this.enddate);
        
    }

    //Ticket No GB-126
    handleDateChange(event){
        let countNull = 0;
        let elementValue = this.template.querySelectorAll("lightning-input");
        elementValue.forEach(function(element){
            
            if(element.name == "Start Date")
                this.startDate = element.value;

            else if(element.name == "End Date")
                this.enddate = element.value;
            
            if(element.value == null || element.value == '')
                countNull += 1;
        },this);
        this.validateDate();
        
        // if(countNull != 2)
        //     this.template.querySelector(".applyButton").disabled = false;
        // else
        //     this.template.querySelector(".applyButton").disabled = true;

    }

    //Ticket No GB-126
    handleReset(event){
        let countNull = 0;
        let elementValue = this.template.querySelectorAll("lightning-input");
        elementValue.forEach(function(element){
            if(element.name == "Start Date"){
                element.value = '';
                this.startDate = null;

            }else if(element.name == "End Date"){
                element.value = '';
                this.enddate = null;
            }
                
            
            if(element.value == null || element.value == '')
                countNull += 1;
        },this);
        // if(countNull != 2)
        //     this.template.querySelector(".applyButton").disabled = false;
        // else
        //     this.template.querySelector(".applyButton").disabled = true;
        this.getInvoices(null,null);
    }
}