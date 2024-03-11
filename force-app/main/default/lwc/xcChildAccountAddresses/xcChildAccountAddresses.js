import { LightningElement, api, track } from 'lwc';
import getAccountDetails from '@salesforce/apex/xc_GetChildAccountDetail.getChildAccountAddress';
import { NavigationMixin } from "lightning/navigation";
import userId from '@salesforce/user/Id';

const columns = [
    { label: 'Account Name', fieldName: 'accountName', },
    { label: 'Billing Address', fieldName: 'billingAddress',wrapText: true },
    { label: 'Shipping Address', fieldName: 'shippingAddress', wrapText: true,}
];

export default class XcChildAccountAddresses extends NavigationMixin( LightningElement ) {
    @api effectiveAccountId;
    @track data;
    @track dataExist = false;
    columns = columns;
    @track siteURL = '';

    connectedCallback()
    {
        this.getChildAccountAddress();
    }

    getChildAccountAddress(){
        getAccountDetails({
            accId: this.effectiveAccountId
        })
        .then((result) => {
            console.log('Result = ' + JSON.stringify(result));
            this.data = result;
            if(this.data.length > 0){
                this.dataExist = true;
            }
        })
        .catch((e) => {
            console.log(e);
        });
    }

    handleChangePassword(){
        let url = window.location.origin;
        url += '/AllAxcess/s/settings/home';
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: url
            }
	    };
        this[NavigationMixin.Navigate](config);
    }

}