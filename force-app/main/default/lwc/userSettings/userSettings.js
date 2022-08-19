import { LightningElement, wire, api, track } from 'lwc';
import { createRecord, updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from "@salesforce/user/Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import STANDARD_BRAND_IMAGES from '@salesforce/resourceUrl/StandardBrandImages';
import saveUserSettingsApex from '@salesforce/apex/UserController.saveUserSettings';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';


export default class UserSettings extends LightningElement {
    TextColor;
    BackgroundColor;
    textColorRgb;
    backgroundColorRgb;
    LogoUrl = STANDARD_BRAND_IMAGES + "/standardlogo.png";
    ImgUrl = STANDARD_BRAND_IMAGES + "/standardprofile.png";
    user;
    updateUserObject = {};
    logoDocumentId;
    imgDocumentId;
    @api
    includedInOtherComponent = false;

    get acceptedFormats() {
        return ['.png', '.jpg'];
    }

    @wire(getRecord, { recordId: USER_ID, fields: ['User.ImgUrl__c', 'User.TextColor__c', 'User.LogoUrl__c', 'User.BackgroundColor__c'] })
    loadUser({error, data}) {
        this.user = {};
        this.user.data = data;
        this.user.error = error;
        
        if(this.user.data) {
            this.TextColor = getFieldValue(this.user.data, 'User.TextColor__c');
            this.BackgroundColor = getFieldValue(this.user.data, 'User.BackgroundColor__c');
            this.LogoUrl = getFieldValue(this.user.data, 'User.LogoUrl__c');
            this.ImgUrl = getFieldValue(this.user.data, 'User.ImgUrl__c');
            this.textColorRgb = 'rgb(' + this.TextColor + ')';
            this.backgroundColorRgb =  'rgb(' + this.BackgroundColor + ')';
            this.loadColorsPreview();
        }
    }

    connectedCallback() {
    }

    renderedCallback() {
        this.loadColorsPreview();
    }

    loadColorsPreview() {
        const colorsPreviewElem = this.template.querySelector(".textColorPreview");
        if(colorsPreviewElem != null && this.TextColor != null && this.BackgroundColor != null) {
            this.template.querySelector(".textColorPreview").style.setProperty("color", 'rgb(' + this.TextColor + ')');
            this.template.querySelector(".backgroundColorPreview").style.setProperty("background-color", 'rgb(' + this.BackgroundColor + ')');
        }
    }

    // Done
    handleTextColorChange(e) {
        const rgbValues = this.hexToRgb(e.target.value);
        this.TextColor = rgbValues.r + ', ' + rgbValues.g + ', ' + rgbValues.b;     
        if(this.TextColor == '255, 255, 255') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fehler',
                    message: 'Die Farbe weiß darf nicht ausgewählt werden.',
                    variant: 'error'
                })
            );
        }
        this.updateUserObject.TextColor__c = this.TextColor;

        // Update text-color inside preview container
        this.template.querySelector(".textColorPreview").style.setProperty("color", 'rgb(' + this.TextColor + ')');
    }

    // Done
    handleBackgroundColorChange(e) {
        const rgbValues = this.hexToRgb(e.target.value);
        this.BackgroundColor = rgbValues.r + ', ' + rgbValues.g + ', ' + rgbValues.b;       
        if(this.BackgroundColor == '255, 255, 255') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fehler',
                    message: 'Die Farbe weiß darf nicht ausgewählt werden.',
                    variant: 'error'
                })
            );
        }   
        this.updateUserObject.BackgroundColor__c = this.BackgroundColor;

        // Update preview container background-color
        this.template.querySelector(".backgroundColorPreview").style.setProperty("background-color", 'rgb(' + this.BackgroundColor + ')');
    }

    hexToRgb(hex) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16)
        } : null;
      }

    @api
    save() {
        this.updateUserObject.BackgroundColor__c = this.BackgroundColor;
        this.updateUserObject.TextColor__c = this.TextColor;
        // Consider updating user from here
        this.saveUser();
    }

    // Code from immoframeCard.js => saveImmoframeKonfiguration()
    // ToDo make sure it works

    /**
     * Update and save record on the server
     */
    saveUser() {
        this.updateUserObject.Id = USER_ID;
        if(this.TextColor != '255, 255, 255' && this.BackgroundColor != '255, 255, 255') {
            saveUserSettingsApex({user: this.updateUserObject, imgDocumentId: this.imgDocumentId, logoDocumentId: this.logoDocumentId})
            .then((data) => {
                this.userSettings = {};
                this.userSettings.imgUrl = this.ImgUrl;
                this.userSettings.logoUrl = this.LogoUrl;
                this.userSettings.textColor = this.TextColor;
                this.userSettings.backgroundColor = this.BackgroundColor;
                window.localStorage.setItem('userSettings', JSON.stringify(this.userSettings));
                refreshApex(this.user);
                if(!this.includedInOtherComponent) {
                    this.showSaveSuccessToast();
                    location.reload();
                }
            })
            .catch((error) => {
                this.showSaveErrorToast(error);
            });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fehler',
                    message: 'Die Farbe weiß darf nicht ausgewählt werden.',
                    variant: 'error'
                })
            );
        }
    }

    handleLogoUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        if(uploadedFiles.length > 0 ) {
            this.logoDocumentId = uploadedFiles[0].contentVersionId;
        }
    }

    handleProfilePhotoUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        if(uploadedFiles.length > 0 ) {
            this.imgDocumentId = uploadedFiles[0].contentVersionId;
        }
    }

    /**
     * Shows success toast
     */
    showSaveSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: 'Der Benutzer wurde erfolgreich gespeichert.',
                variant: 'success'
            })
        );
    }

    /**
     * Shows error toast
     * @param {message: 'your message'} error 
     */
    showSaveErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Beim Speichern ist ein Fehler aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }

}