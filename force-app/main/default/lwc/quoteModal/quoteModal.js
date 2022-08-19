import { LightningElement, api } from 'lwc';

export default class QuoteModal extends LightningElement {
    @api 
    recordId;

    iframeSrc;

    connectedCallback() {
        this.iframeSrc = `"/sfsites/c/apex/CalculationQuote?id=${this.recordId}&tour=&amp;isdtp=p1&amp;sfdcIFrameOrigin=https://wirtschaftshaus--testbox.livepreview.salesforce-communities.com&amp;nonce=76852a93cae52464fe0f5b75ec5fa1e3eb3f3c087f5f7f89e92fd5e0aa24a366&amp;clc=0&amp;sfdcIFrameHost=web`
    }
}