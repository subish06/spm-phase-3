import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import TARGET_CONFIG from '@salesforce/schema/Target_Config__c';
import FINANCIAL_YEAR from '@salesforce/schema/Target_Config__c.Financial_Year__c';

import USER_ID from '@salesforce/user/Id';
import FIRST_NAME from '@salesforce/schema/User.FirstName';
import LAST_NAME from '@salesforce/schema/User.LastName';

import getBDMTargetDist from '@salesforce/apex/DTCController.getBDMTargetDist';
import getDTCStats from '@salesforce/apex/DTCController.getDTCStats';
import saveBDMTargetConfigs from '@salesforce/apex/DTCController.saveBDMTargetConfigs';

import { showError, showSuccess, nFormatter, currencyFormatter } from "c/spm_utility";

export default class Spm_dtc_home extends LightningElement {
    userId = USER_ID;

    @track prevFY;
    @track nextYear = new Date().getFullYear() + 1;
    @track selYear = (() => {
    const nextYearDate = new Date(this.nextYear, 0); // Creating a Date object for the next year
    const isBetweenJanAndMar = nextYearDate.getMonth() >= 0 && nextYearDate.getMonth() <= 2;

    return isBetweenJanAndMar
        ? 'FY-' + (parseInt(this.nextYear.toString().substring(2, 4)) - 1)
        : 'FY-' + this.nextYear.toString().substring(2, 4);
    })();


    @track BDMList = [];
    financialYearPickList = [];
    bdmids = [];

    currencyOptions = [
        { label: 'USD', value: 'USD' },
        { label: 'EUR', value: 'EUR' },
        { label: 'GBP', value: 'GBP' },
        { label: 'JPY', value: 'JPY' }
    ];

    @track message = 'Hello from Parent';
    @track currencyValue = 'USD';
    @track currencySymbol = '$';
    @track prevCurrencySymbol = '$'; //'$'
    @track isLoading = false;
    @track isOpenModal = false;
    @track isPopupOpen = false;
    @track isTargetChanged = false;
    @track isAcknowledged = false;
    @track BDDTarget = 0;
    @track stats = {
        prevYear: 'FY-22',
        prevYearActual: '$0',
        curYearTarget: '$0',
        curYearActual: '$0',
        curYearVariance: '$0',
        varianceArrow: false,
        showVarianceArrow: false
    };
    @track isEditDisable = false;

    connectedCallback() {
        this.calculatePrevFY();
    }

    // fetchCurrentYear(){
    //     let currentMonth = new Date().getMonth();
    //     const currentYear = 'FY-' + new Date().getFullYear().toString().substring(2, 4);

    //     console.log('currentYear==>',currentYear);
    //     console.log('this.selYear==>',this.selYear);
        
    //     if (currentMonth >= 0 && currentMonth <= 2 && currentYear == this.selYear) {
    //         this.selYear = 'FY-' + (this.nextYear.toString().substring(2, 4) - 1);
    //         console.log('currentYear==>',currentYear);
    //     }
    //     console.log('last selyear==>',this.selYear);

    // }


    get firstName() {
        return getFieldValue(this.user.data, FIRST_NAME);
    }

    get lastName() {
        return getFieldValue(this.user.data, LAST_NAME);
    }

    get getFYDisabled() {
        const nextYear = new Date().getFullYear();
        return nextYear.toString().substring(2, 4) > this.selYear.substring(3, 5) || this.isLoading;
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
            // this.fetchCurrentYear();
            this.fetchStats();
        } else if (error) {
            console.log('error===>', error);
            showError(error.message);
        }
    };

    @wire(getBDMTargetDist, { currentUser: '$userId', financialYear: '$selYear', prevFinancialYear: '$prevFY' }) //
    wiredUsers({ data, error }) {
        if (data) {
            this.currencyValue = JSON.parse(data).currencyVal;
            this.currencySymbol = currencyFormatter(JSON.parse(data).currencySymbol);
            this.prevCurrencySymbol = currencyFormatter(JSON.parse(data).prevFYCurrencyVal);
            this.BDDTarget = JSON.parse(data).BDDTarget;
            this.BDMList = JSON.parse(data).BDMList;
            this.fetchStats();

        } else if (error) {
            console.error(error);
            showError(error);
        }
    }

    fetchStats() {
        this.isLoading = true;
        getDTCStats({ selYear: this.selYear })
            .then(result => {
                this.isLoading = false;
                this.stats.prevYear = result.prevYear;
                this.stats.prevYearActual = this.prevCurrencySymbol + nFormatter(result.prevYearActual, 2);
                this.stats.curYearTarget = this.prevCurrencySymbol + nFormatter(result.curYearTarget, 2);//this.currencySymbol + nFormatter(result.curYearTarget, 2);
                this.stats.curYearActual = this.prevCurrencySymbol + nFormatter(result.curYearActual, 2);//this.currencySymbol + nFormatter(result.curYearActual, 2);

                this.stats.curYearVariance = this.prevCurrencySymbol  + nFormatter(result.curYearVariance, 2);
                console.log('this.stats.prevYearActual====>',this.stats.prevYearActual);
                console.log('this.stats.curYearTarget====>',this.stats.curYearTarget);
                console.log('this.stats.curYearActual====>',this.stats.curYearActual);
                if (result.curYearVariance != null & result.curYearVariance < 0) {
                    this.stats.curYearVariance = this.prevCurrencySymbol  + nFormatter((-1 * result.curYearVariance), 2);
                }

                this.stats.varianceArrow = (result.curYearTarget - result.curYearActual < 0);
                this.stats.showVarianceArrow = (result.curYearTarget != result.curYearActual);
            })
            .catch(error => {
                this.isLoading = false;
                console.error('error====>', error);
                showError("No data for this selected financial year");
            });
    }

    saveTarget() {
        if (!this.BDDTarget) {
            this.BDDTarget = 0;
        }
        else if (typeof this.BDDTarget == 'string') {
            this.BDDTarget = parseInt(this.BDDTarget);
        }

        const totalPercentage = this.BDMList.reduce((total, user) => total + parseInt(user.disPercent), 0);
        if (totalPercentage > 100 || totalPercentage < 100) {
            showError('Total Percentage should not be more or less than 100%');
            return;
        }

        this.BDMList = this.BDMList.map((bdm) => {
            return { ...bdm, currencyVal: this.currencyValue };
        });
        console.log('save method BDMList===>', this.BDMList)

        this.isLoading = true;
        this.isPopupOpen = false;

        saveBDMTargetConfigs({
            currentUser: this.userId,
            currencyVal: this.currencyValue,
            BDDTarget: this.BDDTarget,
            financialYear: this.selYear,
            BDMDistData: JSON.stringify(this.BDMList),
            bdmList: this.bdmids,
            // isAcknowledge: this.isAcknowledged

        })
            .then(result => {
                this.isLoading = false;
                this.isPopupOpen = false;
                this.isTargetChanged = false;
                showSuccess('Target Updated Successfully');
                location.reload();
                this.toggleModal();
                this.handleRefresh();
                this.fetchStats();
                const childEvent = new CustomEvent('childevent', { detail: '' });
                this.template.querySelector('c-spm_dtc_manager_card').dispatchEvent(childEvent);
                // const childEvent = new CustomEvent('childevent', { detail: '' });
                // this.template.querySelector('c-spm_bdd_manager_card').dispatchEvent(childEvent);
                location.reload();
            })
            .catch(error => {
                showError(error);
                this.isLoading = false;
                this.isPopupOpen = false;
            });
    }

    calculatePrevFY() {
        const currentYearNumber = parseInt(this.selYear.substring(3), 10);
        const previousYearNumber = currentYearNumber - 1;
        this.prevFY = 'FY-' + previousYearNumber.toString().padStart(2, '0');
    }

    handleFYChange(event) {
        this.selYear = event.target.value;
        // this.fetchCurrentYear();
        this.calculatePrevFY();
        this.fetchStats();
    }

    handleAcknowledge() {
        this.isAcknowledged = !this.isAcknowledged;
    }

    handleCurrencyChange(event) {
        this.isTargetChanged = true;
        this.currencyValue = event.detail.value;
        this.currencySymbol = currencyFormatter(this.currencyValue);
    }

    handleTargetChange(event) {
        this.isTargetChanged = true;
        this.BDDTarget = event.target.value;
    }

    handlePercentageChange(event) {
        this.isTargetChanged = true;
        const updatedList = this.BDMList.map((user) => {
            if (user.userId === event.target.dataset.key) {

                return { ...user, disPercent: event.target.value, isChanged: true };

            }
            return user;
        });
        const changedBDMs = updatedList.filter((user) => user.isChanged);
        this.bdmids = changedBDMs.map((bdm) => bdm.userId);

        this.BDMList = [...updatedList];
        console.log('BDMList===>', this.BDMList);
    }

    // handleSave(event){
    //     const eventData = event.detail;
    // }

    // sendMessageToChild(){
    //     this.message = 'New Message from Parent';
    //     const childEvent = new CustomEvent('childevent', {detail: {message: this.message}});
    //     this.template.querySelector('c-spm_bdd_manager_card').dispatchEvent(childEvent);
    // }

    handleChildEvent(event) {
        const childMessage = event.detail;
    }

    closePopup() {
        this.isPopupOpen = false;
    }

    showpopup() {
        this.isPopupOpen = true;
    }

    toggleModal() {
        this.isLoading = false;
        this.isTargetChanged = false;
        this.isOpenModal = !this.isOpenModal;
    }

}