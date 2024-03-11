import { LightningElement, api } from 'lwc';
import basePathName from '@salesforce/community/basePath';
export default class XCCustomButton extends LightningElement {
    @api id;
    url;
    renderedOnce = false;
    hover = false;
    startReorder() {
        const event = new CustomEvent('startreorder', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                id: this.id
            },
        });
        this.dispatchEvent(event);
    }

    renderedCallback(){
        if(this.id && !this.renderedOnce){
            this.url = basePathName+'/OrderSummary/'+this.id.split('-')[0];
            this.renderedOnce = true;
        }
    }

    handleMouseover(event) {
        console.log(this.id);
        this.hover = true;
        // this.objRecordId = null
        // const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        // toolTipDiv.style.opacity = 1;
        // toolTipDiv.style.display = "block";
        // // eslint-disable-next-line
        // window.clearTimeout(this.delayTimeout);
        // // eslint-disable-next-line @lwc/lwc/no-async-operation
        // this.delayTimeout = setTimeout(() => {
        //     this.objRecordId = this.recordId;
        // }, 50);
    }

    /* Handle Mouse Out*/
    handleMouseout() {
        console.log(this.id);
        console.log('Inside handleMOuseOut');
        this.hover = false;
        // const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        // toolTipDiv.style.opacity = 0;
        // toolTipDiv.style.display = "none";
    }
}