import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

import communityId from '@salesforce/community/Id';
import verifyCartData from '@salesforce/apex/XC_StripePaymentLWCController.verifyCartData';
import verifyInvoiceData from '@salesforce/apex/XC_StripePaymentLWCController.verifyInvoiceData';
import handlePayment from '@salesforce/apex/XC_StripePaymentLWCController.handlePayment';

export default class XcStripePaymentLWC extends LightningElement 
{
    @api
    cartId;
    
    @api
    invoiceId;

    cartRecord;
    hasData = false;
    showSpinner = true;
    msg = '';
    receivedMessage = '';
    error;
    boundListener;

    get vfFullSource()
    {
        let vfSource = '';
        if(window.location.href.includes('/AllAxcess/s/'))
        {
            vfSource += '/AllAxcess';
        }
        vfSource += '/apex/XC_StripePaymentPage?commId=' + communityId;

        if(this.cartId)
        {
            vfSource += '&cartId=' +this.cartId;
        }
        else if(this.invoiceId)
        {
            vfSource += '&invoiceId=' +this.invoiceId;
        }
        return vfSource;
    }

    connectedCallback()
    {
        this.boundListener = this.handleVFResponse.bind(this);
        // Binding EventListener here when Data received from VF
        window.addEventListener("message", this.boundListener);
        //this.verifyCartData();
        this.verifyData();
    }

    disconnectedCallback()
    {
        window.removeEventListener("message", this.boundListener);
    }

    verifyData()
    {
        if(this.cartId)
        {
            this.verifyCartData();
        }
        else if(this.invoiceId)
        {
            this.verifyInvoiceData();
        }
    }

    verifyInvoiceData()
    {
        if(this.invoiceId)
        {
            verifyInvoiceData({
                invoiceId : this.invoiceId
            })
            .then((result) => {
                console.log(result);
                if(result === true)
                {
                    this.showSpinner = false;
                    this.hasData = true;
                }
                else
                {
                    this.showSpinner = false;
                    this.hasData = false;
                    this.showToast('', 'Invalid Invoice', 'error');
                }
                
            })
            .catch((error) => {
                this.showSpinner = false;
                this.hasData = false;
                this.showToast('Error', 'Server call failed', 'error');
            });
        }
    }

    verifyCartData()
    {
        if(this.cartId)
        {
            verifyCartData({
                communityId,
                cartId : this.cartId
            })
            .then((result) => {

                this.cartRecord = result;

                //this.cartitems = result.cartItemList;
                this.showSpinner = false;
                this.hasData = true;
            })
            .catch((error) => {
                this.showSpinner = false;
                this.hasData = false;
                this.showToast('Error', 'Server call failed', 'error');
            });
        }
        else
        {
            this.showSpinner = false;
            this.hasData = false;
            this.showToast('Error', 'Server call failed', 'error');
        }
    }

    handleVFResponse(message) 
    {
        console.log(message.data);
        console.log(message.origin);
        console.log(JSON.parse(JSON.stringify(message.data)));
        if (message.origin === 'https://' + location.host) 
        {
            this.receivedMessage = message.data;
            if(message.data.success)
            {
                this.handlePaymentSuccess(message.data.paymentId, message.data.amount);
            }
            if(message.data.setSpinner)
            {
                this.showSpinner = message.data.boolVal;
            }
        }
    }

    handlePaymentSuccess(paymentId, amount)
    {
        if(this.cartId)
        {
            this.handleCartPayment(paymentId);
        }
        else if(this.invoiceId)
        {
            this.handleInvoicePayment(paymentId);
        }
        
    }

    handleCartPayment(paymentId)
    {
        handlePayment({
            communityId,
            cartId : this.cartId,
            invoiceId : null,
            payIntentId : paymentId
        })
        .then((result) => {
            if(result.success)
            {
                console.log(result);
                //this.cartitems = result.cartItemList;
                this.showSpinner = false;
                this.navToNextPage();
            }
            else
            {
                this.showSpinner = false;
                this.showToast('Error', 'Server call failed', 'error');
            }
        })
        .catch((error) => {
            console.log(error);
            this.showSpinner = false;
            this.showToast('Error', 'Server call failed', 'error');
        });
    }

    handleInvoicePayment(paymentId)
    {
        handlePayment({
            communityId,
            cartId : null,
            invoiceId : this.invoiceId,
            payIntentId : paymentId
        })
        .then((result) => {
            if(result.success)
            {
                console.log(result);
                //this.cartitems = result.cartItemList;
                this.showSpinner = false;
                window.location.reload();
                //this.navToNextPage();
            }
            else
            {
                this.showSpinner = false;
                this.showToast('Error', 'Server call failed', 'error');
            }
        })
        .catch((error) => {
            console.log(error);
            this.showSpinner = false;
            this.showToast('Error', 'Server call failed', 'error');
        });
    }

    navToNextPage()
    {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
 
    handleChange(event) 
    {
        this.msg = event.detail.value;
    }
 
    handleFiretoVF() 
    {
        let message = this.msg;
        //Firing an event to send data to VF
        this.template.querySelector("iframe").contentWindow.postMessage(message, 'https://test-tamko.cs69.force.com');
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