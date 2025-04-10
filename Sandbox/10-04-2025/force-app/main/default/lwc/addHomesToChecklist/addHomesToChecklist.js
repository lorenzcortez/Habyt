import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAllHomes from '@salesforce/apex/AddHomesToChecklistLWC.fetchHomesList';
import createChecklists from '@salesforce/apex/AddHomesToChecklistLWC.createChecklistHomes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const COLS = [
    { label: 'Name', fieldName: 'recordLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, wrapText: true },
    { label: 'Marketing Name', fieldName: 'Marketing_Name__c', type: 'text', wrapText: true },
    { label: 'Home Type', fieldName: 'Home_Type__c', type: 'text', wrapText: true }
];

export default class AddHomesToChecklist extends LightningElement {

    cols = COLS;
    @api recordId;
    @track preSelectedRows = [];
    @track homesList = [];

    //Errror handling
    @track error;
    @track errorTitle;

    connectedCallback() {
        this.loadCaseRecord();
    }

    loadCaseRecord() {
        getAllHomes({ recordId: this.recordId })
            .then((result) => {

                var tempList = [];
                for (var i = 0; i < result.homesList.length; i++) {
                    let tempRecord = Object.assign({}, result.homesList[i]); //cloning object  
                    tempRecord.recordLink = "/" + tempRecord.Id;
                    tempList.push(tempRecord);
                }
                this.homesList = tempList;

                //console.log('result::', JSON.stringify(result));
                //this.homesList = result.homesList;
                if (result.selectedIdSet)
                    this.preSelectedRows = result.selectedIdSet;
                //console.log('homesList::' + JSON.stringify(this.homesList));
                //console.log('preSelectedRows::'+JSON.stringify(this.preSelectedRows));
            })
            .catch((error) => {
                console.error(error);
                this.error = error;
                this.errorTitle = 'Error retreiving data';
            });
    }

    saveData() {
        var selectedRecords =
            this.template.querySelector("lightning-datatable").getSelectedRows();
        createChecklists({ recordId: this.recordId, selectedHomesList: selectedRecords })
            .then(result => {
                //return refreshApex(this.homesList);
                this.loadCaseRecord();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!',
                        message: 'Data saved successfully.',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                if (error.body != undefined && error.body.message != undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error following the record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                }
                //alert('An error occured: ' + JSON.stringify(error));
            })
    }

    get errorMessages() {
        return this.reduceErrors(this.error);
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
}