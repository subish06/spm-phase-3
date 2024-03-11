import { LightningElement, wire, track } from 'lwc';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import USER_ID from '@salesforce/user/Id';
import FIRST_NAME from '@salesforce/schema/User.FirstName';
import LAST_NAME from '@salesforce/schema/User.LastName';

import TARGET_CONFIG from '@salesforce/schema/Target_Config__c';
import FINANCIAL_YEAR from '@salesforce/schema/Target_Config__c.Financial_Year__c';

import getBDDStats from '@salesforce/apex/SPMController.getBDDStats';


import { loadStyle } from 'lightning/platformResourceLoader';
import fileSelectorStyles from '@salesforce/resourceUrl/fileSelectorStyles';

import { showError, showSuccess, nFormatter, currencyFormatter } from "c/spm_utility";


export default class Spm_admin_home extends LightningElement {

    userId = USER_ID;
    financialYearPickList = [];
    BDDList = [];
    
    // @track selYear = 'FY-' + this.nextYear.toString().substring(2, 4);
    @track nextYear = new Date().getFullYear() + 1;
    @track selYear = (() => {
        const nextYearDate = new Date(this.nextYear, 0); // Creating a Date object for the next year
        const isBetweenJanAndMar = nextYearDate.getMonth() >= 0 && nextYearDate.getMonth() <= 2;
        return isBetweenJanAndMar
            ? 'FY-' + (parseInt(this.nextYear.toString().substring(2, 4)) - 1)
            : 'FY-' + this.nextYear.toString().substring(2, 4);
    })();
    @track currencySymbol = '$';
    @track selectedBdd ;
    @track isEditDisable = false;

    
    connectedCallback() {
        this.fetchBDDStats();
        this.isEditDisable = true;
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, fileSelectorStyles)
        ]);
    }

    @wire(getRecord, { recordId: "$userId", fields: [FIRST_NAME, LAST_NAME] })
    user;

    @wire(getObjectInfo, { objectApiName: TARGET_CONFIG })
    targetConfigMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$targetConfigMetadata.data.defaultRecordTypeId',
        fieldApiName: FINANCIAL_YEAR
    })
    wiredFY({ data, error }) {
        if (data) {
            this.financialYearPickList = data.values;
        } else if (error) {
            console.log('error===>', error);
            showError(error.message);
        }
    };

    get firstName() {
        return getFieldValue(this.user.data, FIRST_NAME);
    }

    get lastName() {
        return getFieldValue(this.user.data, LAST_NAME);
    }

    get managerList() {
        this.BDDList = this.BDDList.map((bdd) => {
            return {
                ...bdd,
                class: bdd.userId === this.selectedBdd ? 'slds-p-around_medium card card-selected row' : 'slds-p-around_medium card card-unselected row',
                isBDDSelected: bdd.userId === this.selectedBdd,
                displayArrow: (bdd.varianceAmount != this.currencySymbol + '0.00'),
                varianceArrow: (bdd.target - bdd.actual) < 0 ? true : false
            };
        });
        return this.BDDList;
    }

    fetchBDDStats() {
        getBDDStats({ financialYear: this.selYear })
            .then(data => {

                this.BDDList = [];
                for (var i in data) {
                    var varianceAmount = data[i].targetAmount - data[i].actualAmount;
                    if (varianceAmount < 0 && varianceAmount != null) {
                        varianceAmount *= -1;
                    }

                    this.BDDList.push({
                        userId: data[i].userId,
                        name: data[i].name,
                        url: data[i].url,
                        targetAmount: this.currencySymbol + (nFormatter(data[i].targetAmount, 2)),
                        actualAmount: this.currencySymbol + nFormatter(data[i].actualAmount, 2),
                        varianceAmount: this.currencySymbol + nFormatter(varianceAmount, 2),
                        actual: data[i].actualAmount,
                        target: data[i].targetAmount,
                        variance: data[i].varianceAmount,
                    });
                }

                this.BDDList.sort((a, b) => {
                    return b.target - a.target;
                });

                if (this.BDDList.length > 0) {
                    this.selectedBdd = this.BDDList[0].userId;
                    this.userName = this.BDDList[0].name;
                }
            })
    }

    handleClick(event) {
        this.selectedBdd = event.currentTarget.dataset.userId;
        this.userName = event.currentTarget.dataset.userName;
    }

    handleFYChange(event) {
        this.selYear = event.target.value;
        this.fetchBDDStats();
    }
}