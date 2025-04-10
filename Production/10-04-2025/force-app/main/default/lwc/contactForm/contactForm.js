import { LightningElement, api, track } from 'lwc';

export default class ContactForm extends LightningElement {
    @api brand;

    isOpen = false;
    @track
    successful = false;

    @api
    closeModal() {
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('closed'));
    }

    @api
    showModal() {
        this.isOpen = true;
    }

    @api
    get cssClass() {
        const baseClasses = ['slds-modal'];
        baseClasses.push([this.isOpen ? 'slds-visible slds-fade-in-open' : 'slds-hidden']);
        return baseClasses.join(' ');
    }

    submitModal() {
        this.template.querySelector('.contact-form').submit();
    }

    handleSuccess() {
        this.successful = true;
    }

    handleError(evt) {
        this.successful = true;
    }
}