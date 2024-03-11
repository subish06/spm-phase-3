import { LightningElement, api } from 'lwc';
import getUserInfo from '@salesforce/apex/XC_UserController.getUserInfo';
import changeView from '@salesforce/apex/XC_UserController.changeView';

export default class XcCustomerViewToggleProductDetail extends LightningElement {

    @api userInfo;
    @api buttonText;

    connectedCallback() {
        getUserInfo()
        .then((result) => {
            console.log('result', result);  
            this.userInfo = result;
            this.buttonText = result.CustomerView__c ? 'Dealer View' : 'Customer View';
        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleClick(){
        changeView({customerView: !this.userInfo.CustomerView__c})
        .then((result) => {
            console.log(result);
            location.reload(); 
        })
        .catch((error) => {
            console.log(error);
        });
    }
}