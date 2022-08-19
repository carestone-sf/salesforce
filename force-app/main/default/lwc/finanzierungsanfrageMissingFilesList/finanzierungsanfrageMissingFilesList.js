import { LightningElement, wire, api, track } from 'lwc';
import getContentVersionsApex from '@salesforce/apex/FinanzierungsanfrageController.getContentVersions';
import WELCHE_UNTERLAGEN_WERDEN_GEFORDERT from "@salesforce/schema/Finanzierungsanfrage__c.WelcheUnterlagenWerdenGefordert__c";
import { getRecord, getFieldValue, getRecordNotifyChange} from 'lightning/uiRecordApi';


export default class FinanzierungsanfrageMissingFilesList extends LightningElement {
    @api
    recordId;

    @track
    value = [];
    contentVersions;

    @track
    options = [];

    get selectedValues() {
        return this.value.join(',');
    }

    finanzierungsanfrageLoading = true;
    contentVersionsLoading = true;

    get loading() {
        return this.finanzierungsanfrageLoading == true || this.contentVersionsLoading == true;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [WELCHE_UNTERLAGEN_WERDEN_GEFORDERT] })
    getFinanzierungsanfrage({error, data}) {
        if(data) {
            if(getFieldValue(data, WELCHE_UNTERLAGEN_WERDEN_GEFORDERT) != null) {
                this.options = [];
                const values = getFieldValue(data, WELCHE_UNTERLAGEN_WERDEN_GEFORDERT);
                if(values != null) {
                    const valuesArray = values.split(';');
                    for(let i = 0; i < valuesArray.length; i++) {
                        this.options.push({"label": valuesArray[i], "value": valuesArray[i]});
                    }
                }
            }
        }
        if(data || error) {
            this.finanzierungsanfrageLoading = false;
        } 
    }

    @wire(getContentVersionsApex, { recordId: '$recordId' })
    getContentversions(result) {
        this.contentVersions = result;
        if (result.data) {
            this.value = [];
            for(let i = 0; i < this.contentVersions.data.length; i++) {
                this.value.push(this.contentVersions.data[i].Typ__c);
            }
        }
        if(result.data || result.error) {
            this.contentVersionsLoading = false;
        }
    }

    handleChange(e) {
        this.value = e.detail.value;
    }
}