import { LightningElement, api, track, wire } from 'lwc';
import getTargetBDM from '@salesforce/apex/SPMController.getTargetBDM';
import getBDMTargetData from '@salesforce/apex/SPMController.getBDMTargetData';
import getVarianceBDMData from '@salesforce/apex/SPMController.getVarianceBDMData';
import getActualTarget from '@salesforce/apex/SPMController.getActualsBDM';
import getBDMActualData from '@salesforce/apex/SPMController.getBDMActualData';
import getVarianceBDM from '@salesforce/apex/SPMController.getVarianceBDM';
import saveBDMTargets from '@salesforce/apex/SPMController.saveBDMTargets';
import acknowledgementStatus from '@salesforce/apex/SPMController.acknowledgementStatus';

import { showError, showSuccess, nFormatter } from "c/spm_utility";
export default class Spm_bdd_month_summary extends LightningElement {

    salesTargetData = [];
    actualTargetData = [];
    varianceData = [];
    gridData = [];
    activeSections = ['Target', 'Actuals', 'Variance'];
    loading = false;

    @api hideEditButton;
    @api monthsummaryevent;
    @api monthsummaryevent2;
    @api financialYear;
    @api currentBDD;
    @api selectedBDM;
    @api userName;
    @api currencySymbol;
    @api isEditDisable;
    @track currentYear;
    @track getDataId;
    @track isEditMode = false;
    @track isPopupOpen = false;
    @track isAcknowledge = false;
    @track showAcknowledge = false;


    @track isSummaryMode = false;
    @track gridExpandedRows = [];
    @track nextYear = new Date().getFullYear() + 1;
    // @track selYear = 'FY-' + this.nextYear.toString().substring(2, 4);
    @track selYear = (() => {
        const nextYearDate = new Date(this.nextYear, 0); // Creating a Date object for the next year
        const isBetweenJanAndMar = nextYearDate.getMonth() >= 0 && nextYearDate.getMonth() <= 2;
        return isBetweenJanAndMar
            ? 'FY-' + (parseInt(this.nextYear.toString().substring(2, 4)) - 1)
            : 'FY-' + this.nextYear.toString().substring(2, 4);
    })();
    @track changedValue;
    @track updatedValue;
    @track ackStatus;

    get labelText() {
        return `Do you wish to acknowledge ${this.userName}?`;
    }

    get columns() {
        let columnList = [
            { label: "Business Unit / Month", displayColumn: true, fieldName: "busUnit", type: "text", typeAttributes: {}, initialWidth: 200 },
            { label: "Apr", fieldName: "Apr", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "May", fieldName: "May", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jun", fieldName: "Jun", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jul", fieldName: "Jul", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Aug", fieldName: "Aug", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Sep", fieldName: "Sep", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Oct", fieldName: "Oct", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Nov", fieldName: "Nov", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Dec", fieldName: "Dec", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jan", fieldName: "Jan", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Feb", fieldName: "Feb", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Mar", fieldName: "Mar", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Total", fieldName: "total", displayColumn: !this.isEditMode, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} }
        ];
        return columnList;
    }

    get gridColumns() {
        let gridColumnList = [
            { label: "Business Unit", fieldName: "busUnit", type: "text", typeAttributes: {}, initialWidth: 150 },
            { label: "", fieldName: "value", type: "text", typeAttributes: {}, initialWidth: 70 },
            { label: "Apr", fieldName: "Apr", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "May", fieldName: "May", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Jun", fieldName: "Jun", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Jul", fieldName: "Jul", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Aug", fieldName: "Aug", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Sep", fieldName: "Sep", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Oct", fieldName: "Oct", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Nov", fieldName: "Nov", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Dec", fieldName: "Dec", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Jan", fieldName: "Jan", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Feb", fieldName: "Feb", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Mar", fieldName: "Mar", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 90 },
            { label: "Total", fieldName: "total", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap', style: 'font-weight: bolder;' }, typeAttributes: {}, initialWidth: 90 }
        ];
        return gridColumnList;
    }

    get getFYDisabled() {
        const nextYear = new Date().getFullYear() + 1;
        const nextYearFy = (() => {
            const nextYearDate = new Date(nextYear, 0);
            const isBetweenJanAndMar = nextYearDate.getMonth() >= 0 && nextYearDate.getMonth() <= 2;
            return isBetweenJanAndMar
                ? 'FY-' + (parseInt(nextYear.toString().substring(2, 4)) - 1)
                : 'FY-' + nextYear.toString().substring(2, 4);
        })();

        const isCurrentYear = nextYearFy.toString().substring(3, 5) <= this.financialYear.substring(3, 5);
         if (!isCurrentYear) {
            this.isEditMode = false;
        }
        
        return isCurrentYear && !this.isSummaryMode && !this.isEditMode;
    }

    buttonStyle() {
        acknowledgementStatus({ bddId: this.currentBDD, bdmId: this.selectedBDM, financialYear: this.financialYear })
            .then(result => {
                this.showAcknowledge = true;
                this.ackStatus = result;

                if (this.ackStatus == 'Target sent') {
                    this.showAcknowledge = false;
                }
            })
            .catch(error => {
                showError(error);
            });
    }

    get summaryScreenData() {
        const combinedData = [];
        this.gridExpandedRows = [];

        const months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'total'];

        this.salesTargetData.forEach((targetData, i) => {
            const actualsData = this.actualTargetData[i];
            const varianceData = this.varianceData[i];

            const formattedTargetData = {};
            const formattedActualData = {};
            const formattedVarianceData = {};

            let targetTotal = 0;
            let actualsTotal = 0;
            let varianceTotal = 0;

            months.forEach((month) => {
                if (targetData && targetData.hasOwnProperty(month)) {
                    const formattedTargetValue = this.currencySymbol + nFormatter(targetData[month], 2);
                    formattedTargetData[month] = formattedTargetValue;
                    targetTotal += parseFloat(targetData[month]);
                } else {
                    formattedTargetData[month] = this.currencySymbol + '0';
                }

                if (actualsData && actualsData.hasOwnProperty(month)) {
                    const formattedActualsValue = this.currencySymbol + nFormatter(actualsData[month], 2);
                    formattedActualData[month] = formattedActualsValue;
                    actualsTotal += parseFloat(actualsData[month]);
                } else {
                    formattedActualData[month] = this.currencySymbol + '0';
                }

                if (varianceData && varianceData.hasOwnProperty(month)) {
                    const formattedVarianceValue = this.currencySymbol + nFormatter(varianceData[month], 2);
                    formattedVarianceData[month] = formattedVarianceValue;
                    varianceTotal += parseFloat(varianceData[month]);
                } else {
                    formattedVarianceData[month] = this.currencySymbol + '0';
                }
            });

            const businessUnitItem = {
                id: targetData.id + '_bu',
                busUnit: targetData.busUnit,
                value: 'Target',
                ...formattedTargetData,
                _children: [
                    {
                        id: targetData.id + '_actuals',
                        busUnit: ' ',
                        value: 'Actuals',
                        parentId: targetData.id + '_bu',
                        ...formattedActualData,
                    },
                    {
                        id: targetData.id + '_variance',
                        busUnit: ' ',
                        value: 'Variance',
                        parentId: targetData.id + '_bu',
                        ...formattedVarianceData,
                    },
                ],
            };
            businessUnitItem._children.forEach((child) => {
                this.gridExpandedRows.push(child.id);
            });

            this.gridExpandedRows.push(businessUnitItem.id);
            combinedData.push(businessUnitItem);
        });
        return combinedData;
    }

    @wire(getTargetBDM, { financialYear: '$financialYear', currentUser: '$currentBDD', selectedUser: '$selectedBDM' })
    wiredTargetData(result) {
        this.wiredMyApexMethodResult = result;
        if (result.data) {
            this.formTargetData(result);
        } else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    @wire(getActualTarget, { financialYear: '$financialYear', currentUser: '$currentBDD', selectedUser: '$selectedBDM' })
    wiredActualsData(result) {
        this.wiredMyApexMethodResult = result;
        if (result.data) {
            this.actualTargetData = [];
            let targetData = { id: 1, busUnit: "Total", Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0, Jan: 0, Feb: 0, Mar: 0, total: 0, isFirst: false };

            let count = 2;
            for (let busUnit in result.data) {
                let salesTar = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };
                for (let month in result.data[busUnit]) {
                    if (!month || month == null || month == 'null') {
                        continue;
                    }
                    salesTar.total += result.data[busUnit][month];
                    targetData[month] += result.data[busUnit][month];
                    targetData.total += result.data[busUnit][month];
                }
                for (let key in salesTar) {
                    if (salesTar[key] < 0) {
                        salesTar[key] = salesTar[key] * (-1);
                    }
                }

                for (let key in targetData) {
                    if (targetData[key] < 0) {
                        targetData[key] = targetData[key] * (-1);
                    }
                }

                this.actualTargetData.push(salesTar);
                count++;
            }

            this.actualTargetData.push(targetData);
            this.gridData = this.summaryScreenData;

            for (let data of this.actualTargetData) {
                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                    }
                }
            }

            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    @wire(getVarianceBDM, { financialYear: '$financialYear', currentUser: '$currentBDD', selectedUser: '$selectedBDM' })
    wiredVarianceData(result) {
        this.wiredMyApexMethodResult = result;
        if (result.data) {
            this.varianceData = [];

            let targetData = { id: 1, busUnit: "Total", Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0, Jan: 0, Feb: 0, Mar: 0, total: 0, isFirst: false };

            let count = 2;
            for (let busUnit in result.data) {
                let salesTar = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };
                for (let month in result.data[busUnit]) {
                    salesTar.total += result.data[busUnit][month];
                    targetData[month] += result.data[busUnit][month];
                    targetData.total += result.data[busUnit][month];
                }

                for (let key in salesTar) {
                    if (salesTar[key] < 0) {
                        salesTar[key] = salesTar[key] * (-1);
                    }
                }

                for (let key in targetData) {
                    if (targetData[key] < 0) {
                        targetData[key] = targetData[key] * (-1);
                    }
                }

                this.varianceData.push(salesTar);
                count++;
            }

            this.varianceData.push(targetData);
            this.gridData = this.summaryScreenData;

            for (let data of this.varianceData) {
                const salesTargetData = this.salesTargetData.find(target => target.busUnit === data.busUnit);
                const actualTargetData = this.actualTargetData.find(actual => actual.busUnit === data.busUnit);

                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        if (!this.isEditMode) {
                            data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                        } else {
                            data[key + 'Data'] = this.currencySymbol + nFormatter(data[key]);
                        }

                        let targetVal = (salesTargetData && salesTargetData[key]) ? salesTargetData[key] : 0;
                        let actualsVal = (actualTargetData && actualTargetData[key]) ? actualTargetData[key] : 0;

                        data[key + 'TargetAchieved'] = (targetVal - actualsVal) < 0 ? true : false;
                        data[key + 'ShowVarianceArrow'] = (data[key + 'Data'] != this.currencySymbol + 0.00 && data[key + 'Data'] != this.currencySymbol + '0.00');
                    }
                }
            }

            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }


    formTargetData(result) {
        this.salesTargetData = [];

        const currentDate = new Date();
        const currentMonth = currentDate.toLocaleString('default', { month: 'short' });

        const monthIndex = { Apr: 0, May: 1, Jun: 2, Jul: 3, Aug: 4, Sep: 5, Oct: 6, Nov: 7, Dec: 8, Jan: 9, Feb: 10, Mar: 11 };

        let targetData = { id: 1, busUnit: "Total", total: 0, isFirst: false, displayRow: false, months: {} };

        for (let month in monthIndex) {
            targetData.months[month] = { value: 0, isDisable: false };
        }

        let count = 2;

        for (let busUnit in result.data) {
            let salesTar = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true, displayRow: true, key: 'key-' + count, months: {} };

            for (let month in monthIndex) {
                if (result.data[busUnit].hasOwnProperty(month) && result.data[busUnit][month] !== null && this.financialYear == this.selYear) {
                    salesTar.total += result.data[busUnit][month];
                    salesTar.months[month] = {
                        value: result.data[busUnit][month],
                        isDisable: monthIndex[month] < monthIndex[currentMonth]
                    };
                    targetData.months[month].value += result.data[busUnit][month];
                } else {
                    salesTar.total += result.data[busUnit][month];
                    salesTar.months[month] = {
                        value: result.data[busUnit][month],
                        isDisable: false
                    };
                    targetData.months[month].value += result.data[busUnit][month];
                }
            }
            this.salesTargetData.push(salesTar);
            count++;
        }

        for (let month in targetData.months) {
            targetData.total += targetData.months[month].value;
            if (monthIndex[month] < monthIndex[currentMonth]) {
                targetData.months[month].isDisable = true;
            }
        }

        this.salesTargetData.push(targetData);
        this.gridData = this.summaryScreenData;

        for (let data of this.salesTargetData) {
            for (let key in data.months) {
                this.isEditMode = false;
                if (!this.isEditMode) {
                    data[key + 'Data'] = this.currencySymbol + nFormatter(data.months[key].value, 2);

                }
            }
            data.totalData = this.currencySymbol + nFormatter(data.total, 2);
        }

        this.error = undefined;
    }


    handleInputChange(event) {
        this.updatedValue = event.target.value ? parseFloat(event.target.value) : 0;

        const fieldName = event.target.dataset.fieldName;
        const recordKey = event.target.dataset.key;

        this.salesTargetData = this.salesTargetData.map(record => {
            if (record.key === recordKey) {
                const updatedMonths = { ...record.months };

                for (const month in updatedMonths) {
                    if (month === fieldName) {
                        updatedMonths[month] = {
                            value: this.updatedValue,
                            isDisable: updatedMonths[month].isDisable
                        };
                    }
                }

                return { ...record, [fieldName]: this.updatedValue, months: updatedMonths, isUpdated: true };
            }
            return record;
        });
    }



    handleChildEvntMonthSummary(event) {
        const selectedBdm = event.detail.selectedBdm;
        getBDMTargetData({
            financialYear: this.financialYear, currentUser: this.currentBDD,
            selectedUser: selectedBdm
        }).then(data => {
            this.getBDMVarianceData();
            this.getActualData();
            this.isEditMode = true;
            this.formTargetData({ data });
        });
    }


    handleSave() {
        this.loading = true;
        this.showpopup();
        const updatedRecords = this.salesTargetData.filter(record => record.isUpdated);

        saveBDMTargets({ updatedRecords, financialYear: this.financialYear, bddId: this.currentBDD, bdmId: this.selectedBDM, isAcknowledge: this.isAcknowledge })
            .then(result => {
                showSuccess('Target Updated Successfully');
                this.closePopup();
                this.loading = false;
                this.getBMDTargetData();
                this.getBDMVarianceData();
                this.getActualData();
            })
            .catch(error => {
                console.log('error-->', error)
                this.loading = false;
                showError(error);
            });
    }

    getBMDTargetData() {
        getBDMTargetData({
            financialYear: this.financialYear, currentUser: this.currentBDD,
            selectedUser: this.selectedBDM
        }).then(data => {
            this.isEditMode = true;
            this.formTargetData({ data });

        });
    }

    getActualData() {
        getBDMActualData({
            financialYear: this.financialYear, currentUser: this.currentBDD,
            selectedUser: this.selectedBDM
        })
            .then(data => {
                if (data) {
                    this.actualTargetData = [];

                    let targetData = { id: 1, busUnit: "Total", Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0, Jan: 0, Feb: 0, Mar: 0, total: 0, isFirst: false };

                    let count = 2;
                    for (let busUnit in data) {
                        let salesTar = { ...data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };
                        for (let month in data[busUnit]) {
                            if (!month || month == null || month == 'null') {
                                continue;
                            }
                            salesTar.total += data[busUnit][month];
                            targetData[month] += data[busUnit][month];
                            targetData.total += data[busUnit][month];
                        }

                        this.actualTargetData.push(salesTar);
                        count++;
                    }

                    this.actualTargetData.push(targetData);
                    this.gridData = this.summaryScreenData;

                    for (let data of this.actualTargetData) {
                        for (let key in data) {
                            if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                                data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                            }
                        }
                    }

                    this.error = undefined;
                } else if (result.error) {
                    this.error = result.error;
                    showError(result.error);
                }
            });
    }

    getBDMVarianceData() {
        getVarianceBDMData({
            financialYear: this.financialYear, currentUser: this.currentBDD,
            selectedUser: this.selectedBDM
        })
            .then(data => {
                if (data) {
                    this.varianceData = [];

                    let targetData = { id: 1, busUnit: "Total", Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0, Jan: 0, Feb: 0, Mar: 0, total: 0, isFirst: false };

                    let count = 2;
                    for (let busUnit in data) {
                        let salesTar = { ...data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };
                        for (let month in data[busUnit]) {
                            salesTar.total += data[busUnit][month];
                            targetData[month] += data[busUnit][month];
                            targetData.total += data[busUnit][month];
                        }

                        for (let key in salesTar) {
                            if (salesTar[key] < 0) {
                                salesTar[key] = salesTar[key] * (-1);
                            }
                        }

                        for (let key in targetData) {
                            if (targetData[key] < 0) {
                                targetData[key] = targetData[key] * (-1);
                            }
                        }

                        this.varianceData.push(salesTar);
                        count++;
                    }

                    this.varianceData.push(targetData);
                    this.gridData = this.summaryScreenData;

                    for (let data of this.varianceData) {
                        const salesTargetData = this.salesTargetData.find(target => target.busUnit === data.busUnit);
                        const actualTargetData = this.actualTargetData.find(actual => actual.busUnit === data.busUnit);

                        for (let key in data) {
                            if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                                if (!this.isEditMode) {
                                    data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                                } else {
                                    data[key + 'Data'] = this.currencySymbol + nFormatter(data[key]);
                                }

                                let targetVal = (salesTargetData && salesTargetData[key]) ? salesTargetData[key] : 0;
                                let actualsVal = (actualTargetData && actualTargetData[key]) ? actualTargetData[key] : 0;

                                data[key + 'TargetAchieved'] = (targetVal - actualsVal) < 0 ? true : false;
                                data[key + 'ShowVarianceArrow'] = (data[key + 'Data'] != this.currencySymbol + 0.00 && data[key + 'Data'] != this.currencySymbol + '0.00');
                            }
                        }
                    }

                    this.error = undefined;
                } else if (error) {
                    this.error = error;
                    showError(error);
                }
            });
    }



    toggleEdit() {
        this.isEditMode = !this.isEditMode;
        this.buttonStyle();
    }

    handleToggleChange() {
        this.isSummaryMode = !this.isSummaryMode;
    }

    handleCheckbox() {
        this.isAcknowledge = !this.isAcknowledge;
    }

    closePopup() {
        this.isPopupOpen = false;
    }

    showpopup() {
        this.isPopupOpen = true;
    }
}