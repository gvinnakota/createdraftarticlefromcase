/**
 * Created by klukawski on 2/12/18.
 */

public with sharing class CloneBillingAccountHelper {
    public static final Map<String, String> SALESFORCE_TO_ZUORA_ACCOUNT_FIELD_MAP = new Map<String, String>{
            //'Zuora__AccountNumber__c'=>'AccountNumber',
            'Zuora__AllowInvoiceEdit__c' => 'AllowInvoiceEdit',
            'Zuora__AutoPay__c' => 'AutoPay',
            'Zuora__Batch__c' => 'Batch',
            'Zuora__BcdSettingOption__c' => 'BcdSettingOption',
            'Zuora__BillCycleDay__c' => 'BillCycleDay',
            //'Zuora__BillToId__c'=>'BillToId',
            //'Zuora__Communication_Profile_Id__c'=>'CommunicationProfileId',
            'Channel__c' => 'Channel__c',
            'Company_Code__c' => 'Company_Code__c',
            'Zuora__Currency__c' => 'Currency',
            'Zuora__CustomerServiceRepName__c' => 'CustomerServiceRepName',
            'CRM_Bill_To_Contact_Id__c' => 'CRM_Bill_To_Contact_Id__c',
            'CRM_Sold_To_Contact_Id__c' => 'CRM_Sold_To_Contact_Id__c',
            'Zuora__InvoiceDeliveryPrefsEmail__c' => 'InvoiceDeliveryPrefsEmail',
            'Zuora__InvoiceDeliveryPrefsPrint__c' => 'InvoiceDeliveryPrefsPrint',
            //'Zuora__InvoiceTemplateId__c'=>'InvoiceTemplateId',
            'Name' => 'Name',
            'Zuora__Notes__c' => 'Notes',
            'Zuora__PaymentGateway__c' => 'PaymentGateway',
            'Zuora__PaymentTerm__c' => 'PaymentTerm',
            'Zuora__PurchaseOrderNumber__c' => 'PurchaseOrderNumber',
            'Zuora__SalesRepName__c' => 'SalesRepName',
            //'Zuora__SoldToId__c'=>'SoldToId',
            'Zuora__Status__c' => 'Status',
            'Zuora__TaxExemptCertificateID__c' => 'TaxExemptCertificateID',//possibly to be commented out
            'Zuora__TaxExemptCertificateType__c' => 'TaxExemptCertificateType',
            'Zuora__TaxExemptDescription__c' => 'TaxExemptDescription',
            'Zuora__TaxExemptEffectiveDate__c' => 'TaxExemptEffectiveDate',
            'Zuora__TaxExemptExpirationDate__c' => 'TaxExemptExpirationDate',
            'Zuora__TaxExemptIssuingJurisdiction__c' => 'TaxExemptIssuingJurisdiction',
            'Zuora__TaxExemptStatus__c' => 'TaxExemptStatus'
    };

    public static final Map<String, String> SALESFORCE_TO_ZUORA_BILL_TO_CONTACT_FIELD_MAP = new Map<String, String>{
            'Zuora__BillToAddress1__c' => 'Address1',
            'Zuora__BillToAddress2__c' => 'Address2',
            'Zuora__BillToCity__c' => 'City',
            'Zuora__BillToCountry__c' => 'Country',
            'Zuora__BillToFax__c' => 'Fax',
            'Zuora__BillToName__c' => '',
            'Zuora__BillToPostalCode__c' => 'PostalCode',
            'Zuora__BillToState__c' => 'State',
            'Zuora__BillToWorkEmail__c' => 'WorkEmail',
            'Zuora__BillToWorkPhone__c' => 'WorkPhone'
    };

    public static final Map<String, String> SALESFORCE_TO_ZUORA_SOLD_TO_CONTACT_FIELD_MAP = new Map<String, String>{
            'Zuora__SoldToAddress1__c' => 'Address1',
            'Zuora__SoldToAddress2__c' => 'Address2',
            'Zuora__SoldToCity__c' => 'City',
            'Zuora__SoldToCountry__c' => 'Country',
            'Zuora__SoldToFax__c' => 'Fax',
            'Zuora__SoldToName__c' => '',
            'Zuora__SoldToPostalCode__c' => 'PostalCode',
            'Zuora__SoldToState__c' => 'State',
            'Zuora__SoldToWorkEmail__c' => 'WorkEmail',
            'Zuora__SoldToWorkPhone__c' => 'WorkPhone'
    };

    public static final Map<String, String> SOLD_TO_CONTACT_TO_BILLING_ACCOUNT_FIELD_MAP = new Map<String, String>{
            'MailingAddress' => 'Zuora__SoldToAddress1__c',
            'MailingCity' => 'Zuora__SoldToCity__c',
            'MailingCountry' => 'Zuora__SoldToCountry__c',
            'Fax' => 'Zuora__SoldToFax__c',
            'Name' => 'Zuora__SoldToName__c',
            'MailingPostalCode' => 'Zuora__SoldToPostalCode__c',
            'MailingState' => 'Zuora__SoldToState__c',
            'Email' => 'Zuora__SoldToWorkEmail__c',
            'Phone' => 'Zuora__SoldToWorkPhone__c'
    };

    public static final Map<String, String> BILL_TO_CONTACT_TO_BILLING_ACCOUNT_FIELD_MAP = new Map<String, String>{
            'MailingAddress' => 'Zuora__BillToAddress1__c',
            'MailingCity' => 'Zuora__BillToCity__c',
            'MailingCountry' => 'Zuora__BillToCountry__c',
            'Fax' => 'Zuora__BillToFax__c',
            'Name' => 'Zuora__BillToName__c',
            'MailingPostalCode' => 'Zuora__BillToPostalCode__c',
            'MailingState' => 'Zuora__BillToState__c',
            'Email' => 'Zuora__BillToWorkEmail__c',
            'Phone' => 'Zuora__BillToWorkPhone__c'
    };
}