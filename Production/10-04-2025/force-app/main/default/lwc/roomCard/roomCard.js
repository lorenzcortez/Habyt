import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetRoomRecord from '@salesforce/apex/HomeAvailabilityLWCController.GetRoomRecord';

export default class RoomCard extends LightningElement {
    @api room = [];
    
    connectedCallback(){
        console.log(JSON.stringify(this.room));
    }
    openPopupWindow(event) {

        var selectedRow = event.currentTarget;
        let roomId = selectedRow.dataset.id;
        console.log('room Id::', roomId);


        // Creates the event with the data.
        const selectedEvent = new CustomEvent("expandbtnclick", {
            detail: roomId
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    get IsBeaconDateInPast() {
        if (this.room.AvailableDateTrig__c == null || this.room.AvailableDateTrig__c == undefined) {
            return true;
        } else {
            var selectedDate = new Date(this.room.AvailableDateTrig__c);
            var now = new Date();
            now.setHours(23, 59, 59);
            if (selectedDate < now) {
                //console.log("Selected date is in the past");
                return true;
            } else {
                //console.log("Selected date is NOT in the past");
                return false;
            }
        }
    }
    get TwelveMonthPrice(){
        let price;
        if(this.room && this.room.Pricing_Matrix__r){
            this.room.Pricing_Matrix__r.forEach(function (pricing){ 
                if(pricing.Lease_Term_Months__c === 12){
                    price = pricing.Rent__c;
                }
              });
        }

        return price;
    }

    get concessionDetails(){
        let concessionText = '';
        if(this.room && this.room.Room__r){
            
            concessionText += this.room.Room__r[0].Name;
            if(this.room.Room__r.length > 1){
                concessionText += ' + ';
            }
        }

        return concessionText;
    }

    copyUrlToClipboard(e) {
        e.preventDefault();
        try {

            let url = e.target.dataset.url;
            if (!~url.indexOf('http')) {
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

        } catch (err) {
            console.log('Error copying url', err.message);
            const evt = new ShowToastEvent({
                title: 'Error copying: ' + url,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }

}