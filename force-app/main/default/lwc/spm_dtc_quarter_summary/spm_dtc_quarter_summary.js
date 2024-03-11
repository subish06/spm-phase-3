import { LightningElement, api, wire, track } from 'lwc';
import getTargetQuatBDM from '@salesforce/apex/DemoMonth.getTargetQuatBDM';
import getActualQuatBDM from '@salesforce/apex/DemoMonth.getActualQuatBDM';
import getVarianceQuatBDM from '@salesforce/apex/DemoMonth.getVarianceQuatBDM';


import { showError, showSuccess, nFormatter } from "c/spm_utility";

export default class Spm_dtc_quarter_summary extends LightningElement {

    salesTargetData = [];
    actualData = [];
    varianceData = [];
    activeSections = ['Target', 'Actuals', 'Variance'];

    @api financialYear;
    @api currentBDD;
    @api selectedBDM;
    @api selectedSubChannel;
    @api currencySymbol;

    @track isSummaryMode = false;
    @track gridExpandedRows = [];

    get columns() {
        let columnList = [
            { label: "Business Unit / Quarters", displayColumn: true, fieldName: "busUnit", type: "text", typeAttributes: {}, initialWidth: 200 , header:true },
            { label: "Q1 (Apr - Jun)", fieldName: "Q1", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false },
            { label: "Q2 (July - Sep)", fieldName: "Q2", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false },
            { label: "Q3 (Oct - Dec)", fieldName: "Q3", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false },
            { label: "Q4 (Jan - Mar)", fieldName: "Q4", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false },
            { label: "Total", fieldName: "total", displayColumn: !this.isEditMode, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false }
        ];
        return columnList;
    }

    get gridColumns() {
        let gridColumnList = [
            { label: "Business Unit / Quarters", fieldName: "busUnit", type: "text", typeAttributes: {}, initialWidth: 250 },
            { label: "", fieldName: "value", type: "text", typeAttributes: {}, initialWidth: 70 },
            { label: "Q1 (Apr - Jun)", fieldName: "Q1", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 200 },
            { label: "Q2 (July - Sep)", fieldName: "Q2", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 200 },
            { label: "Q3 (Oct - Dec)", fieldName: "Q3", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 200 },
            { label: "Q4 (Jan - Mar)", fieldName: "Q4", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {}, initialWidth: 200 },
            { label: "Total", fieldName: "total", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap', style: 'font-weight: bolder;' }, typeAttributes: {}, initialWidth: 200 }
        ];
        return gridColumnList;
    }
    
    get summaryScreenData() {
        const combinedData = [];
        this.gridExpandedRows = [];

        const quarters = ['Q1', 'Q2', 'Q3', 'Q4', 'total'];

        this.salesTargetData.forEach((targetData, i) => {
            const actualsData = this.actualData[i];
            const varianceData = this.varianceData[i];

            const formattedTargetData = {};
            const formattedActualData = {};
            const formattedVarianceData = {};

            let targetTotal = 0;
            let actualsTotal = 0;
            let varianceTotal = 0;

            quarters.forEach((quarter) => {
                if (targetData && targetData.hasOwnProperty(quarter)) {
                    const formattedTargetValue = this.currencySymbol + nFormatter(targetData[quarter], 2);
                    formattedTargetData[quarter] = formattedTargetValue;
                    targetTotal += parseFloat(targetData[quarter]);
                } else {
                    formattedTargetData[quarter] = this.currencySymbol + '0';
                }

                if (actualsData && actualsData.hasOwnProperty(quarter)) {
                    const formattedActualsValue = this.currencySymbol + nFormatter(actualsData[quarter], 2);
                    formattedActualData[quarter] = formattedActualsValue;
                    actualsTotal += parseFloat(actualsData[quarter]);
                } else {
                    formattedActualData[quarter] = this.currencySymbol + '0';
                }

                if (varianceData && varianceData.hasOwnProperty(quarter)) {
                    const formattedVarianceValue = this.currencySymbol + nFormatter(varianceData[quarter], 2);
                    formattedVarianceData[quarter] = formattedVarianceValue;
                    varianceTotal += parseFloat(varianceData[quarter]);
                } else {
                    formattedVarianceData[quarter] = this.currencySymbol + '0';
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

    @wire(getTargetQuatBDM, { financialYear: '$financialYear', currentUser: '$currentBDD', selectedSubChannel: '$selectedSubChannel' })
    wiredTargetData(result) {
        this.wiredMyApexMethodResult = result;

        if (result.data) {
            this.salesTargetData = [];

            let targetData = { id: 1, busUnit: "Total", Q1: 0, Q2: 0, Q3: 0, Q4: 0, total: 0, isFirst: false };
            let count = 2;

            for (let busUnit in result.data) {
                let salesTar = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };

                for (let quarter in result.data[busUnit]) {
                    salesTar.total += result.data[busUnit][quarter];
                    targetData[quarter] += result.data[busUnit][quarter];
                }
                targetData.total += salesTar.total;

                this.salesTargetData.push(salesTar);
                count++;
            }
            this.salesTargetData.push(targetData);

            for (let data of this.salesTargetData) {
                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                    }
                }
            }
            this.error = undefined;
        }
        else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    @wire(getActualQuatBDM, { financialYear: '$financialYear', currentUser: '$currentBDD', selectedSubChannel: '$selectedSubChannel' })
    wiredActualData(result) {
        this.wiredMyApexMethodResult = result;
        if (result.data) {
            this.actualData = [];

            let targetData = { id: 1, busUnit: "Total", Q1: 0, Q2: 0, Q3: 0, Q4: 0, total: 0, isFirst: false };

            let count = 2;
            for (let busUnit in result.data) {
                let salesTar = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };

                for (let quarter in result.data[busUnit]) {
                    salesTar.total += result.data[busUnit][quarter];
                    targetData[quarter] += result.data[busUnit][quarter];
                }
                targetData.total += salesTar.total;

                this.actualData.push(salesTar);
                count++;
            }
            this.actualData.push(targetData);

            for (let data of this.actualData) {
                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                    }
                }
            }
            this.error = undefined;
        }
        else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    @wire(getVarianceQuatBDM, { financialYear: '$financialYear', currentUser: '$currentBDD', selectedSubChannel: '$selectedSubChannel' })
    wiredVarianceData(result) {
        this.wiredMyApexMethodResult = result;

        if (result.data) {
            this.varianceData = [];

            let targetData = { id: 1, busUnit: "Total", Q1: 0, Q2: 0, Q3: 0, Q4: 0, total: 0, isFirst: false };
            let count = 2;

            for (let busUnit in result.data) {
                let salesTar = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };

                for (let quarter in result.data[busUnit]) {
                    salesTar.total += result.data[busUnit][quarter];
                    targetData[quarter] += result.data[busUnit][quarter];
                }
                targetData.total += salesTar.total;

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

            for (let data of this.varianceData) {
                const salesTargetData = this.salesTargetData.find(target => target.busUnit === data.busUnit);
                const actualTargetData = this.actualData.find(actual => actual.busUnit === data.busUnit);

                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                        
                        let targetVal = (salesTargetData && salesTargetData[key]) ? salesTargetData[key] : 0;
                        let actualsVal = (actualTargetData && actualTargetData[key]) ? actualTargetData[key] : 0;

                        data[key + 'TargetAchieved'] = (targetVal - actualsVal) < 0 ? true : false;
                        data[key + 'ShowVarianceArrow'] = (data[key + 'Data'] != this.currencySymbol + 0.00 && data[key + 'Data'] != this.currencySymbol + '0.00');
                    }
                }
            }

            // for (let data of this.varianceData) {
            //     for (let key in data) {
            //         if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
            //             data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
            //         }
            //     }
            // }
            this.error = undefined;
        }
        else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    handleToggleChange() {
        this.isSummaryMode = !this.isSummaryMode;
    }

}