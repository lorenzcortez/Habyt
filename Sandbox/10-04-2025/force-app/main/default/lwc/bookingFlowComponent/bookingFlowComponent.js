import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PageUtils from 'c/pageUtils';

import getBrandCities from '@salesforce/apex/BookingFlowController.getBrandCities';
import getDistricts from '@salesforce/apex/BookingFlowController.getDistricts';
import getRooms from '@salesforce/apex/BookingFlowController.getRooms';

import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import CITY_FIELD from '@salesforce/schema/Property__c.City_Picklist__c';

import ROOM_OBJECT from '@salesforce/schema/Room__c';
import TYPE_FIELD from '@salesforce/schema/Room__c.TypePick__c';


export default class ApexImperativeMethod extends LightningElement {
    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    propertyObject;
    @wire(getObjectInfo, { objectApiName: ROOM_OBJECT })
    roomObject;

    // Type Filtering
    @track type = 'ROOM';

    @track shareType = '';
    @track typesLoaded = false;
    @track typesPicklist = [{label:"Everything", value:""}];

    @wire(getPicklistValues, { recordTypeId: '$roomObject.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD })
    getShareTypes({data, error}) {
        if (data != undefined) {
            this.typesLoaded = true;
            this.typesPicklist.push(...data.values);
        }
    }

    // City filtering
    @track city = '';
    @track citiesLoaded = false;
    @track citiesPicklist = [{label:"All cities", value: ""}];
    
    @wire(getPicklistValues, { recordTypeId: '$propertyObject.data.defaultRecordTypeId', fieldApiName: CITY_FIELD })
    getCities({data, error}) {
        if (data != undefined) {
            getBrandCities({brandApiName: this.brand})
                .then(result => {
                    for (let value of data.values) {
                        if (result.includes(value.value)) {
                            this.citiesPicklist.push(value);
                        }
                    }
                    this.citiesLoaded = true;
                }).catch(error => {
                    console.log(error);
                    this.error = error;
                });
        }
    }

    // District filtering
    @track district = '';
    @track districtsLoaded = false;
    @track districtsByCity;
    @track districtsPicklist = [{value:"", label:"All districts"}];

    @wire(getDistricts, {})
    getAllDistricts({data, error}) {
        this.districtsByCity = data;
        this.districtsLoaded = true;
    }

    // Date filtering
    @track earliestDate;
    @track minDate = "";

    @track response = {};
    @track error;

    @track page = 0;
    @track size = 10;
    @track rooms = [];
    @track more = true;
    @track loading = true;
    @track showMore = false;

    @api brand;
    @api dateThreshold;
    @api picturesNumber;

    preProcessRoom(room) {
        const utils = new PageUtils();
        room.availableDate = utils.formatDate(room.availableDate);
        return room;
    }

    connectedCallback() {
        let fullURL = window.location.href;
        let searchParams = new URL(fullURL).searchParams;
        
        if (searchParams.has('moveInDate')) {
            this.earliestDate = searchParams.get('moveInDate');
        }
        
        if (searchParams.has('city')) {
            this.city = searchParams.get('city');
        }

        this.fetchData(true);
    }

    fetchData(reset) {
        const utils = new PageUtils();
        let tmpDate = new Date();
        tmpDate.setDate(tmpDate.getDate() + 3);

        this.minDate = utils.getDateStr(tmpDate);
        
        if (! this.earliestDate) {
            this.earliestDate = this.minDate;
        }

        if (this.earliestDate < this.minDate) {
            // this.error = 'Move-in date must be at least 3 days in the future';
            this.earliestDate = this.minDate;
        } 
        
        if (reset) {
            this.rooms = [];
        }
    
        this.loading = true;
        this.showMore = false;

        let params = {
            "page": this.page.toString(), 
            "size": this.size.toString(),
            "type": this.type,
            "brandApi": this.brand,
            "availableDateTo": this.earliestDate
        };

        if (this.shareType) {
            params["shareType"] = this.shareType;
        }
        if (this.city) {
            params["city"] = this.city;
        }
        if (this.district) {
            params["district"] = this.district;
        }

        getRooms({parameters: params})
            .then(result => {
                this.rooms.push(...result.content.map(this.preProcessRoom))
                this.more = result.content.length == this.size;
                this.loading = false;
                this.showMore = this.more;

            }).catch(error => {
                console.log(error);
                this.error = error;
                this.loading = false;
            });
        
        if (this.error) {
            // TODO: display the error somehow
        }
    }
    
    LoadMore() {
        this.page ++;
        this.fetchData(false);
    }

    OnTypeSelected(event) {
        this.shareType = event.detail.value;
        this.fetchData(true);
    }

    OnCitySelected(event) {
        this.district = "";
        this.districtsPicklist = [{value:"", label:"All districts"}];
        this.city = event.detail.value;
        if (this.districtsByCity[this.city]) {
            for (let i=0; i<this.districtsByCity[this.city].length; i++) {
                this.districtsPicklist.push({value: this.districtsByCity[this.city][i].Name, label:this.districtsByCity[this.city][i].Name});
            }
        }
        this.fetchData(true);
    }

    OnDistrictSelected(event) {
        this.district = event.detail.value;
        this.fetchData(true);
    }

    OnDateSelected(event) {
        this.earliestDate = event.detail.value;
        this.fetchData(true);
    }
}