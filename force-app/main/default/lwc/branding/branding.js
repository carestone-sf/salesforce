import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from "@salesforce/user/Id";

export default class Branding extends LightningElement {

    userSettings;
    textColor;
    backgroundColor;
    logoUrl;
    imgUrl;

    @wire(getRecord, { recordId: USER_ID, fields: ['User.ImgUrl__c', 'User.TextColor__c', 'User.LogoUrl__c', 'User.BackgroundColor__c'] })
    loadUser({error, data}) {
        this.user = {};
        this.user.data = data;
        this.user.error = error;
        
        if(this.user.data) {
            this.textColor = getFieldValue(this.user.data, 'User.TextColor__c');
            this.backgroundColor = getFieldValue(this.user.data, 'User.BackgroundColor__c');
            this.logoUrl = getFieldValue(this.user.data, 'User.LogoUrl__c');
            this.imgUrl = getFieldValue(this.user.data, 'User.ImgUrl__c');

            this.userSettings = localStorage.getItem('userSettings');
            if(!this.userSettings) {
                this.handleBranding();
            }
        }
    }

    connectedCallback() {
        this.userSettings = localStorage.getItem('userSettings');
        if(this.userSettings) {
            this.handleBranding();
        }
    }

    handleBranding() {
        if(this.userSettings) {
            var userSettingsJson = JSON.parse(this.userSettings);
            this.imgUrl = userSettingsJson.imgUrl;
            this.logoUrl = userSettingsJson.logoUrl;
            this.textColor = userSettingsJson.textColor;
            this.backgroundColor = userSettingsJson.backgroundColor;
        } else {
            this.userSettings = {};
            this.userSettings.imgUrl = this.imgUrl;
            this.userSettings.logoUrl = this.logoUrl;
            this.userSettings.textColor = this.textColor;
            this.userSettings.backgroundColor = this.backgroundColor;
            localStorage.setItem('userSettings', JSON.stringify(this.userSettings));
        }
        
        const r = document.querySelector(":root");
        r.style.setProperty('--backgroundRgbValues', this.backgroundColor);
        r.style.setProperty('--textRgbValues', this.textColor);
        const backgroundColorRgb = 'rgb(' + this.backgroundColor + ')';
        const textColorRgb = 'rgb(' + this.textColor + ')';

        if(this.logoUrl) {
            r.style.setProperty('--lwc-brandLogoImage', 'url(' + this.logoUrl + ')');
        }
        
        if(this.backgroundColor) {
            r.style.setProperty('--lwc-brandNavigationBarBackgroundColor', backgroundColorRgb);
            r.style.setProperty('--lwc-brandNavigationBackgroundColor', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextDefault', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextLabel', backgroundColorRgb);
            r.style.setProperty('--lwc-inputStaticColor', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextWeak', backgroundColorRgb);
            r.style.setProperty('--lwc-colorGray13', backgroundColorRgb);
            r.style.setProperty('--lwc-colorGray16', backgroundColorRgb);
            r.style.setProperty('--sds-c-input-text-color', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextPlaceholder', backgroundColorRgb);
        }
        
        if(this.textColor) {
            r.style.setProperty('--lwc-brandNavigationColorText', '#fff');
            r.style.setProperty('--lwc-colorTextActionLabelActive', textColorRgb);
            r.style.setProperty('--sds-c-button-text-color', textColorRgb);
            r.style.setProperty('--lwc-brandPrimary', textColorRgb);
            r.style.setProperty('--lwc-colorTextBrand', textColorRgb);
            r.style.setProperty('--sds-c-button-text-color-hover', textColorRgb);
            r.style.setProperty('--lwc-brandAccessible', textColorRgb);
            r.style.setProperty('--lwc-brandTextLink', textColorRgb);
            r.style.setProperty('--lwc-colorBackgroundButtonBrand', textColorRgb);
            r.style.setProperty('--lwc-colorBrand', textColorRgb);
            r.style.setProperty('--lwc-colorTextLink', textColorRgb);
            r.style.setProperty('--lwc-colorTextLinkHover', textColorRgb);
            r.style.setProperty('--lwc-brandTextLinkActive', 'rgba(' + this.textColor + ', 0.8)');
            r.style.setProperty('--lwc-brandAccessibleActive', 'rgba(' + this.textColor + ', 0.8)');
            r.style.setProperty('--sds-c-button-neutral-color-background-hover', 'rgba(' + this.textColor + ', 0.1)');
            r.style.setProperty('--lwc-colorBackgroundRowHover', 'rgba(' + this.textColor + ', 0.05)');
        }
    
    }

}