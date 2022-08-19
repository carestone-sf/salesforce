import { LightningElement, wire } from 'lwc';
import IMMOBILIEN_LIST_UPDATE_MESSAGE from '@salesforce/messageChannel/ImmobilienListUpdate__c';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';

export default class ImmobilienMap extends LightningElement {
    mapMarkers = [];

    @wire(MessageContext) messageContext;

    connectedCallback() {
        this.subscription = subscribe(
			this.messageContext,
			IMMOBILIEN_LIST_UPDATE_MESSAGE,
			(message) => {
				this.handleImmobilienChange(message)
			}
		);
    }

    disconnectedCallback() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

    handleImmobilienChange(message) {
        if(message.immobilien.data) {
            this.mapMarkers = message.immobilien.data.map(immobilie => {
                const Latitude = immobilie.Location__Latitude__s;
                const Longitude = immobilie.Location__Longitude__s;
                return {
                location: { Latitude, Longitude },
                title: immobilie.Name,
                description: `Koordinaten: ${Latitude}, ${Longitude}`,
                icon: 'standard:account'
                };
            });
        }
    }
}