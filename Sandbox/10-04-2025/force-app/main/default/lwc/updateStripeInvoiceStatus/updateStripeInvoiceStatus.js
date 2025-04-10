import { LightningElement, wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import STRIPE_INVOICE_ID from '@salesforce/schema/Invoice__c.Stripe_Invoice_Id__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateInvoiceStatus from '@salesforce/apex/UpdateStripeInvoiceStatus.updateInvoiceStatus';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class UpdateStripeInvoiceStatus extends LightningElement {
    _recordId;
    displayMessage  = false;
    invoiceStatus   = '';
    stripeInvoiceId = '';
    showSpinner = false;

    get statusOptions() {
        return [
            { label: 'Void', value: 'void' },
            { label: 'Mark Uncollectible', value: 'mark-uncollectible' },
            { label: 'Mark as Paid', value: 'mark-paid-out-of-band' },
        ];
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this._recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, {recordId: '$_recordId', fields: [STRIPE_INVOICE_ID]})
    getContract({ error, data }) {
        if (data) {
            this.stripeInvoiceId = data.fields.Stripe_Invoice_Id__c.value;
        } else if (error) {
            console.error('Error Message', error);
        }
    }

    onchangeStatus(event){
       this.invoiceStatus = event.detail.value;
    }

    handleUpdateInvoice(event){
        const allComboValid = [...this.template.querySelectorAll('lightning-radio-group')].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allComboValid){
            this.displayMessage = true;
        } 
    }

    handleCancel(event){
        this.displayMessage = false;
    }

    handleContinue(event){
        this.showSpinner = true;
        console.log('this.invoiceStatus', this.invoiceStatus);
        console.log('this.stripeInvoiceId', this.stripeInvoiceId);

        updateInvoiceStatus({invoiceId : this.stripeInvoiceId, invoiceStatus : this.invoiceStatus })
        .then(result => {
           console.log('result result result', result);
           let title = '',
           message = '',
           variant = '';

            if(result.statusCode == 200){
                title = 'Success';
                message = 'Invoice updated successfully.';
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
            this.displayMessage = false;
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('Error Message :', error.body.message);
        });
    }
}