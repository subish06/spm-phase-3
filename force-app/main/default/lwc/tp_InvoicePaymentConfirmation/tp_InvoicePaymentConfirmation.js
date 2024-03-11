import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCardInfo from '@salesforce/apex/TP_GenerateStripeLinkController.getCardInfo';
import updateInvoicePaymentSuccessStatus from '@salesforce/apex/TP_GenerateStripeLinkController.updateInvoicePaymentSuccessStatus';
import updateInvoicePaymentFailedStatus from '@salesforce/apex/TP_GenerateStripeLinkController.updateInvoicePaymentFailedStatus';

import completePayment from '@salesforce/apex/TP_GenerateStripeLinkController.completePayment';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TP_InvoiceSuccessPageHeading from '@salesforce/label/c.TP_InvoiceSuccessPageHeading';
import TP_InvoiceSuccessPageBody1 from '@salesforce/label/c.TP_InvoiceSuccessPageBody1';
import TP_InvoiceSuccessPageBody2 from '@salesforce/label/c.TP_InvoiceSuccessPageBody2';
import TP_InvoiceSuccessPageHomeButton from '@salesforce/label/c.TP_InvoiceSuccessPageHomeButton';
import TP_InvoiceSuccessPageBackButton from '@salesforce/label/c.TP_InvoiceSuccessPageBackButton';
import Credit_Card_Success_Message from '@salesforce/label/c.Credit_Card_Success_Message';
import Card_Success_Message from '@salesforce/label/c.Card_Success_Message';
import Card_Error_Message from '@salesforce/label/c.Card_Error_Message';

export default class Tp_InvoicePaymentConfirmation extends NavigationMixin(LightningElement) {

    @track isStripe = false;
    @track isCardSaved = false;
    @track isCreditCard = false;
    @track cardText = 'Please wait we are processing your card information....';
    @track invoice = {InvoiceLineItems__r: {records: []}};

    stripeData = '';

    labels={
        TP_InvoiceSuccessPageHeading,
        TP_InvoiceSuccessPageBody1,
        TP_InvoiceSuccessPageBody2,
        TP_InvoiceSuccessPageHomeButton,
        TP_InvoiceSuccessPageBackButton,
        Credit_Card_Success_Message,
        Card_Success_Message,
        Card_Error_Message
    }

    get hasLinkedOrder() {
        return this.invoice.XC_OrderSummary__c != null;
    }

    get totalCost() {
        return this.invoice.XC_Total__c ? this.invoice.XC_Total__c : 0.00;
    }

    get miscCost() {
        return this.invoice.XC_Misc__c ? this.invoice.XC_Misc__c : 0.00;
    }

    // get cc225Cost() {
    //     return this.invoice.XC_CC225Percent__c ? this.invoice.XC_CC225Percent__c : 0.00;
    // }

    get taxCost() {
        return this.invoice.XC_Tax__c ? this.invoice.XC_Tax__c : 0.00;
    }

    get freightCost() {
        return this.invoice.XC_Freight__c ? this.invoice.XC_Freight__c : 0.00;
    }

    get discountCost() { 
        return this.invoice.XC_TotalDiscount__c ? this.invoice.XC_TotalDiscount__c : 0.00;
    }

    get serviceCharge() {
        return this.invoice.XC_Total__c ? (this.invoice.XC_Total__c * 0.025) : 0.00;
    }

    get totalAmount() {
        return Math.round(this.invoice.XC_Total__c ? this.invoice.XC_Total__c + (this.invoice.XC_Total__c * (this.isCreditCard ? 0.025 : 0)) : 0.00);
    }

    connectedCallback(){
        try{
            // Update Invoice field- Payment Status = Successfull
            const param = 'invoice';
            const param2 = 'success';
            const paramValue = this.getUrlParamValue(window.location.href, param); 
            const paramValue2 = this.getUrlParamValue(window.location.href, param2); 
            const source = this.getUrlParamValue(window.location.href, 'source'); 
            const sessionId = this.getUrlParamValue(window.location.href, 'sessionId');
            let isCreditCardParam = this.getUrlParamValue(window.location.href, 'isCreditCard');
            let isBank = false;
            
            if(isCreditCardParam == null || isCreditCardParam == ''){
                isBank = true;
                isCreditCardParam = false;
            }
            
            if(source == 'stripe') {
                this.isStripe = true;
                getCardInfo({sessionId: sessionId, invoiceId: paramValue})
                    .then((result) => {
                        const data = JSON.parse(result);
                        this.cardText = ''


                        this.isCardSaved = true;

                        if(data.success) {
                            this.invoice = data.invoice;

                            this.stripeData = data.stripeInfo;

                            if(
                                data.stripeInfo && data.stripeInfo.setup_intent && 
                                data.stripeInfo.setup_intent.payment_method && 
                                data.stripeInfo.setup_intent.payment_method.card
                            ) {
                                //this.cardText = 'Your card (XXXX XXXX XXXX '+data.stripeInfo.setup_intent.payment_method.card.last4+') has been successfully saved.';
                                if(data.stripeInfo.setup_intent.payment_method.card.funding == 'credit') {
                                    this.isCreditCard = true;
                                    this.cardText = ' ' +  this.labels.Credit_Card_Success_Message;
                                }
                                this.cardText += ' ' + this.labels.Card_Success_Message;
                            }
                            else {
                                this.isCardSaved = false;
                                this.cardText =  ' ' + this.labels.Card_Error_Message;
                            }
                        }
                    })
                    .catch((e) => {
                        console.log(e);
                    });
                return;
            }

            if(paramValue2=='true'){    
                updateInvoicePaymentSuccessStatus({
                    invoiceId: paramValue,
                    isCreditCard : isCreditCardParam, //? true : false 
                    isBank : isBank
                })
                .then((result) => {
                    //console.log(result);            
                    let isPaymentStatusUpdated= result;
                    if(isPaymentStatusUpdated){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Payment Successful',
                                message: 'Payment is successfull',
                                variant: 'success',
                                mode: 'dismissable'
                            })
                        );
                    }
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
            else if(paramValue2=='false') {
                updateInvoicePaymentFailedStatus({
                    invoiceId: paramValue,
                    isCreditCard : isCreditCardParam,  //? true : false
                    isBank : isBank            
                })
                .then((result) => {
                    //console.log(result);            
                    let isPaymentStatusUpdated= result;
                    if(isPaymentStatusUpdated){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Payment Failed',
                                message: 'Payment Failed, please check with support team',
                                variant: 'error',
                                mode: 'dismissable'
                            })
                        );
                    }
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
        } 
        catch(ex) {
            console.log('ex---->',ex);
        }
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    completePayment() {
        const paramValue = this.getUrlParamValue(window.location.href, 'invoice'); 
        const totalVal = Math.round(this.invoice.XC_Total__c ? this.invoice.XC_Total__c + (this.invoice.XC_Total__c * (this.isCreditCard ? 0.025 : 0)) : 0.00);
      
        completePayment({
            invNo: paramValue,
            invAmount: totalVal,
            isCreditCard: this.isCreditCard,
            stripeData : JSON.stringify(this.stripeData)
        })
        .then((result) => {
            window.location.href = result;
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

    navigateHome(){
        // Navigation to web page             
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "/"
            }
        });
    }

    navigateBack(){
        // Navigation to web page             
        this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": "/invoices"
        }
        });
    }

}