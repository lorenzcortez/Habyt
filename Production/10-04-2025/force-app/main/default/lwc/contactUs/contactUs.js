import { LightningElement, track, api } from 'lwc';

export default class ContactUs extends LightningElement {
    @api mode;
    @api brand;

    @track contactPhone;
    @track needBackdrop;

    connectedCallback() {
        switch (this.brand) {
            case 'Quarters':
                this.contactPhone = '+49 30 21502830';
                break;
        
            case 'MediciLiving':
                this.contactPhone = '+49 30 208980336';
                break;
        
            case 'ErasmosRoom':
                this.contactPhone = '+34 518 89 02 91';
                break;
        
            default:
                this.contactPhone = '+49 30 30808568';
                break;
        }

        this.needBackdrop = this.mode == 'popup';
    }
        
    get modeClass() {
        return this.mode == 'popup' ? 'modePopup slds-var-p-around_small' : '';
    }

    openModal() {
        this.template.querySelector('c-contact-form').showModal();
    }

    onModalClosed() {
        this.dispatchEvent(new CustomEvent('hide'));
    }

    clickedOutside() {
        this.dispatchEvent(new CustomEvent('hide'));
    }
}