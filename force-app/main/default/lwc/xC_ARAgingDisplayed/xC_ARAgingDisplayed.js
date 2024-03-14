import { LightningElement, api, wire, track } from 'lwc';
import getInvoiceList from '@salesforce/apex/XC_ARAgingController.getInvoiceList';



export default class XC_ARAgingDisplayed extends LightningElement {
    @api effectiveAccountId;
    invoiceData;
    showInvoicePopup = false;
    invoiceIdList = [];
    invoiceIdMap = [];
    headerName;
    @api startDate;
    @api endDate;
    invoiceStartDateMap = {
        under30 : new Date(new Date().setDate(new Date().getDate() - 30)),
        under60 : new Date(new Date().setDate(new Date().getDate() - 60)),
        under90 : new Date(new Date().setDate(new Date().getDate() - 90)),
    };
    invoiceEndDateMap = {
        under30 : new Date(),
        under60 : new Date(new Date().setDate(new Date().getDate() - 31)),
        under90 : new Date(new Date().setDate(new Date().getDate() - 61)),
        over90 : new Date(new Date().setDate(new Date().getDate() - 91))
    };
    @track ageMap ={};
    getInvoicesInfo() {
        // console.log(endDate);
        // console.log(startDate);
        getInvoiceList()
            .then(result => {
                this.invoiceData = result;
                console.log(result);
                this.getInvoiceAge();
            })
            .catch(error => {
                console.log('in catch', error);
            })
    }

    handlePopup(e){
        var headerName = e.target.getAttribute('data-header-label');
        this.invoiceIdList = this.invoiceIdMap[headerName];
        this.startDate = this.invoiceStartDateMap[headerName].toISOString();
        this.endDate = this.invoiceEndDateMap[headerName].toISOString();
        this.showInvoicePopup = true;
        this.template.querySelector('c-xc-invoice-list').getInvoices(this.startDate,this.endDate);//auto apply
    }

    
    getInvoiceAge() {
        let invData = this.invoiceData;
        var invoicemap = {
            under30: 0,
            under60: 0,
            under90: 0,
            over90: 0,
            total:0
        };
        this.invoiceIdMap = {
            under30: [],
            under60: [],
            under90: [],
            over90: []
        };
        
        for (let i = 0; i < invData.length; i++) {
            let newDueDate = new Date(new Date(invData[i].XC_DueDate__c).getTime() + new Date(invData[i].XC_DueDate__c).getTimezoneOffset() * 60 * 1000);
            if (new Date() <= new Date(new Date(newDueDate).setDate(newDueDate.getDate() + 30))) {
                invoicemap.under30 += invData[i].XC_Total__c;
                this.invoiceIdMap['under30'].push(invData[i].Id);
                //var under30Date = under30Date ? (newDueDate<under30Date ? newDueDate : under30Date) : newDueDate;
            }
            else if (new Date() <= new Date(new Date(newDueDate).setDate(newDueDate.getDate() + 60))) {
                invoicemap.under60 +=invData[i].XC_Total__c;
                this.invoiceIdMap['under60'].push(invData[i].Id);
                //var under60Date = under60Date ? (newDueDate<under60Date ? newDueDate : under60Date) : newDueDate;
            }
            else if (new Date() <= new Date(new Date(newDueDate).setDate(newDueDate.getDate() + 90))) {
                invoicemap.under90 += invData[i].XC_Total__c;
                this.invoiceIdMap['under90'].push(invData[i].Id);
                //var under90Date = under90Date ? (newDueDate<under90Date ? newDueDate : under90Date) : newDueDate;
            }
            else if (new Date() > new Date(new Date(newDueDate).setDate(newDueDate.getDate() + 90))) {
                invoicemap.over90 += invData[i].XC_Total__c;
                this.invoiceIdMap['over90'].push(invData[i].Id);
                var over90Date = over90Date ? (newDueDate<over90Date ? newDueDate : over90Date) : newDueDate;
            }
            for (const [key, value] of Object.entries(invoicemap)) {
                invoicemap[key] = Math.floor(invoicemap[key]*100)/100;
              }
              
            invoicemap.total = invoicemap.under30 + invoicemap.under60 + invoicemap.under90 + invoicemap.over90;
            // this.invoiceDateMap['under30'] = under30Date;
            // this.invoiceDateMap['under60'] = under60Date;
            // this.invoiceDateMap['under90'] = under90Date;
            this.invoiceStartDateMap['over90'] = over90Date;
        }
        this.ageMap = invoicemap;
    }
    connectedCallback() {
        this.getInvoicesInfo();
    }
}