import { LightningElement, api, wire, track } from 'lwc';
import getOrderListByProductId from '@salesforce/apex/XC_OrdersListPDPView.getOrderListByProductId';
const columns = [{
  label: 'Order Number',
  fieldName: 'orderNumber',
  type: 'text',
  fixedWidth: 150,
  sortable: true
},
{
  label: 'Ordered Date',
  fieldName: 'orderedDate',
  type: 'string',
  fixedWidth: 150
  // sortable: true
},
// {
//   label: 'Filled Qty',
//   fieldName: 'filledQuantity',
//   type: 'number',
//   cellAttributes: { alignment: 'center' },
//   fixedWidth: 150
// },
{
  label: 'Ordered Qty',
  fieldName: 'unFilledQuantity',
  type: 'number',
  cellAttributes: { alignment: 'center' },
  fixedWidth: 150
}
];
export default class XcOrdersListPDPView extends LightningElement {
  @api recordId;
  @track data;
  @track loading = false;
  @track columns = columns;
  @track sortBy;
  @track sortDirection;
  columns = columns;
  orderData;
  activeSection = ''; 
  calledOnce = false;

  //  connectedCallback(){
  //    this.getOrderInfo();
  //  }

   handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    if(openSections.length === 0){
      this.activeSection =''
  }
  else{
      this.activeSection ='ordInfo';
      if(!this.calledOnce){
        this.getOrderInfo();
      }
  }

}

  handleSort(event) {       
    this.sortBy = event.detail.fieldName;       
    this.sortDirection = event.detail.sortDirection;       
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
}

sortData(fieldname, direction) {
    
    let parseData = JSON.parse(JSON.stringify(this.orderData));
   
    let keyValue = (a) => {
        return a[fieldname];
    };

   let isReverse = direction === 'asc' ? 1: -1;

       parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; 
        y = keyValue(y) ? keyValue(y) : '';
       
        return isReverse * ((x > y) - (y > x));
    });
    
    this.orderData = parseData;

}

   getOrderInfo() {
    this.calledOnce = true;
    console.log('recordId: ' + this.recordId);
    getOrderListByProductId({ recordId: this.recordId})
      .then(result => {
        this.orderData = Object.values(result);
        this.totalOrders = this.orderData;
        console.log('in then', result);
        // this.loading = false;
      })
      .catch(error => {
        console.log('in catch', error);
      })
  }

  totalOrders;
  visibleOrders;

  

  updateOrderHandler(event){
    this.visibleOrders=[...event.detail.records]
    console.log(event.detail.records)
}

}