import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import sendInvoicesToStripe from '@salesforce/apex/InvoiceService.sendInvoicesToStripe';
import sendInvoiceItemsToStripe from '@salesforce/apex/InvoiceService.sendInvoiceItemsToStripe';
import mergeDuplicateInvoices from '@salesforce/apex/InvoiceService.mergeDuplicateInvoices';

export default class SendInvoiceAndItemsToStripe extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    showSpinner;
    error;
    invoiceSent;
    stackTrace;

    renderedCallback() {
        if(!this.recordId) {
            this.showSpinner = true;
        } else if(!this.invoiceSent) {
            this.sendToStripe();
        }        
    }

    sendToStripe() {
        if(this.objectApiName === 'InvoiceItem__c') {
            this.sendInvoiceItemsToStripe();
        } else {
            this.sendInvoicesWithItemsToStripe();
        }

        this.invoiceSent = true;
    }

    sendInvoicesWithItemsToStripe() {
        sendInvoicesToStripe({recordId: this.recordId})
            .then(result => {
                console.log('result', result);
                this.navigateToInvoice(this.recordId);
                this.handleApexSuccess('Invoice synchronized');
            })
            .catch(error => {
                console.log('error', error);
                if (error.body.pageErrors && error.body.pageErrors.length > 0 && error.body.pageErrors[0].message.includes('duplicate')) {
                    let duplicateId = error.body.pageErrors[0].message.split('id: ')[1];
                    console.log(duplicateId);
                    console.log('duplicate error');
                    this.mergeDuplicateInvoices(duplicateId);
                } else {
                    this.handleApexError(error);
                }
            });
    }

    mergeDuplicateInvoices(duplicateId) {
        mergeDuplicateInvoices({recordId: this.recordId, stripeWebhookInvoiceId: duplicateId})
            .then(result => {
                console.log('merged result', result);
                this.navigateToInvoice(duplicateId);
                this.handleApexSuccess('Invoice synchronized');
            })
            .catch(error => {
                console.log('error', error);
                this.handleApexError(error);
            });
    }

    navigateToInvoice(recordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'Invoice__c',
                    actionName: 'view'
                }
            });
    }

    sendInvoiceItemsToStripe() {
        sendInvoiceItemsToStripe({recordId: this.recordId})
            .then(result => {
                this.handleApexSuccess('Invoice item synchronized');
            })
            .catch(error => {
                this.handleApexError(error);
            });
    }

    handleApexSuccess(text) {
        this.closeQuickAction();
        this.showToast(text, 'success');
    }

    handleApexError(error) {

        let toastText = this.showToastForException(error);
        this.showSpinner = false;

        if(toastText) {
            this.error = toastText;
        }

        console.log(JSON.stringify(error));                

        this.showSpinner = false;
    }

    showToastForException(error) {
        let toastText = 'Error! ';
        let variant = 'error';

        if(error.body.exceptionType === 'InvoiceService.InvoiceAlreadyHasStripeIdException') {
            this.closeQuickAction();
            toastText = 'Stripe invoice id already defined on the invoice';
            variant = 'warning';
        } else if(error.body.message && error.body.message.includes('Invalid API Key provided: null')) {
            toastText += 'Make sure related Stripe Account is not empty';
        } else if(error.body.exceptionType === 'InvoiceService.NoCustomerIdOnInvoiceException') {
            toastText += 'Customer stripe id not found on invoice or related account.';
        } else if(error.body.exceptionType === 'InvoiceService.NoCustomerIdOnInvoiceItemException') {
            toastText += 'Customer stripe id not found on invoice item or related invoice.';
        } else if(error.body.pageErrors && error.body.pageErrors.length > 0) {
            toastText += error.body.pageErrors[0].message;
        } else if(error.body.exceptionType === 'InvoiceService.InvoiceHasNoItemsException') {
            toastText += 'The invoice doesn\'t have related invoice items. Please, add invoice items and try again.';
        } else if(error.body.exceptionType === 'InvoiceService.NoContractOnInvoiceException') {
            toastText += 'Invoice must have a contract.'
        } else if(error.body.exceptionType === 'InvoiceService.InvoiceHasStripeIdException') {
            toastText += 'Invoice already has a stripe id.'
        } else if(error.body.exceptionType === 'InvoiceService.NoAmountOnInvoiceItemException') {
            toastText += 'No amount on invoice item found. Please add the amount and try again.'
        } else if(error.body.exceptionType === 'StripeService.StripeErrorException') {
            toastText = 'Stripe error! ' + error.body.message;
        } else {
            toastText += error.body.exceptionType;
            this.stackTrace = error.body.message + '. ' + error.body.stackTrace;
        }

        this.showToast(toastText, variant);

        return toastText;
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(message, variant) {
        this.dispatchEvent(new ShowToastEvent({message: message, variant: variant}));
    }
}