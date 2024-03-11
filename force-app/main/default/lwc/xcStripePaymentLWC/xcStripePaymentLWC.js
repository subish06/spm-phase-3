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
        console.log('Inside Stripe Payment LWC Line 48');
        this.boundListener = this.handleVFResponse.bind(this);
        console.log('Inside Stripe Payment LWC Line 50');

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
        // var cardname = document.getElementById("nameOnCard").value;
        // var cardlast4digit = document.getElementByName("cardnumber").value; 
        console.log('-----------');
        // console.log(cardname);
        // console.log(cardlast4digit);
        console.log('Inside Stripe Payment LWC Line 137');
        console.log(message.data);
        console.log('Inside Stripe Payment LWC Line 139');
        console.log(message.origin);
        console.log('Inside Stripe Payment LWC Line 141');
        //console.log(JSON.parse(JSON.stringify(message.data)));
        console.log('Inside Stripe Payment LWC Line 143');
        console.log(location.host);
        if (message.origin === 'https://' + location.host) 
        {
            console.log('Inside Stripe Payment LWC Line 147');
            this.receivedMessage = message.data;
            console.log('Inside Stripe Payment LWC Line 149');
            console.log(message.data.success);
            if(message.data.success)
            {
                console.log('Inside Stripe Payment LWC Line 153');
                this.handlePaymentSuccess(message.data.paymentId, message.data.amount);
                console.log('Inside Stripe Payment LWC Line 155');
            }
            console.log('Inside Stripe Payment LWC Line 157'+message.data.setSpinner);
            console.log('Inside Stripe Payment LWC Line 158'+this.showSpinner);
            console.log('Inside Stripe Payment LWC Line 159'+message.data.boolVal);

            if(message.data.setSpinner)
            {
                console.log('Inside Stripe Payment LWC Line 163');
                this.showSpinner = message.data.boolVal;
            }
        }
    }

    handlePaymentSuccess(paymentId, amount)
    {
        console.log('Inside Stripe Payment LWC Line 165');
        console.log(this.cartId);
        console.log(this.invoiceId);
        if(this.cartId)
        {
            console.log('Inside Stripe Payment LWC Line 170');
            this.handleCartPayment(paymentId);
        }
        else if(this.invoiceId)
        {
            console.log('Inside Stripe Payment LWC Line 174');
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
            console.log('Inside Stripe Payment LWC Line 190');
            console.log(result);
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
            console.log('Inside Stripe Payment LWC Line 221');
            console.log(JSON.stringify(result));
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