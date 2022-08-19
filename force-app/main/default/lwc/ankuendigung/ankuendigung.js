import { LightningElement, wire } from 'lwc';
import getAnkuendigungApex from '@salesforce/apex/AnkuendigungController.getAnkuendigung';

export default class Ankuendigung extends LightningElement {
    ankuendigung;
    loading = true;

    @wire(getAnkuendigungApex)
    loadAnkuendigung(result) {
        this.ankuendigung = result;
        this.loading = false;
    }

    get hasAnkuendigung() {
        return this.ankuendigung && this.ankuendigung.data;
    }
}