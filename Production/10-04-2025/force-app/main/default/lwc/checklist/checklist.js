import { LightningElement, api } from 'lwc';

export default class Checklist extends LightningElement {
    @api ischecked;
    @api checkboxLabel;
}