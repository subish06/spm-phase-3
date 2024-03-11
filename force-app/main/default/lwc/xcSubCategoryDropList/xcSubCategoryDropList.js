import { LightningElement, wire } from 'lwc';
import getParentCategory from '@salesforce/apex/XC_CategoryController.getParentCategory'
import getSubCategories from '@salesforce/apex/XC_CategoryController.getSubCategories'

export default class XcSubCategoryDropList extends LightningElement {






    @wire(getParentCategory)
    wireParentCategory({ error, data }) {
        if (data) {
            this.parentCat = data;
            console.log(JSON.stringify(this.parentCat))
        } else {
            console.log('Erorr ', JSON.stringify(error))
        }
    }


    handleSubMenuMouseHover() {
        this.showHideSubCatPopup = '';
    }

    handleSubMenuMouseOut() {
        this.showHideSubCatPopup = 'display:none;';
    }




    handleMouseHover(event) {


        let parentCatId = event.target.dataset.id;
        getSubCategories({ parentCatId: parentCatId })
            .then(result => {


                this.showNoSubCategory = false;
                this.showHideSubCatPopup = '';

                if (result != null) {

                    this.subCategories = JSON.parse(result);


                    this.subCategories.sort((a, b) => {
                        const nameA = a.subCatName.toLowerCase();
                        const nameB = b.subCatName.toLowerCase();

                        if (nameA < nameB) return -1;
                        if (nameA > nameB) return 1;
                        return 0;
                    });



                } else {
                    this.showNoSubCategory = true;

                }


            })
            .catch(error => {
                console.error(error);
            });



    }

    handleMouseOut() {
        this.showHideSubCatPopup = 'display:none;';
    }

    handleNavigateSubCategory(event) {

        let subCatId = event.target.dataset.id;

        window.location.href = "/AllAxcess/" + subCatId;

    }

    handleMouseover(event) {



        let parentCatId = event.target.dataset.id;
        getSubCategories({ parentCatId: parentCatId })
            .then(result => {

                this.showNoSubCategory = false;
                this.showHideCategoryPopup = true;

                if (result != null) {


                    this.subCategories = JSON.parse(result);


                    this.subCategories.sort((a, b) => {
                        const nameA = a.subCatName.toLowerCase();
                        const nameB = b.subCatName.toLowerCase();

                        if (nameA < nameB) return -1;
                        if (nameA > nameB) return 1;
                        return 0;
                    });



                } else {
                    alert('here')

                    this.showNoSubCategory = true;

                }


            })
            .catch(error => {
                console.error(error);
            });

    }

    /* Handle Mouse Out*/
    handleMouseout1() {
        const toolTipDiv = this.template.querySelector('div.subMenu');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none";
    }













}