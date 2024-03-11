import { LightningElement, wire } from 'lwc';
import getCurrentUser from '@salesforce/apex/XC_CustomUserDetailController.getCurrentUser';

export default class XcCustomUserDetails extends LightningElement {


    currentUser;
    userName;

    @wire(getCurrentUser)
    wiredCurrentUser({ data, error }) {
        if (data) {
            this.currentUser = data;
            this.userName = this.currentUser.Name;
        } else if (error) {
            // Handle error if needed
        }
    }

}