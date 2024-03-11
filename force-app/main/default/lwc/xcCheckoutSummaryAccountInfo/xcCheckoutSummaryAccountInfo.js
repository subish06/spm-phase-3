import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import CREDIT_AVAILABLE_FIELD_NAME from '@salesforce/schema/Account.XC_CreditAvailable__c';

export default class XcCheckoutSummaryAccountInfo extends LightningElement 
{
    @api accountId;

    hasData = false;
    availableCredit = 0;

    @wire(getRecord, { recordId: '$accountId', fields: [CREDIT_AVAILABLE_FIELD_NAME] })
    wiredRecord({ error, data }) 
    {
        if (error) 
        {
            this.hasData = false;
            //error handling?
        } 
        else if (data) 
        {
            
            if(data.fields)
            {
                if(data.fields[CREDIT_AVAILABLE_FIELD_NAME.fieldApiName].value)
                {
                    this.availableCredit = data.fields[CREDIT_AVAILABLE_FIELD_NAME.fieldApiName].value;
                    this.hasData = true;
                }
                else
                {
                    this.hasData = false;
                }
            }
            else
            {
                this.hasData = false;
            }
        }
    }
}