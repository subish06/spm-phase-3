import { LightningElement, api, track } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import * as Constants from './constants';

import getPaymentInfo from '@salesforce/apex/XC_CheckoutPaymentController.getPaymentInfo';
import setPayment from '@salesforce/apex/XC_CheckoutPaymentController.setPayment';
import getBilingAddress from '@salesforce/apex/XC_CheckoutShippingAddressController.getBillingAddresses';

export default class XcCheckoutPayment extends LightningElement 
{
    // Private attributes
    _creditCardErrorMessage;
    _purchaseOrderErrorMessage = '';
    _cartId;
    _purchaseOrderNumber;
    _selectedPaymentType = Constants.PaymentTypeEnum.PONUMBER;
    options = [];
    billingAccountId ='';
    showCreditCard = false;
    /**
     * Comes from the flow itself and only available in flow. Given this component is only designed
     * for use in flows, this is probably fine. The actions will tell us if "Previous" is available
     * so we can display the "Previous" button only when it's available.
     */
    @api availableActions;
    @api hidePurchaseOrder = false;   
    @api previousButtonLabel = 'Previous';
    @api nextButtonLabel = 'Submit Order';
    @api hideBillingAddress = false;
    @api billingAddressRequired = false;
    @api selectedBillingAddress = '';
    
    get labels() 
    {
        return Constants.labels;
    }

    @api
    get selectedPaymentType() 
    {
        return this._selectedPaymentType;
    }

    set selectedPaymentType(newPaymentType) 
    {
        this._selectedPaymentType = newPaymentType;
    }

    @api
    get purchaseOrderNumber() 
    {
        return this._purchaseOrderNumber;
    }

    set purchaseOrderNumber(newNumber) 
    {
        this._purchaseOrderNumber = newNumber;
    }
    

    @api
    get cartId() 
    {
        return this._cartId;
    }

    set cartId(cartId)
     {
        this._cartId = cartId;
        if (cartId) 
        {
            this.initializePaymentData(cartId);
            this.getBillingAddressData(cartId);
        }
    }

    get canGoPrevious() 
    {
        return (this.availableActions && this.availableActions.some(element => element == 'BACK'));
    }

    /**
     * Gets the payment types
     * PO Number or Card Payment
     */
    get paymentTypes() 
    {
        return {
            poNumber: Constants.PaymentTypeEnum.PONUMBER,
            cardPayment: Constants.PaymentTypeEnum.CARDPAYMENT
        };
    }

    get isCardPaymentSelected() 
    {
        return (this.actualSelectedPaymentType === Constants.PaymentTypeEnum.CARDPAYMENT && this.showCreditCard);
    }

    get isPoNumberSelected() 
    {
        return (this.actualSelectedPaymentType === Constants.PaymentTypeEnum.PONUMBER && !this.hidePurchaseOrder);
    }

    get actualSelectedPaymentType() 
    {
        return this.hidePurchaseOrder ? Constants.PaymentTypeEnum.CARDPAYMENT : (!this.showCreditCard ? Constants.PaymentTypeEnum.PONUMBER : this._selectedPaymentType);
    }

    initializePaymentData(cartId) 
    {
        // If we don't have those values yet
        getPaymentInfo(
                { cartId: cartId }
            )
            .then((data) => {
                this._purchaseOrderNumber = data.purchaseOrderNumber;
                this.showCreditCard = false;//(data.orderType != 'Pre-Order' ? true : false);
            })
            .catch((error) => {
                //do nothing, continue as normal
                console.log(error.body.message);
            });
    }

    getBillingAddressData(cartId){
        console.log('callingBillingAddressMethod' + cartId);
        getBilingAddress({cartId : cartId }).then((result) =>{
            let options = [];
            this.billingAccountId = result.billingAddressList[0].Id.slice(0, 15);
            this.selectedBillingAddress = this.billingAccountId;
            for(let i = 0; i < result.billingAddressList.length; i++)
            {
                let curAcc = result.billingAddressList[i];
                let addressLabel = '';
                if(curAcc.Name){
                    addressLabel += curAcc.Name + ': ';
                }
                if(curAcc.BillingStreet){
                    addressLabel += curAcc.BillingStreet + ', ';
                }
                if(curAcc.BillingCity){
                    addressLabel += curAcc.BillingCity + ', ';
                }
                if(curAcc.BillingStateCode){
                    addressLabel += curAcc.BillingStateCode + ' ';
                }
                if(curAcc.BillingPostalCode){
                    addressLabel += curAcc.BillingPostalCode + ' ';
                }
                if(curAcc.BillingCountryCode){
                    addressLabel += curAcc.BillingCountryCode;
                }
                options.push({value: curAcc.Id.slice(0, 15), label: addressLabel});
            }
            //console.log(options);
            this.options = options;
        }).catch((error) => {
            console.log(error.body.message);
        })
    }

    billingAddressChanged(event)
    {
        this.billingAccountId = event.target.value.slice(0, 15);
        this.selectedBillingAddress = this.billingAccountId;
    }


    handleUpdate() 
    {
        const poComponent = this.getComponent('[data-po-number]');
        const poData = (poComponent.value || '').trim();
        this._purchaseOrderNumber = poData;
    }
    
    handlePaymentTypeSelected(event) 
    {
        this._selectedPaymentType = event.currentTarget.value;
    }

    handlePaymentButton() 
    {
        if (this.selectedPaymentType !== Constants.PaymentTypeEnum.CARDPAYMENT) 
        {
            const poInput = this.getComponent('[data-po-number]');       
            // Make sure that PO input is valid first
            if (poInput != null && !poInput.reportValidity()) 
            { 
                return;
            }

            const paymentInfo = {
                poNumber: this.purchaseOrderNumber
            };

            setPayment({
                    paymentType: this.selectedPaymentType,
                    cartId: this.cartId,
                    paymentInfo: paymentInfo
                }).then(() => {
                    // After making the server calls, navigate NEXT in the flow
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                }).catch((error) => {
                    this._purchaseOrderErrorMessage = error.body.message;
                });
        }
    }

    getCreditCardFromComponent(creditPaymentComponent) 
    {
        const cardPaymentData = {};
        [
            'cardHolderName',
            'cardNumber',
            'cvv',
            'expiryYear',
            'expiryMonth',
            'expiryYear',
            'cardType'
        ].forEach((property) => {
            cardPaymentData[property] = creditPaymentComponent[property];
        });
        return cardPaymentData;
    }

    getComponent(locator) 
    {
        return this.template.querySelector(locator);
    }

    dispatchCustomEvent(eventName, detail) {
        this.dispatchEvent(
            new CustomEvent(eventName, {
                bubbles: false,
                composed: false,
                cancelable: false,
                detail
            })
        );
    }
}