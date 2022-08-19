/* eslint-disable no-console */
import { LightningElement , api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
 
export default class RelatedListDeletePopup extends LightningElement {
    showModal = false
    @api sobjectLabel
    @api recordId
    @api parentId
    @api recordName

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleClose() {
        this.showModal = false;     
    }
    handleDialogClose(){
        this.handleClose()
    }

    get body(){
        return `Bitte bestätigen Sie den Löschvorgang`
    }

    get header(){
        return `${this.sobjectLabel} löschen`
    }    

    handleDelete(){
        deleteRecord(this.recordId)
            .then(() => {    
                this.hide()
                const evt = new ShowToastEvent({
                    title: `${this.sobjectLabel}  "${this.recordName}" wurde gelöscht.`,
                    variant: "success"
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent("refreshdata"));
                getRecordNotifyChange([{recordId: this.parentId}]);      
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Fehler beim Löschen',
                    message: error.body.message,
                    variant: 'error'
                })
                this.dispatchEvent(evt)
            });
    }
    
}