// Await until document is ready and available
document.addEventListener("DOMContentLoaded", function() {

    var userSettings = window.localStorage.getItem('userSettings');

    if(userSettings) {
        var userSettingsJson = JSON.parse(userSettings);
        var imgUrl = userSettingsJson.imgUrl;
        var logoUrl = userSettingsJson.logoUrl;
        var textColor = userSettingsJson.textColor;
        var backgroundColor = userSettingsJson.backgroundColor;

        var r = document.querySelector(":root");
        r.style.setProperty('--backgroundRgbValues', backgroundColor);
        r.style.setProperty('--textRgbValues', textColor);
        var backgroundColorRgb = 'rgb(' + backgroundColor + ')';
        var textColorRgb = 'rgb(' + textColor + ')';

        if(logoUrl) {
            r.style.setProperty('--lwc-brandLogoImage', 'url(' + logoUrl + ')');
        }
        
        if(backgroundColor) {
            r.style.setProperty('--lwc-brandNavigationBarBackgroundColor', backgroundColorRgb);
            r.style.setProperty('--lwc-brandNavigationBackgroundColor', backgroundColorRgb);
            r.style.setProperty('--lwc-brandBackgroundPrimary', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextDefault', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextLabel', backgroundColorRgb);
            r.style.setProperty('--lwc-inputStaticColor', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextWeak', backgroundColorRgb);
            r.style.setProperty('--lwc-colorGray13', backgroundColorRgb);
            r.style.setProperty('--lwc-colorGray16', backgroundColorRgb);
            r.style.setProperty('--sds-c-input-text-color', backgroundColorRgb);
            r.style.setProperty('--lwc-colorTextPlaceholder', backgroundColorRgb);
        }
        
        if(textColor) {
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
            r.style.setProperty('--lwc-brandTextLinkActive', 'rgba(' + textColor + ', 0.8)');
            r.style.setProperty('--lwc-brandAccessibleActive', 'rgba(' + textColor + ', 0.8)');
            r.style.setProperty('--sds-c-button-neutral-color-background-hover', 'rgba(' + textColor + ', 0.1)');
            r.style.setProperty('--lwc-colorBackgroundRowHover', 'rgba(' + textColor + ', 0.05)');
        }
    }
});