import { LightningElement, api, wire, track } from 'lwc';
import getTaskEmailHtml from '@salesforce/apex/LWC_MCEmailHTMLViewerController.getTaskEmailHtml';

export default class MCEmailHTMLViewer extends LightningElement {

    @api recordId;
    @track rawHTML;

    @wire(getTaskEmailHtml, { recordId: '$recordId' })
    wiredDEAs({ error, data }) {
        if (data) {
            this.rawHTML = data;
        } else if (error) {
           console.log('errr::',error);
        }
    }
}