import { LightningElement, wire } from 'lwc';
import getProvisionApprovalsApex from '@salesforce/apex/ApprovalController.getProvisionApprovals';
import approveProvisionApex from '@salesforce/apex/ApprovalController.approveProvision';
import rejectProvisionApex from '@salesforce/apex/ApprovalController.rejectProvision';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ApprovalList extends LightningElement {

    @wire(getProvisionApprovalsApex)
    provApprovals;

    get hasApprovals() {
        return this.provApprovals && this.provApprovals.data && this.provApprovals.data.length > 0;
    }

    connectedCallback() {
    }

    renderedCallback() {
    }

    approveProvision(event) {
        const workItemId = event.target.closest('[data-key]').dataset.key;
        approveProvisionApex({workItemId: workItemId}).then((data) => {
            refreshApex(this.provApprovals);
            this.showCalculationSaveSuccessToast('Die Provision wurde erfolgreich genehmigt.');
        }).catch((error) => {
            this.showCalculationSaveErrorToast(error);
        });
    }

    rejectProvision(event) {
        const workItemId = event.target.closest('[data-key]').dataset.key;
        rejectProvisionApex({workItemId: workItemId}).then((data) => {
            refreshApex(this.provApprovals);
            this.showCalculationSaveSuccessToast('Die Provision wurde erfolgreich abgelehnt.');
        }).catch((error) => {
            this.showCalculationSaveErrorToast(error);
        });
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
                title: 'Ein Fehler ist aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }

}