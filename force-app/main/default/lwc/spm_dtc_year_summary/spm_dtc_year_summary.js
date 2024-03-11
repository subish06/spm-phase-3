import { LightningElement,api,track,wire } from 'lwc';
import getYearlyStatsBDM from '@salesforce/apex/DemoMonth.getYearlyStatsBDM';
import { showError, showSuccess, nFormatter } from "c/spm_utility";

export default class Spm_dtc_year_summary extends LightningElement {
    
    overallStats = [];

    @api financialYear;
    @api currentBDD;
    @api selectedSubChannel;
    @api currencySymbol;

    get columns() {
        let columnList = [
            { label: "Business Unit", displayColumn: true, fieldName: "busUnit", type: "text", typeAttributes: {}, initialWidth: 200 , header:true },
            { label: "Target", fieldName: "Target", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false },
            { label: "Open Orders", fieldName: "OpenActual", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false },
            { label: "Invoiced Orders", fieldName: "Actual", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false },
            { label: "Variance", fieldName: "Variance", displayColumn: true, type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'center', class: 'slds-text-wrap' }, typeAttributes: {},  header:false }
        ];
        return columnList;
    }

    @wire(getYearlyStatsBDM, { financialYear: '$financialYear', currentUser: '$currentBDD', selectedSubChannel: '$selectedSubChannel' })
    wiredOverallData(result) {
        this.wiredMyApexMethodResult = result;
        if (result.data) {
            this.overallStats = [];

            let statsData = { id: 1, busUnit: "Total", Target: 0,OpenActual: 0, Actual: 0, Variance: 0, total: 0, isFirst: false};
            let count = 2;

            for (let busUnit in result.data) { 
                let stats = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };

                for (let data in result.data[busUnit]) {
                    statsData[data] += result.data[busUnit][data];
                }

                for (let key in stats) {
                    if (stats[key] < 0) {
                        stats[key] = stats[key] * (-1);
                    }
                }

                for (let key in statsData) {
                    if (statsData[key] < 0) {
                        statsData[key] = statsData[key] * (-1);
                    }
                }

                this.overallStats.push(stats);
                count++;
            }
            this.overallStats.push(statsData);

            for (let data of this.overallStats) {
                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                        data[key + 'TargetAchieved'] = ((data.Target) - (data.Actual)) < 0 ? true : false;
                        data[key + 'ShowVarianceArrow'] = (data[key + 'Data'] != this.currencySymbol + 0.00 && data[key + 'Data'] != this.currencySymbol + '0.00');
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

}