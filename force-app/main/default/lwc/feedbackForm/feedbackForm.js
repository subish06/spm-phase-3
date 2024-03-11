import { LightningElement, api, track } from 'lwc';
import getCaseRecord from '@salesforce/apex/FeedbackFormController.getCaseRecord';
import caseSurveyResult from '@salesforce/apex/FeedbackFormController.caseSurveyResult';
import loadGibsonLogo from '@salesforce/resourceUrl/gibsonLogo';

export default class FeedbackForm extends LightningElement {

    gibsonLogo = loadGibsonLogo;
    caseRecord = {};
    
    @api recordId;

    @track showSpinner = false;
    @track showMessage = false;
    @track messageExistingUser = false;
    @track surveyResult = { Service_Satisfication__c: 0, Resolving_Issues__c: 0, Improvement_in_Service__c: '' };

    @track serviceQnrs = [
        { value: 1, isSelected: false },
        { value: 2, isSelected: false },
        { value: 3, isSelected: false },
        { value: 4, isSelected: false },
        { value: 5, isSelected: false },
        { value: 6, isSelected: false },
        { value: 7, isSelected: false },
        { value: 8, isSelected: false },
        { value: 9, isSelected: false },
        { value: 10, isSelected: false }
    ];

    @track recommendQnrs = [
        { value: 1, isSelected: false },
        { value: 2, isSelected: false },
        { value: 3, isSelected: false },
        { value: 4, isSelected: false },
        { value: 5, isSelected: false },
        { value: 6, isSelected: false },
        { value: 7, isSelected: false },
        { value: 8, isSelected: false },
        { value: 9, isSelected: false },
        { value: 10, isSelected: false }
    ];

    @track issueQnrs = [
        { value: 1, isSelected: false },
        { value: 2, isSelected: false },
        { value: 3, isSelected: false },
        { value: 4, isSelected: false },
        { value: 5, isSelected: false },
        { value: 6, isSelected: false },
        { value: 7, isSelected: false },
        { value: 8, isSelected: false },
        { value: 9, isSelected: false },
        { value: 10, isSelected: false }
    ];

    connectedCallback() {
        getCaseRecord({ recordId: this.recordId})
            .then((data) => {
                this.caseRecord = data;

                if (this.caseRecord.Survey_Submitted__c) {
                    this.messageExistingUser = !this.messageExistingUser;
                }
            });
    }

    satisfiedHandleClick(event) {
        this.surveyResult.Service_Satisfication__c = event.target.dataset.value;
        this.serviceQnrs.forEach((serviceQnr) => {
            if (serviceQnr.value == event.target.dataset.value) {
                serviceQnr.isSelected = true;
            }
            else {
                serviceQnr.isSelected = false;
            }
        });
    }

    issueHandleClick(event) {
        this.surveyResult.Resolving_Issues__c = event.target.dataset.value;
        this.issueQnrs.forEach((issueQnr) => {
            if (issueQnr.value == event.target.dataset.value) {
                issueQnr.isSelected = true;
            }
            else {
                issueQnr.isSelected = false;
            }
        });
    }

    recommendHandleClick(event) {
        this.surveyResult.Recommendation__c = event.target.dataset.value;
        this.recommendQnrs.forEach((recommendQnr) => {
            if (recommendQnr.value == event.target.dataset.value) {
                recommendQnr.isSelected = true;
            }
            else {
                recommendQnr.isSelected = false;
            }
        });
    }

    improveHandleChange(event) {
        this.surveyResult.Improvement_in_Service__c = event.target.value;
    }

    handleClick() {
        this.showSpinner = true;
        caseSurveyResult({ recordId: this.recordId, caseRecord: this.caseRecord, surveyResult: this.surveyResult })
            .then((data) => {
                this.showSpinner = false;
                this.showMessage = true;
            })
            .catch((error) => {
                console.log('error====>', error);
            });
    }
}