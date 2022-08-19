import { LightningElement, track, api, wire } from 'lwc';
import { updateRecord, getRecord, getFieldValue} from 'lightning/uiRecordApi';
import ONBOARDING_ABGESCHLOSSEN from "@salesforce/schema/User.OnBoardingAbgeschlossen__c";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import ROLE from "@salesforce/schema/User.TextRolle__c";
import USER_ROLE_NAME from '@salesforce/schema/User.UserRoleName__c';
import USER_ID from "@salesforce/user/Id";

import getAccountFromContactIdApex from '@salesforce/apex/AccountController.getAccountFromContactId';

export default class OnBoarding extends LightningElement {


    @track currentStep = 1;
    @track backButtonDisabled = true;
    @track inputValue;
    toggleButtonLabel = 'Weiter';
    showModal = false;
    onBoardingCompleted = false;
    dontShowAgain = false;
    saveInProgress = false;
    @track textRole;
    iterator = 0;
    init = false;

    get title() {
        return this.currentStep == this.steps[this.steps.length - 1].value ? '\u2705 Einrichtung erfolgreich abgeschlossen!' : 'Herzlich Willkommen im Vertriebspartner Portal';
    }

    get isNotUser() {
        return this.textRole != 'Benutzer';
    }

    get showModalAndOnBoardingNotCompleted() {
        return this.showModal;
   }

    show() {
        this.showModal = true;
    }
    hide() {
        this.showModal = false;
    }
    @track
    steps = [
        { label: 'Schritt 1', value: 1, iterator: 0 },
        { label: 'Schritt 2', value: 2, iterator: 1 },
        { label: 'Schritt 3', value: 3, iterator: 2 },
        { label: 'Schritt 4', value: 4, iterator: 3 },
        // { label: 'Schritt 5', value: 5, iterator: 4 },
    ];

    @wire(getRecord, { recordId: USER_ID, fields: [ONBOARDING_ABGESCHLOSSEN, CONTACT_ID, ROLE, USER_ROLE_NAME] })
    loadUser({error, data}) {
        this.user = {};
        this.user.data = data;
        this.user.error = error;
        if(this.user.data) {

            if(getFieldValue(this.user.data, ROLE) != null) {
                this.textRole = getFieldValue(this.user.data, ROLE);
            }

            if(getFieldValue(this.user.data, USER_ROLE_NAME) && getFieldValue(this.user.data, USER_ROLE_NAME).indexOf('Benutzer') > -1) {
                this.steps = [
                    { label: 'Schritt 1', value: 2, iterator: 0 },
                    { label: 'Schritt 2', value: 3, iterator: 1 },
                    { label: 'Schritt 3', value: 4, iterator: 2 }
                ];
                this.currentStep = 2;
            }

            getAccountFromContactIdApex({contactId: this.contactId}).then(result => {
                this.acc = result;
            }).catch(error => {

            });

            if(!getFieldValue(this.user.data, ONBOARDING_ABGESCHLOSSEN)) {
                this.showModal = true;
            }
        }
    }
    user;

    get contactId() {
      return getFieldValue(this.user.data, CONTACT_ID);
    }

    acc = {};

    get onBoardingCompleted() {
        return getFieldValue(this.user.data, ONBOARDING_ABGESCHLOSSEN);
    }

    connectedCallback() {
        if(!this.init && this.showModal) {
            const hideSteps = this.template.querySelectorAll('[data-step-value]');
                if(hideSteps) {
                    hideSteps.forEach(function (hideStep) {
                        hideStep.classList.add('hidden');
                    });
                }
                const step = this.template.querySelector(`[data-step-value="${this.currentStep}"]`);
                if(step) {
                    step.classList.remove('hidden');
                }
                this.init = true;
        }
    }

    renderedCallback() {
        if(!this.init && this.showModal) {
            const hideSteps = this.template.querySelectorAll('[data-step-value]');
                if(hideSteps) {
                    hideSteps.forEach(function (hideStep) {
                        hideStep.classList.add('hidden');
                    });
                }
                const step = this.template.querySelector(`[data-step-value="${this.currentStep}"]`);
                if(step) {
                    step.classList.remove('hidden');
                }
                this.init = true;
        }
    }

    handleAccountSaveSuccess(event) {
        this.moveNext();
    }

    handleContactSaveSuccess(event) {
        this.moveNext();
    }

    moveNext() {
        // control the next button based on 'currentStep' attribute value    
        if(this.toggleButtonLabel == 'Fertig') {
            this.hide();
            if(this.dontShowAgain) {
                updateRecord({fields: {Id: USER_ID, 'OnBoardingAbgeschlossen__c': this.dontShowAgain}})
                .then((data) => {
                })
                .catch((error) => {
                });
            }
        }

        const accForm = this.template.querySelector('[data-id=accountForm]');
        if(this.currentStep == 1 && !this.saveInProgress) {
            this.saveInProgress = true;
            accForm.submit();
            return;
        } else if(this.currentStep == 1) {
            this.saveInProgress = false;
        }

        const conForm = this.template.querySelector('[data-id=contactForm]');
        if(this.currentStep == 3 && !this.saveInProgress) {
            this.saveInProgress = true;
            conForm.submit();
            return;
        } else if(this.currentStep == 3) {
            this.saveInProgress = false;
        }


        if (this.currentStep < this.steps[this.steps.length-1].value) {
            this.iterator = this.steps[this.iterator+1].iterator;
            this.currentStep = this.steps[this.iterator].value;
            if (this.currentStep == this.steps[this.steps.length - 1].value) {
                this.toggleButtonLabel = 'Fertig';
            }
        } 
        this.handleContentChange();
    }

    moveBack() {
        // control the back button based on 'currentStep' attribute value    
        if (this.currentStep <= this.steps[this.steps.length - 1].value && this.currentStep > 1) {
            this.iterator = this.steps[this.iterator-1].iterator;
            this.currentStep = this.steps[this.iterator].value;
            this.toggleButtonLabel = 'Weiter';
        } else {

        }
        this.handleContentChange();
    }

    selectStep(event) {
        // connect the progress indicator points to the steps
        this.currentStep = event.target.value;
        if (this.currentStep != this.steps[this.steps.length - 1]) {
            this.toggleButtonLabel = 'Weiter';
        } else {
            this.toggleButtonLabel = 'Fertig';
        }
        this.handleContentChange();
    }

    handleContentChange() {
        const hideSteps = this.template.querySelectorAll('[data-step-value]');
        hideSteps.forEach(function (hideStep) {
            hideStep.classList.add('hidden');
        });
        const step = this.template.querySelector(`[data-step-value="${this.currentStep}"]`);
        step.classList.remove('hidden');
        if (this.currentStep > 1) {
            this.backButtonDisabled = false;
        } else {
            this.backButtonDisabled = true;
        }

        // This means we completed Step 3 and want to save user settings
        if(this.currentStep == 3) {
            this.template.querySelector('c-user-settings').save();
        }
    }
    handleCheckboxChange(event) {
        //in Salesforce Feld aktualisieren
        this.dontShowAgain = event.target.checked;
    }
}