import { LightningElement, api, track, wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getSalesProjectionItemExcelExport from '@salesforce/apex/xc_SalesProjectionItemExport.getSalesProjectionItemExcelExport';
import callSPBatch from '@salesforce/apex/xc_SalesProjectionItemExport.callSPBatch';
////************** Commented below code which was developed for SPI download from UI */
// const columnHeader = ['External Id', 'Account Name','Invoice Account Id', 'Business Unit','Fiscal Year', 'SKU','Description', 
//     'Color','Historical Qty', 'Target Quantity P1', 'Planned Quantity P1', 
//     'Target Quantity P2','Planned Quantity P2', 'Target Quantity P3', 'Planned Quantity P3',
//     'Target Quantity P4', 'Planned Quantity P4','Target Quantity P5', 'Planned Quantity P5',
//     'Target Quantity P6', 'Planned Quantity P6', 'Target Quantity P7', 'Planned Quantity P7',
//     'Target Quantity P8', 'Planned Quantity P8','Target Quantity P9', 'Planned Quantity P9',
//     'Target Quantity P10', 'Planned Quantity P10','Target Quantity P11', 'Planned Quantity P11',
//     'Target Quantity P12', 'Planned Quantity P12'];
    // const fieldMap = {'External Id': 'External_Id',
    // 'Account Name':'XC_Account_Name',
    // 'Invoice Account Id': 'xC_InvoiceAccountId',
    // 'Fiscal Year': 'Fiscal_Year',
    // 'Description': 'Description',
    // 'SKU': 'StockKeepingUnit',
    //  'Color': 'Color',
    //  'Business Unit': 'xc_BusinessUnit',
    // 'Historical Qty': 'XC_Historical_Quantity',
    // 'Target Quantity P1': 'xc_Target_Quantity_P1',
    // 'Planned Quantity P1': 'xc_Planned_Quantity_P1',
    // 'Target Quantity P2': 'xc_Target_Quantity_P2',
    // 'Planned Quantity P2': 'xc_Planned_Quantity_P2',
    // 'Target Quantity P3':'xc_Target_Quantity_P3',
    // 'Planned Quantity P3':'xc_Planned_Quantity_P3',
    // 'Target Quantity P4':'xc_Target_Quantity_P4',
    // 'Planned Quantity P4':'xc_Planned_Quantity_P4',
    // 'Target Quantity P5': 'xc_Target_Quantity_P5',
    // 'Planned Quantity P5': 'xc_Planned_Quantity_P5',
    // 'Target Quantity P6': 'xc_Target_Quantity_P6',
    // 'Planned Quantity P6': 'xc_Planned_Quantity_P6',
    // 'Target Quantity P7': 'xc_Target_Quantity_P7',
    // 'Planned Quantity P7': 'xc_Planned_Quantity_P7',
    // 'Target Quantity P8': 'xc_Target_Quantity_P8',
    // 'Planned Quantity P8':'xc_Planned_Quantity_P8',
    // 'Target Quantity P9': 'xc_Target_Quantity_P9',
    // 'Planned Quantity P9':'xc_Planned_Quantity_P9',
    // 'Target Quantity P10':'	xc_Target_Quantity_P10',
    // 'Planned Quantity P10':'xc_Planned_Quantity_P10',
    // 'Target Quantity P11':'xc_Target_Quantity_P11',
    // 'Planned Quantity P11':'xc_Planned_Quantity_P11',
    // 'Target Quantity P12':'xc_Target_Quantity_P12',
    // 'Planned Quantity P12':'xc_Planned_Quantity_P12'};
//// **********************************************************
export default class XcSalesprojectionExcelExport extends LightningElement {
    // columnHeader = columnHeader;
    spiExport;

    exportData() {
        var invoiceAcct = new String(this.template.querySelector('.invacct-number').value);
        var businessUnit = new String(this.template.querySelector('.business-unit').value);
        var fiscalYear = new String(this.template.querySelector('.fiscal-year').value);
        console.log('invoiceAcct = '+invoiceAcct);
        console.log('businessUnit = '+businessUnit);
        console.log('fiscalYear = '+fiscalYear);
// Calling the Batch Apex..
        callSPBatch({invoiceAcct, businessUnit, fiscalYear})
            .then((result) => {
                console.log(result);
                if(result.length != 0){
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!',
                            message: 'SPI Data export is scheduled and please check your inbox for the email!',
                            variant: 'success'
                        }));
                    }
                else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: 'No data to Export',
                        variant: 'error'
                    }));
                }
            })
            .catch((error) => {
                console.log(error);
            })

// *********** Commented below code which was developed for SPI download in UI
        // getSalesProjectionItemExcelExport({invoiceAcct, businessUnit, fiscalYear})
        // .then((result) => {
        //     console.log(result);
        //     if(result.length != 0){
        //         this.spiExport = result;
        //         // this.exportSPIDataCSV();
        //         this.exportDataToXls();
        //         console.log('result',JSON.stringify(result) );

        //     }
        //     else{
        //         this.dispatchEvent(new ShowToastEvent({
        //             title: 'Error!!',
        //             message: 'No data to Export',
        //             variant: 'error'
        //         }));
        //     }
        // })
        // .catch((error) => {
        //     console.log(error);
        // })
    }

    // exportDataToXls() {
    //     // Prepare a html table
    //     let doc = '<table>';
    //     let fileName;
    //     // Add styles for the table
    //     doc += '<style>';
    //     doc += 'table, th, td {';
    //     doc += '    border: 1px solid black;';
    //     doc += '    column-fill: grey;';
    //     doc += '    border-collapse: collapse;';
    //     doc += '}';
    //     doc += '</style>';
    //     // Add all the Table Headers
    //     doc += '<tr>';
    //     this.columnHeader.forEach(element => {
    //         doc += '<th>' + element + '</th>'
    //     });
    //     doc += '</tr>';
    //     // Add the data rows
    //     this.spiExport.forEach(record => {
    //         if (!fileName){
    //             fileName = record.xC_InvoiceAccountId + '_' + record.xc_BusinessUnit + '_' + record.Fiscal_Year + '_' + '.xls';
    //         }

    //         doc += '<tr>';
    //         doc += '<th>' + record.External_Id + '</th>';
    //         doc += '<th>' + record.XC_Account_Name + '</th>';
    //         doc += '<th>' + record.xC_InvoiceAccountId + '</th>';
    //         doc += '<th>' + record.xc_BusinessUnit + '</th>';
    //         doc += '<th>' + record.Fiscal_Year + '</th>';
    //         doc += '<th>' + record.StockKeepingUnit + '</th>';
    //         doc += '<th>' + record.Description + '</th>';
    //         doc += '<th>' + record.Color + '</th>';
    //         doc += '<th>' + record.XC_Historical_Quantity + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P1 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P1 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P2 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P2 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P3 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P3 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P4 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P4 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P5+ '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P5 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P6 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P6 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P7 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P7 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P8 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P8 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P9 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P9 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P10 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P10 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P11 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P11 + '</th>';
    //         doc += '<th>' + record.xc_Target_Quantity_P12 + '</th>';
    //         doc += '<th>' + record.xc_Planned_Quantity_P12 + '</th>';
    //         doc += '</tr>';
    //     });
    //     doc += '</table>';
    //     doc = doc.replaceAll('<th>undefined</th>','<th></th>');
    //      var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
    //     let downloadElement = document.createElement('a');
    //     downloadElement.href = element;
    //     downloadElement.target = '_self';
    //     // use .csv as extension on below line if you want to export data as csv
    //     downloadElement.download = fileName;
    //     document.body.appendChild(downloadElement);
    //     downloadElement.click();
    // }
}