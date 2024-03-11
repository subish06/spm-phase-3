import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import generateCheckoutLink from '@salesforce/apex/TP_GenerateStripeLinkController.generateCheckoutLink';
//import isInvoicePaid from '@salesforce/apex/TP_GenerateStripeLinkController.isInvoicePaid';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import successLabel from '@salesforce/label/c.TP_Payment_Success_URL';
import errorLabel from '@salesforce/label/c.TP_Payment_Error_URL';
import paymentModalHeadingLabel from '@salesforce/label/c.TP_Payment_Modal_Heading';
import paymentModalBody1Label from '@salesforce/label/c.TP_Payment_Modal_Body1';
import paymentModalBody2Label from '@salesforce/label/c.TP_Payment_Modal_Body2';
import paymentModalBody3Label from '@salesforce/label/c.TP_Payment_Modal_Body3';
import paymentModalOkLabel from '@salesforce/label/c.TP_Payment_Modal_Ok';
import paymentModalCancelLabel from '@salesforce/label/c.TP_Payment_Modal_Cancel';
import paymentPendingHelpTextLabel from '@salesforce/label/c.TP_PendingPayment_HelpText';




export default class XcInvoice extends NavigationMixin(LightningElement)
{
    @api invoice = {};
    label = {
        successLabel,
        errorLabel,
        paymentModalHeadingLabel,
        paymentModalBody1Label,
        paymentModalBody2Label,
        paymentModalBody3Label,
        paymentModalOkLabel,
        paymentModalCancelLabel,
        paymentPendingHelpTextLabel
    };
    showPayment = false;
    isStripePage = false;
    paymentLabel = 'Pay Invoice';
    paidStatus = '';
    checkoutLink = '';
    @track isModalOpen = false;
    @track isCard = false;
    @track showCardModal = false;
    @track isPendingConfirmation = false;

    // get isPaid()
    // {
    //     let paid = false;
    //     if(this.invoice.XC_Status__c == 'Paid' || this.invoice.TP_Payment_Status__c == 'Payment Successful'){
    //         alert('11')
    //         this.paidStatus = 'Invoice Paid';
    //         paid = true;
    //     }else if(this.invoice.XC_Payment_Id__c || this.invoice.TP_Payment_Status__c == 'Payment Successful'){
    //         alert('22')
    //         this.paidStatus = 'Payment Successful';
    //         //this.isPendingConfirmation =true;
    //         paid = true;
    //     }// }else if(this.invoice.XC_Status__c != 'Paid' && this.invoice.TP_Payment_Status__c != 'Payment Successful'){
    //     //     alert('33')
    //     //     this.paidStatus = 'Pay Invoice';
    //     //     this.isPendingConfirmation =false;
    //     //     paid = false;
    //     // }

    //     return paid;
    // }

    get isPaid() {
        let paid = false;
        //console.log(this.invoice.Id);
        //console.log(this.invoice.XC_Status__c);
        //console.log(this.invoice.TP_Payment_Status__c);
        if (this.invoice.TP_Payment_Status__c == 'Payment Successful') {
            this.paidStatus = this.invoice.XC_Status__c == 'Payment In Progress' ? 'Invoice Pending' : 'Invoice Paid';
            paid = true;
        }
        if (this.invoice.XC_Status__c == 'Paid' || this.invoice.TP_Payment_Status__c == 'Payment Successful') {
            this.paidStatus = this.invoice.XC_Status__c == 'Payment In Progress' ? 'Invoice Pending' : 'Invoice Paid';
            paid = true;
        }
        // }else if(this.invoice.XC_Payment_Id__c){
        //     this.paidStatus = 'Payment Pending';
        //     paid = true;
        // }
        return paid;
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

    navToOrderSummary(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.invoice.XC_OrderSummary__c,
                objectApiName: 'OrderSummary',
                actionName: 'view'
            }
        });
    }

    togglePayment() {
        //console.log(this.invoice.XC_ShipTo__c);
        this.showPayment = !this.showPayment;
        //console.log(this.paymentLabel);
        //console.log(this.paymentLabel == 'Pay Invoice');
        this.paymentLabel = this.paymentLabel == 'Pay Invoice' ? 'Cancel' : 'Pay Invoice';
    }

    // connectedCallback(){
    //     isInvoicePaid({
    //         invoiceId: this.invoice.Id            
    //     })
    //     .then((result) => {

    //         alert(result);
    //         let invpaid =result;
    //         if(invpaid==true){
    //             this.ispaid = true;
    //         }else{
    //             this.ispaid = false;
    //         }

    //     })
    //     .catch((e) => {
    //         console.log(JSON.stringify(e));
    //         console.log('errorrrrr')
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error',
    //                 message: JSON.stringify(e),
    //                 variant: 'error',
    //                 mode: 'dismissable'
    //             })
    //         );
    //         //console.log(e);
    //     });
    // }

    handleCard() {
        this.isCard = true;
    }

    handleBankAccount() {
        this.isCard = false;
    }

    async openStripeHostedPage() {
        if (!this.showCardModal) {
            this.showCardModal = true;
            return;
        }

        this.showCardModal = false;

        this.isStripePage = !this.isStripePage;
        try {
            this.loading = true;
            this.isModalOpen = true;
            this.checkoutLink = await generateCheckoutLink({
                invoiceId: this.invoice.Id,
                isCard: this.isCard
            });
            // Navigation to web page 

            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": this.checkoutLink
                }
            });
        } catch (e) {
            this.loading = false;
            this.isModalOpen = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                //message: 'Error Ocuured with Payment Gateway.Please contact system admin',
                message: 'Error Ocuured ' + JSON.stringify(e),
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        finally {
            this.loading = false;
        }
    }

    closeCardModal() {
        this.showCardModal = false;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        location.reload();
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        location.reload();
    }


}