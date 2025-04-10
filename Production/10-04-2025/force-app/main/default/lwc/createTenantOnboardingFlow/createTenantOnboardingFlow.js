import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getPicklistValues from '@salesforce/apex/CreateTenantOnboardingFlowCont.getPicklistValues';
import getRecordSteps from '@salesforce/apex/CreateTenantOnboardingFlowCont.getOnboardingStepsRecord';
import createTenantOnboardingRecords from '@salesforce/apex/CreateTenantOnboardingFlowCont.createTenantOnboardingRecords';

export default class CreateTenantOnboardingFlow extends LightningElement {
    @api 
    recordId;
    isLoading = true;
    flowVariantOptions = [];
    isRendered = false;
    @track 
    dataInput = {
        'contractNumber': null,
        'contractId': null,
        'memberContractNumber': null,
        'memberContractId': null,
        'oppId': null,
        'flowVariant': null,
        'stepsData': []
    };

    connectedCallback(){
        Promise.all([
            this.getFlowVariantOptions()
         ]).then(() =>  
            setTimeout(() => {    
                this.apiCallOut()
            }, 2000)
        );
    }

    // renderedCallback() {
    //     if (!this.isRendered && this.recordId != null) {
    //         this.getFlowVariantOptions();
    //         this.apiCallOut();
    //     }
    // }

    async getFlowVariantOptions(){
        try{
            const picklistVal = await getPicklistValues({sObjectAPI:'Property__c', fieldAPI: 'TOF_Variant__c'});
            this.flowVariantOptions = this.getLabelsObject(picklistVal);
        }catch(error){
            console.error(error);
        }
    }
    
    getLabelsObject(picklistVal){
        const labels = [];
        labels.push({label:'', value:''});
        picklistVal.forEach(function(pickVal){
            labels.push({label:pickVal.label, value:pickVal.value});
        });
        return labels;
    }

    async apiCallOut(){
        console.log('recordId ' + this.recordId);
   
        let getRecordStep = await getRecordSteps({
            recordId: this.recordId
        });
        // console.log('getRecordStep ' + JSON.stringify(getRecordStep));

        if(getRecordStep){
            this.dataInput.contractId = this.recordId,
            this.dataInput.contractNumber = getRecordStep.contractNumber;
            this.dataInput.memberContractId = getRecordStep.memberContractId;
            this.dataInput.memberContractNumber = getRecordStep.memberContractNumber;
            this.dataInput.oppId = getRecordStep.oppId;
            this.dataInput.flowVariant = getRecordStep.flowVariant;
            this.dataInput.stepsData = getRecordStep.stepsData;
        }
        console.log('dataInput ' + JSON.stringify(this.dataInput));

        this.isLoading = false;
    }

    handleChange(event){
        if(event.target.name === 'contractNumber' || event.target.name === 'memberContractNumber' || event.target.name === 'flowVariant'){
            this.dataInput[event.target.name] = event.currentTarget.value;
        }else{
            let rowNumber = parseInt(event.target.dataset.row, 10);
            this.dataInput.stepsData = this.dataInput.stepsData.map(record => {
                return record.row === rowNumber ? { ...record, value: event.currentTarget.checked } : record;
            });
        }
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async generateFlow(){
        this.isLoading = true;

        let createRecs = await createTenantOnboardingRecords({
            jsonBody: JSON.stringify(this.dataInput)
        });

        if(createRecs.isSuccess){
            this.showToast('Success!', createRecs.message, 'success', 'dismissable'); 
            this.dispatchEvent(new CloseActionScreenEvent());
        }else{
            this.showToast('Error!', createRecs.message, 'error', 'dismissable');
        }
    }

    showToast(title, message, variant, mode){
        const toastEvent = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
        this.dispatchEvent(toastEvent);
    }
}