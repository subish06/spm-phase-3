import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
// import { getRecord } from 'lightning/uiRecordApi';

// import REQUESTED_SHIP_DATE_FIELD_NAME from '@salesforce/schema/WebCart.XC_RequestedShipDate__c';

import getShippingAddresses from '@salesforce/apex/XC_CheckoutShippingAddressController.getShippingAddresses';
import getContactPointAddressList from '@salesforce/apex/XC_CheckoutShippingAddressController.getContactPointAddressList';
import createNewCPA from '@salesforce/apex/XC_CheckoutShippingAddressController.createNewCPA';


export default class XcCheckoutShippingAddress extends LightningElement {
    @api requestedShipDate;
    @api cartId;
    @api shippingAccountId;
    @api shippingInstructions;
    @api test;
    @api contactPointAddressId;
    showHideAddrModal = false;
    typeOfAddress = 'Shipping';
    accountId;
    disableEditButton = true;

    hasDelDate = false;
    hasShipAddress = false;
    options = [];
    minDate;
    maxDate;
    orderType;
    addressData = [];
    selectedAddress;

    //changes made by Sangeet
    isLatam = false;

    get hasData() {
        if (this.hasDelDate == true && this.hasShipAddress == true) {
            return true;
        } else {
            return false;
        }
    }

    get todayDate() {
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

    connectedCallback() {
        this.getShippingData();
    }

    getShippingData() {
        getShippingAddresses({
            cartId: this.cartId
        })
            .then((result) => {
                console.log(result);
                this.orderType = result.orderType;
                let startOfSeasonDate = result.startOfSeasonDate;
                let todayD = this.getToday();
                console.log('todayD: ' + todayD);
                console.log('result.requestDeliveryDate: ' + result.requestDeliveryDate);
                let requestDeliveryDate = (result.requestDeliveryDate ? result.requestDeliveryDate : this.getToday());
                this.accountId = result.accountId;

                console.log('requestDeliveryDate: ' + requestDeliveryDate);
                console.log('requestDeliveryDate: ' + requestDeliveryDate);

                if (this.orderType == 'Pre-Order' && startOfSeasonDate) {

                    this.requestedShipDate = (this.returnDate(requestDeliveryDate) < this.returnDate(startOfSeasonDate) ? startOfSeasonDate : requestDeliveryDate);
                    this.minDate = startOfSeasonDate;
                } else {
                    this.minDate = this.getToday();
                    this.requestedShipDate = this.getToday();
                }

                this.shippingAccountId = result.shippingAddressList[0].Id; //.slice(0, 15);
                var AccShippingAddressList = result.shippingAddressList[0];
                if (result.shippingInstructions) {
                    this.shippingInstructions = result.shippingInstructions;
                }

                let options = [];

                this.isLatam = result.islatam;
                if (this.isLatam) {
                    getContactPointAddressList({
                        accId: this.accountId,
                        addrType: this.typeOfAddress
                    })
                        .then((result) => {
                            //update: Sangeet
                            if (result != null) {
                                var deladdress = '';
                                result.map((ele) => {
                                    deladdress = '';
                                    //deladdress = ele.Name;
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
                                    options.push({ value: ele.Id, label: deladdress });
                                    this.addressData.push({ ...ele })
                                    this.options = options;
                                    this.hasDelDate = true;
                                    this.hasShipAddress = true;
                                });

                            } else {
                                var curAcc = AccShippingAddressList;
                                var deladdress = '';
                                //deladdress = curAcc.Name;
                                if (typeof curAcc.ShippingStreet != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = curAcc.ShippingStreet;
                                    } else {
                                        deladdress = deladdress + ', ' + curAcc.ShippingStreet;
                                    }
                                }
                                if (typeof curAcc.ShippingCity != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = curAcc.ShippingCity;
                                    } else {
                                        deladdress = deladdress + ', ' + curAcc.ShippingCity;
                                    }
                                }
                                if (typeof curAcc.ShippingState != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = curAcc.ShippingState;
                                    } else {
                                        deladdress = deladdress + ', ' + curAcc.ShippingState;
                                    }
                                }
                                if (typeof curAcc.ShippingPostalCode != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = curAcc.ShippingPostalCode;
                                    } else {
                                        deladdress = deladdress + ', ' + curAcc.ShippingPostalCode;
                                    }
                                }
                                if (typeof curAcc.ShippingCountry != "undefined") {
                                    if (deladdress == '') {
                                        deladdress = curAcc.ShippingCountry;
                                    } else {
                                        deladdress = deladdress + ', ' + curAcc.ShippingCountry;
                                    }
                                }
                                console.log('deladdress:', deladdress);
                                options.push({ value: curAcc.Id, label: deladdress });
                                this.addressData.push({ ...curAcc });
                                this.options = options;
                                this.hasDelDate = true;
                                this.hasShipAddress = true;
                            }
                        }).catch((e) => {
                            console.error('Exception in getShippingAddressList ', JSON.stringify(error))
                        });
                }
                else {
                    var curAcc = result.shippingAddressList[0];
                    var deladdress = '';
                    //deladdress = curAcc.Name;
                    if (typeof curAcc.ShippingStreet != "undefined") {
                        if (deladdress == '') {
                            deladdress = curAcc.ShippingStreet;
                        } else {
                            deladdress = deladdress + ', ' + curAcc.ShippingStreet;
                        }
                    }
                    if (typeof curAcc.ShippingCity != "undefined") {
                        if (deladdress == '') {
                            deladdress = curAcc.ShippingCity;
                        } else {
                            deladdress = deladdress + ', ' + curAcc.ShippingCity;
                        }
                    }
                    if (typeof curAcc.ShippingState != "undefined") {
                        if (deladdress == '') {
                            deladdress = curAcc.ShippingState;
                        } else {
                            deladdress = deladdress + ', ' + curAcc.ShippingState;
                        }
                    }
                    if (typeof curAcc.ShippingPostalCode != "undefined") {
                        if (deladdress == '') {
                            deladdress = curAcc.ShippingPostalCode;
                        } else {
                            deladdress = deladdress + ', ' + curAcc.ShippingPostalCode;
                        }
                    }
                    if (typeof curAcc.ShippingCountry != "undefined") {
                        if (deladdress == '') {
                            deladdress = curAcc.ShippingCountry;
                        } else {
                            deladdress = deladdress + ', ' + curAcc.ShippingCountry;
                        }
                    }
                    options.push({ value: curAcc.Id, label: deladdress });
                    this.addressData.push({ ...curAcc });
                    this.options = options;
                    this.hasDelDate = true;
                    this.hasShipAddress = true;
                }
                //console.log(options);
                //this.invoiceList = result;
                console.log('this.options', this.options);
            })
            .catch((e) => {
                console.log(e);
            });
    }

    getToday() {
        let today = new Date();
        let day = today.getDate();
        let month = today.getMonth() + 1;
        let year = today.getFullYear();

        day = day < 10 ? '0' + day : day;
        month = month < 10 ? '0' + month : month;
        return year + '-' + month + '-' + day;
    }

    returnDate(myDate) {
        let tempStart = myDate;
        let arrStart = tempStart.split('-');
        let formatDate = new Date(parseInt(arrStart[0]), parseInt(arrStart[1]) - 1, parseInt(arrStart[2]));
        formatDate.setHours(0, 0, 0, 0);
        return formatDate;
    }

    getTodayPlus30() {
        let today = new Date();
        today.setDate(today.getDate() + 30);
        let day = today.getDate();
        let month = today.getMonth() + 1;
        let year = today.getFullYear();

        day = day < 10 ? '0' + day : day;
        month = month < 10 ? '0' + month : month;
        return year + '-' + month + '-' + day;
    }


    updateRequestedShipDate(event) {
        console.log('order Type: ' + this.orderType);
        if (event.target.value < this.minDate) {
            this.requestedShipDate = this.requestedShipDate;
            this.template.querySelector('.requestedShipDate').value = this.requestedShipDate;
            this.showToast('', 'Selected date is not valid, reverted back to a valid date', 'warning');
        } else if (this.orderType != 'Pre-Order' && event.target.value > this.getTodayPlus30()) {
            this.requestedShipDate = this.requestedShipDate;
            this.template.querySelector('.requestedShipDate').value = this.requestedShipDate;
            this.showToast('', 'Selected date is not valid, reverted back to a valid date', 'warning');
        } else {
            this.requestedShipDate = event.target.value;
        }
    }

    handleTextAreaOnchange(event) {
        this.shippingInstructions = event.detail.value;
    }

    shippingAddressChanged(event) {
        this.shippingAccountId = event.target.value;

        if (this.shippingAccountId) {
            this.disableEditButton = false;

            this.contactPointAddressId = this.shippingAccountId;

            this.addressData.find(ele => {
                if (ele.Id === this.contactPointAddressId) {
                    this.selectedAddress = ele;
                }
            })
        }
        console.log('selectedAddress :', this.selectedAddress);
    }

    showToast(title, message, variant) {
        let event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleOpenCloseModal(event) {
        let addressType = event.target.dataset.addressType;
        this.showHideAddrModal = this.showHideAddrModal ? false : true;
    }

    handleFlowNavigation() {
        if (this.selectedAddress.Id == this.accountId) {
            var shipAddress = {
                Name: this.selectedAddress.Name,
                City: this.selectedAddress.ShippingCity,
                Country: this.selectedAddress.ShippingCountry,
                postalcode: this.selectedAddress.ShippingPostalCode,
                state: this.selectedAddress.ShippingState,
                street: this.selectedAddress.ShippingStreet
            };
            createNewCPA({ shipAddress: shipAddress, addrType: this.typeOfAddress })
                .then(result => {
                    console.log('result :', result);
                    this.selectedAddress = result;
                    console.log('this.selectedAddress :', this.selectedAddress);
                })
                .catch(error => {
                    console.log('Error on creating CPA :', error);
                })
        }
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}