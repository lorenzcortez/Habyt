import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import CONTRACTNUMBER_FIELD from '@salesforce/schema/Contract.ContractNumber';
import RECORDTYPENAME_FIELD from '@salesforce/schema/Contract.RecordType.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createInvoice from '@salesforce/apex/CreateInternalInvoiceController.createInvoice';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateInternalInvoice extends LightningElement {
    _recordId;
    invoiceTypeValue = '';
    isSendInvoicewithDueDate = false;
    showLineItems = false;
    showSpinner = false;
    recordTypeName  = '';
    get invoiceTypeOptions(){
        let options = [];
        console.log('this.recordTypeName ', this.recordTypeName);
        if(this.recordTypeName == 'Rent'){
            options = [
                { label: 'Rent', value: 'Rent' },
                { label: 'Deposit', value: 'Deposit' },
                { label: 'Collections', value: 'Collections' },
            ]; 
        } else if(this.recordTypeName == 'Membership Fee') {
            options = [
                { label: 'Membership Fee', value: 'Membership Fee' },
            ];
        } else {
            options = [
                { label: 'Rent', value: 'Rent' },
                { label: 'Deposit', value: 'Deposit' },
                { label: 'Membership Fee', value: 'Membership Fee' },
                { label: 'APAC Membership Fee', value: 'APAC Membership Fee' },
                { label: 'Upcoming Rent', value: 'Upcoming Rent' },
                { label: 'Collections', value: 'Collections' },
                { label: 'Other', value: 'Other' },
            ]; 
        }
        return options;
    }

    get isInvoiceType(){
        return this.invoiceTypeValue == 'Rent' || this.invoiceTypeValue == 'Collections';
    }

    contractNumber;
    billingMethod = 'charge_automatically';
    dueDate;
    @api lineItems = [
        {
            key : 1,
            amount : null,
            description : '' ,
            isFirst : true
        }
    ];

    billingMonthValue = '';
    get billingMonthOptions(){
        return [
            {label : 'January', value : 'January'},
            {label : 'February', value : 'February'},
            {label : 'March', value : 'March'},
            {label : 'April', value : 'April'},
            {label : 'May', value  : 'May'},
            {label: 'June', value : 'June'},
            {label: 'July', value : 'July'},
            {label: 'August', value : 'August'},
            {label: 'September', value : 'September'},
            {label: 'October', value : 'October'},
            {label: 'November', value : 'November'},
            {label: 'December', value : 'December'}
        ]
    }

    billingYearValue = '';
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this._recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, {recordId: '$_recordId', fields: [CONTRACTNUMBER_FIELD, RECORDTYPENAME_FIELD]})
    getContract({ error, data }) {
        if (data) {
            this.contractNumber = data.fields.ContractNumber.value;
            this.recordTypeName = data.fields.RecordType.value.fields.Name.value;
        } else if (error) {
            console.error('Error Message', error);
        }
    }
    
    changeContract(event){
        this.contractNumber = event.detail.value;
    }

    invoiceTypeChange(event){
        this.invoiceTypeValue = event.detail.value;
    }
    /*
    onBillingType(event){
        this.isSendInvoicewithDueDate = event.target.value == 'Send Invoice with Due Date';
        if(this.isSendInvoicewithDueDate){
            this.billingMethod = 'send_invoice';
        }
    }
    */
    billingMonthChange(event){
        this.billingMonthValue = event.target.value;
    }

    billingYearChange(event){
        this.billingYearValue = event.target.value 
    }
    /*
    changeDueDate(event){
        console.log('event.target.value', event.target.value);
        this.dueDate = event.target.value;
    }
    */

    changeAmount(event){
        let identifier  = Number(event.currentTarget.dataset.identifier) - 1,
        value       = event.currentTarget.value;
        setTimeout(() => {
            this.lineItems[identifier].amount = Number(value);
        }, 500);
    }

    changeDescription(event){
        let identifier  = Number(event.currentTarget.dataset.identifier) - 1,
        value       = event.currentTarget.value;

        setTimeout(() => {
            this.lineItems[identifier].description = value;
        }, 500);
    }

    handleAddLineItem(){
        this.showLineItems = true;
        const allValid = [...this.template.querySelectorAll('.validate-item')].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allValid){
            if( this.lineItems.length < 20 ){
                this.lineItems.push({
                    key : this.lineItems.length + 1,
                    amount : null,
                    description : '' ,
                    isFirst : false
                });
    
            } else {
                const evt = new ShowToastEvent({
                    titlec : 'Error Message',
                    message : ' Line Items has exceed 20 limits.',
                    variant : 'error',
                    mode    : 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        }

        this.showLineItems = false;
    }

    onDelete(event){
        let identifier  = Number(event.currentTarget.dataset.identifier);
        this.showLineItems = true;
        this.lineItems.splice(identifier-1, 1);
        this.showLineItems = false;
    }

    handleCreateInvoice(event){
        let proceed = false;
        const allComboValid = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        const allValidItems = [...this.template.querySelectorAll('.validate-item')].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        const allValidYear = [...this.template.querySelectorAll('.validate-year')].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allComboValid && allValidItems && allValidYear) {
            proceed = true;
            if( this.billingMethod == 'send_invoice'){
                const allValid = [...this.template.querySelectorAll('.validate-due')].reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);

                if(allValid){
                    proceed = true;
                } else {
                    proceed = false;
                    const evt = new ShowToastEvent({
                        title: 'Error Message',
                        message: 'Due Date is required.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
            } 

            if(proceed){
                this.showLineItems = true;
                let lineItems = this.lineItems.map( item => {
                    return {
                        amount  : item.amount,
                        description : item.description
                    };
                });

                let invoiceData = {
                    contractNumber  : this.contractNumber,
                    invoiceType     : this.invoiceTypeValue,
                    billingMethod   : this.billingMethod,
                    lineItems
                };

                if( this.billingMonthValue != '' && (this.invoiceTypeValue == 'Rent' || this.invoiceTypeValue == 'Collections')){
                    invoiceData.billingMonth = this.billingMonthValue;
                }

                if( this.billingYearValue != '' && (this.invoiceTypeValue == 'Rent' || this.invoiceTypeValue == 'Collections')){
                    invoiceData.billingYear = Number(this.billingYearValue);
                }

                if( this.billingMethod == 'send_invoice'){
                    invoiceData.dueDate = this.dueDate
                }
                this.showSpinner = true;
                createInvoice({ recordId : this._recordId, jsonBody : JSON.stringify(invoiceData)})
                .then(result => {
                    console.log('Result : ', result);
                    this.showSpinner = false;
                    this.showLineItems = false;
                    const evt = new ShowToastEvent({
                        title : 'Success',
                        message : 'Invoice successfully created.',
                        variant : 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    window.open('/'+result, '_self');
                })
                .catch(error => {
                    console.log('Error Message :', error);
                });
            }
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please check required field/s.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    }
}