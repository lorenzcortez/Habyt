import { LightningElement, wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import STRIPE_INVOICE_ID from '@salesforce/schema/Dispute__c.Invoice__r.Stripe_Invoice_Id__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import duplicateInvoice from '@salesforce/apex/ReissueDisputedInvoice.duplicateInvoice';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class ReissueDisputedInvoice extends LightningElement {
    _recordId;
    showSpinner = false;
    stripeInvoiceId = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this._recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, {recordId: '$_recordId', fields: [STRIPE_INVOICE_ID]})
    getContract({ error, data }) {
        if (data) {
            console.log('data data data', data);
            this.stripeInvoiceId = data.fields.Invoice__r.value.fields.Stripe_Invoice_Id__c.value;
        } else if (error) {
            console.log('Error Message', error);
        }
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    confirmReissue(event){
        this.showSpinner = true;

        console.log('stripeInvoiceId stripeInvoiceId stripeInvoiceId', this.stripeInvoiceId);

        duplicateInvoice({invoiceId : this.stripeInvoiceId})
        .then(result => {
            console.log('result result result', result);
            let title = '',
            message = '',
            variant = '';

            if(result.statusCode == 200){
                title = 'Success';
                message = 'Operation completed successfully.';
                variant = 'success';
            } else {
                title = 'Error';
                message = result.message;
                variant = 'error';
            }
            
            const evt = new ShowToastEvent({
                title,
                message,
                variant,
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

            this.dispatchEvent(new CloseActionScreenEvent());
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('Error Message :', error.body.message);
            const evt = new ShowToastEvent({
                title : 'Error',
                message : error.body.message,
                variant : 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CloseActionScreenEvent());
            this.showSpinner = false;

        });
    }
}