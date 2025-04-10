import { LightningElement, track, api } from 'lwc';
import getFromTwilioCalls from "@salesforce/apex/TwilioCallLogsLWC.getFromTwilioCalls";
import getToTwilioCalls from "@salesforce/apex/TwilioCallLogsLWC.getToTwilioCalls";
import getCustomerPhone from "@salesforce/apex/TwilioCallLogsLWC.getCustomerPhone";
import getFromTwilioMessages from "@salesforce/apex/TwilioCallLogsLWC.getFromTwilioMessages";
import getToTwilioMessages from "@salesforce/apex/TwilioCallLogsLWC.getToTwilioMessages";
import getLatestRecording from '@salesforce/apex/TwilioCallLogsLWC.getLatestRecording';

const actions = [
    { label: 'Go to latest Recording', name: 'go_to_recording' }
];

const columns = [
    { label: 'Call SID', fieldName: 'callUrl', type: 'url',   initialWidth:100, typeAttributes: { label: { fieldName: 'sid' }, target: '_blank' } },
    { label: 'From', fieldName: 'from', type: 'phone',   initialWidth:100,wrapText: true },
    { label: 'To', fieldName: 'to', type: 'phone', wrapText: true,  initialWidth:100 },
    { label: 'Direction', fieldName: 'direction', wrapText: true,  initialWidth:100 },
    { label: 'Status', fieldName: 'status', wrapText: true,  initialWidth:100 },
    { label: 'Start Time', fieldName: 'start_time', type: 'date', initialWidth:170, wrapText: true, typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true } },
    { label: 'Duration', fieldName: 'duration', type: 'number', wrapText: true,  initialWidth:100 },
    { label: 'End Time', fieldName: 'end_time', type: 'date', wrapText: true,  initialWidth:170, typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true } },
    { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto' } }
];

const messageColumns = [
    { label: 'Message SID', fieldName: 'messageURL', type: 'url',  initialWidth:100, typeAttributes: { label: { fieldName: 'sid' }, target: '_blank' } },
    { label: 'Body', fieldName: 'body', wrapText: true,  initialWidth:200},
    { label: 'From', fieldName: 'from', type: 'phone', wrapText: true,  initialWidth:100 },
    { label: 'To', fieldName: 'to', type: 'phone', wrapText: true,  initialWidth:100 },
    { label: 'Direction', fieldName: 'direction', wrapText: true,  initialWidth:100 },
    { label: 'Status', fieldName: 'status', wrapText: true,  initialWidth:100 },
    { label: 'Date Sent', fieldName: 'date_sent', type: 'date', wrapText: true,  initialWidth:170, typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true } }
]


export default class TwilioLogs extends LightningElement {

    @track fromCalls = [];
    @track toCalls = [];
    @track allCalls = [];
    columns = columns;
    messageColumns = messageColumns;
    @track customerPhone = '';
    @track customerPhoneFormatted = '';
    @track phoneNumberFound = false;
    @track toCallsError = '';
    @track fromCallsError = '';
    // Message States
    @track allMessages = [];
    @track fromMessages = [];
    @track toMessages = [];
    @track toMessagesError = '';
    @track fromMessagesError = '';
    @track allMessageError = '';
    //@track allCallsError = '';
    @track lwcTitle = '';
    @api recordId;
    @track isLoaded = false;

    @track error;
    @track errorTitle;

    isLoading;

    connectedCallback() {
        this.message = [];
        this.findCustomerInfo();
        this.loadCalls();
        this.loadMessages();
    }
    /*
        renderedCallback(){
            this.message = [];
            this.loadCalls();
            this.findCustomerInfo();
        }
    */

    loadMessages() {
        getToTwilioMessages({ recordId: this.recordId })
            .then((result) => {
                const obj = JSON.parse(result);
                if (obj && obj.messages) {
                    this.toMessages = obj.messages;
                }

                if (this.toMessages.length == 0 && this.toMessagesError == '') {
                    this.toMessagesError = 'No Twilio Outbound messages found matching ' + this.customerPhone;
                }

                for (let i = 0; i < this.toMessages.length; i++) {
                    const element = this.toMessages[i];
                    this.toMessages[i].messageURL = `https://console.twilio.com/us1/monitor/logs/sms?frameUrl=%2Fconsole%2Fsms%2Flogs%2FACfb4affff04744e54b4dc74c73c882fdd%2F${element.sid}%3F__override_layout__%3Dembed%26bifrost%3Dtrue%26x-target-region%3Dus1&currentFrameUrl=%2Fconsole%2Fsms%2Flogs%2FACfb4affff04744e54b4dc74c73c882fdd%2F${element.sid}%3F__override_layout__%3Dembed%26bifrost%3Dtrue%26x-target-region%3Dus1`;
                    if (element.direction && element.direction.toLowerCase().includes('inbound')) {
                        this.toMessages[i].direction = 'Inbound';
                    } else if (element.direction && element.direction.toLowerCase().includes('outbound')) {
                        this.toMessages[i].direction = 'Outbound';
                    }
                }

               
                this.allMessages = this.allMessages.concat(this.toMessages);
                this.allMessages.sort((a, b) => {
                    return new Date(b.date_sent) - new Date(a.date_sent);
                });

                if(this.toMessages.length === 0 && this.fromMessages.length === 0 && this.allMessageError == ''){
                    this.allMessageError = 'No Twilio messages found matching ' + this.customerPhone;
                }

            })
            .catch((error) => {
                console.error("TO MESSAGES ERROR", error);
                this.error = error;
                this.errorTitle = 'Error retreiving data';
                this.isLoaded = true;
            });

        getFromTwilioMessages({ recordId: this.recordId })
            .then((result) => {
                const obj = JSON.parse(result);
                if (obj && obj.messages) {
                    this.fromMessages = obj.messages;
                }

                if (this.fromMessages.length == 0 && this.fromMessagesError == '') {
                    this.fromMessagesError = 'No Twilio Inbound messages found matching ' + this.customerPhone;
                }

                for (let i = 0; i < this.fromMessages.length; i++) {
                    const element = this.fromMessages[i];
                    this.fromMessages[i].messageURL = `https://console.twilio.com/us1/monitor/logs/sms?frameUrl=%2Fconsole%2Fsms%2Flogs%2FACfb4affff04744e54b4dc74c73c882fdd%2F${element.sid}%3F__override_layout__%3Dembed%26bifrost%3Dtrue%26x-target-region%3Dus1&currentFrameUrl=%2Fconsole%2Fsms%2Flogs%2FACfb4affff04744e54b4dc74c73c882fdd%2F${element.sid}%3F__override_layout__%3Dembed%26bifrost%3Dtrue%26x-target-region%3Dus1`;
                    if (element.direction && element.direction.toLowerCase().includes('inbound')) {
                        this.fromMessages[i].direction = 'Inbound';
                    } else if (element.direction && element.direction.toLowerCase().includes('outbound')) {
                        this.fromMessages[i].direction = 'Outbound';
                    }
                }

                this.allMessages = this.allMessages.concat(this.fromMessages);
                this.allMessages.sort((a, b) => {
                    return new Date(b.date_sent) - new Date(a.date_sent);
                });

                if(this.toMessages.length === 0 && this.fromMessages.length === 0 && this.allMessageError == ''){
                    this.allMessageError = 'No Twilio messages found matching ' + this.customerPhone;
                }

            })
            .catch((error) => {
                console.error("FROM MESSAGES ERROR", error);
                this.error = error;
                this.errorTitle = 'Error retreiving data';
                this.isLoaded = true;
            });
    }

    loadCalls() {
        getFromTwilioCalls({ recordId: this.recordId })
            .then((result) => {
                console.log(result);
                const obj = JSON.parse(result);

                if (obj && obj.calls) {
                    console.log(obj.calls);
                    this.fromCalls = obj.calls;
                } else if (obj.message) {
                    this.fromCallsError = 'Message: ' + obj.message + '<br/>';
                    this.fromCallsError += 'Detail: ' + obj.detail + '<br/>';
                    if (obj.more_info)
                        this.fromCallsError += 'More info: ' + obj.more_info + '';
                }

                if (this.fromCalls.length == 0 && this.fromCallsError == '') {
                    this.fromCallsError = 'No Twilio Inbound phone calls found matching ' + this.customerPhone;
                }
                for (var i = 0; i < this.fromCalls.length; i++) {
                    this.fromCalls[i].callUrl = 'https://console.twilio.com/us1/monitor/logs/calls?frameUrl=%2Fconsole%2Fvoice%2Fcalls%2Flogs%2F' + this.fromCalls[i].sid;
                    if (this.fromCalls[i].direction && this.fromCalls[i].direction.toLowerCase().includes('inbound')) {
                        this.fromCalls[i].direction = 'Inbound Call';
                    } else if (this.fromCalls[i].direction && this.fromCalls[i].direction.toLowerCase().includes('outbound')) {
                        this.fromCalls[i].direction = 'Outbound Call';
                    }
                }
                console.log('From Calls::', JSON.stringify(this.fromCalls));
                this.allCalls = this.toCalls.concat(this.fromCalls);
                this.allCalls.sort((a, b) => {
                    return new Date(b.start_time) - new Date(a.start_time);
                });
                //this.isLoaded = true;
            })
            .catch((error) => {
                console.error(error);
                this.error = error;
                this.errorTitle = 'Error retreiving data';
                this.isLoaded = true;
            });

        getToTwilioCalls({ recordId: this.recordId })
            .then((result) => {
                console.log(result);
                const obj = JSON.parse(result);

                if (obj && obj.calls) {
                    console.log(obj.calls);
                    this.toCalls = obj.calls;
                } else if (obj.message) {
                    this.toCallsError = 'Message: ' + obj.message + '<br/>';
                    this.toCallsError += 'Detail: ' + obj.detail + '<br/>';
                    if (obj.more_info)
                        this.toCallsError += 'More info: ' + obj.more_info + '';
                }

                if (this.toCalls.length == 0 && this.toCallsError == '') {
                    this.toCallsError = 'No Twilio Outbound phone calls found matching ' + this.customerPhone;
                }

                for (var i = 0; i < this.toCalls.length; i++) {
                    this.toCalls[i].callUrl = 'https://console.twilio.com/us1/monitor/logs/calls?frameUrl=%2Fconsole%2Fvoice%2Fcalls%2Flogs%2F' + this.toCalls[i].sid;
                    if (this.toCalls[i].direction && this.toCalls[i].direction.toLowerCase().includes('inbound')) {
                        this.toCalls[i].direction = 'Inbound Call';
                    } else if (this.toCalls[i].direction && this.toCalls[i].direction.toLowerCase().includes('outbound')) {
                        this.toCalls[i].direction = 'Outbound Call';
                    }
                }
                //console.log('To Calls::', JSON.stringify(this.toCalls));
                this.isLoaded = true;
                this.allCalls = this.toCalls.concat(this.fromCalls);
                this.allCalls.sort((a, b) => {
                    return new Date(b.start_time) - new Date(a.start_time);
                });
            })
            .catch((error) => {
                console.error(error);
                this.error = error;
                this.errorTitle = 'Error retreiving data';
                this.isLoaded = true;
            });

    }

    get allCallsError() {
        let errors = '';
        if (this.toCallsError != '' && this.fromCallsError != '') {
            if (this.toCallsError != '')
                errors = this.toCallsError;
            else
                errors = this.fromCallsError;
        }
        console.log('all calls error::', errors);
        return errors;
    }
    findCustomerInfo() {
        getCustomerPhone({ recordId: this.recordId })
            .then((result) => {
                this.customerPhone = result;
                if (this.customerPhone) {
                    this.phoneNumberFound = true;
                    this.customerPhoneFormatted = this.formatPhoneNumber(this.customerPhone);
                    console.log('customerPhoneFormatted::', this.customerPhoneFormatted);
                    if (this.customerPhoneFormatted) {
                        this.lwcTitle = ' Twilio Calls ' + this.customerPhoneFormatted;
                    } else {
                        this.lwcTitle = ' Twilio Calls ' + this.customerPhone;
                        this.customerPhoneFormatted = this.customerPhone;
                    }
                } else {
                    this.phoneNumberFound = false;
                }
                this.isLoaded = true;
            })
            .catch((error) => {
                console.error(error);
                this.error = error;
                this.errorTitle = 'Error retreiving data';
                this.isLoaded = true;
            });
    }

    formatPhoneNumber(phoneNumberString) {
        var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
        var match = cleaned.match(/^(1|)?(\d{3})(\d{3})(\d{4})$/);
        if (match) {
            var intlCode = (match[1] ? '+1 ' : '');
            return [intlCode, '(', match[2], ') ', match[3], '-', match[4]].join('');
        }
        return null;
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

    async handleRowAction(event){
        this.isLoading = true;
        
        let actionName = event.detail.action.name;
        console.log('action name: '+actionName);
        let row = JSON.parse(JSON.stringify(event.detail.row));
        if(actionName == 'go_to_recording'){
            console.log('row to get recording parsed?');
            console.log(row);

            let result = await getLatestRecording({ callSid : row.sid });
            if(result){
                let parsedResult = JSON.parse(result);
                console.log('the parsed result wotdo');
                console.log(parsedResult);

                if(parsedResult.recordings && Array.isArray(parsedResult.recordings)){
                    let latestRecording;

                    for(let index in parsedResult.recordings){
                        let recording = parsedResult.recordings[index];
                        if(!latestRecording || latestRecording.created < recording.created){
                            latestRecording = recording;
                        }
                    }
                    
                    console.log('this is the latest recording');
                    console.log(latestRecording);

                    if(latestRecording){
                        window.open('https://api.twilio.com/2010-04-01/Accounts/'+latestRecording.account_sid+'/Recordings/'+latestRecording.sid);
                    } else {
                        alert('No recording found for this call.');
                    }
                } else {
                    alert('No recording found for this call.');
                }
            } else {
                alert('An issue has occurred while getting the Recording URL.');
            }

            this.isLoading = false;
        }
    }
    
}