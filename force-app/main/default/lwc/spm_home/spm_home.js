import { LightningElement, wire, api, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/SPMController.getUserInfo';
import { showError } from "c/spm_utility";

export default class Spm_home extends LightningElement {
    userId = USER_ID;
    // @api currentUser;
    // connectedCallback(){
    //     console.log('currentUser', this.currentUser);
    //     console.log('userId', this.userId);
    // }

    // get recordId() {
    //     return this.currentUser ? this.currentUser : this.userId;
    // }

    showBDD = false;
    showAdmin = false;
    showDTC = false;
    showDTCBDM = false;
    renderHome = false;

    @wire(getUserInfo, { currentUser: '$userId' })
    wireUser({ data, error }) {
        if (data) {
            this.showBDD = (data[0].Role__c == "BDD");
            this.showAdmin = (data[0].Role__c == "Admin");
            this.showDTC = (data[0].Role__c == "DTC BDD");
            this.showDTCBDM = (data[0].Role__c == "DTC BDM");
            this.renderHome = (data[0].Role__c == "BDD" || data[0].Role__c == "BDM" || data[0].Role__c == 'Admin' || data[0].Role__c == "DTC BDD" || data[0].Role__c == "DTC BDM");
        } else if (error) {
            console.error(error);
            showError(error);
        }
    }

}