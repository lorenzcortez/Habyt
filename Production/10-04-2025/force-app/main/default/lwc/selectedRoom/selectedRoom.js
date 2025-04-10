import { LightningElement,api ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SelectedRoom extends NavigationMixin(LightningElement) {
    @api room;
    @api earliestDate;
    @api picturesNumber;

    @track rentFormatted;
    @track areaFormatted;

    @track carouselItems = [];
    @track carouselOptions = { autoScroll: false, autoScrollTime: 5 };
    @track roomTitle;

    connectedCallback() {
        try{
            if (this.room.images.length > 0) {
                let picturesMaxNumber = this.room.images.length < this.picturesNumber ? this.room.images.length : this.picturesNumber;
                for (let i=0; i < picturesMaxNumber; i++) {
                    this.carouselItems.push({
                        image: this.room.images[i].files.original.url,
                        description: this.room.images[i].type //,
                    });
                }
            }
            switch (this.room.shareType) {
                case 'Private apartment':
                    this.roomTitle = this.room.shareType;
                    break;
                default:
                    this.roomTitle = this.room.shareType + ' in ' + this.room.bedrooms + '-Bedroom Unit';
                    break;
            }
        }catch(err){
            console.log('err'+err);
        }
    }

    roomDetailPage() {       
        try{
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'details'
                },
                state: {
                    'reference': this.room.referenceId,
                    'available': this.earliestDate
                }
            });
        }catch(err){
            console.log('err30::'+err);
        }
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
                    'available': this.earliestDate
                }
            });
        }catch(err){
            console.log('err30::'+err);
        }
    }
}