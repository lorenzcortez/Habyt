import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class RoomDetailPopup extends NavigationMixin(LightningElement) {
    @api popupSuite = [];
    @api popupHome = [];
    @api popupRoom = [];
    //@api activeSections = ['Fees', 'Selling', 'Home', 'Amenities'];

    connectedCallback() {
        //console.log('Room::',JSON.stringify(this.popupRoom));
        //console.log('Home::',JSON.stringify(this.popupHome));
        //console.log('Suite::',JSON.stringify(this.popupSuite));
    }

    get IsBeaconDateInPast(){
        if(this.popupRoom.AvailableDateTrig__c == null || this.popupRoom.AvailableDateTrig__c == undefined){
            return true;
        }else{
            var selectedDate = new Date(this.popupRoom.AvailableDateTrig__c);
            var now = new Date();
            now.setHours(0,0,0,0);
            if (selectedDate < now) {
                //console.log("Selected date is in the past");
                return true;
            } else {
                //console.log("Selected date is NOT in the past");
                return false;
            }
        }
    }

    get ThreeMonthPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 3){
                    price = pricing.Rent__c;
                }
              });
        }

        return price;
    }
    get SixMonthPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 6){
                    price = pricing.Rent__c;
                }
              });
        }

        return price;
    }
    get NineMonthPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 9){
                    price = pricing.Rent__c;
                }
              });
        }

        return price;
    }
    get TwelveMonthPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 12){
                    price = pricing.Rent__c;
                }
              });
        }

        return price;
    }

    get ThreeMonthNetPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 3){
                    price = pricing.Net_Rent__c;
                }
              });
        }

        return price;
    }
    get SixMonthNetPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 6){
                    price = pricing.Net_Rent__c;
                }
              });
        }

        return price;
    }
    get NineMonthNetPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 9){
                    price = pricing.Net_Rent__c;
                }
              });
        }

        return price;
    }
    get TwelveMonthNetPrice(){
        let price;
        if(this.popupRoom && this.popupRoom.Pricing_Matrix__r){
            this.popupRoom.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 12){
                    price = pricing.Net_Rent__c;
                }
              });
        }

        return price;
    }

    
    get concessionDetails(){
        let concessionText = '';
        if(this.popupRoom && this.popupRoom.Room__r){
            
            concessionText += this.popupRoom.Room__r[0].Name;
            if(this.popupRoom.Room__r.length > 1){
                concessionText += ' + ';
            }
        }

        return concessionText;
    }

    // Navigate to View Room Page
    navigateToViewRoomPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.popupRoom.Id,
                objectApiName: 'Room__c',
                actionName: 'view'
            },
        });
    }
    copyUrlToClipboard (e) {
        e.preventDefault();
        try {
            let url = e.target.dataset.url;
            if(!~url.indexOf('http')) {
                url = 'http://' + url;
            }

            // Create hidden element to select
            const el = document.createElement('textarea');
            el.value = url;
            el.setAttribute('readonly', '');
            el.style.position = 'absolute';
            el.style.left = '-9999px';
            document.body.appendChild(el);

            // Save user's current selection
            const selected =
                document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : null;
            
            // Select and copy
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);

            // Reset to previous selection if necessary
            if (selected) {
                document.getSelection().removeAllRanges();
                document.getSelection().addRange(selected);
            }

            const evt = new ShowToastEvent({
                title: 'Successfully copied: ' + url,
                variant: 'success',
            });
            this.dispatchEvent(evt);
        } catch(err) {
            console.log('Error copying url', err.message);
            const evt = new ShowToastEvent({
                title: 'Error copying: ' + url,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }
}