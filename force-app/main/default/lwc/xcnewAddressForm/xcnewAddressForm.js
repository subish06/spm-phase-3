import { LightningElement, track } from 'lwc';

export default class AddressForm extends LightningElement {
    @track street;
    @track city;
    @track state;
    @track postalCode;

    handleStreetChange(event) {
        this.street = event.target.value;
    }

    handleCityChange(event) {
        this.city = event.target.value;
    }

    handleStateChange(event) {
        this.state = event.target.value;
    }

    handlePostalCodeChange(event) {
        this.postalCode = event.target.value;
    }

    saveAddress() {
        // Perform the necessary operations to save the address
        // Call an Apex method or perform any client-side logic
        // to handle the address data and store it in the "Address" object
    }
}