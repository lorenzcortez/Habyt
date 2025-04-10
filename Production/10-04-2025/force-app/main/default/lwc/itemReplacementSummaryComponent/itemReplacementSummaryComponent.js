import { LightningElement , track, api } from 'lwc';
import getSummary from '@salesforce/apex/ItemReplacementComponentController.GetSummary';
import getSuiteOrders from '@salesforce/apex/ItemReplacementComponentController.GetSuiteOrders';
export default class ItemReplacementSummaryComponent extends LightningElement {
    @api recordId;
    @api Details;
    @api AccountName;
    @api HomeName;
    @api SuiteName;
    
    @api homebugetyearly;
    @api homebugetmonthly;
    @api approvedhomeorderAmountthismonth;
    @api approvedhomeorderAmountthisyear;
    @api newmonthlyhomeorderamount;
    @api newyearlyhomeorderamount;
        
    @api approvedsuiteorderAmountthismonth;
    @api approvedsuiteorderAmountthisyear;
    @api newmonthlysuiteorderamount;
    @api newyearlysuiteorderamount;
    
    @api OtherOrderList = [];
    
    
    connectedCallback() {
        
        getSummary({ recordId: this.recordId }).then(res => {
            this.Details = res;
            this.AccountName = res.AccountName;
            this.HomeName = res.HomeName;
            this.SuiteName = res.SuiteName;

            this.homebugetyearly = res.homebugetyearly;
            this.homebugetmonthly = res.homebugetmonthly;
            this.approvedhomeorderAmountthismonth = res.approvedhomeorderAmountthismonth;
            this.approvedhomeorderAmountthisyear = res.approvedhomeorderAmountthisyear;
            this.newmonthlyhomeorderamount = res.newmonthlyhomeorderamount;
            this.newyearlyhomeorderamount = res.newyearlyhomeorderamount;
                
            this.approvedsuiteorderAmountthismonth = res.approvedsuiteorderAmountthismonth;
            this.approvedsuiteorderAmountthisyear = res.approvedsuiteorderAmountthisyear;
            this.newmonthlysuiteorderamount = res.newmonthlysuiteorderamount;
            this.newyearlysuiteorderamount = res.newyearlysuiteorderamount;

            console.log('this.Details::',this.AccountName);
            console.log('this.Details::',this.Details);
            console.log('this.Details::' + JSON.stringify(this.Details));
        }
        ).catch(err => {
            this.error = err;
            console.error('err retreiving BiosDetails:', err);
        });

        getSuiteOrders({ recordId: this.recordId }).then(res => {
            
            this.OtherOrderList = res;
            console.log('res::',res);
            console.log('this.OtherOrderList::',this.OtherOrderList);

        }
        ).catch(err => {
            this.error = err;
            console.error('err retreiving BiosDetails:', err);
        });
    }
}