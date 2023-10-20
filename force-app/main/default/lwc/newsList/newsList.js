import { LightningElement, track } from 'lwc';

export default class NewsList extends LightningElement {

    news;
    isLoading = true;

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
    }

}