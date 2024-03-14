import { LightningElement, wire, api, track } from 'lwc';
import getTargetSubChannel from '@salesforce/apex/bdmController2.getTargetSubChannel';
import getActualsSubChannel from '@salesforce/apex/bdmController2.getActualsSubChannel';
import getVarianceBDM from '@salesforce/apex/bdmController2.getVarianceBDM';
import getBusinessUnits from '@salesforce/apex/bdmController2.getBusinessUnits';
import downloadTargetCommitStats from '@salesforce/apex/bdmController2.downloadTargetCommitStats';
import updateTargetCommit from '@salesforce/apex/bdmController2.updateTargetCommit';
import pendingTargetUpload from '@salesforce/apex/BDMController.pendingTargetUpload';
// import getOrdersByIds  from '@salesforce/apex/BDMController.getOrdersByIds';
import { showError, nFormatter, showSuccess } from "c/spm_utility";


export default class Spm_dtc_account_summary extends LightningElement {

    isSelected = false;
    gridData = [];
    targetData = [];
    actualData = [];
    varianceData = [];
    businessUnits = [];
    downloadCSVData = [];
    targetCommitStats = [];
    targetCommitList = [];
    activeSections = ['Target', 'Order', 'Variance'];
    pendingUpload;

    @api loggedUser;
    @api subChannel;
    @api showSection;
    @api accountName;
    @api accountTarget;
    @api accountActuals;
    @api accountVariance;
    @api actualAmount;
    @api targetAmount;
    @api financialYear;
    @api selectedAccount;
    @api currencySymbol;
    @api hideButton;
    @api isBdm;

    @track activeTabValue = 'Summary';
    @track tempActiveTabValue;
    @track value = 'Invoiced';
    @track progressVal = 10;
    @track nextYear = new Date().getFullYear() + 1;
    // @track selYear = 'FY-' + this.nextYear.toString().substring(2, 4);
    @track selYear = (() => {
        const nextYearDate = new Date(this.nextYear, 0); // Creating a Date object for the next year
        const isBetweenJanAndMar = nextYearDate.getMonth() >= 0 && nextYearDate.getMonth() <= 2;
    
        return isBetweenJanAndMar
            ? 'FY-' + (parseInt(this.nextYear.toString().substring(2, 4)) - 1)
            : 'FY-' + this.nextYear.toString().substring(2, 4);
    })();
    @track gridExpandedRows = [];
    @track selectedRowData = null;
    @track isPendingSize = '';
    @track isSummaryScrnSelected = false;
    @track showSpinner = false;
    @track isPopupOpen = false;
    @track downloadingPrompt = false;
    @track showUploadDialog = false;
    @track isPending = false;
    @track isPendingData = false;
    @track refreshTable = false;
    @track isCurrentYear = false;
    @track showWarning = false;
    @track futureYear = new Date().getFullYear() + 2;
    @track nextYearFy = 'FY-' + this.futureYear.toString().substring(2, 4);
    

    connectedCallback() {
        if (this.financialYear >= this.selYear || this.financialYear == this.nextYearFy) {
            this.isCurrentYear = true;
        }
        // this.pendingTarUpload();
    }

  
    get options() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Open', value: 'Open' },
            { label: 'Invoiced', value: 'Invoiced' },
        ];
    }

    get displayArrow() {
        return this.targetAmount - this.actualAmount != 0 ? true : false;
    }

    get varianceArrow() {
        return (this.targetAmount - this.actualAmount) < 0 ? true : false;
    }

    get columns() {
        let columnList = [
            { label: "Business Unit / Month", fieldName: "busUnit", type: "text", typeAttributes: {} },
            { label: "Apr", fieldName: "Apr", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "May", fieldName: "May", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jun", fieldName: "Jun", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jul", fieldName: "Jul", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Aug", fieldName: "Aug", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Sep", fieldName: "Sep", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Oct", fieldName: "Oct", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Nov", fieldName: "Nov", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Dec", fieldName: "Dec", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jan", fieldName: "Jan", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Feb", fieldName: "Feb", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Mar", fieldName: "Mar", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} }
        ];
        columnList.push({ label: "Total", fieldName: "total", type: "currency", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} });
        return columnList;
    }

    get gridColumns() {
        let gridColumnList = [
            { label: "Business Unit / Month", fieldName: "busUnit", type: "text", typeAttributes: {}, initialWidth: 150 },
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

    @wire(getTargetSubChannel, { financialYear: '$financialYear', loggedUser: '$loggedUser', accountId: '$selectedAccount', subChannel: '$subChannel', isBDM:'$isBdm' })
    wiredTargetData(result) {
        if (result.data) {
            this.targetData = [];
            let tarData = { id: 1, busUnit: "Total", Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0, Jan: 0, Feb: 0, Mar: 0, total: 0, isFirst: false };
            let count = 2;

            for (let busUnit in result.data) {
                let target = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };
                for (let month in result.data[busUnit]) {
                    target.total += result.data[busUnit][month];
                    tarData[month] += result.data[busUnit][month];
                    tarData.total += result.data[busUnit][month];
                }
                this.targetData.push(target);
                count++;
            }

            this.targetData.push(tarData);
            this.gridData = this.summaryScreenData;

            for (let data of this.targetData) {
                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                    }
                }
            }
        }
        else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    @wire(getActualsSubChannel, { financialYear: '$financialYear', loggedUser: '$loggedUser', accountId: '$selectedAccount', subChannel: '$subChannel' , isBDM:'$isBdm' })
    wiredActualsData(result) {
        if (result.data) {
            this.actualData = [];
            let actData = { id: 1, busUnit: "Total", Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0, Jan: 0, Feb: 0, Mar: 0, total: 0, isFirst: false };
            let count = 2;

            for (let busUnit in result.data) {
                let actual = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };
                for (let month in result.data[busUnit]) {
                    actual.total += result.data[busUnit][month];
                    actData[month] += result.data[busUnit][month];
                    actData.total += result.data[busUnit][month];
                }
                this.actualData.push(actual);

                count++;
            }

            this.actualData.push(actData);
            this.gridData = this.summaryScreenData;

            for (let data of this.actualData) {
                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                    }
                }
            }
        }
        else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    @wire(getVarianceBDM, { financialYear: '$financialYear', loggedUser: '$loggedUser', accountId: '$selectedAccount', subChannel: '$subChannel' , isBDM:'$isBdm' })
    wiredVarianceData(result) {

        if (result.data) {
            this.varianceData = [];
            let varData = { id: 1, busUnit: "Total", Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0, Jan: 0, Feb: 0, Mar: 0, total: 0, isFirst: false };
            let count = 2;

            for (let busUnit in result.data) {
                let variance = { ...result.data[busUnit], id: count, busUnit: busUnit, total: 0, isFirst: true };
                for (let month in result.data[busUnit]) {
                    variance.total += result.data[busUnit][month];
                    varData[month] += result.data[busUnit][month];
                    varData.total += result.data[busUnit][month];
                }

                for (let key in variance) {
                    if (variance[key] < 0) {
                        variance[key] = variance[key] * (-1);
                    }
                }

                for (let key in varData) {
                    if (varData[key] < 0) {
                        varData[key] = varData[key] * (-1);
                    }
                }

                this.varianceData.push(variance);
                count++;
            }
            this.varianceData.push(varData);
            this.gridData = this.summaryScreenData;

            for (let data of this.varianceData) {
                const targetData = this.targetData.find(target => target.busUnit === data.busUnit);
                const actualData = this.actualData.find(actual => actual.busUnit === data.busUnit);

                for (let key in data) {
                    if (key != 'id' && key != 'busUnit' && key != 'isFirst') {
                        if (data[key] < 0) {
                            data[key + 'Data'] = this.currencySymbol + nFormatter((-1 * data[key]), 2);
                        }
                        else {
                            data[key + 'Data'] = this.currencySymbol + nFormatter(data[key], 2);
                        }

                        let targetVal = (targetData && targetData[key]) ? targetData[key] : 0;
                        let actualsVal = (actualData && actualData[key]) ? actualData[key] : 0;

                        data[key + 'TargetAchieved'] = (targetVal - actualsVal) < 0 ? true : false;
                        data[key + 'ShowVarianceArrow'] = (data[key + 'Data'] != this.currencySymbol + 0.00 && data[key + 'Data'] != this.currencySymbol + '0.00');
                    }
                }
            }
        }
        else if (result.error) {
            this.error = result.error;
            showError(result.error);
        }
    }

    @wire(getBusinessUnits, { accountId: '$selectedAccount' })
    wiredBusinessUnits({ data, error }) {
        if (data) {
            this.businessUnits = data;
        }
        else if (error) {
            showError(error);
        }
    }

    get summaryScreenData() {
        this.isCurrentYear = false; //new changes this is added additionally from connected call back

        if (this.financialYear >= this.selYear || this.financialYear == this.nextYearFy) {
            this.isCurrentYear = true;
        } // new changes till this

        const combinedData = [];
        this.gridExpandedRows = [];

        const months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'total'];

        this.targetData.forEach((targetData, i) => {
            const actualsData = this.actualData[i];
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
                }
                else {
                    formattedTargetData[month] = this.currencySymbol + '0';
                }

                if (actualsData && actualsData.hasOwnProperty(month)) {
                    const formattedActualsValue = this.currencySymbol + nFormatter(actualsData[month], 2);
                    formattedActualData[month] = formattedActualsValue;
                    actualsTotal += parseFloat(actualsData[month]);
                }
                else {
                    formattedActualData[month] = this.currencySymbol + '0';
                }

                if (varianceData && varianceData.hasOwnProperty(month)) {
                    const formattedVarianceValue = this.currencySymbol + nFormatter(varianceData[month], 2);
                    formattedVarianceData[month] = formattedVarianceValue;
                    varianceTotal += parseFloat(varianceData[month]);
                }
                else {
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

    downloadCSV() {
        this.targetCommitStats = [];
        this.openDownloadDialog();
        this.progressVal = 0;

        const incrementProgress = () => {
            if (this.progressVal < 90) {
                this.progressVal += 15;
                setTimeout(incrementProgress, 5000);
            }
        };

        incrementProgress();

        downloadTargetCommitStats({ accountId: this.selectedAccount, subChannel: this.subChannel,selectedUser: this.loggedUser, financialYear: this.financialYear, businessUnitName : null })
            .then(result => {
                this.targetCommitStats = result;
                this.progressVal = 100;

                if (this.targetCommitStats && this.targetCommitStats.length > 0) {
                    const currentDate = new Date();
                    // const currentMonth = currentDate.getMonth() - 3;
                    const currentMonthIndex = currentDate.getMonth();
                    const currentMonth = currentMonthIndex >=0 && currentMonthIndex <= 2
                                        ? currentMonthIndex + 9 : currentMonthIndex - 3
                    const months = [
                        "April", "May", "June", "July", "August", "September", "October",
                        "November", "December", "January", "February", "March"
                    ];
                    const dynamicHeaders = [
                        "SKU", "Description", "Finish", "BusinessUnit","StartDate", "UnitPrice", ...months.slice(currentMonth)
                    ];

                    const csvData = [];

                    for (let record of this.targetCommitStats) {
                        const rowData = [
                            record.productCode || '',
                            (record.description || '').replace(/[\r\n,.;#]+/g, ' '),
                            (record.finish || '').replace(/[\r\n,.;#]+/g, ' '),
                            record.businessUnit || '',
                            record.startDate || '',
                            record.unitPrice || 0,
                        ];


                        for (let i = currentMonth; i < 12; i++) {
                            rowData.push(record[months[i]]);
                        }
                        csvData.push(rowData);
                    }

                    const rowEnd = '\n';
                    let csvString = dynamicHeaders.join(',') + rowEnd;

                    for (let rowData of csvData) {
                        csvString += rowData.join(',') + rowEnd;
                    }

                    this.downloadedFileName = this.accountName + '_' + this.financialYear + '_Product_Data.csv';
                    const downloadElement = document.createElement('a');
                    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
                    downloadElement.target = '_self';
                    downloadElement.download = this.downloadedFileName;
                    document.body.appendChild(downloadElement);
                    downloadElement.click();
                    document.body.removeChild(downloadElement);
                    this.openDownloadDialog();
                    showSuccess('Data downloaded successfully');
                } else {
                    this.openDownloadDialog();
                    showError('No data is available for download. Please contact your System Administrator for assistance.');
                }
            })
            .catch(error => {
                this.error = error;
                showError(error);
                this.openDownloadDialog();
            });
    }

    handleUploadWindow(){
        this.showUploadDialog = false;
    }

    handleFileUpload(event) {
        const file = event.target.files[0];
        this.downloadedFileName = this.accountName + '_' + this.financialYear + '_Product_Data.csv';
        if (file) {
            const reader = new FileReader();
            const uploadedFileName = file.name;
            if (uploadedFileName !== this.downloadedFileName) {
                this.showUploadDialog = false;
                showError('Please upload a valid file format. Kindly ensure that the uploaded file corresponds to the selected Account');
            }
            else {
                reader.onload = (e) => {
                    const csvContent = e.target.result;
                    if (this.isCSVValid(csvContent)) {
                        this.parseCSV(csvContent);
                    }
                };
            }
            reader.readAsText(file);
        }
    }

    isCSVValid(csvContent) {
        const rows = csvContent.split('\n');
        if (!csvContent.trim()) {
            showError('Invalid File Format: Please check the file, the file appears to empty.');
            this.showUploadDialog = false;
            return false;
        }
        return true;
    }
    
    parseCSV(csvContent) {
        this.showSpinner = true;
        this.showUploadDialog = true;

        const currentDate = new Date();
        // const currentMonth = currentDate.getMonth() - 3;
        const currentMonthIndex = currentDate.getMonth();
        const currentMonth = currentMonthIndex >=0 && currentMonthIndex <= 2
                            ? currentMonthIndex + 9 : currentMonthIndex - 3

        const months = [
            "April", "May", "June", "July", "August", "September", "October", "November",
            "December", "January", "February", "March"
        ];
        const dynamicHeaders = [
            "SKU", "BusinessUnit","StartDate", "UnitPrice", ...months.slice(currentMonth)
        ];
        const monthAPI = {
            "January": "Jan__c", "February": "Feb__c", "March": "Mar__c", "April": "Apr__c",
            "May": "May__c", "June": "Jun__c", "July": "Jun__c", "August": "Aug__c",
            "September": "Sep__c", "October": "Oct__c", "November": "Nov__c", "December": "Dec__c"
        }

        const expectedColumns = 6 + months.length - currentMonth;
        const rows = csvContent.split('\n');
        const headers = rows[0].split(',');

        this.targetCommitList = [];

        for (let i = 1; i < rows.length; i++) {
            const cols = rows[i].split(',');

            if (cols.length === expectedColumns) {
                const record = {};

                for (let j = 0; j < headers.length; j++) {
                    const header = headers[j].trim();
                    const value = cols[j].trim();
                    if (dynamicHeaders.includes(header)) {
                        if (header === 'UnitPrice') {
                            record.Unit_Price__c = value;
                        }
                        else if (header === 'BusinessUnit') {
                            record.Product_Business_Unit__c = value;
                        }
                        else if (header === 'SKU') {
                            record.Product_SKU__c = value;
                        }
                        else if (header === 'StartDate') {
                            const originalStartDateValue = value;
                            const dateComponents = originalStartDateValue.split('-');
                            const parsedDate =new Date(dateComponents[2], dateComponents[1] - 1, dateComponents[0]);
                            const formattedStartDate = `${parsedDate.getFullYear()}-${(parsedDate.getMonth() + 1).toString()
                            .padStart(2, '0')}-${parsedDate.getDate().toString().padStart(2, '0')}`;
                            
                            record.Start_Date__c = formattedStartDate != 'NaN-NaN-NaN' ? formattedStartDate : '';

                        }
                        else {
                            record[monthAPI[header]] = value;
                            if (
                                (isNaN(record[monthAPI[header]]) || record[monthAPI[header]] === '' ||
                                    record[monthAPI[header]] === null)
                                ) {
                                showError('Invalid Quantity Format: Please enter numeric values for respective months.');
                                this.showSpinner = false;
                                this.showUploadDialog = false;
                                return;
                            }
                        }
                    }
                }

                this.targetCommitList.push({
                    ...record,
                    IsUpload__c: true,
                    Account__c: this.selectedAccount,
                    BDM__c: this.loggedUser,
                    Status__c: 'Pending',
                    Financial_Year__c: this.financialYear
                });
            }
            // else {
            //     console.log('error=-->', error);
            //     this.showError('Invalid CSV Format: The number of columns in the uploaded file does not match the expected format.');
            //     // return;
            // }
        }


        let targetCommitListCopy = [...this.targetCommitList];
        const batchSize = 5000;
        this.progressVal = 0;

        const incrementProgress = () => {
            if (this.progressVal < 90) {
                this.progressVal += 5;
                setTimeout(incrementProgress, 3000);
            }
        };

        incrementProgress();

        const processBatch = (batch) => {
            return new Promise((resolve, reject) => {
                updateTargetCommit({ targetCommitList: batch })
                    .then((data) => {
                        resolve();
                    })
                    .catch(error => {
                        console.log('error===>', error);
                        this.showUploadDialog = false;
                        reject(error);
                    });
            });
        };

        const processRemainingBatches = async () => {
            while (targetCommitListCopy.length > 0) {
                const remainingRecords = targetCommitListCopy.splice(0, batchSize);
                try {
                    await processBatch(remainingRecords);
                } catch (error) {
                    this.showSpinner = false;
                    this.showUploadDialog = false;
                    showError(error);
                    return;
                }
            }
            this.showSpinner = false;
            this.showUploadDialog = false;
            this.targetCommitList = [];
            this.progressVal = 100;
            this.showWarning = true;
            showSuccess('Records updated successfully');
            // this.pendingTarUpload();        
        };

        processRemainingBatches();
    }

    handleShowWarning(){
        this.showWarning = false;
    }

    // pendingTarUpload(){
    //     pendingTargetUpload({ subChannel: this.subChannel })
    //         .then(result => {
    //             this.isPendingSize = result.size;

    //             if (result.isPendingUpload == true) {
    //                 this.isPendingData = false;
    //             }
    //             else {
    //                 this.isPendingData = true;
    //             }
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             showError(error);
    //         });
    // }

    pendingTarUpload() {
        const incrementProgress = () => {
            pendingTargetUpload({ currentUser: this.loggedUser })
                .then(result => {
                    this.isPendingSize = result.size;
    
                    if (result.isPendingUpload) {
                        this.isPendingData = false;
                    } else {
                        this.isPendingData = true;
                    }
    
                    if (this.isPendingSize !== 0) {
                        setTimeout(incrementProgress, 3000);
                    }
                })
                .catch(error => {
                    this.error = error;
                    showError(error);
                });
        };
    
        incrementProgress();
    }
    

    openUploadDialog() {
        pendingTargetUpload({ currentUser: this.loggedUser })
            .then(result => {
                this.isPendingSize = result.size;

                if (result.isPendingUpload == true) {
                    this.showUploadDialog = !this.showUploadDialog;
                    this.isPendingData = false;
                }
                else {
                    this.isPending = true;
                    this.showUploadDialog = false;
                    this.isPendingData = true;
                }
            })
            .catch(error => {
                this.error = error;
                showError(error);
            });
    }

    showPendingWindow() {
        this.isPending = false;
    }

    handleCustomEvent(event) {
        const busUnitName = event.detail.busUnitName;
        this.tempActiveTabValue = busUnitName;
    }

    refreshProdTable() {
        const tempSelectedAccount = this.selectedAccount;
        this.selectedAccount = null;
        this.isPendingSize = '';
        if(this.selectedAccount == null){
            showSuccess('Data Refreshed Successfully');
        }
        setTimeout(() => {
            this.selectedAccount = tempSelectedAccount;
            this.activeTabValue = this.tempActiveTabValue;
            // this.pendingTarUpload();
        }, 100);
        
    }

    openDownloadDialog() {
        this.downloadingPrompt = !this.downloadingPrompt;
    }

    handleToggleChange() {
        this.isSummaryScrnSelected = !this.isSummaryScrnSelected;
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    closePopup() {
        this.isPopupOpen = false;
    }

}