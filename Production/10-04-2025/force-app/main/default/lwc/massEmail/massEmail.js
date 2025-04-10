import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getActiveTenants from '@salesforce/apex/LWC_MassEmailController.getActiveTenants';
import sendMassEmail from '@salesforce/apex/LWC_MassEmailController.sendMassEmail';

export default class MassEmail extends LightningElement {
    @api recordId;
    @api objectApiName;
    lstSelectedTenants;
    subject;
    body;
    disabled = false;
    error;

    @wire(getActiveTenants, { recordId: '$recordId' })
    contracts;

    handleSendEmailAction() {
        // Update selected tenants
        this.updateSelectedTenants();
        // Validate all data
        if (this.validateData()) {
            sendMassEmail({ lstRecipients: this.lstSelectedTenants, subject: this.subject, htmlBody: this.body })
                .then(result => {
                    if (result === 'Success') {
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.showNotification('Success', 'The emails have been sent successfully.', 'success');
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.result = undefined;
                });
        }
    }

    validateData() {
        let passedValidation = true;
        let validationError;
        if (!this.lstSelectedTenants || this.lstSelectedTenants.length == 0) {
            passedValidation = false;
            validationError = 'You must select at leats one tenant.';
        } else if (!this.subject) {
            passedValidation = false;
            validationError = 'Please fill the subject.';
        } else if (!this.body) {
            passedValidation = false;
            validationError = 'Please fill the email body.';
        }

        if (! passedValidation) {
            this.showNotification('Warning', validationError, 'warning');
        }

        return passedValidation;
    }

    handleChange(event) {
        const field = event.target.name;
        if (field === 'subjectInput') {
            this.subject = event.target.value;
        } else if (field === 'bodyInput') {
            this.body = event.target.value;
        }
    }

    updateSelectedTenants() {
        this.lstSelectedTenants = Array.from(
            [...this.template.querySelectorAll('lightning-input')]
            .filter(element => element.checked)
            .filter(element => element.dataset.id)
            .map(element => element.dataset.id)
        );
    }

    handleCheckUncheckAll(event) {
        let checkboxes = Array.from(this.template.querySelectorAll('lightning-input'));
        let i;

        for (i = 0; i < checkboxes.length; i++) {
            // Toggle the checkbox
            checkboxes[i].checked = event.target.checked;
        }
    }

    handleBackAction() {
        this.error = undefined;
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showNotification(titleText, messageText, variant) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

}