import { LightningElement, wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import STRIPE_INVOICE_ID from '@salesforce/schema/Invoice__c.Stripe_Invoice_Id__c';
import execute from '@salesforce/apex/UpdateStripeMetadata.execute';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class UpdateStripeMetadata extends LightningElement {
    _recordId;
    billingMonthValue = '';
    billingYearValue = '';
    showSpinner = false;
    stripeInvoiceId;

    get billingMonthOptions(){
        return [
            {label : 'None', value : ''},
            {label : 'January', value : 'January'},
            {label : 'February', value : 'February'},
            {label : 'March', value : 'March'},
            {label : 'April', value : 'April'},
            {label : 'May', value  : 'May'},
            {label: 'June', value : 'June'},
            {label: 'July', value : 'July'},
            {label: 'August', value : 'August'},
            {label: 'September', value : 'September'},
            {label: 'October', value : 'October'},
            {label: 'November', value : 'November'},
            {label: 'December', value : 'December'}
        ]
    }

    get billingYearOptions(){
        const d = new Date();
        let year = d.getFullYear();
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

    billingMonthChange(event){
        this.billingMonthValue = event.detail.value;
    }
    
    billingYearChange(event){
        this.billingYearValue = event.detail.value;
    }

    handleUpdateMetadata(event){
        this.showSpinner = true;
        console.log('this.stripeInvoiceId', this.stripeInvoiceId);
        console.log('this.billingMonthValue', this.billingMonthValue);
        console.log('this.billingYearValue', this.billingYearValue);

        if( this.stripeInvoiceId ){
            let params = {
                invoiceId : this.stripeInvoiceId, 
                billingMonthValue : this.billingMonthValue != '' ? this.billingMonthValue : null, 
                billingYearValue: this.billingYearValue != '' ? this.billingYearValue : null
            }
    
            execute(params)
            .then(result => {
                console.log('result result result', result);
                let title = '',
                message = '',
                variant = '';
    
                if(result.statusCode == 200){
                    title = 'Success';
                    message = 'Stripe Metadata successfully updated.';
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
                console.log('Error Message :', error);
            });
        } else {
            const evt = new ShowToastEvent({ title : 'Error', message : 'Stripe Id not found.', variant: 'error', mode: 'dismissable'});
            this.dispatchEvent(evt);
        }
        
    }
}