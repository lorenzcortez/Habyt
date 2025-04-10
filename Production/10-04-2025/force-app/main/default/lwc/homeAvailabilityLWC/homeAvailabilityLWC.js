import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RetreiveCities from '@salesforce/apex/HomeAvailabilityLWCController.RetreiveCities';
import RetreiveHomes from '@salesforce/apex/HomeAvailabilityLWCController.RetreiveHomes';
import getPickListValues from '@salesforce/apex/HomeAvailabilityLWCController.getPickListValues';
import GetRooms from '@salesforce/apex/HomeAvailabilityLWCController.GetRooms';
import { NavigationMixin } from 'lightning/navigation';
import GetOpportunityRecord from '@salesforce/apex/HomeAvailabilityLWCController.GetOpportunityRecord';
import GetRoomRecord from '@salesforce/apex/HomeAvailabilityLWCController.GetRoomRecord';
import GetHomeRecord from '@salesforce/apex/HomeAvailabilityLWCController.GetHomeRecord';
import GetSuiteRecord from '@salesforce/apex/HomeAvailabilityLWCController.GetSuiteRecord';
import RetreiveNeighborhoods from '@salesforce/apex/HomeAvailabilityLWCController.RetreiveNeighborhoods';

export default class HomeAvailabilityLWC extends LightningElement {

    @api recordId;
    @api CityOptions = [];
    @api HomeOptions = [];
    //@api BrandOptions = [];
    @api UnitTypeOptions = [];
    @api NeighborhoodOptions = []

    @track selectedCity = '';
    @track selectedHome = '';
    @track selectedSortOption = 'Property__r.isFeatured__c';
    @track selectedOrderOption = 'asc';
    @track selectedBrand = '';
    @track selectedTermLength = '';
    @track selectedUnitType = '';
    @track selectedAffordableUnit = 'Affordable_Unit__c = FALSE';
    @track selectedNeighborhood = '';
    @track selectedPrice = -1;
    @track BedroomCount = -1;

    //@track roomList = [];

    @track CurrentMonthRooms = [];
    @track NextMonthRooms = [];
    @track ThirdMonthRooms = [];
    @track FourthMonthRooms = [];

    noCurrentMonRoomsFound = false;
    noNextMonRoomsFound = false;
    noThirdMonRoomsFound = false;
    noFourthMonRoomsFound = false;

    @api isLoading = false;
    @api showModalPopup = false;

    @track popupHome = [];
    @track popupRoom = [];
    @track popupSuite = [];

    @api error;
    @api errorTitle;

    @track noHomesFound = false;
    @track noNeighborhoodsFound = false;
    @track OppRecord;

    @track iframeSrc = null;
    @track roomIdForCreatingTour = null;

    connectedCallback() {

        this.isLoading = true;

        RetreiveCities().then(res => {
            this.CityOptions = res;
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Cities';
            console.error('err retreiving Cities:', err);
        });
        /*
        getPickListValues({ objApiName: 'Home__c', fieldName: 'Brand__c' }).then(res => {
            this.BrandOptions = res;
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Brand picklist';
            console.error('err retreiving Brand picklist:', err);
        });
        */
        getPickListValues({ objApiName: 'Property__c', fieldName: 'Allowable_term_lengths__c' }).then(res => {
            this.TermLengthOptions = res;
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Allowable term lengths picklist';
            console.error('err retreiving Allowable_term_lengths__c picklist:', err);
        });


        if (this.recordId != null && this.recordId != undefined && this.recordId != '') {

            GetOpportunityRecord({ OppId: this.recordId }).then(res => {
                console.log('Opp Record:: ', res);
                if (res.City_Lookup__c != null && res.City_Lookup__c != undefined)
                    this.selectedCity = res.City_Lookup__c;
                //if (res.Brand__c != null && res.Brand__c != undefined) {
                    //this.selectedBrand = res.Brand__c.charAt(0).toUpperCase() + res.Brand__c.slice(1);
                //}
                if (res.Home_Committed__c != null && res.Home_Committed__c != undefined)
                    this.selectedHome = res.Home_Committed__c;
                if (res.Max_Budget__c != null && res.Max_Budget__c != undefined)
                    this.selectedPrice = res.Max_Budget__c;


                RetreiveHomes({ CityId: this.selectedCity, Brand: this.selectedBrand, Neighborhood: this.selectedNeighborhood }).then(res => {
                    this.HomeOptions = res;
                    if (res == null || res.length == 0) {
                        this.noHomesFound = true;
                    }

                    this.searchRooms();
                }
                ).catch(err => {
                    this.isLoading = false;
                    this.error = err;
                    this.errorTitle = 'Error retreiving Homes';
                    console.error('err retreiving Homes:', err);
                });

                RetreiveNeighborhoods({ CityId: this.selectedCity }).then(res => {
                    this.NeighborhoodOptions = res;
                    if (res == null || res.length == 0) {
                        this.noNeighborhoodsFound = true;
                    }
                }
                ).catch(err => {
                    this.isLoading = false;
                    this.error = err;
                    this.errorTitle = 'Error retreiving Neighborhoods';
                    console.error('err retreiving neighborhoods:', err);
                });

            }
            ).catch(err => {
                this.isLoading = false;
                this.error = err;
                this.errorTitle = 'Error retreiving Opportunity Record: ';
                console.error('Error retreiving Opportunity Record:', err);
            });

        }
        this.isLoading = false;

        this.initCreateTourModal();
    }


    get SortOptions() {
        return [
            { label: 'Featured', value: 'Property__r.isFeatured__c' },
            { label: 'Price', value: 'Price_Matrix_12_Month' },
            { label: 'Square Foot', value: 'Square_Footage__c' },
            { label: 'Date Available', value: 'AvailableDateTrig__c' },
        ];
    }

    get OrderOptions() {
        return [
            { label: 'Ascending ', value: 'asc' },
            { label: 'Descending', value: 'desc' },
        ];
    }

    get StatusOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Available ', value: 'Available' },
            { label: 'Occupied', value: 'Occupied' },
        ];
    }
    
    get UnitTypeOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Traditional', value: 'Traditional' },
            { label: 'Coliving', value: 'Coliving' },
        ];
    }
    
    get AffordableUnitOptions() {
        return [
            { label: 'Affordable Unit', value: 'Affordable_Unit__c = TRUE' },
            { label: 'Market Rate', value: 'Affordable_Unit__c = FALSE' },
            { label: 'Both', value: '' },
        ];
    }
    get CurrentMonthName() {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];

        const d = new Date();
        return monthNames[d.getMonth()] + ' ' + d.getFullYear();
    }

    get NextMonthName() {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];

        let d1 = new Date();
        let d = new Date(d1.setMonth(d1.getMonth() + 1));
        return monthNames[d.getMonth()] + ' ' + d.getFullYear();
    }
    get ThirdMonthName() {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];

        let d1 = new Date();
        let d = new Date(d1.setMonth(d1.getMonth() + 2));
        return monthNames[d.getMonth()] + ' ' + d.getFullYear();
    }

    get FourthMonthName() {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];

        let d1 = new Date();
        let d = new Date(d1.setMonth(d1.getMonth() + 3));
        return monthNames[d.getMonth()] + ' ' + d.getFullYear();
    }

    get IsBeaconDateInPast() {
        if (this.popupRoom.AvailableDateTrig__c == null || this.popupRoom.AvailableDateTrig__c == undefined) {
            return true;
        } else {
            var selectedDate = new Date(this.popupRoom.AvailableDateTrig__c);
            var now = new Date();
            now.setHours(0, 0, 0, 0);
            if (selectedDate < now) {
                //console.log("Selected date is in the past");
                return true;
            } else {
                //console.log("Selected date is NOT in the past");
                return false;
            }
        }
    }

    handleCityChange(event) {
        this.isLoading = true;
        this.noHomesFound = false;
        this.noNeighborhoodsFound = false;
        this.selectedCity = event.target.value;

        this.selectedHome = '';
        this.selectedBrand = '';
        this.selectedNeighborhood = '';

        //console.log(event.target.value);
        //console.log('this.selectedCity',this.selectedCity);
        //console.log('this.selectedBrand',this.selectedBrand);
        //console.log('this.selectedNeighborhood',this.selectedNeighborhood);

        RetreiveHomes({ CityId: this.selectedCity, Brand: this.selectedBrand, Neighborhood: this.selectedNeighborhood }).then(res => {
            this.HomeOptions = res;
            //console.log('Home Options::', JSON.stringify(this.HomeOptions));
            if (res == null || res.length == 0) {
                this.noHomesFound = true;
            }
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Homes';
            console.error('err retreiving Homes:', err);
        });
        RetreiveNeighborhoods({ CityId: this.selectedCity }).then(res => {
            this.NeighborhoodOptions = res;
            console.log('NeighborhoodOptions::', JSON.stringify(this.NeighborhoodOptions));
            if (res == null || res.length == 0) {
                this.noNeighborhoodsFound = true;
            }
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Neighborhoods';
            console.error('err retreiving neighborhoods:', err);
        });
        this.isLoading = false;
    }

    handleHomeChange(event) {
        console.log(event.target.value);
        this.selectedHome = event.target.value;

        GetHomeRecord({ HomeId: this.selectedHome }).then(res => {
            if (res && res.NeighbourhoodRef__c) {
                this.selectedNeighborhood = res.NeighbourhoodRef__c;
            }
        }
        ).catch(err => {
            //console.error('Error retreiving Home Record:' , err);
        });
    }
    handleBrandChange(event) {
        this.isLoading = true;
        this.noHomesFound = false;
        console.log(event.target.value);
        this.selectedBrand = event.target.value;

        RetreiveHomes({ CityId: this.selectedCity, Brand: this.selectedBrand, Neighborhood: this.selectedNeighborhood }).then(res => {
            this.HomeOptions = res;
            if (res == null || res.length == 0) {
                this.noHomesFound = true;
            }
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Homes';
            console.error('err retreiving Homes:', err);
        });
        this.isLoading = false;
    }
    handleTermLengthChange(event) {
        this.selectedTermLength = event.target.value;
    }
    handleUnitTypeChange(event) {
        this.selectedUnitType = event.target.value;
    }
    handleAffordableUnitChange(event) {
        this.selectedAffordableUnit = event.target.value;
    }

    handleNeighborhoodChange(event) {
        this.selectedNeighborhood = event.target.value;
        this.noHomesFound = false;

        RetreiveHomes({ CityId: this.selectedCity, Brand: this.selectedBrand, Neighborhood: this.selectedNeighborhood }).then(res => {
            this.HomeOptions = res;
            if (res == null || res.length == 0) {
                this.noHomesFound = true;
            }
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Homes';
            console.error('err retreiving Homes:', err);
        });

    }
    handleSortByChange(event) {
        console.log(event.target.value);
        this.selectedSortOption = event.target.value;
    }
    handleOrderChange(event) {
        console.log(event.target.value);
        this.selectedOrderOption = event.target.value;
    }
    handlePriceChange(event) {
        console.log(event.target.value);
        this.selectedPrice = event.target.value;
    }
    handleBedRoomCountChange(event) {
        this.BedroomCount = event.target.value;
    }

    searchRooms() {

        this.isLoading = true;

        Promise.all([
            
            GetRooms({ CityId: this.selectedCity, HomeId: this.selectedHome, Brand: this.selectedBrand, TermLength: this.selectedTermLength, UnitType: this.selectedUnitType, AffordableUnit: this.selectedAffordableUnit, Neighborhood: this.selectedNeighborhood, Price: this.selectedPrice, BedroomCount: this.BedroomCount, SortField: this.selectedSortOption, SortBy: this.selectedOrderOption, checkboxFilters: this.SelectedCheckboxFilters, Month: 0 }).then(res => {
                this.CurrentMonthRooms = res;
                this.noCurrentMonRoomsFound = false;
                if (res == undefined || res.length == 0) {
                    this.noCurrentMonRoomsFound = true;
                } else {
                    this.CurrentMonthRooms = this.sortRoomsbyPricingMetrix(this.CurrentMonthRooms);
                }
            }
            ).catch(err => {
                this.error = err;
                this.errorTitle = 'Error retreiving Current Month Rooms';
                console.error('err retreiving Current Month Rooms:', err);
            }),

            GetRooms({ CityId: this.selectedCity, HomeId: this.selectedHome, Brand: this.selectedBrand, TermLength: this.selectedTermLength, UnitType: this.selectedUnitType, AffordableUnit: this.selectedAffordableUnit, Neighborhood: this.selectedNeighborhood, Price: this.selectedPrice, BedroomCount: this.BedroomCount, SortField: this.selectedSortOption, SortBy: this.selectedOrderOption, checkboxFilters: this.SelectedCheckboxFilters, Month: 1 }).then(res => {
                this.NextMonthRooms = res;
                this.noNextMonRoomsFound = false;
                if (res == undefined || res.length == 0) {
                    this.noNextMonRoomsFound = true;
                } else {
                    this.NextMonthRooms = this.sortRoomsbyPricingMetrix(this.NextMonthRooms);
                }
            }
            ).catch(err => {
                //this.isLoading = false;
                this.error = err;
                this.errorTitle = 'Error retreiving Next Month Rooms';
                console.error('retreiving Next Month Rooms:', err);
            }),

            GetRooms({ CityId: this.selectedCity, HomeId: this.selectedHome, Brand: this.selectedBrand, TermLength: this.selectedTermLength, UnitType: this.selectedUnitType, AffordableUnit: this.selectedAffordableUnit, Neighborhood: this.selectedNeighborhood, Price: this.selectedPrice, BedroomCount: this.BedroomCount, SortField: this.selectedSortOption, SortBy: this.selectedOrderOption, checkboxFilters: this.SelectedCheckboxFilters, Month: 2 }).then(res => {
                this.ThirdMonthRooms = res;
                this.noThirdMonRoomsFound = false;
                if (res == undefined || res.length == 0) {
                    this.noThirdMonRoomsFound = true;
                } else {
                    this.ThirdMonthRooms = this.sortRoomsbyPricingMetrix(this.ThirdMonthRooms);
                }
                //hide loader
                //this.isLoading = false;
            }
            ).catch(err => {
                this.error = err;
                this.errorTitle = 'Error retreiving Third Month Rooms';
                console.error('err retreiving Third Month Rooms:', err);
            }),
            
            GetRooms({ CityId: this.selectedCity, HomeId: this.selectedHome, Brand: this.selectedBrand, TermLength: this.selectedTermLength, UnitType: this.selectedUnitType, AffordableUnit: this.selectedAffordableUnit, Neighborhood: this.selectedNeighborhood, Price: this.selectedPrice, BedroomCount: this.BedroomCount, SortField: this.selectedSortOption, SortBy: this.selectedOrderOption, checkboxFilters: this.SelectedCheckboxFilters, Month: 3 }).then(res => {
                this.FourthMonthRooms = res;
                this.noFourthMonRoomsFound = false;
                if (res == undefined || res.length == 0) {
                    this.noFourthMonRoomsFound = true;
                } else {
                    this.FourthMonthRooms = this.sortRoomsbyPricingMetrix(this.FourthMonthRooms);
                }
                //hide loader
                //this.isLoading = false;
            }
            ).catch(err => {
                //this.isLoading = false;
                this.error = err;
                this.errorTitle = 'Error retreiving Fourth Month Rooms';
                console.error('err retreiving Fourth Month Rooms:', err);
            })

        ]).then((values) => {
            this.isLoading = false;
        });
    }

    sortRoomsbyPricingMetrix(roomsArray){

        let arrayForSort = [...roomsArray];

        if (this.selectedSortOption === 'Price_Matrix_12_Month') {
            if(this.selectedOrderOption === 'asc'){
                arrayForSort.sort((a, b) => {
                    if(a.Pricing_Matrix__r && b.Pricing_Matrix__r && a.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12) != undefined && b.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12) != undefined){
                        const aRent = a.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12).Rent__c;
                        const bRent = b.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12).Rent__c;
                        return aRent - bRent;
                    }else{
                        return -1;
                    }
                });
            }else{
                arrayForSort.sort((a, b) => {
                    if(a.Pricing_Matrix__r && b.Pricing_Matrix__r && a.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12) != undefined && b.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12) != undefined){
                        const aRent = a.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12).Rent__c;
                        const bRent = b.Pricing_Matrix__r.find(pm => pm.Lease_Term_Months__c === 12).Rent__c;
                        return bRent - aRent;
                    }else{
                        return -1;
                    }
                });
            }
        }
        
        return arrayForSort;
    }

    handleNavigateToRecord(event) {

        //reset variables
        this.popupHome = [];
        this.popupRoom = [];
        this.popupSuite = [];

        //var selectedRow = event.currentTarget;
        //let roomId = selectedRow.dataset.id;
        let roomId = event.detail;
        console.log('room Id::', roomId);



        GetRoomRecord({ RoomId: roomId }).then(res => {

            this.popupRoom = res;
            console.log('popupRoom', JSON.stringify(this.popupRoom));
            if (res.ApartmentRef__c != null && res.ApartmentRef__c != undefined) {
                GetSuiteRecord({ SuiteId: res.ApartmentRef__c }).then(res2 => {
                    this.popupSuite = res2;
                }
                ).catch(err2 => {
                    console.error('Error retreiving Suite Record:', err2);
                });
            }

            if (res.Property__c != null && res.Property__c != undefined) {
                GetHomeRecord({ HomeId: res.Property__c }).then(res3 => {
                    this.popupHome = res3;
                }
                ).catch(err => {
                    console.error('Error retreiving Home Record:', err);
                });
            }
            this.showModalPopup = true;
        }
        ).catch(err => {
            this.isLoading = false;
            this.error = err;
            this.errorTitle = 'Error retreiving Room Record: ';
            console.error('Error retreiving Room Record:', err);
        });


        /*
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: roomId,
                objectApiName: 'Room__c',
                actionName: 'view'
            }
        });
        */
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.showModalPopup = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.showModalPopup = false;
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
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

    get errorMessages() {
        return this.reduceErrors(this.error);
    }

    get CheckBoxFilters() {
        const filters = [
            { label: 'Has Elevator', value: 'Property__r.Elevator__c = TRUE' },
            { label: 'Loft', value: 'Loft__c = TRUE' },
            { label: 'Wellness Studio', value: 'Property__r.Wellness_Studio__c = TRUE' },
            { label: 'En-suite Bathroom', value: 'En_suite_Bathroom__c = TRUE' },
            { label: 'No ESA In Suite?', value: 'ApartmentRef__r.ESA_in_Suite__c = FALSE' }
        ];

        filters.forEach((filter) => {
            filter.changeHandler = () => {
                const isSelected = !!this.SelectedCheckboxFilters.filter(selected => selected === filter.value).length;
                if (isSelected) {
                    this.SelectedCheckboxFilters = this.SelectedCheckboxFilters.filter(selected => selected !== filter.value);
                } else {
                    this.SelectedCheckboxFilters.push(filter.value);
                }

                console.log('filters', this.SelectedCheckboxFilters);
            }
        })
        return filters;
    }

    SelectedCheckboxFilters = [];

    get selectedCheckboxValues() {
        return this.SelectedCheckboxFilters.join(',');
    }

    buttonStatefulState = false;
    handleChange(e) {
        this.SelectedCheckboxFilters = e.detail.value;
    }

    openCreateTourModal(e) {
        this.roomIdForCreatingTour = e.target.dataset.roomId;
        this.iframeSrc = '/apex/skedCommonBookingGrid?opportunityId=' + this.recordId + '&roomId=' + this.roomIdForCreatingTour + '&_t=' + Date.now();
    }

    closeCreateTourModal() {
        this.roomIdForCreatingTour = null;
        this.iframeSrc = null;
    }

    initCreateTourModal() {
        console.log('initCreateTourModal');

        window.addEventListener('message', event => {
            let data = event.data;
            if (data) {
                console.log(data.message);
                if (data.message && data.message === 'cancel') {
                    this.closeCreateTourModal();
                } else if (data.message && data.message === 'done') {
                    this.closeCreateTourModal();
                    // Didn't make this change, but probably this is to keep the ui
                    // in sync with the changes made while in this tour component
                    // window.location.reload();
                }
            }
        });
    }
}