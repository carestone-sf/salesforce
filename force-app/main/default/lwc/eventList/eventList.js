import { LightningElement, wire } from 'lwc';
import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCampaignsAndEventsApex from '@salesforce/apex/EventController.getCampaignsAndEvents';
import createCampaignMemberApex from '@salesforce/apex/EventController.createCampaignMember';
import deleteCampaignMemberApex from '@salesforce/apex/EventController.deleteCampaignMember';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EventList extends LightningElement {

    events;
    loading = true;

    // Sneaky trick to get the current contact id
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user;
    get contactId() {
      return getFieldValue(this.user.data, CONTACT_ID);
    }

    @wire(getCampaignsAndEventsApex)
    loadEvents(result) {
        this.events = result;
        this.loading = false;
    }

    connectedCallback() {
    }

    get hasEvents() {
        return this.events && this.events.data && this.events.data.length > 0;
    }

    register(event) {
        this.loading = true;
        const campaignId = event.target.closest('[data-key]').dataset.key;
        const campaignMember = {
            CampaignId: campaignId,
            ContactId: this.contactId,
            Status: 'Angemeldet'
            
        };
        createCampaignMemberApex({cm: campaignMember}).then(
            (data) => {
                this.showCalculationSaveSuccessToast('Vielen Dank für Ihre Anmeldung');
                refreshApex(this.events);
                this.loading = false;
            }
        ).catch(
            (error) => {
                this.showCalculationSaveErrorToast(error);
                this.loading = false;
            }
        );
    }

    unregister(event) {
        this.loading = true;
        const campaignId = event.target.closest('[data-key]').dataset.key;
        const campaignMember = {
            CampaignId: campaignId,
            ContactId: this.contactId
        };
        deleteCampaignMemberApex({cm: campaignMember}).then(
            (data) => {
                this.showCalculationSaveSuccessToast('Sie wurden erfolgreich vom Webinar abgemeldet.');
                refreshApex(this.events);
                this.loading = false;
            }
        ).catch(
            (error) => {
                this.showCalculationSaveErrorToast(error);
                this.loading = false;
            }
        );
    }

    /**
         * Shows success toast
         */
    showCalculationSaveSuccessToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: message,
                variant: 'success'
            })
        );
    }

    /**
     * Shows error toast
     * @param {message: 'your message'} error 
     */
    showCalculationSaveErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Bei der An-/Abmeldung ist ein Fehler aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }

}