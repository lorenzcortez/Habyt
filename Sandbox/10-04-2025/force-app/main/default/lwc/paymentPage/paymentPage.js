import { LightningElement, api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PageUtils from 'c/pageUtils';

import getRooms from '@salesforce/apex/BookingFlowController.getRooms';
import getFirstRent from '@salesforce/apex/BookingFlowController.getFirstRent';
import submitApplication from '@salesforce/apex/BookingFlowController.submitApplication';
import getPhoneCodes from '@salesforce/apex/BookingFlowController.getPhoneCodes';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import GENDER_FIELD from '@salesforce/schema/Account.GenderPick__c';
import OCCUPATION_FIELD from '@salesforce/schema/Account.OccupationPick__c';
import INCOME_FIELD from '@salesforce/schema/Account.IncomeLevelPick__c';
import NATIONALITY_FIELD from '@salesforce/schema/Account.Nationality__c';


export default class PaymentPage extends NavigationMixin(LightningElement) {
    @track brand;

    @track picklistsLoaded = 0;
    @track dataInitialized = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountObject;

    @track genderPicklist = [];
    @wire(getPicklistValues, { recordTypeId: '$accountObject.data.defaultRecordTypeId', fieldApiName: GENDER_FIELD })
    getGenders({data, error}) {
        if (data != undefined) {
            this.genderPicklist.push(...data.values);
            this.onPicklistLoaded();
        }
    }

    @track occupationPicklist = [];
    @wire(getPicklistValues, { recordTypeId: '$accountObject.data.defaultRecordTypeId', fieldApiName: OCCUPATION_FIELD })
    getOccupation({data, error}) {
        if (data != undefined) {
            this.occupationPicklist.push(...data.values);
            this.onPicklistLoaded();
        }
    }

    @track incomePicklist = [];
    @wire(getPicklistValues, { recordTypeId: '$accountObject.data.defaultRecordTypeId', fieldApiName: INCOME_FIELD })
    getIncome({data, error}) {
        if (data != undefined) {
            this.incomePicklist.push(...data.values);
            this.onPicklistLoaded();
        }
    }

    @track nationalityPicklist = [];
    @wire(getPicklistValues, { recordTypeId: '$accountObject.data.defaultRecordTypeId', fieldApiName: NATIONALITY_FIELD })
    getNationalities({data, error}) {
        if (data != undefined) {
            this.nationalityPicklist.push(...data.values);
            this.onPicklistLoaded();
        }
    }

    @track selectedPhoneCode;
    @track phonePickList;
    @wire(getPhoneCodes) wiredPhoneCodes({ error, data }) {
        if (data) {
            this.phonePickList = this.fillPhonePicklist(data);    
            this.sortPhonesArray();        
            this.selectedPhoneCode = this.phonePickList[0].value;
        } else if (error) {
            console.error(error);
        }
    }

    sortPhonesArray() {
        this.phonePickList.sort(
            function(firstElement, secondElement) {
                var labelFirstElement = firstElement.masterLabel.toLowerCase();
                var labelSecondElement = secondElement.masterLabel.toLowerCase();

                if (labelFirstElement < labelSecondElement)
                    return -1;
                if (labelFirstElement > labelSecondElement)
                    return 1;

                return 0;
            }
        );
    }

    fillPhonePicklist(data) {
        let codesArray = [];

        for(let i in data) {
            let phoneCodeObject = data[i];

            codesArray.push({
                value: phoneCodeObject.DeveloperName,
                label: phoneCodeObject.MasterLabel + ' (' + phoneCodeObject.Phone_Code__c + ')',
                code: phoneCodeObject.Phone_Code__c,
                masterLabel: phoneCodeObject.MasterLabel
            });
        }

        return codesArray;
    }

    handlePhoneCode(event) {
        this.selectedPhoneCode = event.detail.value;
    }

    getPhoneCodeByName(name) {
        for(let i in this.phonePickList) {
            if(this.phonePickList[i].value === name) {
                return this.phonePickList[i].code;
            }
        }
        
        return null;
    }

    get messagePatternMismatch() {
        return "Your number format is invalid. Please do not use any character and do not start with '0'.";
    }

    onPicklistLoaded() {
        this.picklistsLoaded ++;
        if (this.picklistsLoaded >= 4) {
            this.selectedStep = 'step1';
        }
    }

    get allDataRendered() {
        return this.picklistsLoaded >= 4 && this.room;
    }

    @track minDate;
    @track maxDate;

    @track room;
    @track earliestDate;
    @track firstRent;
    @track earliestDateStr;

    @track selectedStep = 'loading';
    @track carouselItems = [];
    @track carouselOptions = { autoScroll: false, autoScrollTime: 5 };

    @track policyUrl = "https://habyt.com/privacy-policy";

    @track UserData = {    
        firstName: '',
        lastName: '',
        email: '',
        companyName: '',
        addressLine1: '',
        addressLine2: '',
        addressLine3: '',
        postalCode: '',
        city: '',
        state: '',
        countryCode: '',
        phone: '',
        type: 'MOBILE',
        idNumber: '',
        nationality: '',
        gender: '',
        birthday: '',
        occupation: '',
        incomeLevel: '',
        referenceId: '',
    };

    connectedCallback(){      
        let fullURL = window.location.href;
        let searchParams = new URL(fullURL).searchParams;
        let reference = searchParams.get('reference');

        this.earliestDate = searchParams.get('available');
        const utils = new PageUtils();
        this.earliestDateStr = utils.formatDate(this.earliestDate);

        getRooms({parameters: {"referenceId": reference}})
            .then(result => {
                if (result.numberOfElements > 0) { // TODO: do we need to handle the case of multiple rooms?
                    this.room = result.content[0];
                    this.initData();
                }
            }).catch(error => {
                console.log(error);
                this.error = error;
            });

        getFirstRent({parameters: {"referenceId": reference, "startOfContract": this.earliestDate}})
            .then(result => {
                this.firstRent = result;
            }).catch(error => {
                console.log(error);
                this.error = error;
            });
    }

    initData() {
        this.initRoomDate();

        if (this.room.images != undefined && this.room.images.length > 0) { 
            for (let i=0; i<this.room.images.length; i++) {
                this.carouselItems.push({
                    image: this.room.images[i].files.original.url,
                    description: this.room.images[i].type //,
                });
            }
        }
        this.UserData.referenceId = this.room.referenceId;
        this.dataInitialized = true;
        this.brand = this.room.brandApi;
        
        switch (this.brand) {
            case 'Quarters':
            case 'MediciLiving':
                this.policyUrl = "https://quarters.com/privacy-policy/?__hstc=186302838.e0e895a67079580c5473d9cfb9a855d8.1624986489996.1624986489996.1624986489996.1&__hssc=186302838.1.1624986489996&__hsfp=1079805803";
                break;
        
            default:
                this.policyUrl = "https://habyt.com/privacy-policy";
                break;
        }
    }

    initRoomDate() {
        this.minDate = this.room.leaseConditions.earliestStartOfContract;
        this.maxDate = this.room.leaseConditions.latestStartOfContract;
    }

    onDateSelected(event) {
        this.earliestDate = event.detail.value;
    }

    formatDate(dateValue) {
        let dateSplitted = dateValue.split('-');
        let formattedDate = dateSplitted[2] + '.' + dateSplitted[1] + '.' + dateSplitted[0];

        return formattedDate;
    }

    get calendarMessageOverflow() {
        return "Move-in date cannot be after the " + this.formatDate(this.maxDate);
    }

    get calendarMessageUnderflow() {
        return "Move-in date cannot be before the " + this.formatDate(this.minDate);
    }

    get MainPage() {
        return 'MainData ' + ((this.selectedStep == 'step3' || !this.dataInitialized || this.picklistsLoaded < 4) ? 'slds-hide' : 'slds-show');
    }
    get LoadingPage() {
        return 'MainData ' + ((this.selectedStep == 'loading' || !this.dataInitialized || this.picklistsLoaded < 4) ? 'slds-show' : 'slds-hide');
    }
    get ThankyouPage() {
        return 'ThankyouData ' + (this.selectedStep == 'step3' ? 'slds-show' : 'slds-hide');
    }

    get divClassStep1() {
        return 'payment-step-1 ' + (this.selectedStep == 'step1' ? 'slds-show' : 'slds-hide');
    }
    get tabClassStep1() {
        return 'tab slds-var-p-around_small' + (this.selectedStep == 'step1' ? ' selected' : '');
    }
    get divClassStep2() {
        return 'payment-step-2 ' + (this.selectedStep == 'step2' ? 'slds-show' : 'slds-hide');
    }
    get tabClassStep2() {
        return 'tab slds-var-p-around_small' + (this.selectedStep == 'step1' ? '' : ' selected');
    }
    
    selectedStep1 () {
        this.selectedStep = 'step1';
    }
    selectedStep2 () {
        const allValid = [...this.template.querySelectorAll('.payment-step-1 .validate')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            this.selectedStep = 'step2';
        }
    }

    GoBack () {
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

    GoHome () {
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

    Submit(event){
        const allValid = [...this.template.querySelectorAll('.payment-step-2 .validate')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        
        if (allValid) {
            this.selectedStep = 'loading';
            this.concatenatePhoneAndCode();
            let payload = JSON.stringify(this.UserData);
            submitApplication({userPayload: payload, startOfContract: this.earliestDate})
                .then(result => {
                    this.selectedStep = 'step3';
                })
                .catch(error => {
                    console.log(error);
                    this.error = error;
                    this.selectedStep = 'step2';
                });
        }
    }

    concatenatePhoneAndCode() {
        if(this.selectedPhoneCode && this.getPhoneCodeByName(this.selectedPhoneCode)) {
            this.UserData.phone = this.getPhoneCodeByName(this.selectedPhoneCode) + this.UserData.phone;
        }
    }

    handleFirstName(event) {
        this.UserData.firstName = event.target.value;
    }
    handleLastName(event) {
        this.UserData.lastName = event.target.value;
    }
    handleEmail(event) {
        this.UserData.email = event.target.value;
    }
    handleCompanyName(event) {
        this.UserData.companyName = event.target.value;
    }
    handleAddressLine1(event) {
        this.UserData.addressLine1 = event.target.value;
    }
    handleAddressLine2(event) {
        this.UserData.addressLine2 = event.target.value;
    }
    handleAddressLine3(event) {
        this.UserData.addressLine3 = event.target.value;
    }
    handlePostalCode(event) {
        this.UserData.postalCode = event.target.value;
    }
    handleCity(event) {
        this.UserData.city = event.target.value;
    }
    handleState(event) {
        this.UserData.state = event.target.value;
    }
    handleCountryCode(event) {
        this.UserData.countryCode = event.target.value;
    }
    handlePhone(event) {
        this.UserData.phone = event.target.value;
    }
    handleType(event) {
        this.UserData.type = event.target.value;
    }
    handleIdNumber(event) {
        this.UserData.idNumber = event.target.value;
    }
    handleNationality(event) {
        this.UserData.nationality = event.target.value;
    }
    handleGender(event) {
        this.UserData.gender = event.target.value;
    }
    handleBirthday(event) {
        this.UserData.birthday = event.target.value;
    }
    handleOccupation(event) {
        this.UserData.occupation = event.target.value;
    }
    handleIncomeLevel(event) {
        this.UserData.incomeLevel = event.target.value;
    }
    handleReferenceId(event) {
        this.UserData.referenceId = event.target.value;
    }
}