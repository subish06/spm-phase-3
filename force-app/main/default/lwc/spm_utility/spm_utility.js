import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Call this method to display error message in toast event
export function showError(error) {
    let message;
    if (error && typeof error === "string") {
        message = error;
    } else if (
        // UI API read operations return an array of objects
        Array.isArray(error.body)
    ) {
        message = error.body.map((e) => e.message).join(", ");
    } else if (
        error.body.output &&
        Array.isArray(error.body.output.errors) &&
        error.body.output.errors.length > 0
    ) {
        message = error.body.output.errors.map((e) => e.message).join(", ");
    }
    // UI API write operations, Apex read and write operations
    // and network errors return a single object
    else if (error.body && typeof error.body.message === "string") {
        message = error.body.message;
    } 
    else if (
        Array.isArray(error.body.output.fieldErrors) &&
        error.body.output.fieldErrors.length > 0
    ) {
        //field specific errors--we'll say what the field is
        for (const fieldName in error.body.output.fieldErrors) {
            if (error.body.output.fieldErrors[fieldName]) {
                message = error.body.output.fieldErrors[fieldName]
                    .map((e) => e.message)
                    .join(", ");
            }
        }
    }

    // Display toast message
    const evt = new ShowToastEvent({
        title: "Error!",
        message: message,
        variant: "error"
    });
    dispatchEvent(evt);
}

// Call this method to display success message in toast event
export function showSuccess(message) {
    // Display toast message
    const evt = new ShowToastEvent({
        title: "Success!",
        message: message,
        variant: "success"
    });
    dispatchEvent(evt);
}

export function currencyFormatter(currency) {
    switch (currency) {
        case 'USD': return '$';
        case 'EUR': return '€';
        case 'GBP': return '£';
        case 'JPY': return '¥';
        default: return '';
    }
}

export function nFormatter(num, digits) {
    /*const lookup = [
        { value: 1, symbol: "" },
        { value: 1e3, symbol: "k" },
        { value: 1e6, symbol: "M" },
        { value: 1e9, symbol: "G" },
        { value: 1e12, symbol: "T" },
        { value: 1e15, symbol: "P" },
        { value: 1e18, symbol: "E" }
    ];
    const rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
    var item = lookup.slice().reverse().find(function (item) {
        return num >= item.value;
    });
    return item ? (num / item.value).toFixed(digits).replace(rx, "$1") + item.symbol : "0";*/

    // if (num < 0) {
    //     return "-" + formatCompactNumber(-1 * num);
    // }

    
    if (num < 1000) {
        return num.toFixed(digits);
    } else if (num >= 1000 && num < 1000000) {
        return (num / 1000).toFixed(digits) + "K";
    } else if (num >= 1000000 && num < 1000000000) {
        return (num / 1000000).toFixed(digits) + "M";
    } else if (num >= 1000000000 && num < 1000000000000) {
        return (num / 1000000000).toFixed(digits) + "B";
    } else if (num >= 1000000000000 && num < 1000000000000000) {
        return (num / 1000000000000).toFixed(digits) + "T";
    }  
}