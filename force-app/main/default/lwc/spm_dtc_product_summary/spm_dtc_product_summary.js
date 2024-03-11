import { LightningElement, wire, api, track } from 'lwc';
import getBusUnitTarActVar from '@salesforce/apex/DemoMonth.getBusUnitTarActVar';
import getMonthTarActVar from '@salesforce/apex/DemoMonth.getMonthTarActVar';
import MonthTarActVar from '@salesforce/apex/DemoMonth.MonthTarActVar';
import downloadTargetCommitStats from '@salesforce/apex/DemoMonth.downloadTargetCommitStats';
import updateTargetCommit from '@salesforce/apex/DemoMonth.updateTargetCommit';
import pendingTargetUpload from '@salesforce/apex/DemoMonth.pendingTargetUpload';

import { showError, showSuccess, nFormatter } from "c/spm_utility";

export default class Spm_dtc_product_summary extends LightningElement {

    targetAmt = '';
    actualAmt = '';
    varianceAmt = '';
    draftValues = [];
    orderCommitList = [];
    busUnitProductData = [];

    @api loggedUser;
    @api busUnitName;
    @api accountName;
    @api accountId;
    @api financialYear;
    @api currencySymbol;
    @api hideButton;
    @api businessUnitId;
    @api refreshTable;

    @track showWarning = false;
    @track isPending = false;
    @track varianceArrow = false;
    @track downloadingPrompt = false;
    @track showVarianceArrow = false;
    @track isCurrentYear = false;
    @track showUploadDialog = false;
    @track showSpinner = false;
    @track ProdCode = '';
    @track ProdDescription = '';
    @track monthTargetAmt;
    @track monthActualAmt;
    @track monthVarianceAmt;
    @track monthOrdCommitTarAmt;
    @track monthOrdCommitVarAmt;
    @track monthOrdShowVarianceArrow;
    @track monthOrdVarianceArrow;
    @track monthTargetShowVarianceArrow;
    @track busUnitShowVarianceArrow;
    @track busUnitVarianceArrow;
    @track monthTargetArrow;
    @track selectedMonthIndex;
    @track isAvailableForCommitment = true;
    @track isPendingUpload = false;
    @track selectedMonth = 'Apr';
    @track selectedRows = [];
    @track nextYear = new Date().getFullYear() + 1;
    // @track selYear = 'FY-' + this.nextYear.toString().substring(2, 4);
    @track selYear = (() => {
        const nextYearDate = new Date(this.nextYear, 0); // Creating a Date object for the next year
        const isBetweenJanAndMar = nextYearDate.getMonth() >= 0 && nextYearDate.getMonth() <= 2;
    
        return isBetweenJanAndMar
            ? 'FY-' + (parseInt(this.nextYear.toString().substring(2, 4)) - 1)
            : 'FY-' + this.nextYear.toString().substring(2, 4);
    })();
    @track futureYear = new Date().getFullYear() + 1;
    @track nextYearFy = 'FY-' + this.futureYear.toString().substring(2, 4);


    get monthOptions() {
        return [
            { label: 'April', value: 'Apr',index :3 }, 
            { label: 'May', value: 'May' ,index :4}, 
            { label: 'June', value: 'Jun',index :5 },
            { label: 'July', value: 'Jul',index :6 }, 
            { label: 'August', value: 'Aug',index :7 },
            { label: 'September', value: 'Sep',index :8 },
            { label: 'October', value: 'Oct',index :9 },
            { label: 'November', value: 'Nov',index :10 },
            { label: 'December', value: 'Dec',index :11},
            { label: 'January', value: 'Jan',index :0 },
            { label: 'February', value: 'Feb',index :1 },
            { label: 'March', value: 'Mar',index : 2 }
        ];
    }

    connectedCallback() {
        const currentMonthIndex = new Date().getMonth();
        if(currentMonthIndex >= 0 && currentMonthIndex <= 2){
            this.selectedMonth = this.monthOptions[(currentMonthIndex)  + 9].value;
        } else{
            this.selectedMonth = this.monthOptions[(currentMonthIndex) - 3].value;
        }

        if (this.financialYear >= this.selYear  || this.financialYear == this.nextYearFy) {
            this.isCurrentYear = true;
        }
    }

    fetchMonthData(){
        const selectedBusUnit = new CustomEvent('customevent', {
            detail: { busUnitName: this.busUnitName }
          });
        this.dispatchEvent(selectedBusUnit);

        getMonthTarActVar({ financialYear: this.financialYear, accountId: this.accountId, businessUnitName: this.busUnitName, selectedMonth: this.selectedMonth })
        .then((data) => {
            this.monthOrdVarianceArrow = false;
            this.monthOrdShowVarianceArrow = false;
            this.monthTargetShowVarianceArrow = false;
            this.monthTargetArrow = false;
            this.monthOrdCommitTarAmt = this.currencySymbol + 0;

            this.monthTargetAmt = this.currencySymbol + nFormatter(data.monthTarAmt, 2);
            this.monthActualAmt = this.currencySymbol + nFormatter(data.monthActAmt, 2);
            
            this.monthTargetArrow = (data.monthTarAmt - data.monthActAmt) < 0;
            this.monthTargetShowVarianceArrow = data.monthTarAmt != data.monthActAmt;
            this.monthOrdVarianceArrow = (data.monthTarAmt - data.monthOrdCommit) < 0;
            this.monthOrdShowVarianceArrow = (data.monthTarAmt - data.monthOrdCommit) != 0 && (data.monthTarAmt - data.monthOrdCommit) != null && data.monthOrdCommit != undefined;
            this.monthVarianceAmt = this.currencySymbol + nFormatter(data.monthVarAmt, 2);
           
            if (data.monthVarAmt != null && data.monthVarAmt < 0) {
                this.monthVarianceAmt = this.currencySymbol + nFormatter((-1 * data.monthVarAmt),2);
            }

            if (data.monthOrdCommit != undefined && data.monthOrdCommit != null) {
                this.monthOrdCommitTarAmt = this.currencySymbol + nFormatter(data.monthOrdCommit, 2);
            }
           
            if (data.monthOrdCommit == undefined) {
                this.monthOrdShowVarianceArrow = true;
                this.monthOrdVarianceArrow = false;
            }

            if (data.monthOrdCommit == undefined && data.monthTarAmt == 0) {
                this.monthOrdShowVarianceArrow = false;
            }     

            if (data.monthTarAmt == 0) {
                if (data.monthTarAmt != null && data.monthTarAmt != undefined) {
                    this.monthOrdCommitVarAmt = this.currencySymbol + nFormatter(data.monthTarAmt, 2);
                }
            }

            else {

                if (data.monthOrdCommit == null || data.monthOrdCommit == undefined) {
                    this.monthOrdCommitVarAmt = this.currencySymbol + nFormatter(data.monthTarAmt, 2);
                }

                if (data.monthOrdCommit != null && data.monthOrdCommit != undefined) {
                    this.monthOrdCommitVarAmt = this.currencySymbol + nFormatter((data.monthTarAmt - data.monthOrdCommit), 2);
                    if ((data.monthTarAmt - data.monthOrdCommit) < 0) {
                        this.monthOrdCommitVarAmt = this.currencySymbol + nFormatter(((data.monthTarAmt - data.monthOrdCommit) * (-1)), 2);
                    }
                }
            }
        })

    }

    @wire(getBusUnitTarActVar, { financialYear: '$financialYear', accountId: '$accountId', businessUnitName: '$busUnitName' })
    wiredBusUnitTarActVar({ data, error }) {
        if (data) {
            this.busUnitVarianceArrow = false;
            this.busUnitShowVarianceArrow = false;

            this.targetAmt = this.currencySymbol + nFormatter(data.targetAmt, 2);
            this.actualAmt = this.currencySymbol + nFormatter(data.actualAmt, 2);
            this.varianceAmt = this.currencySymbol + '0';

            if ((data.targetAmt - data.actualAmt) < 0) {
                this.busUnitVarianceArrow = true;
            }

            if (data.varianceAmt != null & data.varianceAmt < 0) {
                this.varianceAmt = this.currencySymbol + nFormatter((data.varianceAmt) * (-1), 2);
            }
            if (data.varianceAmt != null & data.varianceAmt > 0) {
                this.varianceAmt = this.currencySymbol + nFormatter((data.varianceAmt), 2);
            }

            if (this.targetAmt != this.actualAmt) {
                this.busUnitShowVarianceArrow = true;
            }
            // this.varianceAmt = this.currencySymbol + nFormatter(data.varianceAmt, 2);
        }
        else if (error) {
            showError(error);
        }
    }

    @wire(MonthTarActVar, { financialYear: '$financialYear', accountId: '$accountId', businessUnitName: '$busUnitName', selectedMonth: '$selectedMonth' })
    wiredMonthTarActVar({ data, error }) {
        if (data) {
          this.fetchMonthData();
        }
        else if (error) {
            showError(error);
        }
    }

    handleMonthChange(event) {
        this.isCurrentYear = false;
        this.selectedMonth = event.detail.value;
        const currentMonthIndex = new Date().getMonth();
        const selectedMonthObj = this.monthOptions.find(month => month.value === this.selectedMonth);
        if ((this.financialYear >= this.selYear && selectedMonthObj.index < this.monthOptions[currentMonthIndex].index) || this.financialYear == this.nextYearFy ) {
            this.isCurrentYear = true;
        }
    }

    handleCheckboxChange(event){
        this.isAvailableForCommitment = !this.isAvailableForCommitment;
    }

    handleProdCodeChange(event) {
        this.ProdCode = event.target.value;
    }

    handleProdDescriptionChange(event) {
        this.ProdDescription = event.target.value;
    }

    handleDispatch(event){
        const eventData = event.detail;
        this.dispatchEvent(new CustomEvent('save', { detail: '' }));
        this.fetchMonthData();
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

        downloadTargetCommitStats({ accountId: this.accountId, selectedUser: this.loggedUser, financialYear: this.financialYear, businessUnitName : this.busUnitName })
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

                    this.downloadedFileName = this.accountName +  '_' + this.busUnitName+ '_' + this.financialYear + '_Product_Data.csv';
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

    handleFileUpload(event) {
        const file = event.target.files[0];
        this.downloadedFileName = this.accountName +  '_' + this.busUnitName+ '_' + this.financialYear +'_Product_Data.csv';
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
            "SKU", "BusinessUnit","StartDate","UnitPrice", ...months.slice(currentMonth)
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
                    Account__c: this.accountId,
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
        
        console.log('this.targetCommitList==>', this.targetCommitList);


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
            this.isPendingUpload = true;
            showSuccess('Records updated successfully.');
            this.dispatchEvent(new CustomEvent('pendingchange', {
                detail: {pendingUpload : (this.isPendingUpload)}
            }));
        };

        processRemainingBatches();
    }


    handleShowWarning(){
        this.showWarning = !this.showWarning;
    }
    
    handleUploadDialog(){
        this.showUploadDialog = false;
    }

    openUploadDialog() {
        pendingTargetUpload({ currentUser: this.loggedUser })
            .then(result => {
                this.isPendingSize = result.size;

                if (result.isPendingUpload == true) {
                    this.showUploadDialog = !this.showUploadDialog;
                }
                else {
                    this.isPending = true;
                    this.showUploadDialog = false;
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

    
    openDownloadDialog() {
        this.downloadingPrompt = !this.downloadingPrompt;
    }

}