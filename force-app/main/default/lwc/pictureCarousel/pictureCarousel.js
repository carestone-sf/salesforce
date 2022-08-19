import { LightningElement,api, wire, track } from 'lwc';

export default class PictureCarousel extends LightningElement {
    @api immobilie;

    @track
    selectedImage;
    @track
    showPictureModal;

    runOnce = false;

    get immobilieId() {
        return this.immobilie?.Id;
    }

    renderedCallback() {
        if(!this.runOnce) {
            const slide = this.template.querySelector('.slide');
            if(slide) {
                slide.classList.add('active');
                this.selectedImage = slide.dataset.key;
            }
        }
        this.runOnce = true;
    }

    selectSlide(event){
        const key = event.target.closest('[data-key]').dataset.key;
        this.selectedImage = key;
        this.template.querySelectorAll('.slide').forEach(function(slide) {
            slide.classList.remove('active');
        });
        this.template.querySelector('.slide[data-key="' + key + '"]').classList.add('active');
    }

    openPictureModal() {
        // Currently not used
        // add onclick on the img to use 
        this.showPictureModal = true;
    }

    closePictureModal() {
        this.showPictureModal = false;
    }
}