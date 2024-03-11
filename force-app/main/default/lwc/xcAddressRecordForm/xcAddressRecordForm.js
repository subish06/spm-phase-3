import { LightningElement, track } from 'lwc';

export default class XcAddressRecordForm extends LightningElement {


    @track street = '';
    @track city = '';
    @track state = '';
    @track postalCode = '';

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

    handleSave() {
        // Perform save logic here, e.g., call an Apex method or dispatch an event
        // to notify parent components.
    }
}