import { LightningElement, wire, track, api } from 'lwc';

import USER_ID from '@salesforce/user/Id';

import getBDMAccountStats from '@salesforce/apex/bdmController2.getBDMAccountStats';
import { showError, nFormatter } from "c/spm_utility";

export default class Spm_dtc_accounts extends LightningElement {
    userId = USER_ID;
    BDMAccounts = [];

    @api loggedUser;
    @api subChannel;
    @api financialYear;
    @api currencySymbol;
    @api hideButton;

    @track showSpinner = false;
    @track showAccountSearch = true;
    @track varianceArrow = false;
    @track searchKeyWord = '';
    @track selectedAcc;
    @track selectedAccName;
    @track selectedTargetAmount;
    @track selectedActualAmount;
    @track selectedVarianceAmount;
    @track selectedActual;
    @track selectedTarget;

    @wire(getBDMAccountStats, { loggedUser:'$loggedUser', subChannel: '$subChannel', financialYear: '$financialYear', searchTerm: '$searchKeyWord' })
    wiredBDMAccounts({ data, error }) {
        if (data) {
            this.BDMAccounts = [];
            for (var i in data) {
                var varianceAmount = data[i].targetAmount - data[i].actualAmount;
                if (varianceAmount < 0 && varianceAmount != null) {
                    varianceAmount *= -1;
                }
                this.BDMAccounts.push({
                    accId: data[i].accId,
                    userId: data[i].userId,
                    accName: data[i].name,
                    targetAmount: this.currencySymbol + nFormatter(data[i].targetAmount, 2),
                    actualAmount: this.currencySymbol + nFormatter(data[i].actualAmount, 2),
                    varianceAmount: this.currencySymbol + nFormatter(varianceAmount, 2),
                    actual: data[i].actualAmount,
                    target: data[i].targetAmount,
                    variance: data[i].varianceAmount,
                });
                this.BDMAccounts.sort((a, b) => {
                    return b.target - a.target;
                });
            }
            if (this.BDMAccounts.length > 0) {
                this.selectedAcc = this.BDMAccounts[0].accId;
                this.selectedAccName = this.BDMAccounts[0].accName;
                this.selectedTargetAmount = this.BDMAccounts[0].targetAmount
                this.selectedActualAmount = this.BDMAccounts[0].actualAmount;
                this.selectedVarianceAmount = this.BDMAccounts[0].varianceAmount;
                this.selectedActual = this.BDMAccounts[0].actual;
                this.selectedTarget = this.BDMAccounts[0].target;
            }
        }
        else if (error) {
            console.error('error==>', error);
            showError(error);
        }
    }

    get showSec() {
        return this.selectedAcc != null;
    }
    get viewSize() {
        return this.showAccountSearch ? '10' : '12';
    }
    get iconName() {
        return this.showAccountSearch ? "utility:chevronleft" : "utility:chevronright";
    }
    get title() {
        return this.showAccountSearch ? "Collapse" : "Expand";
    }

    get accountlist() {
        this.BDMAccounts.forEach((bdm) => {
            bdm['class'] = 'slds-p-around_medium card card-unselected ';
            bdm['displayArrow'] = (bdm.varianceAmount != this.currencySymbol + '0.00');
            bdm['varianceArrow'] = (bdm.target - bdm.actual) < 0 ? true : false
            if (bdm.accId === this.selectedAcc) {
                bdm['class'] = 'slds-p-around_medium card card-selected ';
            }
        })
        return this.BDMAccounts;
    }

    handleSearchToggle() {
        this.showAccountSearch = !this.showAccountSearch;
    }

    handleSearch(event) {
        this.searchKeyWord = event.target.value;
    }

    handleNameClick(event) {
        this.showSpinner = true;
        this.selectedAcc = event.currentTarget.dataset.accId;
        this.selectedAccName = event.currentTarget.dataset.accName;
        this.selectedTargetAmount = event.currentTarget.dataset.targetAmount;
        this.selectedActualAmount = event.currentTarget.dataset.actualAmount;
        this.selectedVarianceAmount = event.currentTarget.dataset.varianceAmount;
        this.selectedActual = event.currentTarget.dataset.actual;
        this.selectedTarget = event.currentTarget.dataset.target;

        setTimeout(() => {
            this.showSpinner = false;
        }, 500);
    }

}