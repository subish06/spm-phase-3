import { LightningElement, api, wire, track } from 'lwc';
import getOrderListByDateAndSKU from '@salesforce/apex/XC_OrderController.getOrderListByDateAndSKU';
import getOrderListByDateAndSKUForExport from '@salesforce/apex/XC_OrderController.getOrderListByDateAndSKUForExport';
import startReorder from '@salesforce/apex/XC_OrderController.startReorder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import getTotalRecordsNumber from '@salesforce/apex/XC_OrderController.getTotalRecordsNumber';
import {
  publish,
  MessageContext
 } from "lightning/messageService";
 import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
const columns = [{
  label: 'Order Number',
  fieldName: 'orderNumber',
  type: 'text',
  fixedWidth: 150,
  sortable: true
},
{
  label: 'PO Number',
  fieldName: 'poNumber',
  type: 'text',
  fixedWidth: 150,
  sortable: true
},
{
  label: 'Ordered Date',
  fieldName: 'orderedDate',
  type: 'string',
  fixedWidth: 150,
  sortable: true
},
{
  label: 'Requested Ship Date',
  fieldName: 'requestedShipDate',
  type: 'date-local',
  fixedWidth: 150,
  sortable: true,  
  typeAttributes:
  {
    day: 'numeric',
    month: 'numeric',
    year: 'numeric'
  }
},
{
  label: 'Estimated Ship Date',
  fieldName: 'estimatedShipDate',
  type: 'date-local',
  fixedWidth: 150,
  sortable: true,  
  typeAttributes:
  {
    day: 'numeric',
    month: 'numeric',
    year: 'numeric'
  }
},
{
  label: 'Status',
  fieldName: 'status',
  type: 'text',
  fixedWidth: 150,
  // sortable: true
},
{
  label: 'Total',
  fieldName: 'totalAmount',
  type: 'currency',
  cellAttributes: { alignment: 'left' },
  fixedWidth: 150,
  sortable: true
},
{
  label: 'Start Reorder', type: 'xcButton', fieldName: 'startReorder',
  typeAttributes: {
    id: { fieldName: 'id' }
  },
  fixedWidth: 250
}
];
// const columnHeader = ['Order Number', 'Ordered Date', 'Requested Ship Date', 'Status', 'Total Amount', 'Quantity', 'Attributes'];
const columnHeader = ['Order Number','PO Number', 'Ordered Date', 'Shipping Address', 'Requested Ship Date','Estimated Ship Date', 'Status',
  'Order Item SKU','SKU Name','Business Unit', 'Quantity','Unit Price','Total Amount', 'Product Code'];
export default class XCOrderSummaryListView extends LightningElement {
  @track data;
  @track loading = false;
  @track columns = columns;
  @track sortBy = 'orderNumber';
  @track sortDirection = 'ASC';
  @wire(MessageContext)
    messageContext;

  columns = columns;
  colheader = columnHeader;
  orderData;
  pageNumber=1;
  totalRecords;
  totalPage;
  disablePrevious = true;
  disableNext = true;

   connectedCallback(){
   this.endDate = new Date().toISOString();
   this.startDate = new Date(new Date().setFullYear(new Date().getFullYear() - 1)).toISOString();
    }

    
    nextHandler(){
      this.pageNumber=this.pageNumber+ 1;
      this.getOrder();
    }

    previousHandler(){
      this.pageNumber=this.pageNumber- 1;
      this.getOrder();
    }
 

  doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
     this.getOrder();

}


  getOrder() {
      this.loading = true;
      // this.totalPage = '';
      // this.pageNumber = '';
      // this.totalRecords = '';
    var sDate = new Date(this.template.querySelector('.start-date').value);
    sDate = JSON.stringify(sDate) !== 'null' ? sDate : null;
    var eDate = new Date(this.template.querySelector('.end-date').value);
    eDate = JSON.stringify(eDate) !== 'null' ? eDate : null;
    var sKU = new String(this.template.querySelector('.sku-number').value);
    getTotalRecordsNumber({ startDate: sDate, endDate: eDate,SKU:sKU})
      //getOrderListByDateAndSKU({startDate:startDate,endDate:endDate,SKU:''})
      .then(result => {
        this.totalRecords = result;
        this.totalPage = Math.ceil(this.totalRecords/25);
        if(this.totalPage==this.pageNumber){
          this.disableNext = true;
        }
        else{
          this.disableNext =false;
        }
        if(this.pageNumber==1){
          this.disablePrevious = true;
        }
        else{
          this.disablePrevious =false;
        }
        console.log('in then', result);
      })
      .catch(error => {
        console.log('in catch', error);
      })
    getOrderListByDateAndSKU({ startDate: sDate, endDate: eDate, SKU: sKU, pageNumber: this.pageNumber , field: this.sortBy, sortOrder: this.sortDirection})
      //getOrderListByDateAndSKU({startDate:startDate,endDate:endDate,SKU:''})
      .then(result => {
        this.orderData = result;
        console.log('in then', result);
        this.loading = false;
      })
      .catch(error => {
        console.log('in catch', error);
      })
  }

  exportDataToCsv() {
    //  getOrder(startDate,endDate,SKU){
    var sDate = new Date(this.template.querySelector('.start-date').value);
    sDate = JSON.stringify(sDate) !== 'null' ? sDate : null;
    var eDate = new Date(this.template.querySelector('.end-date').value);
    eDate = JSON.stringify(eDate) !== 'null' ? eDate : null;
    var sKU = new String(this.template.querySelector('.sku-number').value);
    getOrderListByDateAndSKUForExport({ startDate: sDate, endDate: eDate, SKU: sKU })
      //getOrderListByDateAndSKU({startDate:startDate,endDate:endDate,SKU:''})
      .then(e => {
        console.log(e);
        // Prepare a html table
        if (e) {
          let doc = '<table>';
          // Add styles for the table
          doc += '<style>';
          doc += 'table, th, td {';
          doc += '    border: 1px solid black;';
          doc += '    border-collapse: collapse;';
          doc += '}';
          doc += '</style>';
          // Add all the Table Headers
          doc += '<tr>';
          this.colheader.forEach(element => {
            doc += '<th>' + element + '</th>'
          });
          doc += '</tr>';
          // Add the data rows
          e.forEach(record => {

            doc += '<tr>';
            doc += '<th>' + record.orderNumber + '</th>';
            doc += '<th>' + record.poNumber + '</th>';
            doc += '<th>' + record.orderedDate + '</th>';
            doc += '<th>' + record.shippingAddress + '</th>';
            doc += '<th>' + record.requestedShipDate + '</th>';
            doc += '<th>' + record.estimatedShipDate + '</th>';
            doc += '<th>' + record.status + '</th>';
           
            // doc += '<th>' + record.attributes + '</th>';
            doc += '<th>' + record.sku + '</th>';
            doc += '<th>' + record.name + '</th>';
            doc += '<th>' + record.businessUnit + '</th>';
            doc += '<th>' + record.quantity + '</th>';
            doc += '<th>' + record.unitPrice + '</th>';
            doc += '<th>' + record.totalAmount + '</th>';
            doc += '<th>' + record.productCode + '</th>';

            doc += '</tr>';
          });
          doc += '</table>';
          doc = doc.replaceAll('undefined', '--');
          var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
          let downloadElement = document.createElement('a');
          downloadElement.href = element;
          downloadElement.target = '_self';
          // use .csv as extension on below line if you want to export data as csv
          downloadElement.download = 'Order Summary.xls';
          document.body.appendChild(downloadElement);
          downloadElement.click();
        }

      })
      .catch(error => {
        console.log('in catch', error);
      });
  }

  startReorder(event){
    this.loading = true;
    startReorder({orderSumId: event.detail.id.split('-')[0]})
    .then(result => {
      if(result){
        console.log(JSON.stringify(result));
        publish(this.messageContext, cartChanged);
        this.loading = false;
        this.dispatchEvent(new ShowToastEvent({
          title: 'Success!',
          message: 'All items were added to the cart',
          variant: 'success'
      }));
      //  window.location.reload ();
      }
        else{
          this.dispatchEvent(new ShowToastEvent({
              title: 'Error!',
              message: result.message,
              variant: 'error'
          }));
      }
    })
    .catch(error => {
      this.loading = false;
      this.dispatchEvent(new ShowToastEvent({
        title: 'No Order Items!',
        message: 'No Order Items',
        variant: 'error'
    }));
      console.log('in catch', error);
    })
  }

  handleReset(event) {
    let countNull = 0;
    this.totalPage = '';
    this.pageNumber = 1;
    let elementValue = this.template.querySelectorAll("lightning-input");
    elementValue.forEach(function (element) {
      if (element.name == "Order Date Start") {
        element.value = '';
        this.startDate = null;

      } else if (element.name == "Order Date End") {
        element.value = '';
        this.endDate = null;
      } else if (element.name == "Order Item SKU") {
        element.value = '';
        this.endDate = null;
      }

      if (element.value == null || element.value == '')
        countNull += 1;
    }, this);
    if (countNull != 2)
      this.template.querySelector(".applyButton").disabled = false;
    else
      this.template.querySelector(".applyButton").disabled = true;
    this.orderData = '';
  }
}