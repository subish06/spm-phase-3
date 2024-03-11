import { LightningElement, api, wire } from 'lwc';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UpdateAddress from '@salesforce/apex/XC_AddressController.UpdateAddress';




export default class XcAddressRecordModal extends LightningElement {







    @api typeOfAddress;

    @api selectedAddress;

    addressDataToUpdate = {};


    connectedCallback() {
        this.addressDataToUpdate.Id = this.selectedAddress.Id;
    }


    handleUpdateAddress() {



        UpdateAddress({
                addressData: this.addressDataToUpdate
            })
            .then((data) => {
                if (data) {



                    this.handleCloseModal();

                    eval("$A.get('e.force:refreshView').fire();");

                    this.handleShowToast('', 'Address Updated Successfully !', 'success');

                }

            }).catch((e) => {
                console.error('Exception in UpdateAddress ', JSON.stringify(e))
            });
    }

    handleCloseModal() {

        const customEvent = new CustomEvent('closemodalevent');
        this.dispatchEvent(customEvent)


    }

    handleAddressFieldsOnChange(event) {

        let field = event.currentTarget.dataset.field;

        let val = event.target.value;


        if (field == 'street') {
            this.addressDataToUpdate.street = val;

        } else if (field == 'city') {
            this.addressDataToUpdate.city = val;
        } else if (field == 'state') {
            this.addressDataToUpdate.state = val;
        } else if (field == 'zip') {
            this.addressDataToUpdate.zip = val;
        } else if (field == 'country') {
            this.addressDataToUpdate.country = val;
        }




    }

    handleShowToast(title, msg, variant) {

        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);

    }



}