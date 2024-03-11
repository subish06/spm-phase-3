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
        try {
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
            let originalDueDate = new Date(invData[i].XC_InvoiceDate__c);
            let neDueDate = new Date(originalDueDate.getTime() + originalDueDate.getTimezoneOffset() * 60 * 1000);

            let currentDate = new Date();
            let currentDateMinus30Days = new Date(currentDate);
            currentDateMinus30Days.setDate(currentDate.getDate() - 30);

            let currentDateMinus60Days = new Date(currentDate);
            currentDateMinus60Days.setDate(currentDate.getDate() - 60);

            let currentDateMinus90Days = new Date(currentDate);
            currentDateMinus90Days.setDate(currentDate.getDate() - 90);

            let currentDateMinus2000Days = new Date(currentDate);
            currentDateMinus2000Days.setDate(currentDate.getDate() - 2000);

            if (neDueDate >= currentDateMinus30Days && neDueDate <= currentDate) {
                console.log('yes');
            }

            let newDueDate = new Date(new Date(invData[i].XC_InvoiceDate__c).getTime() + new Date(invData[i].XC_InvoiceDate__c).getTimezoneOffset() * 60 * 1000);
            if (neDueDate >= currentDateMinus30Days && neDueDate <= currentDate) {
                invoicemap.under30 += invData[i].XC_Total__c;
                this.invoiceIdMap['under30'].push(invData[i].Id);
                //var under30Date = under30Date ? (newDueDate<under30Date ? newDueDate : under30Date) : newDueDate;
            }
            else if (neDueDate >= currentDateMinus60Days && neDueDate <= currentDate) {
                invoicemap.under60 +=invData[i].XC_Total__c;
                this.invoiceIdMap['under60'].push(invData[i].Id);
                //var under60Date = under60Date ? (newDueDate<under60Date ? newDueDate : under60Date) : newDueDate;
            }
            else if (neDueDate >= currentDateMinus90Days && neDueDate <= currentDate) {
                invoicemap.under90 += invData[i].XC_Total__c;
                this.invoiceIdMap['under90'].push(invData[i].Id);
                //var under90Date = under90Date ? (newDueDate<under90Date ? newDueDate : under90Date) : newDueDate;
            }
            else if (neDueDate >= currentDateMinus2000Days && neDueDate <= currentDate) {
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
        this.invoiceIdList = this.invoiceIdMap['under30'];
        this.startDate = this.invoiceStartDateMap['under30'].toISOString();
        this.endDate = this.invoiceEndDateMap['under30'].toISOString();
        console.log('1 -->','under30');
        console.log('2 -->',this.invoiceIdMap);
        console.log('3 -->',this.invoiceIdList);
        console.log('4 -->',this.startDate);
        console.log('5 -->',this.endDate);
        //this.showInvoicePopup = true;
        this.template.querySelector('c-xc-invoice-list').getInvoices(this.startDate,this.endDate);//auto apply
        } catch (err) {
            console.log('name  -->',err.name);
            console.log('message   -->',err.message );
            // error handling
          
          }
        
    }
    connectedCallback() {
        this.getInvoicesInfo();
    }

    renderedCallback() {
        
    }
}