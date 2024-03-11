import { LightningElement,track } from 'lwc';
import {EXAMPLES_COLUMNS_DEFINITION_BASIC,EXAMPLES_DATA_BASIC,} from './sampleData';

const columns = [
    { label: 'Business Unit / Month', fieldName: 'BusinessUnit', type: 'text',hideDefaultActions: true, initialWidth: 200,},
    { label: 'Apr', fieldName: 'Apr', type: 'text', hideDefaultActions: true },
    { label: 'May', fieldName: 'May', type: 'text', hideDefaultActions: true },
    { label: 'Jun', fieldName: 'Jun', type: 'text', hideDefaultActions: true },
    { label: 'Jul', fieldName: 'Jul', type: 'text', hideDefaultActions: true },
    { label: 'Aug', fieldName: 'Aug', type: 'text', hideDefaultActions: true },
    { label: 'Sep', fieldName: 'Sep', type: 'text', hideDefaultActions: true },
    { label: 'Oct', fieldName: 'Oct', type: 'text', hideDefaultActions: true },
    { label: 'Nov', fieldName: 'Nov', type: 'text', hideDefaultActions: true },
    { label: 'Dec', fieldName: 'Dec', type: 'text', hideDefaultActions: true },
    { label: 'Jan', fieldName: 'Jan', type: 'text', hideDefaultActions: true },
    { label: 'Feb', fieldName: 'Feb', type: 'text', hideDefaultActions: true },
    { label: 'Mar', fieldName: 'Mar', type: 'text', hideDefaultActions: true },
];

const tarData = [
    {
        BusinessUnit : 'Acoustic',Apr : '$2M',May : '$20M',Jun : '$20M',Jul : '$20M',Aug : '$20M',
        Sep : '$20M',Oct : '$20M',Nov : '$20M',Dec : '$20M',Jan : '$20M',Feb : '$20M',Mar : '$20M'},
        {
        BusinessUnit : 'Custom',Apr : '$2M',May : '$3M',Jun : '$2.4M',Jul : '$2.3M',Aug : '$3.4M',
        Sep : '$2M',Oct : '$3M',Nov : '$8M',Dec : '$22M',Jan : '$2M',Feb : '$7.4M',	Mar : '$2M'},
        {
        BusinessUnit : 'Epiphone',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'},
        {
        BusinessUnit : 'Kramer',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'},
        {
        BusinessUnit : 'Mesa Boogie',Apr : '$20M',May : '$20M',Jun : '$20M',Jul : '$20M',Aug : '$20M',
        Sep : '$20M',Oct : '$20M',Nov : '$20M',Dec : '$20M',Jan : '$20M',Feb : '$20M',Mar : '$20M'},
        {
        BusinessUnit : 'Steinberger',Apr : '$2M',May : '$3M',Jun : '$2.4M',Jul : '$2.3M',Aug : '$3.4M',
        Sep : '$2M',Oct : '$3M',Nov : '$8M',Dec : '$22M',Jan : '$2M',Feb : '$7.4M',	Mar : '$2M'},
        {
        BusinessUnit : 'Total',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'}

];

const ordData = [
    {
        BusinessUnit : 'Kramer',Apr : '$20M',May : '$20M',Jun : '$20M',Jul : '$20M',Aug : '$20M',
        Sep : '$20M',Oct : '$20M',Nov : '$20M',Dec : '$20M',Jan : '$20M',Feb : '$20M',Mar : '$20M'},
        {
        BusinessUnit : 'KRK',Apr : '$2M',May : '$3M',Jun : '$2.4M',Jul : '$2.3M',Aug : '$3.4M',
        Sep : '$2M',Oct : '$3M',Nov : '$8M',Dec : '$22M',Jan : '$2M',Feb : '$7.4M',	Mar : '$2M'},
        {
        BusinessUnit : 'Lifestyle',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'},
        {
        BusinessUnit : 'Mesa Boogie',Apr : '$20M',May : '$20M',Jun : '$20M',Jul : '$20M',Aug : '$20M',
        Sep : '$20M',Oct : '$20M',Nov : '$20M',Dec : '$20M',Jan : '$20M',Feb : '$20M',Mar : '$20M'},
        {
        BusinessUnit : 'Steinberger',Apr : '$2M',May : '$3M',Jun : '$2.4M',Jul : '$2.3M',Aug : '$3.4M',
        Sep : '$2M',Oct : '$3M',Nov : '$8M',Dec : '$22M',Jan : '$2M',Feb : '$7.4M',	Mar : '$2M'},
        {
        BusinessUnit : 'Total',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'}

];

const varData = [
    {
        BusinessUnit : 'Acoustic',Apr : '$20M',May : '$20M',Jun : '$20M',Jul : '$20M',Aug : '$20M',
        Sep : '$20M',Oct : '$20M',Nov : '$20M',Dec : '$20M',Jan : '$20M',Feb : '$20M',Mar : '$20M'},
        {
        BusinessUnit : 'Custom',Apr : '$2M',May : '$3M',Jun : '$2.4M',Jul : '$2.3M',Aug : '$3.4M',
        Sep : '$2M',Oct : '$3M',Nov : '$8M',Dec : '$22M',Jan : '$2M',Feb : '$7.4M',	Mar : '$2M'},
        {
        BusinessUnit : 'Epiphone',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'},
        {
        BusinessUnit : 'Mesa Boogie',Apr : '$20M',May : '$20M',Jun : '$20M',Jul : '$20M',Aug : '$20M',
        Sep : '$20M',Oct : '$20M',Nov : '$20M',Dec : '$20M',Jan : '$20M',Feb : '$20M',Mar : '$20M'},
        {
        BusinessUnit : 'Steinberger',Apr : '$2M',May : '$3M',Jun : '$2.4M',Jul : '$2.3M',Aug : '$3.4M',
        Sep : '$2M',Oct : '$3M',Nov : '$8M',Dec : '$22M',Jan : '$2M',Feb : '$7.4M',	Mar : '$2M'},
        {
        BusinessUnit : 'USA',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'},
        {
        BusinessUnit : 'Total',Apr : '$3.40M',May : '$6.62M',Jun : '$2.32M',Jul : '$2M',Aug : '$2.4M',
        Sep : '$7M',Oct : '$8.3M',Nov : '$1.1M',Dec : '$1.23M',Jan : '$1.53M',Feb : '$2.23M',Mar : '$2.23M'}

];

export default class Spm_bdm_overall_account_summary extends LightningElement {

    activeSections = ['Target', 'Order', 'Variance'];

    @track isSummaryScreen = false;

    columns = columns;
    tarData = tarData;
    ordData = ordData;
    varData = varData;

    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
    gridData = EXAMPLES_DATA_BASIC;
    gridExpandedRows = ['1','2','3','4','5','6','7','8','9','10','11','12',
                        '13','14','15','16','17','18','19','20','21','22','23','24',
                        '25','26','27','28'];
    
    handleToggleChange(){
        this.isSummaryScreen = !this.isSummaryScreen;	
    }
}