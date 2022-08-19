import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getProvisionenApex from '@salesforce/apex/ProvisionController.getProvisionen';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import ROLE from "@salesforce/schema/User.TextRolle__c";
import USER_ID from "@salesforce/user/Id";

export default class ProvList extends LightningElement {

    provisionen;
    provTotal = 0;
    provTotalCurrentYear = 0;
    provOpen = 0;

    @track textRole;

    get isManager() {
        return this.textRole == 'Manager';
    }

    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID, ROLE] })
    loadUser({error, data}) {
        this.user = {};
        this.user.data = data;
        this.user.error = error;
        if(this.user.data) {
            if(getFieldValue(this.user.data, ROLE) != null) {
                this.textRole = getFieldValue(this.user.data, ROLE);
            }
        }
    }
    user;

    @wire(getProvisionenApex)
    loadProvisionen(result) {
        if(result.data) {
            this.provisionen = result.data;
            for(let i = 0; i<this.provisionen.length; i++) {
                const invoiceDateText = this.provisionen[i].Rechnungsvorlage_verschickt_am__c;
                if(invoiceDateText != null) {
                    this.provTotal += this.provisionen[i].Provisionssumme__c;
                    const invoiceDate = new Date(invoiceDateText);
                    const dateToday = new Date();
                    if(invoiceDate.getFullYear() == dateToday.getFullYear()) {
                        this.provTotalCurrentYear += this.provisionen[i].Provisionssumme__c;
                    }
                } else {
                    this.provOpen += this.provisionen[i].Provisionssumme__c;
                }
            }
        }
    }

}