import { LightningElement, api } from 'lwc';
import UpdateScore from '@salesforce/apex/UpdateScoreOnFeedbackLWC.UpdateScoreOnFeedback';

export default class UpdateScoreOnFeedback extends LightningElement {

    @api recordId;

    connectedCallback() {
        let parameters = this.getQueryParameters();
        console.log(parameters);

        if (parameters['score'] != undefined || parameters['score'] != null){
            console.log(parameters['score'])
            UpdateScore({ recordId: this.recordId, score: parameters['score'] }).then(res => {
                console.log(res);
            }
            ).catch(err => console.error('err:' + err));
        }

    }
    
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }
}