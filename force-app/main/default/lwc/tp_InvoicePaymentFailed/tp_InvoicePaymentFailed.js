import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import updateInvoicePaymentSuccessStatus from '@salesforce/apex/TP_GenerateStripeLinkController.updateInvoicePaymentSuccessStatus';
import updateInvoicePaymentFailedStatus from '@salesforce/apex/TP_GenerateStripeLinkController.updateInvoicePaymentFailedStatus';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TP_InvoiceSuccessPageHeading from '@salesforce/label/c.TP_InvoiceSuccessPageHeading';
import TP_InvoiceSuccessPageBody1 from '@salesforce/label/c.TP_InvoiceSuccessPageBody1';
import TP_InvoiceSuccessPageBody2 from '@salesforce/label/c.TP_InvoiceSuccessPageBody2';
import TP_InvoiceSuccessPageHomeButton from '@salesforce/label/c.TP_InvoiceSuccessPageHomeButton';
import TP_InvoiceSuccessPageBackButton from '@salesforce/label/c.TP_InvoiceSuccessPageBackButton';



export default class Tp_InvoicePaymentFailed extends NavigationMixin(LightningElement) {


labels={
    TP_InvoiceSuccessPageHeading,
    TP_InvoiceSuccessPageBody1,
    TP_InvoiceSuccessPageBody2,
    TP_InvoiceSuccessPageHomeButton,
    TP_InvoiceSuccessPageBackButton
 
}

connectedCallback(){

    try{    
        // Update Invoice field- Payment Status = Successfull
        const param = 'invoice';
        const param2 = 'success';
        const paramValue = this.getUrlParamValue(window.location.href, param); 
        const paramValue2 = this.getUrlParamValue(window.location.href, param2); 
        console.log('p11111--->'+paramValue);
        console.log('p22222--->'+paramValue2);
        console.log('p22222 type--->'+typeof paramValue2);
        if(paramValue2=='true'){        
            updateInvoicePaymentSuccessStatus({
                invoiceId: paramValue,
                isCreditCard : false,
                isBank : false          
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
                console.log('fail==>', e)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Server call failed.',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
                //console.log(e);
            });


        }
        else if(paramValue2=='false'){

            updateInvoicePaymentFailedStatus({
                invoiceId: paramValue,
                isCreditCard : false,
                isBank : false             
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
                //console.log(e);
            });



        }
    }catch(ex){
        console.log('ex---->'+ex);
    }
}

getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
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