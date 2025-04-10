import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import BRANDS from '@salesforce/resourceUrl/Brands';

export default class TopBar extends NavigationMixin(LightningElement) {
    @api brand;

    @track logo_url;

    @track popupVisible = false;

    connectedCallback() {
        this.logo_url = BRANDS + '/logos/' + this.brand.toLowerCase() + '.jpg';
    }

    togglePopup() {
        this.popupVisible = ! this.popupVisible;
    }

    hidePopup() {
        this.popupVisible = false;
    }

    goHome() {
        try{
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Home'
                }
            });
        }catch(err){
            console.log('err30::'+err);
        }
    }
}