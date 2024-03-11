/**
 * Default settings values
 */
export const KEYFIELD = 'name';

/**
 * Columns definition
 * :: valid basic version
 */
export const COLUMNS_DEFINITION_BASIC = [
    {
        type: 'text',
        fieldName: 'accountName',
        label: 'Account Name',
    },
    {
        type: 'phone',
        fieldName: 'phone',
        label: 'Phone Number',
    },
];

/**
 * Columns definition
 * :: with non-whitelisted column keys
 */
export const COLUMNS_DEFINITION_NONWHITELIST = [
    {
        type: 'text',
        fieldName: 'accountName',
        label: 'Account Name',
    },
    {
        type: 'phone',
        fieldName: 'phone',
        label: 'Phone Number',
        sortable: true,
    },
];

/**
 * Columns definition
 * :: used in examples
 */
export const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    {type: 'text',fieldName: 'BusinessUnit',label: 'Business Unit / Month',initialWidth: 200},
    {type: 'text',fieldName: 'sections', label: ''},
    {type: 'text',fieldName: 'Apr',label: 'Apr',},
    {type: 'text',fieldName: 'May',label: 'May',},
    {type: 'text',fieldName: 'Jun',label: 'Jun',},
    {type: 'text',fieldName: 'Jul',label: 'Jul',},
    {type: 'text',fieldName: 'Aug',label: 'Aug',},
    {type: 'text',fieldName: 'Sep',label: 'Sep',},
    {type: 'text',fieldName: 'Oct',label: 'Oct',},
    {type: 'text',fieldName: 'Nov',label: 'Nov',},
    {type: 'text',fieldName: 'Dec',label: 'Dec',},
    {type: 'text',fieldName: 'Jan',label: 'Jan',},
    {type: 'text',fieldName: 'Feb',label: 'Feb',},
    {type: 'text',fieldName: 'Mar',label: 'Mar',},
    
];

/**
 * Sample expanded rows
 * :: valid basic version, no invalid row IDs
 */
export const EXPANDED_ROWS_BASIC = ['584996-s7', '377526-zg'];

/**
 * Sample expanded rows including some without children content
 * :: valid basic version, no invalid row IDs
 */
export const EXPANDED_ROWS_MISSING_CHILDREN_CONTENT = [
    '584996-s7',
    '377526-zg',
    '816682-xr',
];

/**
 * Sample expanded rows
 * :: with invalid row IDs
 */
export const EXPANDED_ROWS_INVALID = [
    '584996-s7',
    '377526-zg',
    'AWEFUL-bad_iD',
    '882894-s3',
    'PiCkLeS',
    '31337-ID',
];

/**
 * Sample selected rows
 * :: valid basic version, no invalid row IDs
 */
export const SELECTED_ROWS_BASIC = ['125313-7j', '584996-s7'];

/**
 * Sample selected rows
 * :: with invalid row IDs
 */
export const SELECTED_ROWS_INVALID = [
    '584996-s7',
    '377526-zg',
    'AWEFUL-bad_iD',
    '882894-s3',
    'PiCkLeS',
    '31337-ID',
];

/**
 * Sample data
 * :: valid basic version, no missing children content
 */
export const DATA_BASIC = [
    {
        name: '125313-7j',
        accountName: 'Dach-Welch',
        phone: '837-555-0100',
    },
    {
        name: '584996-s7',
        accountName: 'Corkery-Windler',
        phone: '837-555-0100',
        _children: [
            {
                name: '747773-jw',
                accountName: 'Corkery-Abshire',
                phone: '837-555-0100',
            },
            {
                name: '377526-zg',
                accountName: 'Robel, Friesen and Flatley',
                phone: '837-555-0100',
                _children: [
                    {
                        name: '955330-wp',
                        accountName: 'Donnelly Group',
                        phone: '837-555-0100',
                    },
                    {
                        name: '343693-9x',
                        accountName: 'Kshlerin Group',
                        phone: '837-555-0100',
                    },
                ],
            },
            {
                name: '638483-y2',
                accountName: 'Bruen, Steuber and Spencer',
                phone: '837-555-0100',
            },
        ],
    },
    {
        name: '306979-mx',
        accountName: 'Spinka LLC',
        phone: '837-555-0100',
    },
    {
        name: '066195-o1',
        accountName: 'Koelpin LLC',
        phone: '837-555-0100',
        _children: [],
    },
];

/**
 * Sample data
 * :: valid basic version, with missing children content
 */
export const DATA_MISSING_CHILDREN_CONTENT = [
    {
        name: '125313-7j',
        accountName: 'Dach-Welch',
        phone: '837-555-0100',
    },
    {
        name: '584996-s7',
        accountName: 'Corkery-Windler',
        phone: '837-555-0100',
        _children: [],
    },
    {
        name: '816682-xr',
        accountName: 'Schmitt-Littel',
        phone: '837-555-0100',
        _children: [
            {
                name: '118985-mf',
                accountName: 'Hegmann-Turcotte',
                phone: '837-555-0100',
            },
            {
                name: '841476-yo',
                accountName: 'Kuhlman LLC',
                phone: '837-555-0100',
            },
        ],
    },
    {
        name: '653331-j4',
        accountName: 'Swaniawski-Hilpert',
        phone: '366-145-6134',
        _children: [
            {
                name: '605249-ei',
                accountName: 'Swaniawski, Veum and Barton',
                phone: '837-555-0100',
            },
            {
                name: '686777-5d',
                accountName: 'Lubowitz, McClure and Russel',
                phone: '837-555-0100',
            },
            {
                name: '582166-n4',
                accountName: 'Reichel-Jerde',
                phone: '837-555-0100',
                _children: [
                    {
                        name: '513683-mm',
                        accountName: 'Tromp Inc',
                        phone: '837-555-0100',
                    },
                ],
            },
        ],
    },
    {
        name: '306979-mx',
        accountName: 'Spinka LLC',
        phone: '837-555-0100',
    },
    {
        name: '066195-o1',
        accountName: 'Koelpin LLC',
        phone: '837-555-0100',
        _children: [],
    },
];

/**
 * Sample data
 * :: used by examples
 */
export const EXAMPLES_DATA_BASIC = [
    
    {
        name: '1',
        BusinessUnit : 'Epiphone',
        _children: [
            {
                name: '2',
                sections: 'Target', 
                Apr : '$24.43k',May : '$34.6k',Jun : '$4.50k',Jul : '$44.56k',Aug : '$99.56k',Sep : '$28.56k',
                Oct : '$3.5k',Nov : '$2.56k',Dec : '$4.86k',Jan : '$6.56k',Feb : '$4.56k',Mar : '$9.56k',             
            },
            {
                name: '3',
                sections: 'Order', 
                Apr : '$4.56k',May : '$55.56k',Jun : '$4.56k',Jul : '$55.56k',Aug : '$24.56k',Sep : '$25.56k',
                Oct : '$24.56k',Nov : '$4.58k',Dec : '$34.58k',Jan : '$23.56k',Feb : '$4.56k',Mar : '$2.56k',             
            },
            {
                name: '4',
                sections: 'Variance', 
                Apr : '$23.50k',May : '$4.56k',Jun : '$234.56k',Jul : '$11.55k',Aug : '$54.56k',Sep : '$234.56k',
                Oct : '$34.56k',Nov : '$74.56k',Dec : '$2.66k',Jan : '$34.46k',Feb : '$4.54k',Mar : '$3.56k',             
            },
        ],
    
    },

    {
        name: '5',
        BusinessUnit : 'Custom',
        _children: [
            {
                name: '6',
                sections: 'Target', 
                Apr : '$23.76k',May : '$45.55k',Jun : '$34.76k',Jul : '$23.55k',Aug : '$54.56k',Sep : '$64.50k',
                Oct : '$4.56k',Nov : '$2.50k',Dec : '$24.56k',Jan : '$25.56k',Feb : '$234.56k',Mar : '$234.66k',             
            },
            {
                name: '7',
                sections: 'Order', 
                Apr : '$34.56k',May : '$25.56k',Jun : '$9.56k',Jul : '$234.56k',Aug : '$234.56k',Sep : '$234.56k',
                Oct : '$4.56k',Nov : '$22.56k',Dec : '$4.56k',Jan : '$1.56k',Feb : '$9.56k',Mar : '$8.50k',             
            },
            {
                name: '8',
                sections: 'Variance', 
                Apr : '$24.86k',May : '$3.56k',Jun : '$3.56k',Jul : '$8.50k',Aug : '$1.56k',Sep : '$2.56k',
                Oct : '$2.56k',Nov : '$4.56k',Dec : '$5.86k',Jan : '$88.55k',Feb : '$2.56k',Mar : '$4.56k',             
            },
        ],
    
    },

    {
        name: '9',
        BusinessUnit : 'Meesa Boogie',
        _children: [
            {
                name: '10',
                sections: 'Target', 
                Apr : '$4.56k',May : '$2.56k',Jun : '$23.56k',Jul : '$24.56k',Aug : '$4.56k',Sep : '$5.56k',
                Oct : '$24.56k',Nov : '$3.58k',Dec : '$2.55k',Jan : '$3.58k',Feb : '$5.56k',Mar : '$6.56k',             
            },
            {
                name: '11',
                sections: 'Order', 
                Apr : '$5.56k',May : '$4.56k',Jun : '$9.66k',Jul : '$6.56k',Aug : '$2.56k',Sep : '$4.86k',
                Oct : '$5.56k',Nov : '$3.56k',Dec : '$6.55k',Jan : '$2.56k',Feb : '$2.55k',Mar : '$5.55k',             
            },
            {
                name: '12',
                sections: 'Variance', 
                Apr : '$24.86k',May : '$4.56k',Jun : '$8.56k',Jul : '$6.58k',Aug : '$2.26k',Sep : '$26.59k',
                Oct : '$4.56k',Nov : '$74.56k',Dec : '$6.56k',Jan : '$4.63k',Feb : '$2.56k',Mar : '$4.66k',             
            },
        ],
    
    },

    {
        name: '17',
        BusinessUnit : 'Kramer',
        _children: [
            {
                name: '18',
                sections: 'Target', 
                Apr : '$4.56k',May : '$3.52k',Jun : '$2.52k',Jul : '$4.50k',Aug : '$3.56k',Sep : '$4.56k',
                Oct : '$24.56k',Nov : '$4.26k',Dec : '$2.54k',Jan : '$4.56k',Feb : '$3.56k',Mar : '$4.56k',             
            },
            {
                name: '19',
                sections: 'Order', 
                Apr : '$55.56k',May : '$2.58k',Jun : '$25.56k',Jul : '$26.56k',Aug : '$24.50k',Sep : '$2.66k',
                Oct : '$4.56k',Nov : '$6.66k',Dec : '$2.86k',Jan : '$24.56k',Feb : '$23.56k',Mar : '$4.56k',             
            },
            {
                name: '20',
                sections: 'Variance', 
                Apr : '$23.56k',May : '$4.56k',Jun : '$34.5k',Jul : '$4.56k',Aug : '$9.86k',Sep : '$23.56k',
                Oct : '$34.56k',Nov : '$24.56k',Dec : '$4.56k',Jan : '$4.56k',Feb : '$2.96k',Mar : '$24.56k',             
            },
        ],
    
    },

    {
        name: '21',
        BusinessUnit : 'USA',
        _children: [
            {
                name: '22',
                sections: 'Target', 
                Apr : '$24.55k',May : '$26.86k',Jun : '$1.56k',Jul : '$8.56k',Aug : '$2.99k',Sep : '$2.86k',
                Oct : '$24.56k',Nov : '$4.55k',Dec : '$2.59k',Jan : '$29.55k',Feb : '$5.56k',Mar : '$2.96k',             
            },
            {
                name: '23',
                sections: 'Order', 
                Apr : '$2.56k',May : '$54.59k',Jun : '$2.86k',Jul : '$2.56k',Aug : '$2.56k',Sep : '$24.56k',
                Oct : '$4.56k',Nov : '$4.36k',Dec : '$4.26k',Jan : '$4.56k',Feb : '$2.56k',Mar : '$2.56k',             
            },
            {
                name: '24',
                sections: 'Variance', 
                Apr : '$234.56k',May : '$24.56k',Jun : '$23.56k',Jul : '$25.56k',Aug : '$34.56k',Sep : '$34.56k',
                Oct : '$34.56k',Nov : '$4.56k',Dec : '$23.56k',Jan : '$23.56k',Feb : '$24.56k',Mar : '$54.56k',             
            },
        ],
    
    },

    {
        name: '25',
        BusinessUnit : 'Total',
        _children: [
            {
                name: '26',
                sections: 'Target', 
                Apr : '$24.56M',May : '$32.56M',Jun : '$88.56M',Jul : '$24.56M',Aug : '$4.63M',Sep : '$8.26M',
                Oct : '$24.77M',Nov : '$24.56M',Dec : '$34.56M',Jan : '$2.56M',Feb : '$4.55M',Mar : '$9.86M',             
            },
            {
                name: '27',
                sections: 'Order', 
                Apr : '$2.52M',May : '$23.56M',Jun : '$8.33M',Jul : '$2.56M',Aug : '$3.86M',Sep : '$8.56M',
                Oct : '$4.52M',Nov : '$1.22M',Dec : '$2.26M',Jan : '$4.66M',Feb : '$6.36M',Mar : '$2.56M',             
            },
            {
                name: '28',
                sections: 'Variance', 
                Apr : '$23.56M',May : '$4.56M',Jun : '$23.56M',Jul : '$23.56M',Aug : '$54.36M',Sep : '$74.56M',
                Oct : '$23.22M',Nov : '$24.56k',Dec : '$34.56M',Jan : '$24.56k',Feb : '$22.36M',Mar : '$4.56M',             
            },
        ],
    
    },

    // {
    //     name: '123557',
    //     accountName: 'Rhode Enterprises',
    //     employees: 6000,
    //     phone: '837-555-0100',
    //     accountOwner: 'http://salesforce.com/fake/url/jane-doe',
    //     accountOwnerName: 'John Doe',
    //     billingCity: 'New York, NY',
    //     _children: [
    //         {
    //             name: '123557-A',
    //             accountName: 'Rhode Enterprises (UCA)',
    //             employees: 2540,
    //             phone: '837-555-0100',
    //             accountOwner: 'http://salesforce.com/fake/url/jane-doe',
    //             accountOwnerName: 'John Doe',
    //             billingCity: 'New York, NY',
    //         },
    //     ],
    // },

    // {
    //     name: '123558',
    //     accountName: 'Tech Labs',
    //     employees: 1856,
    //     phone: '837-555-0100',
    //     accountOwner: 'http://salesforce.com/fake/url/jane-doe',
    //     accountOwnerName: 'John Doe',
    //     billingCity: 'New York, NY',
    //     _children: [
    //         {
    //             name: '123558-A',
    //             accountName: 'Opportunity Resources Inc',
    //             employees: 1934,
    //             phone: '837-555-0100',
    //             accountOwner: 'http://salesforce.com/fake/url/jane-doe',
    //             accountOwnerName: 'John Doe',
    //             billingCity: 'Los Angeles, CA',
    //         },
    //     ],
    // },
];

/**
 * Sample data
 * :: used by lazy loading example
 */
export const EXAMPLES_DATA_LAZY_LOADING = [
    {
        name: '123555',
        accountName: 'Rewis Inc',
        employees: 3100,
        phone: '837-555-0100',
        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
        accountOwnerName: 'Jane Doe',
        billingCity: 'Phoeniz, AZ',
    },

    {
        name: '123556',
        accountName: 'Acme Corporation',
        employees: 10000,
        phone: '837-555-0100',
        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
        accountOwnerName: 'John Doe',
        billingCity: 'San Francisco, CA',
        _children: [
            {
                name: '123556-A',
                accountName: 'Acme Corporation (Bay Area)',
                employees: 3000,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'New York, NY',
                _children: [],
            },

            {
                name: '123556-B',
                accountName: 'Acme Corporation (East)',
                employees: 430,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'San Francisco, CA',
                _children: [
                    {
                        name: '123556-B-A',
                        accountName: 'Acme Corporation (NY)',
                        employees: 1210,
                        phone: '837-555-0100',
                        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                        accountOwnerName: 'Jane Doe',
                        billingCity: 'New York, NY',
                    },
                    {
                        name: '123556-B-B',
                        accountName: 'Acme Corporation (VA)',
                        employees: 410,
                        phone: '837-555-0100',
                        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                        accountOwnerName: 'John Doe',
                        billingCity: 'New York, NY',
                        _children: [],
                    },
                ],
            },
        ],
    },

    {
        name: '123557',
        accountName: 'Rhode Enterprises',
        employees: 6000,
        phone: '837-555-0100',
        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
        accountOwnerName: 'John Doe',
        billingCity: 'New York, NY',
        _children: [
            {
                name: '123557-A',
                accountName: 'Rhode Enterprises (UCA)',
                employees: 2540,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'New York, NY',
            },
        ],
    },

    {
        name: '123558',
        accountName: 'Tech Labs',
        employees: 1856,
        phone: '837-555-0100',
        accountOwner: 'http://salesforce.com/fake/url/jane-doe',
        accountOwnerName: 'John Doe',
        billingCity: 'New York, NY',
        _children: [
            {
                name: '123558-A',
                accountName: 'Opportunity Resources Inc',
                employees: 1934,
                phone: '837-555-0100',
                accountOwner: 'http://salesforce.com/fake/url/jane-doe',
                accountOwnerName: 'John Doe',
                billingCity: 'Los Angeles, CA',
            },
        ],
    },
];