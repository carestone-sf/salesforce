import { LightningElement, api } from 'lwc';

export default class ProgressBar extends LightningElement {
    @api immobilie;
    soldRatio;
    reservedRatio;
    freeRatio;
    countAppartments;

    renderedCallback(){
        this.countAppartments = this.immobilie.Verkaufte_Appartements__c + this.immobilie.Reservierte_Appartements__c+this.immobilie.Freie_Appartments__c;  
        this.soldRatio = this.immobilie.Verkaufte_Appartements__c/this.countAppartments*100; 
        this.reservedRatio = this.immobilie.Reservierte_Appartements__c/this.countAppartments*100; 
        this.freeRatio = this.immobilie.Freie_Appartments__c/this.countAppartments*100; 

        this.computeBarStyles();             
    }
    computeBarStyles(){
        //WIDTHS of Bars
         this.template.querySelector(".soldBar").style.width = this.soldRatio+"%"
         this.template.querySelector(".reservedBar").style.width = this.reservedRatio+"%";
         this.template.querySelector(".freeBar").style.width = this.freeRatio+"%";
        
        //LEFTS of Bars
        var reservedBarLeft = this.soldRatio;
        this.template.querySelector(".reservedBar").style.left = reservedBarLeft+"%";
        var freeBarLeft = reservedBarLeft+this.reservedRatio;
        this.template.querySelector(".freeBar").style.left = freeBarLeft+"%";
    }
}