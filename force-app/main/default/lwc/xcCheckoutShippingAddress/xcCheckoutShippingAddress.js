import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import REQUESTED_SHIP_DATE_FIELD_NAME from '@salesforce/schema/WebCart.XC_RequestedShipDate__c';

import getShippingAddresses from '@salesforce/apex/XC_CheckoutShippingAddressController.getShippingAddresses';

export default class XcCheckoutShippingAddress extends LightningElement 
{
    @api requestedShipDate;
    @api cartId;
    @api shippingAccountId;
    @api shippingInstructions;

    hasDelDate = false;
    hasShipAddress = false;
    options = [];
    minDate;
    maxDate;
    orderType;

    get hasData()
    {
        if(this.hasDelDate == true && this.hasShipAddress == true)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    get todayDate()
    {
        return this.getToday();
    }

   /* @wire(getRecord, { recordId: '$cartId', fields: [REQUESTED_SHIP_DATE_FIELD_NAME] })
    wiredRecord({ error, data }) 
    {
        if(error) 
        {
            this.hasDelDate = false;
            this.requestedShipDate = this.getToday();
            //error handling?
        } 
        else if(data) 
        {
            
            if(data.fields)
            {
                if(data.fields[REQUESTED_SHIP_DATE_FIELD_NAME.fieldApiName].value && data.fields[REQUESTED_SHIP_DATE_FIELD_NAME.fieldApiName].value > this.getToday())
                {
                    this.requestedShipDate = data.fields[REQUESTED_SHIP_DATE_FIELD_NAME.fieldApiName].value;
                    this.hasDelDate = true;
                }
                else
                {
                    this.requestedShipDate = this.getToday();
                    this.hasDelDate = true;
                }
            }
            else
            {
                this.requestedShipDate = this.getToday();
                this.hasDelDate = false;
            }
        }
    }*/

    connectedCallback()
    {
        this.getShippingData();
    }

    getShippingData()
    {
        getShippingAddresses({
            cartId : this.cartId
        })
        .then((result) => {
            //console.log(result);
            this.orderType = result.orderType;
            let startOfSeasonDate = result.startOfSeasonDate;
            let todayD = this.getToday();
            console.log('todayD: ' + todayD);
            console.log('result.requestDeliveryDate: ' + result.requestDeliveryDate);
            let requestDeliveryDate = (result.requestDeliveryDate ? result.requestDeliveryDate : this.getToday());
            
            console.log('requestDeliveryDate: ' + requestDeliveryDate);
            console.log('requestDeliveryDate: ' + requestDeliveryDate);

            if(this.orderType == 'Pre-Order' && startOfSeasonDate){

                this.requestedShipDate = (this.returnDate(requestDeliveryDate) < this.returnDate(startOfSeasonDate) ? startOfSeasonDate : requestDeliveryDate);
                this.minDate = startOfSeasonDate;
            }else{
                this.minDate = this.getToday();
                this.requestedShipDate = this.getToday();
            }

           

            this.shippingAccountId = result.shippingAddressList[0].Id;//.slice(0, 15);
            if(result.shippingInstructions)
            {
                this.shippingInstructions = result.shippingInstructions;
            }

            let options = [];

            for(let i = 0; i < result.shippingAddressList.length; i++)
            {
                let curAcc = result.shippingAddressList[i];
                options.push({value: curAcc.Id, label: curAcc.Name + ': ' + curAcc.ShippingStreet  + ', ' + curAcc.ShippingCity  + ', ' + curAcc.ShippingStateCode  + ' ' + curAcc.ShippingPostalCode  + ' ' + curAcc.ShippingCountryCode});
            }
            //console.log(options);
            //this.invoiceList = result;
            this.options = options;
            this.hasDelDate = true;
            this.hasShipAddress = true;
        })
        .catch((e) => {
            console.log(e);
        });
    }

    getToday()
    {
        let today = new Date();
        let day = today.getDate();
        let month = today.getMonth() + 1;
        let year = today.getFullYear();

        day = day < 10 ? '0' + day : day;
        month = month < 10 ? '0' + month : month;
        return year +'-'+ month +'-'+ day;
    }    

    returnDate(myDate){
        let tempStart = myDate;
        let arrStart = tempStart.split('-');
        let formatDate = new Date(parseInt(arrStart[0]), parseInt(arrStart[1]) - 1, parseInt(arrStart[2]));                   
        formatDate.setHours(0, 0, 0, 0);
        return formatDate;
    }

    getTodayPlus30()
    {
        let today = new Date();
        today.setDate(today.getDate() + 30);
        let day = today.getDate();
        let month = today.getMonth() + 1;
        let year = today.getFullYear();

        day = day < 10 ? '0' + day : day;
        month = month < 10 ? '0' + month : month;
        return year +'-'+ month +'-'+ day;
    }    
    
    
    updateRequestedShipDate(event)
    {
        console.log('order Type: ' + this.orderType);
        if(event.target.value < this.minDate){
            this.requestedShipDate = this.requestedShipDate;
            this.template.querySelector('.requestedShipDate').value = this.requestedShipDate;
            this.showToast('', 'Selected date is not valid, reverted back to a valid date', 'warning');
        }else if(this.orderType != 'Pre-Order' && event.target.value > this.getTodayPlus30()){
            this.requestedShipDate = this.requestedShipDate;
            this.template.querySelector('.requestedShipDate').value = this.requestedShipDate;
            this.showToast('', 'Selected date is not valid, reverted back to a valid date', 'warning');
        }else{
            this.requestedShipDate = event.target.value;
        }
    }

    handleTextAreaOnchange(event){
        this.shippingInstructions = event.detail.value;
    }

    shippingAddressChanged(event)
    {
        this.shippingAccountId = event.target.value;
        console.log(event.target.value);
        console.log(this.shippingInstructions);
    }

    showToast(title, message, variant) 
    {
        let event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}