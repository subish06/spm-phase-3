import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';

import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import communityId from '@salesforce/community/Id';
import getInitData from '@salesforce/apex/XC_CheckoutButtonController.getInitData';
import deleteItems from '@salesforce/apex/XC_CheckoutButtonController.removeLowInventoryItems';
//import saveCartOrderType from '@salesforce/apex/XC_CheckoutButtonController.saveCartOrderType';

import CartCreditHold from '@salesforce/label/c.XC_CartCreditHold';
import CartCheckoutButtonLabel from '@salesforce/label/c.XC_CartCheckoutButtonLabel';



const CHECKOUT_URL_PREFIX = '/checkout/';
const CART_URL_PREFIX = '/cart/';

export default class XcCheckoutButton extends NavigationMixin(LightningElement) 
{
    labels = {
        CartCreditHold,
        CartCheckoutButtonLabel
    };

    @api cartId;
    @api effectiveAccountId;
    cartChangeSub = null;

    @wire(MessageContext)
    messageContext;

    canPreOrder = false;
    showCheckout = false;
    showBlockLabel = false;
    orderType = '';
    preOrderCheckBox = false;
    isModalOpen = false;
    wanringMessage = '';
    warningMessage2 = "Continuing with checkout will remove these items from your cart. Click 'Cancel' to return to your cart.";
    warningHeader = '';
    showContinueCheckout = false;
    nonPreOrderItems = '';
    unavailableQtyItems = '';
    hasNonPreOrderItems = false;
    hasNonAvailItems = false;

    renderedCallback() {
        if (this.template.querySelector('[data-id="checkbox"]')) {
            this.template.querySelector('[data-id="checkbox"]').checked = this.preOrderCheckBox;
        }
    }

    connectedCallback()
    {
        this.subscribeToMessageChannel();
        this.getInitData();
    }

    disconnectedCallback() 
    {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() 
    {
        if (!this.cartChangeSub) {
            this.cartChangeSub = subscribe(
                this.messageContext,
                cartChanged,
                (message) => this.getInitData(),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() 
    {
        unsubscribe(this.cartChangeSub);
        this.cartChangeSub = null;
    }

    removeItems(){
        deleteItems({
            cartId : this.cartId
        })
        .then((result) => {
            //window.location = CHECKOUT_URL_PREFIX + this.cartId.slice(0,15);
            console.log('result: ' + result);
            if(result > 0){
                let url = CHECKOUT_URL_PREFIX + this.cartId.slice(0,15);
                this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: url
                        }
                    },false
                );                
            }else{
                let url = CART_URL_PREFIX + this.cartId.slice(0,15);
                this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: url
                        }
                    },false
                );                
            }
            
        })
        .catch((error) => {
            
        });

    }

    /*saveOrderTypeSetting(){
        let orderType = (this.preOrderCheckBox ? 'Pre-Order' : 'Standard');
        saveCartOrderType({cartId : this.cartId, orderType: orderType})
        .then((result) => {
            if(!this.canPreOrder && this.hasNonAvailItems){
                this.warningLowInventory();
            }else{
                this.proceedToCheckout();
            }
        })
        .catch((error) => {
            this.showToast('Error', 'Server call failed', 'error');
        });
        
    }*/

    getInitData()
    {
        this.showCheckout = false;
        getInitData({
            cartId : this.cartId,
            effectiveAccountId : this.effectiveAccountId,
            communityId : communityId
        })
        .then((result) => {
            console.log('result: ' + JSON.stringify(result));
            if(result.error)
            {
                this.showCheckout = false;
                this.showBlockLabel = false;
                this.showToast('Error', 'Server call failed', 'error');
            }
            else
            {
                this.showCheckout = result.allowCheckout ? true : false;
                this.showBlockLabel = result.showCreditHold ? true : false;
                //this.canPreOrder = result.preorder;
                //this.orderType = result.orderType;
                //this.preOrderCheckBox = (this.orderType == 'Pre-Order' ? true : false);
                //this.nonPreOrderItems = result.nonPreOrderItems;
                this.unavailableQtyItems = result.unavailableQtyItems;
                //this.hasNonPreOrderItems = result.hasNonPreOrderItems;
                this.hasNonAvailItems = result.hasNonAvailItems;
               
            }
        })
        .catch((error) => {
            this.showCheckout = false;
            this.showBlockLabel = false;
            this.showToast('Error', 'Server call failed', 'error');
        });
    }

    handlePreOrder(event){
        this.preOrderCheckBox = event.target.checked;
    }

    handleCheckOut(event){
        /*let cartPreOrder = (this.orderType == 'Pre-Order' ? true : false);
        if(this.hasNonPreOrderItems && this.preOrderCheckBox){
            this.warningInvalidPreOrder();
        }else if(this.preOrderCheckBox != cartPreOrder && this.canPreOrder){
            this.saveOrderTypeSetting();
        }else{
            if(!this.preOrderCheckBox && this.hasNonAvailItems){
                this.warningLowInventory();
            }else{
                this.proceedToCheckout();
            }
            
        }*/

        if(this.hasNonAvailItems){
            this.warningLowInventory();
        }else{
            this.proceedToCheckout();
        }
    }

    /*warningInvalidPreOrder(){
        this.warningMessage = 'The following item(s) are not available for preorder and must be removed from the cart to continue placing a preorder: ' + this.nonPreOrderItems;
        this.warningHeader = 'Invalid Preorder Items';
        this.showContinueCheckout = false;
        this.isModalOpen = true;
    }*/

    warningLowInventory(){
        this.warningMessage = 'The following item(s) in your cart exceed available inventory: ' + this.unavailableQtyItems;
        this.warningHeader = 'Low Inventory Warning';
        this.showContinueCheckout = true;
        this.isModalOpen = true;
    }

    closeModal(event){
        this.isModalOpen = false;
    }

    proceedToCheckout()
    {
        this.removeItems();
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