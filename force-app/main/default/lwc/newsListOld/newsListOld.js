import { LightningElement, track } from 'lwc';

export default class NewsListOld extends LightningElement {

    news;
    items;
    totalItems;
    itemClassName;
    slide;
    moving;
    isLoading = true;

    itemsHaveRendered;

    connectedCallback() {
        const typo3NewsUrl = 'https://api.carestone.com/carestone/news.json';
        fetch(typo3NewsUrl)
        .then(function(response) {
            return response.json();
        })
        .then((jsonResponse) => {
            this.news = jsonResponse;
            this.news.forEach(function(singleNews) {
                singleNews.image = 'https://carestone.com' + singleNews.image;
            });
            this.isLoading = false;
        });
    }

    renderedCallback() {
        // window.tns();    
        if(this.template.querySelectorAll('.carousel__photo').length > 0 && !this.itemsHaveRendered) {
            this.itemsHaveRendered = true;
            this.init();
        }
    }

    init() {
        this.itemClassName = "carousel__photo";
        this.items = this.template.querySelectorAll('.' + this.itemClassName);
        this.totalItems = this.items.length;
        this.slide = 0;
        this.moving = true;
        this.setInitialClasses();
        // Set moving to false so that the carousel becomes interactive
        this.moving = false;
    }

    // Set classes
    setInitialClasses() {
        // Targets the previous, current, and next items
        // This assumes there are at least three items.
        this.items[this.totalItems - 1].classList.add("prev");
        this.items[0].classList.add("active");
        this.items[1].classList.add("next");
    }

    // Next navigation handler
    moveNext() {
        // Check if moving
        if (!this.moving) {
            // If it's the last slide, reset to 0, else +1
            if (this.slide === (this.totalItems - 1)) {
                this.slide = 0;
            } else {
                this.slide++;
            }
            // Move carousel to updated slide
            this.moveCarouselTo(this.slide);
        }
    }
    // Previous navigation handler    
    movePrev() {
        // Check if moving
        if (!this.moving) {
            // If it's the first slide, set as the last slide, else -1
            if (this.slide === 0) {
                this.slide = (this.totalItems - 1);
            } else {
                this.slide--;
            }
                    
            // Move carousel to updated slide
            this.moveCarouselTo(this.slide);
        }
    }
    
    disableInteraction() {
        // Set 'moving' to true for the same duration as our transition.
        // (0.5s = 500ms)
        
        this.moving = true;
        // setTimeout runs its function once after the given time
        setTimeout(() => {
          this.moving = false
        }, 500);
      }

    moveCarouselTo(slide) {
        // Check if carousel is moving, if not, allow interaction
        if(!this.moving) {
          // temporarily disable interactivity
          this.disableInteraction();
          // Update the "old" adjacent slides with "new" ones
          var newPrevious = this.slide - 1,
              newNext = this.slide + 1,
              oldPrevious = this.slide - 2,
              oldNext = this.slide + 2;
          // Test if carousel has more than three items
          if ((this.totalItems - 1) > 3) {
            // Checks and updates if the new slides are out of bounds
            if (newPrevious <= 0) {
              oldPrevious = (this.totalItems - 1);
            } else if (newNext >= (this.totalItems - 1)){
              oldNext = 0;
            }
            // Checks and updates if slide is at the beginning/end
            if (this.slide === 0) {
              newPrevious = (this.totalItems - 1);
              oldPrevious = (this.totalItems - 2);
              oldNext = (this.slide + 1);
            } else if (this.slide === (this.totalItems -1)) {
              newPrevious = (this.slide - 1);
              newNext = 0;
              oldNext = 1;
            }
            // Now we've worked out where we are and where we're going, 
            // by adding/removing classes we'll trigger the transitions.
            // Reset old next/prev elements to default classes
            this.items[oldPrevious].className = this.itemClassName;
            this.items[oldNext].className = this.itemClassName;
            // Add new classes
            this.items[newPrevious].className = this.itemClassName + " prev";
            this.items[slide].className = this.itemClassName + " active";
            this.items[newNext].className = this.itemClassName + " next";
          }
        }
      }

}