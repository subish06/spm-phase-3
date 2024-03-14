import { LightningElement, api } from 'lwc';
import basePathName from '@salesforce/community/basePath';
export default class XCCustomButton extends LightningElement {
    @api id;
    url;
    renderedOnce = false;
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
}