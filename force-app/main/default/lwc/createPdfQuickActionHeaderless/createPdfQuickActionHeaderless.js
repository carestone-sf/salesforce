import { LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import downloadjs from '@salesforce/resourceUrl/downloadjs';
import downloadPDF from '@salesforce/apex/CreateAndSavePdf.getPDFprint';
import successMessage from '@salesforce/label/c.PDFGenerationSuccessMessage'
import errorMessage from '@salesforce/label/c.PDFGenerationErrorMessage'

export default class CreatePdfQuickActionHeaderless extends LightningElement {
    isExecuting = false;    
    boolShowSpinner = false;
    strFile;
    pdfString;
    error;
    isSuccess;
    title;
    messasge;
    variant;

    @api recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    async downloadPdfAsync(){
        try{
         this.isSuccess = await downloadPDF({recordId:this.recordId});

        }catch(e){
            console.log('error try catch'+e);
        }
        console.log(this.isSuccess)
    }

    renderCallback(){
      loadScript(this, downloadjs)
      .then(()=> console.log('Loaded download.js'))
      .catch(error => console.log(error))
    }
  

    @api async invoke() {    
        console.log('record ID is: ' + this.recordId);
        await this.downloadPdfAsync();
     
        
        if(this.isSuccess){
            this.title= 'Success';
            this.message= successMessage;
            this.variant= 'success'
        } else {
            this.title= 'Error';
            this.message= errorMessage;
            this.variant= 'error'
        }
        
        
        
        this.dispatchEvent(
            new ShowToastEvent( {
                title: this.title,
                message: this.message,
                variant: this.variant
            } )
        )  
        eval("$A.get('e.force:refreshView').fire();");
    }   
}