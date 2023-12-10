import { LightningElement, wire } from 'lwc';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getImmoframeKonfigurationApex from '@salesforce/apex/ImmoframeController.getImmoframeKonfiguration';
import insertImmoframeKonfigurationApex from '@salesforce/apex/ImmoframeController.insertImmoframeKonfiguration';
import IMMOFRAME_THEMES from '@salesforce/resourceUrl/immoframeThemes';


export default class ImmoframeCard extends LightningElement {
    // Theme Carousel
    ThemeCarousel = IMMOFRAME_THEMES + "/Darstellung-ImmoFrame_Slider.png";
    // // Theme Grid
    ThemeGrid = IMMOFRAME_THEMES + "/Darstellung-ImmoFrame_Raster.png";
    // // Theme List
    ThemeList = IMMOFRAME_THEMES + "/Darstellung-ImmoFrame_Liste.png";
    URL = "";
    CustomColor = "#34D229";
    Theme = 2;
    immoframeConfiguration;
    updateImmoframeConfigurationObject = {};
    JSCode = `<a href='https://immoframe.carestone.com/?apikey=' id='cs-immoframe'>Carestone Immoframe</a><script>!function(a,b,c){var d,e=a.getElementsByTagName(b)[0],f=/^http:/.test(a.location)?'http':'https';a.getElementById(c)||(d=a.createElement(b),d.id=c,d.src=f+'://immoframe.carestone.com/immoframe-widget.js',e.parentNode.insertBefore(d,e))}(document,'script','cs-immoframe-js');</script>`;

    @wire(getImmoframeKonfigurationApex)
    loadImmoframeConfiguration(result) {
        this.immoframeConfiguration = result;
        // Further processing
        if (result.data === null) {
            insertImmoframeKonfigurationApex().then(data => {
                refreshApex(this.immoframeConfiguration);
            }).catch(e => console.log(e));
        }

        this.URL = this.immoframeConfiguration?.data?.Url__c ?? "";
        this.CustomColor = this.immoframeConfiguration?.data?.Color__c ?? "#34D229";
        this.Theme = this.immoframeConfiguration?.data?.Theme__c ?? 2;
        if (this.immoframeConfiguration?.data?.Id) {
            this.JSCode = `<a href='https://immoframe.carestone.com/?apikey=${this.immoframeConfiguration?.data?.Id ?? ""}' id='cs-immoframe'>Carestone Immoframe</a><script>!function(a,b,c){var d,e=a.getElementsByTagName(b)[0],f=/^http:/.test(a.location)?'http':'https';a.getElementById(c)||(d=a.createElement(b),d.id=c,d.src=f+'://immoframe.carestone.com/immoframe-widget.js',e.parentNode.insertBefore(d,e))}(document,'script','cs-immoframe-js');</script>`;
        }
    }

    connectedCallback() {
    }

    /**
    * Lighten / Darken / Combine colors
    * https://stackoverflow.com/questions/5560248/programmatically-lighten-or-darken-a-hex-color-or-rgb-and-blend-colors
    */
    pSBC = (p, c0, c1, l) => {
        let r, g, b, P, f, t, h, i = parseInt,
            m = Math.round,
            a = typeof(c1) == "string";
        if (typeof(p) != "number" || p < -1 || p > 1 || typeof(c0) != "string" || (c0[0] != 'r' && c0[0] != '#') || (c1 && !a)) return null;
        if (!this.pSBCr) this.pSBCr = (d) => {
            let n = d.length,
                x = {};
            if (n > 9) {
                [r, g, b, a] = d = d.split(","), n = d.length;
                if (n < 3 || n > 4) return null;
                x.r = i(r[3] == "a" ? r.slice(5) : r.slice(4)), x.g = i(g), x.b = i(b), x.a = a ? parseFloat(a) : -1
            } else {
                if (n == 8 || n == 6 || n < 4) return null;
                if (n < 6) d = "#" + d[1] + d[1] + d[2] + d[2] + d[3] + d[3] + (n > 4 ? d[4] + d[4] : "");
                d = i(d.slice(1), 16);
                if (n == 9 || n == 5) x.r = d >> 24 & 255, x.g = d >> 16 & 255, x.b = d >> 8 & 255, x.a = m((d & 255) / 0.255) / 1000;
                else x.r = d >> 16, x.g = d >> 8 & 255, x.b = d & 255, x.a = -1
            }
            return x
        };
        h = c0.length > 9, h = a ? c1.length > 9 ? true : c1 == "c" ? !h : false : h, f = this.pSBCr(c0), P = p < 0, t = c1 && c1 != "c" ? this.pSBCr(c1) : P ? {
            r: 0,
            g: 0,
            b: 0,
            a: -1
        } : {
            r: 255,
            g: 255,
            b: 255,
            a: -1
        }, p = P ? p * -1 : p, P = 1 - p;
        if (!f || !t) return null;
        if (l) r = m(P * f.r + p * t.r), g = m(P * f.g + p * t.g), b = m(P * f.b + p * t.b);
        else r = m((P * f.r ** 2 + p * t.r ** 2) ** 0.5), g = m((P * f.g ** 2 + p * t.g ** 2) ** 0.5), b = m((P * f.b ** 2 + p * t.b ** 2) ** 0.5);
        a = f.a, t = t.a, f = a >= 0 || t >= 0, a = f ? a < 0 ? t : t < 0 ? a : a * P + t * p : 0;
        if (h) return "rgb" + (f ? "a(" : "(") + r + "," + g + "," + b + (f ? "," + m(a * 1000) / 1000 : "") + ")";
        else return "#" + (4294967296 + r * 16777216 + g * 65536 + b * 256 + (f ? m(a * 255) : 0)).toString(16).slice(1, f ? undefined : -2)
    }

    /**
     * Immobilienkategorien with 4 checkboxes
     * Make sure that every checkbox is set to immoframeConfiguration values or to true by default
     */
    get Immobilienkategorien() {
        return [{
            label: 'Pflegeapartments',
            value: 'Pflegeapartments__c',
            name: "Pflegeapartments__c",
            initiallyChecked: this.immoframeConfiguration?.data?.Pflegeapartments__c ?? true,
            id: "Pflegeimmobilien_id"
        },
        {
            label: 'Service-Wohnungen',
            value: 'ServiceWohnungen__c',
            name: "ServiceWohnungen__c",
            initiallyChecked: this.immoframeConfiguration?.data?.ServiceWohnungen__c ?? true,
            id: "Betreuteswohnen_id"
        },
        {
            label: 'Wohnimmobilien',
            value: 'Wohnimmobilien__c',
            name: "Wohnimmobilien__c",
            initiallyChecked: this.immoframeConfiguration?.data?.Wohnimmobilien__c ?? true,
            id: "Kapitalanlange_id"
        },
        {
            label: 'Mikroapartments',
            value: 'Mikroapartments__c',
            name: "Mikroapartments__c",
            initiallyChecked: this.immoframeConfiguration?.data?.Mikroapartments__c ?? true,
            id: "Ferienimmobilie_id"
        },
    ];
    }

    /**
     * Themes with 3 checkboxes
     * Make sure that every checkbox is set to immoframeConfiguration theme or to Grid by default
     */
    get Themes() {
        return [{
                label: "Slider",
                value: 1,
                initiallyChecked: this.Theme == 1,
                imgSrc: this.ThemeCarousel,
            },
            {
                label: "Raster",
                value: 2,
                initiallyChecked: this.Theme == 2,
                imgSrc: this.ThemeGrid,
            },
            {
                label: "Liste",
                value: 3,
                initiallyChecked: this.Theme == 3,
                imgSrc: this.ThemeList,
            },
        ]
    }

    /**
     * Default colors
     */ 
    get default_colors() {
        return ["#1774B6", "#1F5CC1", "#33C4E9", "#5A34E8", "#EB36C7", "#EC8B36", "#52785C", "#E9C916",
            "#999999", "#34D229", "#B6B6B6", "#A30041", "#A3927D", "#111212", "#263082", "#387C5F", "#387C5F"
        ];
    }

    /**
     * First set of colors checkboxes
     */ 
    get colors_first() {
        let items = [];
        for (let i = 1; i < 9; i++) {
            let label = i.toString();
            if (label.length == 1) label = label + "⠀";
            items.push({
                "name": `${i}`,
                "id": `color_${i}`,
                "colorBoxId": `immoframeColor${i}`,
                "colorBoxStyle": `"background: ${this.default_colors[i - 1]}"`,
                "value": this.default_colors[i - 1],
                "initiallyChecked": this.CustomColor.toLowerCase() == this.default_colors[i - 1],
                "label": label,
            });
        }

        return items;
    }

    /**
     * Second set of colors checkboxes
     */ 
    get colors_second() {
        let items = [];
        for (let i = 9; i < 17; i++) {
            let label = i.toString();
            if (label.length == 1) label = label + "⠀";
            items.push({
                "name": `${i}`,
                "id": `color_${i}`,
                "colorBoxId": `immoframeColor${i}`,
                "colorBoxStyle": `"background: ${this.default_colors[i - 1]}"`,
                "value": this.default_colors[i - 1],
                "initiallyChecked": this.CustomColor.toLowerCase() == this.default_colors[i - 1],
                "label": label,
            });
        }

        return items;
    }

    /**
     * If custom color was used, check the custom color checkbox
     */ 
    get isCustomColorChecked() {
        return ![...this.colors_first, ...this.colors_second].some(color => color.initiallyChecked);
    }

    /**
     * Optionen with 4 checkboxes
     * Make sure to set the initial values based on configuration / default value
     */
    get Optionen() {
        return [{
                label: 'Exposé',
                value: 'Exposee__c',
                name: "Exposee__c",
                initiallyChecked: this.immoframeConfiguration?.data?.Exposee__c ?? false,
                id: "Exposee__id"
            },
            {
                label: 'Factsheet',
                value: 'Factsheets__c',
                name: "Factsheets__c",
                initiallyChecked: this.immoframeConfiguration?.data?.Factsheets__c ?? false,
                id: "Factsheets__id"
            },
            {
                label: 'Grundriss',
                value: 'Grundriss__c',
                name: "Grundriss__c",
                initiallyChecked: this.immoframeConfiguration?.data?.Grundriss__c ?? true,
                id: "Grundriss__id"
            },
            {
                label: 'Transparenter Hintergrund',
                value: 'Transparent__c',
                name: "Transparent__c",
                initiallyChecked: this.immoframeConfiguration?.data?.Transparent__c ?? true,
                id: "BetrTransparent__id"
            },
        ];
    }



    /**
     * First checkbox section - Immobilienkategorien
     */
     handleImmobilienKategorienChange(e) {
        /**
         * First check what value was clicked
         * Then update corresponding field in @param {*} this.updateImmoframeConfigurationObject
         */
        if (e.target.value == "Pflegeapartments__c") {
            this.updateImmoframeConfigurationObject.Pflegeapartments__c = e.target.checked;
        } else if (e.target.value == "Wohnimmobilien__c") {
            this.updateImmoframeConfigurationObject.Wohnimmobilien__c = e.target.checked;
        } else if (e.target.value == "Mikroapartments__c") {
            // then update our updateImmoframeConfigurationObject.Mikroapartments__c to the value of the checkbox (true | false)
            this.updateImmoframeConfigurationObject.Mikroapartments__c = e.target.checked;
            // then update our updateImmoframeConfigurationObject.Betreuteswohnen__c to the value of the checkbox (true | false)
        } else if (e.target.value == "ServiceWohnungen__c") {
            // then update our updateImmoframeConfigurationObject.ServiceWohnungen__c to the value of the checkbox (true | false)
            this.updateImmoframeConfigurationObject.ServiceWohnungen__c = e.target.checked;
        }
    }

    /**
     * Last checkbox section - Optionnen
     */
    handleOptionnenChange(e) {
        /**
         * First check what value was clicked
         * Then update corresponding field in @param {*} this.updateImmoframeConfigurationObject
         */
        if (e.target.value == "Exposee__c") {
            this.updateImmoframeConfigurationObject.Exposee__c = e.target.checked;
        } else if (e.target.value == "Grundriss__c") {
            this.updateImmoframeConfigurationObject.Grundriss__c = e.target.checked;
        } else if (e.target.value == "Factsheets__c") {
            this.updateImmoframeConfigurationObject.Factsheets__c = e.target.checked;
        } else if (e.target.value == "Transparent__c") {
            this.updateImmoframeConfigurationObject.Transparent__c = e.target.checked;
        }
    }

    /**  If the clicked checkbox target contains a unique label property associated with only Themes
     * Then we uncheck all the other checkboxes in this categorie
     * @param themeLabels 
     * this function maps our themes' labels, and checks if our checkbox has a corresponding label
     */
    handleThemeChange(e) {
        const themeLabels = ["Slider", "Raster", "Liste"];
        const checkboxes = this.template.querySelectorAll('.checkbox lightning-input');
        checkboxes.forEach(function(checkbox) {
            checkbox.checked = false;
        });
        e.target.checked = true;

        if (themeLabels.includes(e.target.label)) {
            // Set theme to Carousel 1 / Grid 2 / List 3
            this.updateImmoframeConfigurationObject.Theme__c = e.target.value;
            // Find all lightning-input elements on the page
            let boxes = Array.from(this.template.querySelectorAll('lightning-input'));
            // Filter all checkboxes which include themes' labels // same as inside if statement
            boxes = boxes.filter(box => themeLabels.includes(box.label));
            // Uncheck checkboxes in this template
            boxes.forEach(box => box.checked = e.target.label === box.label);
        }
    }

    /**
     * Create an array from 1 to 17 (including 17), each index corresponds to color index / checkbox name property
     * If clicked element exists in generated array, then we can tell we clicked on color checkboxes 
     */
    handleColorChange(e) {
        const colorIndexes = Array.from({ length: 17 }, (_, i) => `${i + 1}`);
        if (colorIndexes.includes(e.target.name)) {
            // Set Color__c to selected color value (hex)
            this.updateImmoframeConfigurationObject.Color__c = e.target.value;
            // Set Lightcolor__c programmatically to lighter color than selected (hex)
            this.updateImmoframeConfigurationObject.Lightcolor__c = this.pSBC(0.1, e.target.value);
            // Find all checkboxes
            let boxes = Array.from(this.template.querySelectorAll('input[type=checkbox]'));
            // Filter all checkboxes with 1-17 value in them, to select only color checkboxes
            boxes = boxes.filter(box => colorIndexes.includes(`${box.name}`));
            // Filter out Themes checkboxes
            boxes = boxes.filter(box => !this.Themes.map(theme => theme.label).includes(box.name));
            // Uncheck checkboxes in this template
            boxes.forEach(box => box.checked = e.target.name === box.name);
        }
    }

    /** 
    // input is an html element input[type=text]
    // for every text input field, update updateImmoframeConfigurationObject object
    */
    handleTextFields(input) {
        if (input.name == "Url__c") {
            this.updateImmoframeConfigurationObject.Url__c = input.value;
        }
    }

    /**
     * Function that triggers while save button is clicked
     */
    handleSaveClick() {
        // first of all - find all text input fields
        let myInputs = this.template.querySelectorAll("input[type=text]");
        // handle text fields, to update our updateImmoframeConfigurationObject
        myInputs.forEach(input => this.handleTextFields(input));

        // save ImmoframeKonfiguration and update in the cloud
        this.saveImmoframeKonfiguration();
    }


    /**
     * Update and save record on the server
     */
     saveImmoframeKonfiguration() {

        // Which Id do we reference? Saved in immoframe object we get at the beginning?
        if (this.immoframeConfiguration.data.Id) {
            
            this.updateImmoframeConfigurationObject.Id = this.immoframeConfiguration.data.Id;
            updateRecord({fields: this.updateImmoframeConfigurationObject})
            .then((data) => {
                // this.getOrInsertImmoframeKonfiguration();
                this.showSaveSuccessToast();
                refreshApex(this.immoframeConfiguration);
            })
            .catch((error) => {
                this.showSaveErrorToast(error);
            });
        } else {

            createRecord({apiName: 'Immoframe_Konfiguration__c', fields: this.updateObject})
            .then((data) => {
                this.recordId = data.id;
                // ToDo
                // this.getOrInsertImmoframeKonfiguration();
            })
            .catch((error) => {
                this.showSaveErrorToast(error);
            });
        }
    }


    /**
     * Shows success toast
     */
    showSaveSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: 'Die Immoframe wurde erfolgreich gespeichert.',
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