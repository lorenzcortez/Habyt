import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getRooms from '@salesforce/apex/BookingFlowController.getRooms';


export default class RoomDetail extends NavigationMixin(LightningElement) {
    @api brand;
    @api room;
    @api urlParam ;

    @track imageUrl;
    @track imageIndex = 0;
    @track imageListLength = 0;
    @track movingDate;

    @track isContactShown = false;

    @track carouselItems = [];
    @track carouselOptions = { autoScroll: false, autoScrollTime: 5 };

    connectedCallback() {
        let fullURL = window.location.href;
        let searchParams = new URL(fullURL).searchParams;
        let reference = searchParams.get('reference');
        this.movingDate = searchParams.get('available');
       
        getRooms({parameters: {"referenceId": reference}})
        .then(result => {
            if (result.numberOfElements > 0) { // TODO: do we need to handle the case of multiple rooms?
                this.room = result.content[0];
                this.initRoom();
            }
        }).catch(error => {
            console.log(error);
            this.error = error;
        });
    }

    initRoom() {
        if(this.room != null || this.room != undefined ){
            if (this.room.images.length > 0) {
                for (let i=0; i<this.room.images.length; i++) {
                    this.carouselItems.push({
                        image: this.room.images[i].files.original.url,
                        description: this.room.images[i].type //,
                    });
                }
            }

            if (this.room.descriptions != undefined) {
                for (let i = 0; i < this.room.descriptions.length; i++) {
                    this.room.descriptions[i].description = this.room.descriptions[i].description.toLowerCase();
                }
            }
            this.brand = this.room.brandApi;
        }                      
    }

    toggleContact() {
        this.isContactShown = ! this.isContactShown;
    }

    get contactButtonClass() {
        return 'slds-button pointer' + (this.isContactShown ? ' active' : '');
    }

    get showContactClass() {
        return this.isContactShown ? 'slds-show' : 'slds-hide';
    }

    bookNow() {
        try { 
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'booking'
                },
                state: {
                    'reference': this.room.referenceId,
                    'available': this.movingDate
                }
            });
        }catch(err){
            console.log('err30::'+err);
        }
    }
}