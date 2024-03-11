import { createElement } from 'lwc';
import Spm_dtc_month_summary from 'c/spm_dtc_month_summary';

describe('c-spm-dtc-month-summary', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('TODO: test case generated by CLI command, please fill in test logic', () => {
        // Arrange
        const element = createElement('c-spm-dtc-month-summary', {
            is: Spm_dtc_month_summary
        });

        // Act
        document.body.appendChild(element);

        // Assert
        // const div = element.shadowRoot.querySelector('div');
        expect(1).toBe(1);
    });
});