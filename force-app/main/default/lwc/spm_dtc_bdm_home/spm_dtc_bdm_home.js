import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import TARGET_CONFIG from '@salesforce/schema/Target_Config__c';
import FINANCIAL_YEAR from '@salesforce/schema/Target_Config__c.Financial_Year__c';
import USER_ID from '@salesforce/user/Id';
import FIRST_NAME from '@salesforce/schema/User.FirstName';
import LAST_NAME from '@salesforce/schema/User.LastName';

import getBDMstats from '@salesforce/apex/DTCController.getBDMstats';
import getUserInfo from '@salesforce/apex/DTCController.getUserInfo';

import { showSuccess, showError, nFormatter, currencyFormatter } from "c/spm_utility";

export default class Spm_dtc_bdm_home extends LightningElement {

    userId = USER_ID;
    defaultYear = 'FY-23';
    financialYearPickList = [];

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
    @track respectiveBDD;
    @track showSpinner = true;
    @track overallAccountSummary = false;
    @track hideBDMEditButton = false;
    @track stats = {
        curYearTarget: '$0',
        curYearActual: '$0',
        curYearVariance: '$0',
        varianceArrow: false,
        totalAccount: '0',
        targetAchieved: '0%',
        showVarianceArrow: false,
    };
    @track hideButton = false;
    @track isPopupOpen = false;
    @track ifAccept = false;
    @track ifRevert = false;
    @track acceptDisable = false;
    @track revertDisable = false;
    @track showButton = false;
    @track ackStatus;
    @track isBdm= false;

    connectedCallback(){
        this.isBdm= true;
    }

    get firstName() {
        return getFieldValue(this.user.data, FIRST_NAME);
    }

    get lastName() {
        return getFieldValue(this.user.data, LAST_NAME);
    }

    @wire(getUserInfo, { currentUser: '$userId' })
    wireUser({ data, error }) {
        if (data) {
            this.respectiveBDD = data[0].Manager__c;
        } else if (error) {
            console.error(error);
            showError(error);
        }
    }

    @wire(getRecord, { recordId: "$userId", fields: [FIRST_NAME, LAST_NAME] })
    user;

    @wire(getObjectInfo, { objectApiName: TARGET_CONFIG })
    targetConfigMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$targetConfigMetadata.data.defaultRecordTypeId',
        fieldApiName: FINANCIAL_YEAR
    })

    wiredFY({ error, data }) {
        if (data) {
            this.financialYearPickList = data.values;
            this.fetchStats();
        } else if (error) {
            console.log('error===>', error);
            showError(error);
        }
    };

    fetchStats() {
        getBDMstats({ selYear: this.selYear })
            .then(result => {
                this.showSpinner = !this.showSpinner;
                this.currencySymbol = currencyFormatter(result.currencyVal);

                this.stats.curYearTarget = this.currencySymbol + nFormatter(result.curYearTarget, 2);
                this.stats.curYearActual = this.currencySymbol + nFormatter(result.curYearActual, 2);
                this.stats.totalAccount = result.totalAccount;
                const firstDigit = result.targetAchieved.toString().substring(0, 4);
                this.stats.targetAchieved = firstDigit + '%';

                this.stats.varianceArrow = false;
                this.stats.showVarianceArrow = false;

                if (result.curYearTarget - result.curYearActual < 0) {
                    this.stats.varianceArrow = true;
                }

                if (result.curYearVariance != null && result.curYearVariance < 0) {
                    this.stats.curYearVariance = this.currencySymbol + nFormatter((result.curYearVariance * (-1)), 2);
                }
                else if (result.curYearVariance != null && result.curYearVariance > 0) {
                    this.stats.curYearVariance = this.currencySymbol + nFormatter(result.curYearVariance, 2);
                }

                if (result.curYearTarget != result.curYearActual) {
                    this.stats.showVarianceArrow = true;
                }
            })
            .catch(error => {
                console.error('error====>', error);
                showError(error);
            });
    }

  

    handleChildEvntMonthSummary(event) {
        const childMessage = event.detail;
    }

    handleFYChange(event) {
        this.selYear = event.target.value;
        this.showSpinner = !this.showSpinner;
        this.fetchStats();
      
    }

    handleOverallAccountSummary() {
        this.overallAccountSummary = !this.overallAccountSummary;
        this.hideBDMEditButton = !this.hideBDMEditButton;
    }

    handleComments(event) {
        this.commentText = event.target.value
    }

    acceptPopup() {
        this.isPopupOpen = true;
        this.ifAccept = true;
        this.ifRevert = false;
    }

    revertPopup() {
        this.isPopupOpen = true;
        this.ifAccept = false;
        this.ifRevert = true;
    }

    closePopup() {
        this.isPopupOpen = false;
    }
}