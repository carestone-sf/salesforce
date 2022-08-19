import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendDatevStammdatenCsvAsEmailApex from '@salesforce/apex/DatevController.sendDatevStammdatenCsvAsEmail';

export default class DatevExport extends LightningElement {
    startDate = '';
    endDate = '';
    downloadUrl = '';

    exportTypeValue = 'debitors';

    get exportTypeOptions() {
        return [
            { label: 'Debitoren', value: 'debitors' },
            { label: 'Kreditoren', value: 'creditors' },
        ];
    }

    connectedCallback() {
        const date = new Date();
        const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);
        let startOfMonthMonth = startOfMonth.getMonth() + 1;
        startOfMonthMonth = ''+startOfMonthMonth;
        if(startOfMonthMonth.length == 1) {
            startOfMonthMonth = '0' + startOfMonthMonth;
        }
        let startOfMonthDay = ''+startOfMonth.getDate();
        if(startOfMonthDay.length == 1) {
            startOfMonthDay = '0' + startOfMonthDay;
        }
        this.startDate = startOfMonth.getFullYear() + '-' + startOfMonthMonth + '-' + startOfMonthDay;


        const endOfMonth = new Date(date.getFullYear(), date.getMonth()+1, 0);
        let endOfMonthMonth = endOfMonth.getMonth() + 1;
        endOfMonthMonth = ''+endOfMonthMonth;
        if(endOfMonthMonth.length == 1) {
            endOfMonthMonth = '0' + endOfMonthMonth;
        }
        let endOfMonthDay = ''+endOfMonth.getDate();
        if(endOfMonthDay.length == 1) {
            endOfMonthDay = '0' + endOfMonthDay;
        }        
        this.endDate = endOfMonth.getFullYear() + '-' + endOfMonthMonth + '-' + endOfMonthDay;
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.detail.value;
    }
    
    handleExportTypeValueChange(event) {
        this.exportTypeValue = event.detail.value;
    }

    handleRequestCSVButtonClick() {
        sendDatevStammdatenCsvAsEmailApex({startDate: this.startDate, endDate: this.endDate, exportType: this.exportTypeValue}).then((data) => {
            this.showCalculationSaveSuccessToast();
            // getDocumentApex().then((innerData) => {
            //     this.downloadUrl = `/servlet/servlet.FileDownload?file=${innerData.Id}`;
                
            // }).catch((error) => {
            //     this.showCalculationSaveErrorToast(error);
            // });
        }).catch((error) => {
            this.showCalculationSaveErrorToast(error);
        });
    }

    /**
     * Shows success toast
     */
     showCalculationSaveSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erfolg',
                message: 'Die CSV wird dir via E-Mail zugesendet.',
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
                title: 'Beim Anfordern der CSV ist ein Fehler aufgetreten.',
                message: error.message,
                variant: 'error'
            })
        );
    }
}