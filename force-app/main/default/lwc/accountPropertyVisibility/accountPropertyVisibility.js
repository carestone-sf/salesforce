import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProperties from '@salesforce/apex/AccountPropertyVisibilityController.getProperties';
import hidePropertyApex from '@salesforce/apex/AccountPropertyVisibilityController.hideProperty';
import unhidePropertyApex from '@salesforce/apex/AccountPropertyVisibilityController.unhideProperty';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AccountPropertyVisibility extends NavigationMixin(LightningElement) {
    @api recordId;

    @track properties = [];
    isFirstRender = true;

    renderedCallback() {
        if(this.isFirstRender) {
            this.isFirstRender = false;
            this.loadProperties();
        }
    }

    loadProperties() {
        getProperties({accountId: this.recordId}).then(result => {
            this.properties = JSON.parse(JSON.stringify(result));
        }).catch(error => this.handleError(error));
    }

    hideProperty(event) {
        const propertyId = event.target.dataset.propertyid;
        this.properties.find(property => property.propertyId === propertyId).isVisible = false;
        hidePropertyApex({accountId: this.recordId, propertyId: propertyId})
        .catch(error => {
            this.properties.find(property => property.propertyId === propertyId).isVisible = true;
            this.handleError(error);
        });
    }

    unhideProperty(event) {
        const propertyId = event.target.dataset.propertyid;
        this.properties.find(property => property.propertyId === propertyId).isVisible = true;
        unhidePropertyApex({accountId: this.recordId, propertyId: propertyId})
        .catch(error => {
            this.properties.find(property => property.propertyId === propertyId).isVisible = false;
            this.handleError(error);
        });
    }

    handleError(error) {
        console.error(error);
        this.dispatchEvent(new ShowToastEvent({variant: error, title: 'Fehler', message: 'Es ist ein Fehler aufgetreten. Bitte wenden Sie sich an Ihren Systemadministrator.'}));
    }

    openProperty(event) {
        const propertyId = event.target.dataset.propertyid;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: propertyId,
                actionName: 'view'
            }
        });
    }

    get selectedRows() {
        return this.properties.filter(property => property.isVisible);
    }

    get columns() {
        return [
            { label: 'Immobilie', fieldName: 'propertyName' }
        ];
    }
}