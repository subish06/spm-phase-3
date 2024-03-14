import { LightningElement, track, wire, api } from 'lwc';
import getSubChannelStats from '@salesforce/apex/DTCController.getSubChannelStats';
import prepareBDMStats from '@salesforce/apex/bdmController2.prepareBDMStats';
import getTargetBDM from '@salesforce/apex/bdmController2.getTargetBDM';
import saveBDMTargets from '@salesforce/apex/DemoMonth.saveBDMTargets';
// import acknowledgementStatus from '@salesforce/apex/SPMController.acknowledgementStatus';
// import ackHistoryData from '@salesforce/apex/SPMController.ackHistoryData';
import { loadStyle } from 'lightning/platformResourceLoader';
import fileSelectorStyles from '@salesforce/resourceUrl/fileSelectorStyles';
import { showError, showSuccess, nFormatter, currencyFormatter } from "c/spm_utility";

const ackColumns = [
    { label: 'Date', fieldName: 'createdDate', type: 'date' },
    { label: 'Status', fieldName: 'status', type: 'string' },
    { label: 'Comments', fieldName: 'comments', type: 'string' }
];

export default class Spm_dtc_bdm_card extends LightningElement {

    ackColumns = ackColumns;
    subChannelList = [];
    salesTargetData = [];
    uploadData = [];
    @track ackHistory = [];

    @api childevent;
    @api currencySymbol;
    @api refreshTable;
    @api currentUser;
    @api selectedFinancialYear;
    @api isEditDisable;
    @api isBdm;

    @track ackStatus;
    @track selectedSubChannel;
    @track userName = '';
    @track isBDMSelected = false;
    @track showUploadDialog = false;
    @track isLoading = false;
    @track switchAccount = false;
    @track hideButtons = false;
    @track hideBDMEditButton = false;
    @track isPopupOpen = false;
    @track isAcknowledge = false;
    @track isAckTable = false;
    @track ifStatusNull = false;
    @track showAcknowledge = false;
    

    connectedCallback() {
        this.addEventListener('childevent', this.handleChildEvent.bind(this));
    }


    get labelText() {
        return `Do you wish to acknowledge ${this.userName}?`;
    }

    get columns() {
        let columnList = [
            { label: "Business Unit / Month", fieldName: "busUnit", type: "text", typeAttributes: {}, initialWidth: 200 },
            { label: "Apr", fieldName: "Apr", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "May", fieldName: "May", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jun", fieldName: "Jun", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jul", fieldName: "Jul", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Aug", fieldName: "Aug", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Sep", fieldName: "Sep", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Oct", fieldName: "Oct", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Nov", fieldName: "Nov", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Dec", fieldName: "Dec", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Jan", fieldName: "Jan", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Feb", fieldName: "Feb", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} },
            { label: "Mar", fieldName: "Mar", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} }
        ];
        columnList.push({ label: "Total", fieldName: "total", type: "text", sortable: true, cellAttributes: { alignment: 'center', iconName: { fieldName: 'trendIcon' }, iconPosition: 'right', class: 'slds-text-wrap' }, typeAttributes: {} });
        return columnList;
    }

    get showSec() {
        return this.selectedSubChannel != null;
    }

    get subChanList() {
        this.subChannelList = this.subChannelList.map((subChannel) => {
            return {
                ...subChannel,
                class: subChannel.name === this.selectedSubChannel ? 'slds-p-around_xxx-small card card-selected row' : 'slds-p-around_xxx-small card card-unselected row',
                isBDMSelected: subChannel.name === this.selectedSubChannel,
                displayArrow: (subChannel.varianceAmount != this.currencySymbol + '0.00'),
                varianceArrow: (subChannel.target - subChannel.actual) < 0 ? true : false
            };
        });
        return this.subChannelList;
    }

    get getFYDisabled() {
        const nextYear = new Date().getFullYear();
        return nextYear.toString().substring(2, 4) > this.selectedFinancialYear.substring(3, 5);
    }

    get acceptedFormats() {
        return ['.csv'];
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, fileSelectorStyles)
        ]);
    }

    // fetchAckHistory() {
    //     ackHistoryData({ currentUser: this.currentUser, selectedUser: this.selectedSubChannel, financialYear: this.selectedFinancialYear })
    //         .then(ackData => {
    //             this.ackHistory = ackData;
    //         })
    //         .catch(error => {
    //             showError(error);
    //         });
    // }

    fetchBDMStats() {
        getSubChannelStats({ currentUser: this.currentUser, financialYear: this.selectedFinancialYear, isBDM : this.isBdm })
            .then(data => {
                this.subChannelList = [];

                Object.keys(data).forEach(key => {
                    var varianceAmount = data[key].Target - data[key].Actual;
                    if (varianceAmount < 0 && varianceAmount != null) {
                        varianceAmount *= -1;
                    }
                    this.subChannelList.push({
                        name: key,
                        targetAmount: this.currencySymbol + (nFormatter(data[key].Target, 2)),
                        actualAmount: this.currencySymbol + nFormatter(data[key].Actual, 2),
                        varianceAmount: this.currencySymbol + nFormatter(varianceAmount, 2),
                        actual: data[key].Actual,
                        target: data[key].Target,
                        variance: data[key].Variance,
                    });
                });

                this.subChannelList.sort((a, b) => {
                    return b.target - a.target;
                });

                if (this.subChannelList.length > 0) {
                    this.selectedSubChannel = this.subChannelList[0].name;
                    this.userName = this.subChannelList[0].name;


                    const monthSummaryEvent2 = new CustomEvent('monthsummaryevent2', {
                        detail: { selectedSubChannel: this.selectedSubChannel }
                    });
                    this.template.querySelector('c-spm_dtc_month_summary').dispatchEvent(monthSummaryEvent2);
                }
                const monthSummaryEvent = new CustomEvent('monthsummaryevent', { detail: '' });
                this.template.querySelector('c-spm_dtc_month_summary').dispatchEvent(monthSummaryEvent);
            })
            .catch(error => {
                showError(error);
            });

    }

    @wire(prepareBDMStats, { currentUser: '$currentUser', financialYear: '$selectedFinancialYear', isBDM: '$isBdm' })
    wiredBDMUsers({ data, error }) {
        if (data) {
            this.fetchBDMStats();
            this.error = undefined;
        }
        else if (error) {
            showError(error);
        }
    }

    // @wire(getBDMStats, { currentUser: '$currentUser', financialYear: '$selectedFinancialYear' })
    // wiredBDMUsers({ data, error }) {
    //     if (data) {
    //         this.subChannelList = [];
    //         for (var i in data) {
    //             var varianceAmount = data[i].targetAmount - data[i].actualAmount;
    //             if (varianceAmount < 0 && varianceAmount != null) {
    //                 varianceAmount *= -1;
    //             }

    //             this.subChannelList.push({
    //                 userId: data[i].userId,
    //                 name: data[i].name,
    //                 url: data[i].url,
    //                 targetAmount: this.currencySymbol + (nFormatter(data[i].targetAmount, 2)),
    //                 actualAmount: this.currencySymbol + nFormatter(data[i].actualAmount, 2),
    //                 varianceAmount: this.currencySymbol + nFormatter(varianceAmount, 2),
    //                 actual: data[i].actualAmount,
    //                 target: data[i].targetAmount,
    //                 variance: data[i].varianceAmount,
    //             });
    //         }

    //         this.subChannelList.sort((a, b) => {
    //             return b.target - a.target;
    //         });

    //         if (this.subChannelList.length > 0) {
    //             this.selectedSubChannel = this.subChannelList[0].userId;
    //             this.userName = this.subChannelList[0].name;
    //         }
    //     }
    //     else if (error) {
    //         showError(error);
    //     }
    // }


    handleChildEvent(event) {
        const childMessage = childEvent;
        this.fetchBDMStats();
    }


    updateUploadedData() {
        if (this.uploadData.length === 0) {
            showError('No data to upload.');
            this.showUploadDialog = false;
            return;
        }
        this.isLoading = true;
        saveBDMTargets({
            updatedRecords: this.uploadData,
            financialYear: this.selectedFinancialYear,
            bddId: this.currentUser,
            subChannel: this.selectedSubChannel
            // isAcknowledge: this.isAcknowledge
        })
            .then((data) => {
                showSuccess('Data uploaded successfully:');
                this.uploadData = [];
                this.isLoading = false;
                this.showUploadDialog = false;
                location.reload();
            })
            .catch((error) => {
                showError(error);
                console.log('error', error);
                this.uploadData = [];
                this.isLoading = false;
                this.showUploadDialog = false;
            });
    }

    switchToAccount(selectedSubChannel) {
        this.switchAccount = !this.switchAccount;
        this.hideButtons = true;
        // this.handleClick();
    }

    handleClick(event) {
        this.selectedSubChannel = event.currentTarget.dataset.userName;
        this.userName = event.currentTarget.dataset.userName;
        const monthSummaryEvent2 = new CustomEvent('monthsummaryevent2', {
            detail: { selectedSubChannel: this.selectedSubChannel }
        });
        this.template.querySelector('c-spm_dtc_month_summary').dispatchEvent(monthSummaryEvent2);
    }

    handleChildEvent(event) {
        const selectedBdd = event.detail; //changes
        this.fetchBDMStats();
    }

    handleChildEvntMonthSummary(event) {
        const childMessage = event.detail;
    }

    // handleSave(event){
    //     console.log('hanldesave ===>');
    //     const eventData = event.detail;       

    //     this.dispatchEvent(new CustomEvent('save', { detail: '' }));
    //     this.fetchBDMStats();
    // }

    handleDownload() {
        getTargetBDM({
            financialYear: this.selectedFinancialYear,
            currentUser: this.currentUser,
            subChannel: this.selectedSubChannel
        })
            .then((data) => {
                this.salesTargetData = [];
                let targetData = {
                    "Business Unit": "Total",
                    Apr: 0,
                    May: 0,
                    Jun: 0,
                    Jul: 0,
                    Aug: 0,
                    Sep: 0,
                    Oct: 0,
                    Nov: 0,
                    Dec: 0,
                    Jan: 0,
                    Feb: 0,
                    Mar: 0,
                    Total: 0
                };

                for (let busUnit in data) {
                    let salesTar = {
                        "Business Unit": busUnit,
                        Total: 0
                    };
                    for (let month in data[busUnit]) {
                        salesTar[month] = data[busUnit][month];
                        salesTar.Total += data[busUnit][month];
                        targetData[month] += data[busUnit][month];
                        targetData.Total += data[busUnit][month];
                    }
                    this.salesTargetData.push(salesTar);
                }

                this.salesTargetData.push(targetData);

                let rowEnd = '\n';
                let csvString = '';

                let rowData = Object.keys(this.salesTargetData[0]);
                rowData.push(rowData.splice(rowData.indexOf('Total'), 1)[0]);
                csvString += rowData.join(',') + rowEnd;

                for (let i = 0; i < this.salesTargetData.length; i++) {
                    let colValue = 0;
                    for (let key in rowData) {
                        if (rowData.hasOwnProperty(key)) {
                            let rowKey = rowData[key];
                            if (colValue > 0) {
                                csvString += ',';
                            }

                            let value = this.salesTargetData[i][rowKey] === undefined ? '' : this.salesTargetData[i][rowKey];
                            // csvString += '"' + value + '"';
                            csvString += value;
                            colValue++;
                        }
                    }
                    csvString += rowEnd;
                }

                let downloadElement = document.createElement('a');
                downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
                downloadElement.target = '_self';
                if (this.selectedSubChannel != '' && this.selectedSubChannel != undefined) {
                    downloadElement.download = this.selectedSubChannel + '_' + this.selectedFinancialYear + '_Target.csv';
                } else {
                    downloadElement.download = 'Sub_Channel_Target.csv';
                }
                document.body.appendChild(downloadElement);
                downloadElement.click();
                document.body.removeChild(downloadElement);
            })
            .catch((error) => {
                showError(error);
            });
    }

    handleUpload(event) {
        const file = event.target.files[0];

        const downloadedFileName = this.selectedSubChannel + '_' + this.selectedFinancialYear + '_Target.csv';
        if (file) {
            const reader = new FileReader();
            const uploadedFileName = file.name;
            if (uploadedFileName !== downloadedFileName) {
                this.showUploadDialog = false;
                showError('Please upload a valid file format. Kindly ensure that the uploaded file corresponds to the selected user');
            }
            else {
                reader.onload = (e) => {
                    const csvData = e.target.result;
                    const rowData = csvData.split('\n');

                    const headers = rowData[0].split(',');
                    const uploadedDataFormat = { busUnit: "Total" };

                    for (let i = 1; i < headers.length; i++) {
                        uploadedDataFormat[headers[i]] = 0;
                    }

                    const fileData = rowData.slice(1);
                    fileData.forEach((row) => {
                        const colData = row.split(',');
                        const jsonRow = { ...uploadedDataFormat, busUnit: colData[0].replace(/^"|"$/g, '') };

                        for (let i = 1; i < colData.length; i++) {
                            const propertyName = headers[i];
                            jsonRow[propertyName] = parseFloat(colData[i]);
                        }
                        this.uploadData.push(jsonRow);
                    });
                    this.updateUploadedData();
                };
            }
            reader.readAsText(file);
        }
    }

    openUploadDialog() {
        this.showUploadDialog = !this.showUploadDialog;
    }

    handleCheckbox() {
        this.isAcknowledge = !this.isAcknowledge;
    }

    handleAckTracking() {
        this.isAckTable = !this.isAckTable;
        this.fetchAckHistory();
    }

    closePopup() {
        this.isPopupOpen = false;
        this.isAckTable = false;
    }
}