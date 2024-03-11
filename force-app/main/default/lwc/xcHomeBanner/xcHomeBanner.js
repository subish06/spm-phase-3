import { LightningElement } from 'lwc';

export default class LWCParentSliders extends LightningElement {
    slider1Image = 'https://i.ytimg.com/vi/3up4QeRYGhk/maxresdefault.jpg';
    slider1Link = '#';
    slider2Image = 'https://i.ytimg.com/vi/wHp8Byc5ZXM/maxresdefault.jpg';
    slider2Link = '#';
    slider3Image = 'https://media.bizj.us/view/img/12032163/gibson-garage-32*750xx4016-2259-0-0.jpg';
    slider3Link = '#';
    // slider4Image = 'https://wildwoodguitars.com/wp-content/uploads/2019/05/gibson-original-collection-guitars-banner.jpg';
    // slider4Link = '#';
    autoScroll = true;

    get sliderData() {
        return [{
            "image": this.slider1Image,
            "link": this.slider1Link,
            "heading": "",
            "description": "",
        },
        {
            "image": this.slider2Image,
            "link": this.slider2Link,
            "heading": "",
            "description": "",
        },
        {
            "image": this.slider3Image,
            "link": this.slider3Link,
            "heading": "",
            "description": "",
        }
        ]
    }
}