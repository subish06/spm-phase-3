import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class XcInvoice extends NavigationMixin(LightningElement) 
{
    @api invoice = {};

    showPayment = false;
    paymentLabel = 'Pay Invoice';
    paidStatus = 'Payment Pending';

    get isPaid()
    {
        let paid = false;
        if(this.invoice.XC_Status__c == 'Paid'){
            this.paidStatus = 'Invoice Paid';
            paid = true;
        }else if(this.invoice.XC_Payment_Id__c){
            this.paidStatus = 'Payment Pending';
            paid = true;
        }
        return paid;
    }

    get hasLinkedOrder()
    {
        return this.invoice.XC_OrderSummary__c != null;
    }

    get totalCost()
    {
        return this.invoice.XC_Total__c ? this.invoice.XC_Total__c : 0.00;
    }

    get miscCost()
    {
        return this.invoice.XC_Misc__c ? this.invoice.XC_Misc__c : 0.00;
    }

    get cc225Cost()
    {
        return this.invoice.XC_CC225Percent__c ? this.invoice.XC_CC225Percent__c : 0.00;
    }

    get taxCost()
    {
        return this.invoice.XC_Tax__c ? this.invoice.XC_Tax__c : 0.00;
    }

    get freightCost()
    {
        return this.invoice.XC_Freight__c ? this.invoice.XC_Freight__c : 0.00;
    }

    get discountCost()
    {
        return this.invoice.XC_TotalDiscount__c ? this.invoice.XC_TotalDiscount__c : 0.00;
    }

    navToOrderSummary(event)
    {
        this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.invoice.XC_OrderSummary__c,
                    objectApiName: 'OrderSummary',
                    actionName: 'view'
            }
        });
    }

    togglePayment()
    {
        //console.log(this.invoice.XC_ShipTo__c);
        this.showPayment = !this.showPayment;
        //console.log(this.paymentLabel);
        //console.log(this.paymentLabel == 'Pay Invoice');
        this.paymentLabel = this.paymentLabel == 'Pay Invoice' ? 'Cancel' : 'Pay Invoice';
    }
}