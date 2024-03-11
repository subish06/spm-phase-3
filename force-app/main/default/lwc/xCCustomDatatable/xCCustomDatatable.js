import LightningDatatable from 'lightning/datatable';
import xCButtonTemplate from './xCButton.html';

export default class XCCustomDatableElement extends LightningDatatable {

    static customTypes = {
        xcButton: {
            template: xCButtonTemplate,
            standardCellLayout: true,
            typeAttributes: ['id'],
        }
        // Other types here
    }
}