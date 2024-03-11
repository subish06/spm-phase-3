import { LightningElement, wire, track, api } from 'lwc';
import getBusUnitProducts from '@salesforce/apex/BDMController.getBusUnitProducts';
import prepareBUProducts from '@salesforce/apex/BDMController.prepareBUProducts';
import upsertOrdCommit from '@salesforce/apex/BDMController.upsertOrdCommit';

import { showError, showSuccess, nFormatter } from "c/spm_utility";

export default class Spm_bdm_product_table extends LightningElement {

    draftValues = [];
    orderCommitList = [];
    downloadCSVData = [];
    downloadBUProducts = [];

    downloadedFileName = '';
    totalRecords = 0;
    pageSize = 25;
    totalPages;
    pageNumber = 1;

    recordsToDisplay = [];
    pageSizeOptions = [25, 50, 75, 100];
    uploadedCSVData = null;

    @api busUnitName;
    @api accountName;
    @api accountId;
    @api financialYear;
    @api selectedMonth;
    @api prodCode;
    @api prodDescription;
    @api currencySymbol;
    @api hideButton;
    @api commitmentAvailable;

    @track showSpinner = false;
    @track noProductMessage = false;
    @track showUploadDialog = false;
    @track downloadingPrompt = false;
    @track busUnitProducts = [];
    @track preSelectedRows = [];
    @track sortBy;
    @track sortDirection;

    connectedCallback() {
        this.showSpinner = !this.showSpinner;
        const downloadAccountName = this.accountName.replace(/[/\\:*,?"<>|]/g, '_');
        const downloadBusUnitName = this.busUnitName.replace(/[/\\:*,?"<>|]/g, '_');
    }

    get monthOptions() {
        return [
            { label: 'January', value: 'Jan' },
            { label: 'February', value: 'Feb' },
            { label: 'March', value: 'Mar' },
            { label: 'April', value: 'Apr' },
            { label: 'May', value: 'May' },
            { label: 'June', value: 'Jun' },
            { label: 'July', value: 'Jul' },
            { label: 'August', value: 'Aug' },
            { label: 'September', value: 'Sep' },
            { label: 'October', value: 'Oct' },
            { label: 'November', value: 'Nov' },
            { label: 'December', value: 'Dec' },
        ];
    }

    get columns() {
        const isEditMode = this.editDisabled();
        let columnList = [
            { label: 'Product Code', fieldName: 'productCode', type: 'text', hideDefaultActions: true, sortable: "true" },
            { label: 'Product Description', fieldName: 'description', type: 'text', hideDefaultActions: true, sortable: "true" },
            { label: 'Start Date', fieldName: 'startDateField', type: 'text', hideDefaultActions: true, sortable: "true" },
            { label: 'Finish', fieldName: 'finish', type: 'text', hideDefaultActions: true, sortable: "true" },
            { label: 'Quantity', fieldName: 'ordCommitsQuantity', type: 'number', editable: isEditMode, hideDefaultActions: true, sortable: "true" },
            { label: 'Unit Price', fieldName: 'ordCommitsUnitPrice', type: 'currency', hideDefaultActions: true, sortable: "true" },
            { label: 'Committed Order', fieldName: 'committedOrder', type: 'currency', hideDefaultActions: true, sortable: "true" },
            { label: 'Invoiced Order Qt', fieldName: 'invoicedQty', type: 'number', hideDefaultActions: true, sortable: "true" },
            { label: 'Invoiced Order Amt', fieldName: 'invoicedPrice', type: 'currency', hideDefaultActions: true, sortable: "true" },
            { label: 'Open Order Qt', fieldName: 'openQty', type: 'number', hideDefaultActions: true, sortable: "true" },
            { label: 'Open Order amt', fieldName: 'openPrice', type: 'currency', hideDefaultActions: true, sortable: "true" }



        ];
        return columnList;
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    get uploadDisabled() {
        return this.editDisabled();
    }

    //------------old code dont delete before consulting the team------------------

    // editDisabled() {
    //     const nextYear = new Date().getFullYear() + 1;
    //     const isCurrentYear = nextYear.toString().substring(2, 4) <= this.financialYear.substring(3, 5);
    //     const currentMonthIndex = new Date().getMonth();
    //     const selectedMonthIndex = this.monthOptions.findIndex((option) => option.value === this.selectedMonth);

    //     if (!isCurrentYear || selectedMonthIndex < currentMonthIndex) {
    //         this.isEditMode = false;
    //         if (nextYear.toString().substring(2, 4) < this.financialYear.substring(3, 5)) {
    //             this.isEditMode = true;
    //         }
    //     }
    //     else {
    //         this.isEditMode = true;
    //     }

    //     return (isCurrentYear && this.isEditMode) && !this.hideButton && this.commitmentAvailable ;
    // }

    editDisabled() {
        let currentYear = new Date().getFullYear() + 1;
        const pastyear = currentYear - 1;
        const currentMonthIndex = new Date().getMonth();
        const selectedYear = parseInt(this.financialYear.substring(3), 10);
        const selectedMonthIndex = this.monthOptions.findIndex((option) => option.value === this.selectedMonth);

        if (selectedMonthIndex <= 2) {
            currentYear = new Date().getFullYear() + 2;
        }

        if ((currentYear.toString().substring(2, 4) > selectedYear && selectedMonthIndex <= 2) || (currentYear.toString().substring(2, 4) <= selectedYear && selectedMonthIndex >= currentMonthIndex)) {
            this.isEditMode = true;
        } else {
            this.isEditMode = false;
        }

        return this.isEditMode && !this.hideButton && this.commitmentAvailable;
    }

    @wire(prepareBUProducts, {
        busId: null,
        businessUnit: '$busUnitName', accountId: '$accountId', financialYear: '$financialYear',
        selectedMonth: '$selectedMonth', ProdCode: '$prodCode', ProdDescription: '$prodDescription', commitmentAvailable: '$commitmentAvailable'
    })
    wiredBusUnitProducts({ data, error }) {
        if (data) {
            this.fetchData();
            this.error = undefined;
        }
        else if (error) {
            showError(error);
        }
    }

    fetchData() {
        this.showSpinner = true;
        getBusUnitProducts({
            busId: null,
            businessUnit: this.busUnitName, accountId: this.accountId, financialYear: this.financialYear,
            selectedMonth: this.selectedMonth, ProdCode: this.prodCode, ProdDescription: this.prodDescription, commitmentAvailable: this.commitmentAvailable
        })
            .then(data => {
                this.showSpinner = false;
                this.busUnitProducts = [];
                this.preSelectedRows = [];


                let count = 1;

                data.forEach((busUnitProd) => {
                    this.busUnitProducts.push({ ...busUnitProd, key: 'key-' + count });
                    if (busUnitProd.startDateField > busUnitProd.startDateWrapper
                    ) {
                        this.preSelectedRows.push(busUnitProd.key);
                    }
                    count++;

                });
                this.totalRecords = data.length;
                this.pageSize = this.pageSizeOptions[0];
                this.paginationHelper();
                this.handleRowSelection();
            })
            .catch(error => {
                this.showSpinner = false;
                showError(error);
            });
    }

    handleCellChange(event) {
        const changedCell = event.detail.draftValues[0];

        if (changedCell) {
            this.handleSave(changedCell);
        }
    }

    handleRowSelection() {
        this.preSelectedRows = this.busUnitProducts.filter(row => row.startDateField > row.startDateWrapper).map(row => row.key);
    }

    handleSave(changedCell) {
        this.showSpinner = true;
        const matchingBusUnitProd = this.busUnitProducts.find((busUnitProd) => busUnitProd.key === changedCell.key);

        if (matchingBusUnitProd) {
            this.orderCommitList.push({
                Id: matchingBusUnitProd.orderCommitId,
                Quantity__c: changedCell.ordCommitsQuantity,
                Product__c: matchingBusUnitProd.productId,
                Business_Unit__c: matchingBusUnitProd.buId,
                Account__c: matchingBusUnitProd.accId,
                Financial_Year__c: matchingBusUnitProd.financialYear,
                Month__c: matchingBusUnitProd.month,
                Unit_Price__c: matchingBusUnitProd.ordCommitsUnitPrice,
                BDM__c: matchingBusUnitProd.accountOwnerId
            });
        }

        upsertOrdCommit({
            ordCommitList: this.orderCommitList,
            ProdCode: this.prodCode,
            ProdDescription: this.prodDescription,
            commitmentAvailable: this.commitmentAvailable
        })
            .then((data) => {
                this.showSpinner = false;
                this.orderCommitList = [];
                this.fetchData();
                this.dispatchEvent(new CustomEvent('save', { detail: '' }));
                showSuccess('Records updated successfully');
            })
            .catch(error => {
                this.showSpinner = false;
                showError(error);
            });
    }

    handleSort(event) {
        const { fieldName: sortBy, sortDirection } = event.detail;
        this.sortBy = sortBy;
        this.sortDirection = sortDirection;
        this.sortData(sortBy, sortDirection);
        this.paginationHelper();
    }

    sortData(fieldName, sortDirection) {
        let sortedData = JSON.parse(JSON.stringify(this.busUnitProducts));
        sortedData.sort((a, b) => {
            let valA = a[fieldName];
            let valB = b[fieldName];

            if (sortDirection === 'asc') {
                return valA > valB ? 1 : -1;
            } else if (sortDirection === 'desc') {
                return valA < valB ? 1 : -1;
            }
            return 0;
        });

        this.busUnitProducts = sortedData;
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    paginationHelper() {
        this.showSpinner = false;
        this.recordsToDisplay = [];
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }

        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.busUnitProducts[i]);
        }

        if (this.recordsToDisplay.length <= 0) {
            this.noProductMessage = true;
        }
        else {
            this.noProductMessage = false;
        }
    }
}