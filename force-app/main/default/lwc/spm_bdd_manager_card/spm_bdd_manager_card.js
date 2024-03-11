import { LightningElement, track, wire, api } from 'lwc';
    import getBDMStats from '@salesforce/apex/SPMController.getBDMStats';
    import prepareBDMStats from '@salesforce/apex/SPMController.prepareBDMStats';
    import getTargetBDM from '@salesforce/apex/SPMController.getTargetBDM';
    import saveBDMTargets from '@salesforce/apex/SPMController.saveBDMTargets';
    import acknowledgementStatus from '@salesforce/apex/SPMController.acknowledgementStatus';
    import ackHistoryData from '@salesforce/apex/SPMController.ackHistoryData';
    import { loadStyle } from 'lightning/platformResourceLoader';
    import fileSelectorStyles from '@salesforce/resourceUrl/fileSelectorStyles';
    import { showError, showSuccess, nFormatter, currencyFormatter } from "c/spm_utility";

    const ackColumns = [
        { label: 'Date', fieldName: 'createdDate',type: 'date'},
        { label: 'Status', fieldName: 'status', type: 'string' },
        { label: 'Comments', fieldName: 'comments', type: 'string' }
    ];

    export default class Spm_bdd_manager_card extends LightningElement {

        ackColumns = ackColumns;
        BDMList = [];
        salesTargetData = [];
        uploadData = [];
        @track ackHistory = [];

        @api childevent;
        @api currencySymbol;
        @api refreshTable;
        @api currentUser;
        @api selectedFinancialYear;
        @api isEditDisable;
        @track ackStatus;
        @track selectedBdm;
        @track userName = '';
        @track isBDMSelected = false;
        @track showUploadDialog = false;
        @track isLoading = false;
        @track switchBdm = false;
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
            return this.selectedBdm != null;
        }

        get managerList() {
            this.BDMList = this.BDMList.map((bdm) => {
                return {
                    ...bdm,
                    class: bdm.userId === this.selectedBdm ? 'slds-p-around_medium card card-selected row' : 'slds-p-around_medium card card-unselected row',
                    isBDMSelected: bdm.userId === this.selectedBdm,
                    displayArrow: (bdm.varianceAmount != this.currencySymbol + '0.00'),
                    varianceArrow: (bdm.target - bdm.actual) < 0 ? true : false
                };
            });
            return this.BDMList;
        }        

        get getFYDisabled() {
            const nextYear = new Date().getFullYear();
            return nextYear.toString().substring(2, 4) > this.selectedFinancialYear.substring(3, 5);
        }

        get acceptedFormats() {
            return ['.csv'];
        }

        get buttonStyle() {
            acknowledgementStatus({ bddId: this.currentUser, bdmId: this.selectedBdm, financialYear: this.selectedFinancialYear })
            .then(result => {
                this.showAcknowledge = true;
                this.ackStatus = result;
                this.ifStatusNull = false;

                if(this.ackStatus == '' || this.ackStatus == null){
                    this.ifStatusNull = true;
                }
                if(this.ackStatus == 'Target sent'){
                    this.showAcknowledge = false;
                }
            })
            .catch(error => {
                showError(error);
            });

            switch (this.ackStatus) {
                case 'Target sent':
                    return 'background-color: orange;';
                case 'Accepted':
                    return 'background-color: greenyellow;'; 
                case 'Reverted':
                    return 'background-color: red;';
                default:
                    return '';
            }    
        }

        // @wire(ackHistoryData, { currentUser: '$currentUser', selectedUser: '$selectedBdm', financialYear: '$selectedFinancialYear' })
        // wiredAckHistory({ data, error }) {
        //     if (data) {
        //         console.log('Ack DATA111111===>',data);
        //         this.ackHistory = data;
        //         console.log('Ack DATA===>',this.ackHistory);
        //     }
        //     else if (error) {
        //         showError(error);
        //     }
        // }

        renderedCallback() {
            Promise.all([
                loadStyle(this, fileSelectorStyles)
            ]);
        }

        fetchAckHistory() {
            ackHistoryData({ currentUser: this.currentUser, selectedUser: this.selectedBdm, financialYear: this.selectedFinancialYear})
            .then(ackData=> {
                this.ackHistory = ackData;
            })
            .catch(error => {
                showError(error);
            });
        }

        fetchBDMStats() {
            console.log('this.currentUser manager card ===>', this.currentUser);
            console.log('this.selectedFinancialYear manager card ===>', this.selectedFinancialYear);
            getBDMStats({currentUser: this.currentUser, financialYear: this.selectedFinancialYear})
            .then(data => {
                this.BDMList = [];
                for (var i in data) {
                    var varianceAmount = data[i].targetAmount - data[i].actualAmount;
                    if (varianceAmount < 0 && varianceAmount != null) {
                        varianceAmount *= -1;
                    }

                    this.BDMList.push({
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

                this.BDMList.sort((a, b) => {
                    return b.target - a.target;
                });

                if (this.BDMList.length > 0) {
                    this.selectedBdm = this.BDMList[0].userId;
                    this.userName = this.BDMList[0].name;
                    
                    const monthSummaryEvent2 = new CustomEvent('monthsummaryevent2', {
                        detail: { selectedBdm: this.selectedBdm }
                    });
                    this.template.querySelector('c-spm_bdd_month_summary').dispatchEvent(monthSummaryEvent2);
                }
                const monthSummaryEvent = new CustomEvent('monthsummaryevent', {detail: ''});
                this.template.querySelector('c-spm_bdd_month_summary').dispatchEvent(monthSummaryEvent);

            })
            .catch(error => {
                showError(error);
            });
           
        }   

        @wire(prepareBDMStats, { currentUser: '$currentUser', financialYear: '$selectedFinancialYear' })
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
        //         this.BDMList = [];
        //         for (var i in data) {
        //             var varianceAmount = data[i].targetAmount - data[i].actualAmount;
        //             if (varianceAmount < 0 && varianceAmount != null) {
        //                 varianceAmount *= -1;
        //             }

        //             this.BDMList.push({
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

        //         this.BDMList.sort((a, b) => {
        //             return b.target - a.target;
        //         });

        //         if (this.BDMList.length > 0) {
        //             this.selectedBdm = this.BDMList[0].userId;
        //             this.userName = this.BDMList[0].name;
        //         }
        //     }
        //     else if (error) {
        //         showError(error);
        //     }
        // }


        // handleChildEvent(event){
        //     const childMessage = childEvent;
        //     console.log('childMessagef2==>', childMessage);
        //     this.fetchBDMStats();
        // }


        updateUploadedData() {
            if (this.uploadData.length === 0) {
                showError('No data to upload.');
                this.showUploadDialog = false;
                return;
            }
            this.isLoading = true;
            // this.showUploadDialog = false;
            saveBDMTargets({
                updatedRecords: this.uploadData,
                financialYear: this.selectedFinancialYear,
                bddId: this.currentUser,
                bdmId: this.selectedBdm,
                isAcknowledge : this.isAcknowledge 
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

        switchToBDM(selectedBdm){
            this.switchBdm = !this.switchBdm;
            this.hideButtons = true;
        }

        handleClick(event) {
            this.selectedBdm = event.currentTarget.dataset.userId;
            this.userName = event.currentTarget.dataset.userName;
            const monthSummaryEvent2 = new CustomEvent('monthsummaryevent2', {
                detail: { selectedBdm: this.selectedBdm }
            });
            this.template.querySelector('c-spm_bdd_month_summary').dispatchEvent(monthSummaryEvent2);
        }

        handleChildEvent(event) {
            const selectedBdd = event.detail; //changes
            this.fetchBDMStats();
        }

        handleChildEvntMonthSummary(event){
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
                selectedUser: this.selectedBdm
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
                    if (this.userName != '' && this.userName != undefined) {
                        downloadElement.download = this.userName + '_' + this.selectedFinancialYear + '_Target.csv';
                    } else {
                        downloadElement.download = 'BDM_Target.csv';
                    }
                    document.body.appendChild(downloadElement);
                    downloadElement.click();
                    document.body.removeChild(downloadElement);
                })
                .catch((error) => {
                    showError(error);
                });
        }

        // handleUpload(event) {
        //     const file = event.target.files[0];
        //     const reader = new FileReader();
            
        //     reader.onload = (e) => {
        //         const csvData = e.target.result;
        //         const rowData = csvData.split('\n');
        
        //         const headers = rowData[0].split(',');
        //         const uploadedDataFormat = { busUnit: "Total" };
        
        //         for (let i = 1; i < headers.length; i++) {
        //             uploadedDataFormat[headers[i]] = 0;
        //         }
        
        //         const fileData = rowData.slice(1);
                
        //         fileData.forEach((row) => {
        //             const colData = row.split(',');
        //             const jsonRow = { ...uploadedDataFormat, busUnit: colData[0].replace(/^"|"$/g, '') };
        
        //             for (let i = 1; i < colData.length; i++) {
        //                 const propertyName = headers[i];
        //                 jsonRow[propertyName] = parseFloat(colData[i]);
        //             }
        //             this.uploadData.push(jsonRow);
        //         });
        //         this.updateUploadedData();
        //     };
            
        //     reader.readAsText(file);
        // }

        handleUpload(event) {
            const file = event.target.files[0];
    
            const downloadedFileName = this.userName + '_' + this.selectedFinancialYear + '_Target.csv';
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
                            
                            for(let i = 1; i < colData.length; i++){
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

        handleCheckbox(){
            this.isAcknowledge = !this.isAcknowledge;
        }

        handleAckTracking(){
            this.isAckTable = !this.isAckTable;
            this.fetchAckHistory();
        }

        closePopup(){
            this.isPopupOpen = false;
            this.isAckTable = false;
        }
    }