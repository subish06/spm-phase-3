import { LightningElement, api, track } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import * as Constants from './constants';

import getPaymentInfo from '@salesforce/apex/XC_CheckoutPaymentController.getPaymentInfo';
import setPayment from '@salesforce/apex/XC_CheckoutPaymentController.setPayment';
import getBilingAddress from '@salesforce/apex/XC_CheckoutShippingAddressController.getBillingAddresses';
// import payAmount from '@salesforce/apex/XC_StripeController.payAmount';
//import activateOrder from '@salesforce/apex/XC_StripeController.activateOrder';

import getContactPointAddressList from '@salesforce/apex/XC_CheckoutShippingAddressController.getContactPointAddressList';


export default class XcCheckoutPayment extends LightningElement {
    // Private attributes
    _creditCardErrorMessage;
    _purchaseOrderErrorMessage = '';
    _cartId;
    _purchaseOrderNumber;
    _selectedPaymentType = Constants.PaymentTypeEnum.PONUMBER;
    options = [];
    billingAccountId = '';
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
    typeOfAddress = 'Billing'; // Added by ashwin
    isSubmitOrderDisable = true;// Added by ashwin
    isLatam = false; // Added by Sangeet
    accountId; // Added by Sangeet
    billingAddressId;
    get labels() {
        return Constants.labels;
    }

    @api
    get selectedPaymentType() {
        return this._selectedPaymentType;
    }

    set selectedPaymentType(newPaymentType) {
        this._selectedPaymentType = newPaymentType;
    }

    @api
    get purchaseOrderNumber() {
        return this._purchaseOrderNumber;
    }

    set purchaseOrderNumber(newNumber) {
        this._purchaseOrderNumber = newNumber;
    }


    @api
    get cartId() {
        return this._cartId;
    }

    set cartId(cartId) {
        this._cartId = cartId;
        if (cartId) {
            this.initializePaymentData(cartId);
            this.getBillingAddressData(cartId);
        }
    }

    get canGoPrevious() {
        return (this.availableActions && this.availableActions.some(element => element == 'BACK'));
    }

    /**
     * Gets the payment types
     * PO Number or Card Payment
     */
    get paymentTypes() {
        return {
            poNumber: Constants.PaymentTypeEnum.PONUMBER,
            cardPayment: Constants.PaymentTypeEnum.CARDPAYMENT
        };
    }

    get isCardPaymentSelected() {
        return (this.actualSelectedPaymentType === Constants.PaymentTypeEnum.CARDPAYMENT && this.showCreditCard);
    }

    get isPoNumberSelected() {
        return (this.actualSelectedPaymentType === Constants.PaymentTypeEnum.PONUMBER && !this.hidePurchaseOrder);
    }

    get actualSelectedPaymentType() {
        return this.hidePurchaseOrder ? Constants.PaymentTypeEnum.CARDPAYMENT : (!this.showCreditCard ? Constants.PaymentTypeEnum.PONUMBER : this._selectedPaymentType);
    }




    initializePaymentData(cartId) {
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

    getBillingAddressData(cartId) {

        console.log('callingBillingAddressMethod' + cartId);
        getBilingAddress({ cartId: cartId }).then((result) => {
            let options = [];
            this.billingAccountId = result.billingAddressList[0].Id.slice(0, 15);
            // Below Code Commented by ashwin
            // this.selectedBillingAddress = this.billingAccountId;

            // for (let i = 0; i < result.billingAddressList.length; i++) {
            //     let curAcc = result.billingAddressList[i];
            //     let addressLabel = '';
            //     if (curAcc.Name) {
            //         addressLabel += curAcc.Name + ': ';
            //     }
            //     if (curAcc.BillingStreet) {
            //         addressLabel += curAcc.BillingStreet + ', ';
            //     }
            //     if (curAcc.BillingCity) {
            //         addressLabel += curAcc.BillingCity + ', ';
            //     }
            //     if (curAcc.BillingStateCode) {
            //         addressLabel += curAcc.BillingStateCode + ' ';
            //     }
            //     if (curAcc.BillingPostalCode) {
            //         addressLabel += curAcc.BillingPostalCode + ' ';
            //     }
            //     if (curAcc.BillingCountryCode) {
            //         addressLabel += curAcc.BillingCountryCode;
            //     }
            //     options.push({ value: curAcc.Id.slice(0, 15), label: addressLabel });
            // }

            //Changes made by Sangeet
            this.isLatam = result.isLatam;
            console.log('latam :', this.isLatam);
            this.accountId = result.accountId;
            if (this.isLatam) {
                getContactPointAddressList({
                    accId: this.accountId,
                    addrType: this.typeOfAddress
                })
                    .then((result) => {
                        //update: Sangeet
                        try {
                            console.log('result :', result);
                            var deladdress = '';
                            result.map((ele) => {
                                deladdress = '';
                                deladdress = ele.Name;
                                if (typeof ele.Address.street != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = ele.Address.street;
                                    } else {
                                        deladdress = deladdress + ', ' + ele.Address.street;
                                    }
                                }
                                if (typeof ele.Address.city != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = ele.Address.city;
                                    } else {
                                        deladdress = deladdress + ', ' + ele.Address.city;
                                    }
                                }
                                if (typeof ele.Address.state != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = ele.Address.state;
                                    } else {
                                        deladdress = deladdress + ', ' + ele.Address.state;
                                    }
                                }
                                if (typeof ele.Address.postalCode != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = ele.Address.postalCode;
                                    } else {
                                        deladdress = deladdress + ', ' + ele.Address.postalCode;
                                    }
                                }
                                if (typeof ele.Address.country != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = ele.Address.country;
                                    } else {
                                        deladdress = deladdress + ', ' + ele.Address.country;
                                    }
                                }
                                console.log('deladdress:', deladdress);
                                options.push({ value: ele.Id, label: deladdress });
                            });
                            this.options = options;
                        } catch (error) {
                            console.log('error : ', error);
                        }

                    }).catch((error) => {
                        console.log('Exception in getBillingAddressList ', error)
                    });
            }
            else {
                var curAcc = result.billingAddressList[0];
                var deladdress = '';
                deladdress = curAcc.Name;
                if (typeof curAcc.BillingStreet != "undefined") {
                    if (deladdress == '') {
                        deladdress = curAcc.BillingStreet;
                    } else {
                        deladdress = deladdress + ', ' + curAcc.BillingStreet;
                    }
                }
                if (typeof curAcc.BillingCity != "undefined") {
                    if (deladdress == '') {
                        deladdress = curAcc.BillingCity;
                    } else {
                        deladdress = deladdress + ', ' + curAcc.BillingCity;
                    }
                }
                if (typeof curAcc.BillingState != "undefined") {
                    if (deladdress == '') {
                        deladdress = curAcc.BillingState;
                    } else {
                        deladdress = deladdress + ', ' + curAcc.BillingState;
                    }
                }
                if (typeof curAcc.BillingPostalCode != "undefined") {
                    if (deladdress == '') {
                        deladdress = curAcc.BillingPostalCode;
                    } else {
                        deladdress = deladdress + ', ' + curAcc.BillingPostalCode;
                    }
                }
                if (typeof curAcc.BillingCountry != "undefined") {
                    if (deladdress == '') {
                        deladdress = curAcc.BillingCountry;
                    } else {
                        deladdress = deladdress + ', ' + curAcc.BillingCountry;
                    }
                }
                options.push({ value: curAcc.Id, label: deladdress });
                this.options = options;
            }


            /*commented by Sangeet
            // Apex Class Called by ashwin
            getContactPointAddressList({
                accId: this.billingAccountId,
                addrType: this.typeOfAddress
            })
                .then((result) => {

                    result.map((ele) => {
                        options.push({ value: ele.Id, label: ele.Name + ': ' + ele.Address.street + ', ' + ele.Address.city + ', ' + ele.Address.stateCode + ' ' + ele.Address.postalCode + ' ' + ele.Address.countryCode });
                    });

                    this.options = options;


                }).catch((e) => {

                    console.error('Exception in getShippingAddressList ', JSON.stringify(error))
                }); */
        }).catch((error) => {
            console.log(error.body.message);
        })
    }

    // Below Code Commented by ashwin
    // billingAddressChanged(event) {

    // this.billingAccountId = event.target.value.slice(0, 15);
    //  this.selectedBillingAddress = this.billingAccountId;
    // }


    handleUpdate() {
        const poComponent = this.getComponent('[data-po-number]');
        const poData = (poComponent.value || '').trim();
        this._purchaseOrderNumber = poData;
    }

    handlePaymentTypeSelected(event) {
        this._selectedPaymentType = event.currentTarget.value;
    }

    handlePaymentButton() {
        if (this.selectedPaymentType !== Constants.PaymentTypeEnum.CARDPAYMENT) {





            const poInput = this.getComponent('[data-po-number]');
            // Make sure that PO input is valid first
            if (poInput != null && !poInput.reportValidity()) {
                return;
            }

            const paymentInfo = {
                poNumber: this.purchaseOrderNumber
            };

            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                paymentInfo: paymentInfo,
                conPointBillAddrId: this.billingAddressId
            }).then(() => {
                // After making the server calls, navigate NEXT in the flow
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this._purchaseOrderErrorMessage = error.body.message;
            });
        }
    }

    // initiatePayment(){
    //             payAmount().then((data) => {
    //                 let result = JSON.parse(data);
    //                 window.location.href = result.url;
    //             }).catch((error) => {
    //                 console.log('Error====> ', JSON.stringify(error));
    //             });


    // }

    getCreditCardFromComponent(creditPaymentComponent) {
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

    getComponent(locator) {
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

    billingAddressOnChanged(event) {
        this.billingAddressId = event.target.value;

        if (this.billingAddressId) {
            this.isSubmitOrderDisable = false;
            this.selectedBillingAddress = this.billingAddressId;

            //this.contactPointAddressId = this.shippingAccountId;
        }

    }
}