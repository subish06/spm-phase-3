import { LightningElement, track, wire, api } from 'lwc';
import getParentCategory from '@salesforce/apex/XC_CategoryController.getParentCategory'
import getSubCategories from '@salesforce/apex/XC_CategoryController.getSubCategories'

export default class XcCategory extends LightningElement {

    parentCat;
    subCategories;
    showNoSubCategory = false;
    showHideCategoryPopup = true;
    categoryHierarchy = [];
    parentCategoryIds;


    
    showHideSubCatPopup = 'display:none;'

    @wire(getParentCategory)
    wireParentCategory({ error, data }) {
        if (data) {
            this.parentCat = data;



            console.log('here are we', JSON.stringify(this.parentCat))


            let allParentCategory = []

            // For PArent Category
            for (const category of this.parentCat) {

                const parentCategoryId = category.ParentCategoryId;
                if (!parentCategoryId) {
                    allParentCategory.push({ ...category, subCategory: [] })
                }
            }

            const parentCategoryIds  = allParentCategory.map(obj => obj.Id);


            // For Second Level category
            const parentIdExists = this.parentCat.some(itm => {

                const parentCategory = itm.ParentCategoryId;

                if (parentCategory) {
                    const foundObject = allParentCategory.find(obj => {

                        if (obj.Id == parentCategory) {
                            obj.isContainSecondLevel = true;
                            obj.subCategory.push({ ...itm, subSubCategory: [] });

                        }
                    });

                }

            });

             // For third Level category
            const subParentIdExists = allParentCategory.some(itm => {


                itm.subCategory.some(obj => {

                     const foundObject = this.parentCat.find(obj1 => {
                            if( itm.subCategory && obj.Id == obj1.ParentCategoryId){
                                
                                obj.subSubCategory.push({...obj1, fourthLevelsubCategory: []})
                            }

                     })
                })
            })


            this.categoryHierarchy = allParentCategory;





        }
        else {
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



                }
                else {
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



                }
                else {

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
    @track data = [
        { id: 1, name: 'Ankit', type: 'CS', buttonname: 'CS1', imageUrl: 'https://source.unsplash.com/user/c_v_r/100x100' },
        { id: 2, name: 'Rijwan', type: 'EC', buttonname: 'EC2', imageUrl: 'https://i.picsum.photos/id/887/200/200.jpg?hmac=yOynpt597y5pLfJ5SsRVVKZiT5MXElbhtgUYeRzu3S4' },
        { id: 3, name: 'Himanshu', type: 'MEC', buttonname: 'MEC3', imageUrl: 'https://source.unsplash.com/user/c_v_r/100x100' },
        { id: 4, name: 'Anil', type: 'CS', buttonname: 'CS4', imageUrl: 'https://source.unsplash.com/user/c_v_r/100x100' },
        { id: 5, name: 'Sachin', type: 'MSC', buttonname: 'CS5', imageUrl: 'https://source.unsplash.com/user/c_v_r/100x100' },
    ];

    handleSectionToggle(event) {
        let subCatId = event.target.dataset.id;
        alert(subCatId)
        console.log(event.detail.openSections);
    }


    // @track sections = [
    //     { id: '1', label: 'Section 1', open: false },
    //     { id: '2', label: 'Section 2', open: false },
    //     { id: '3', label: 'Section 3', open: false }
    // ];

    // handleSectionToggle(event) {
    //     const selectedSectionId = event.detail.name;

    //     this.sections = this.sections.map(section => ({
    //         ...section,
    //         open: section.id === selectedSectionId
    //     }));
    // }



handleParentSection(){
    const accordionSection = this.template.querySelector('.parentSection');

    alert(JSON.stringify(accordionSection));
}


handleClickhere(event){
    let a = event.currentTarget.dataset.id;
    var divblock = this.template.querySelector('[data-id="'+ a +'"]');
    
 let ab = this.template.querySelector('[data-id="'+ a +'"]').className;
   
    if(ab.includes('slds-is-open')){

        this.template.querySelector('[data-id="'+ a +'"]').classList.remove('slds-is-open');
        
        
    }
    else{
        this.template.querySelector('[data-id="'+ a +'"]').className = 'slds-accordion__section slds-is-open';
    }


    this.categoryHierarchy.forEach(ele => {

        let abc = this.template.querySelector('[data-id="'+ ele.Id +'"]').className;
        if(abc.includes('slds-is-open') && ele.Id != a){
            this.template.querySelector('[data-id="'+ ele.Id +'"]').classList.remove('slds-is-open');
        }

      
    });

   




}

  




}