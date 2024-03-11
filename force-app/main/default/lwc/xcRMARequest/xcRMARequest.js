import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import RMAButtonLabel from '@salesforce/label/c.XC_RMAButtonLabel';
import RMACreateButtonLabel from '@salesforce/label/c.XC_RMACreateButtonLabel';
import RMAModalHeader from '@salesforce/label/c.XC_RMAModalHeader';
import RMAReasonDropdownLabel from '@salesforce/label/c.XC_RMAReasonDropdownLabel';
import ReturnSubjectToReview from '@salesforce/label/c.XC_ReturnSubjectToReview';

import getOrderData from '@salesforce/apex/XC_RMARequestController.getOrderData';
import createRMA from '@salesforce/apex/XC_RMARequestController.createRMA';

export default class XcRMARequest extends LightningElement 
{
    labels = {
        RMAButtonLabel,
        RMAModalHeader,
        RMACreateButtonLabel,
        RMAReasonDropdownLabel,
        ReturnSubjectToReview
    };

    @api orderSummId;
    showModal = false;
    showSpinner = false;
    returnReason = '';
    showReturnDisclaimer = false;

    rmaOptions = [];
    order = {};
    orderItems = [];

    toggleModal()
    {
        let newBool = !this.showModal;

        if(newBool)
        {
            this.getOrderData();
        }
        
        this.showModal = newBool;
    }

    getOrderData()
    {
        this.showSpinner = true;

        getOrderData({
            orderSummId : this.orderSummId
        })
        .then((result) => {
            console.log(result);
            this.order = result.order;
            this.orderItems = result.order.OrderItemSummaries;
            this.showReturnDisclaimer = result.showReturnDisclaimer;
            this.buildRMAReasonsPicklist(result.rmaReasons);

            console.log(this.order);
            console.log(this.orderItems);
            if(result.error)
            {

            }
            else
            {
                
            }
            this.showSpinner = false;
        })
        .catch((error) => {
            this.showSpinner = false;
        });
    }

    buildRMAReasonsPicklist(rmaReasons)
    {
        let rmaOptions = [];
        let keySet = Object.keys(rmaReasons);

        for(let i = 0; i < keySet.length; i++)
        {
            rmaOptions.push({label: rmaReasons[keySet[i]], value: keySet[i]});
        }
        console.log(rmaOptions);
        //this.returnReason = rmaOptions[0].value;
        this.rmaOptions = rmaOptions;
    }

    handleRMAOptionChange(event)
    {
        // this.accountInfo.state = '';
        // this.accountInfo.country = event.detail.value;
        console.log(event.detail.value);
        this.returnReason = event.detail.value;
    }

    handleQtyChange(event)
    {
        console.log(event.target.dataset.max);
        if(event.detail.value > event.target.dataset.max)
        {
            event.detail.value = event.target.dataset.max;
            this.template.querySelector('[data-id="' + event.target.dataset.id + '"]').value = event.target.dataset.max;
            console.log('changed');
            console.log(event.detail.value);
            console.log(this.template.querySelector('[data-id="' + event.target.dataset.id + '"]').value);
        }
        if(event.detail.value > 0)
        {
            this.showNoQtyMessage = false;
        }
        //console.log(event.target.dataset.max);
        //console.log(event.detail.dataset.max);
    }

    checkRMAData()
    {
        let inputFields = this.template.querySelectorAll('.qtyInput');
        let hasQty = false;
        let qtyMap = {};

        for(let i = 0; i < inputFields.length; i++)
        {
            let curQty = inputFields[i].value;
            if(curQty > 0)
            {
                hasQty = true;
                qtyMap[inputFields[i].dataset.id] = curQty;
            }
            // console.log(inputFields[i].value);
            // console.log(inputFields[i].dataset.id);
        }

        if(!hasQty)
        {
            this.showToast('', 'No quantity entered', 'error');
            console.log('no');
        }
        else if(!this.returnReason)
        {
            this.showToast('', 'Select a return reason', 'error');
        }
        else
        {
            console.log('yes');
            this.createRMA(qtyMap);
        }
        console.log(qtyMap);
    }

    createRMA(dataMap)
    {
        this.showSpinner = true;
        createRMA({
            orderSummId : this.orderSummId,
            qtyMap : dataMap,
            returnReason : this.returnReason
        })
        .then((result) => {
            console.log(result);
            
            if(result.error)
            {
                this.showToast('', 'Server call failed', 'error');
            }
            else
            {
                this.showToast('', 'RMA submitted', 'success');
                this.showModal = false;
            }
            this.showSpinner = false;
        })
        .catch((error) => {
            this.showToast('', 'Server call failed', 'error');
            this.showSpinner = false;
        });
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