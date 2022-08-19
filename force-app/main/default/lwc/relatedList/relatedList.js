import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import RelatedListHelper from "./relatedListHelper";
import {loadStyle} from 'lightning/platformResourceLoader';
import relatedListResource from '@salesforce/resourceUrl/relatedListResource';

export default class RelatedList extends NavigationMixin(LightningElement) {
    @track state = {}
    @api sobjectApiName;
    @api relatedFieldApiName;
    @api numberOfRecords = 6;
    @api sortedBy;
    @api sortedDirection = "ASC";
    @api rowActionHandler;
    @api fields;
    @api columns;
    @api customActions = [];
    @api parentId;
    helper = new RelatedListHelper()

    renderedCallback() {
        loadStyle(this, relatedListResource + '/relatedList.css')
    }

    connectedCallback() {
        this.init();
    }

    @api
    get recordId() {
        return this.state.recordId;
    }

    set recordId(value) {
        this.state.recordId = value;
    }
    get hasRecords() {
        return this.state.records != null && this.state.records.length;
    }

    get isBerechnungsApartment() {
        return this.sobjectApiName == 'BerechnungsApartment__c';
    }

    get isFinanzierungsBaustein() {
        return this.sobjectApiName == 'Finanzierungsbaustein__c';
    }

    async init() {
        this.state.showRelatedList = this.recordId != null;
        if (! (this.recordId
            && this.sobjectApiName
            && this.relatedFieldApiName
            && this.fields
            && this.columns)) {
            this.state.records = [];
            return;
        }

        this.state.fields = this.fields
        this.state.relatedFieldApiName= this.relatedFieldApiName
        this.state.recordId= this.recordId
        this.state.numberOfRecords= this.numberOfRecords
        this.state.sobjectApiName= this.sobjectApiName
        this.state.sortedBy= this.sortedBy
        this.state.sortedDirection= this.sortedDirection
        this.state.customActions= this.customActions

        const data = await this.helper.fetchData(this.state);
        this.state.records = data.records;
        this.state.iconName = data.iconName;
        this.state.sobjectLabel = data.sobjectLabel;
        this.state.sobjectLabelPlural = data.sobjectLabelPlural;
        if(data.title.indexOf('Berechnungs-Apartments') > -1) {
            this.state.title = data.title.replace('Berechnungs-Apartments', 'Apartments');
        } else if(data.title.indexOf('Finanzierungsbausteine') > -1) {
            this.state.title = data.title.replace('Finanzierungsbausteine', 'Finanzierung');
        } else {
            this.state.title = data.title;
        }
        this.state.parentRelationshipApiName = data.parentRelationshipApiName;
        this.state.columns = this.columns;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
            switch (actionName) {
                case "delete":
                    this.handleDeleteRecord(row);
                    break;
                case "edit":
                    this.handleEditRecord(row);
                    break;
                default:
            }
        }
    }

    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: this.recordId,
                relationshipApiName: this.state.parentRelationshipApiName,
                actionName: "view",
                objectApiName: this.sobjectApiName
            }
        });
    }

    handleCreateRecord() {
        let newEditPopup = this.template.querySelector("c-related-list-new-edit-popup");;
        if(this.sobjectApiName == 'BerechnungsApartment__c') {
            newEditPopup = this.template.querySelector("c-related-list-new-edit-popup-berechnungs-apartment");
        } else if(this.sobjectApiName == 'Finanzierungsbaustein__c') {
            newEditPopup = this.template.querySelector("c-related-list-new-edit-popup-finanzierungs-baustein");
        }
        newEditPopup.recordId = null
        newEditPopup.recordName = null        
        newEditPopup.sobjectApiName = this.sobjectApiName;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    }

    handleEditRecord(row) {
        let newEditPopup = this.template.querySelector("c-related-list-new-edit-popup");
        if(this.sobjectApiName == 'BerechnungsApartment__c') {
            newEditPopup = this.template.querySelector("c-related-list-new-edit-popup-berechnungs-apartment");
        } else if(this.sobjectApiName == 'Finanzierungsbaustein__c') {
            newEditPopup = this.template.querySelector("c-related-list-new-edit-popup-finanzierungs-baustein");
        }
        newEditPopup.recordId = row.Id;
        newEditPopup.recordName = row.Name;
        newEditPopup.sobjectApiName = this.sobjectApiName;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    }

    handleDeleteRecord(row) {
        const newEditPopup = this.template.querySelector("c-related-list-delete-popup");
        newEditPopup.recordId = row.Id;
        newEditPopup.recordName = row.Name;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    }

    handleRefreshData() {
        this.init();
    }
}