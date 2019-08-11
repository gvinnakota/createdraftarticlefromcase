public class certExtension {
    /*
    * certExtension is an extension for /apex/newCertification. Allows the new certification page to be prepopulated depending 
    * on the where the user clicked "New Certification". Also allows dependent picklists for the form for a 
    * better user experience.
    *
    *
    */
    public final ApexPages.standardController controller;
    public Certification__c certification;
    
    //variables for input fields on new certification page
    public Id pivProduct {get; set;}
    public Id pivProdVersion {get; set;}
    public Id partnerProduct {get; set;}
    public Id partnerProductVersion {get; set;}
    public Id partnerAcct {get; set;}
    public Id badId {get; set;} // used to reset partner Product Version to invalid ID
    public String error {get; set;}


    //variables for params passed through URL
    public String pivVersionstr {get; set;}
    public String partnerVersionstr {get; set;}


    public certExtension(ApexPages.StandardController stdcontroller) {
        this.controller = stdcontroller;
        this.certification = (Certification__c) stdcontroller.getRecord();


        /*
        *   This section is necessary for the fields to be pre-selected when a new certification record
        *   is created from either the (1) Pivotal integrated product version record or the (2) Partner product version record.
        *
        *   URL params:      
        *       -pivVer: Salesforce 15 digit Id of the Pivotal Integrated Version record ie. "/apex/newCertification?pivVer=a10J0000001PVJ7" 
        *       -partnerVer: Salesforce 15 digit Id of the Partner Product Version record ie. "/apex/newCertification?partnerVer=a0vJ0000001wuGU"
        *
        *   If a certification record is created from (1), then pivVer params are present.
        *   If a certification record is created from (2), then partnerVer params are present.
        *
        */

        this.checkURL();

     }


    public void checkURL() {

        //check if pivotal product version param is in the URL and assign to appropriate field
        if (ApexPages.currentPage().getParameters().get('pivVer') != NULL) {
            pivProdVersion = Id.valueOf(ApexPages.currentPage().getParameters().get('pivVer'));
            pivProduct = [SELECT Product_Name_Piv__r.Id
                          FROM Pivotal_Integrated_Product_Version__c
                          WHERE Id=:pivProdVersion].Product_Name_Piv__r.Id;
        }

        //check if partner product version param is in the URL and assign to appropriate field
        if (ApexPages.currentPage().getParameters().get('partnerVer') != NULL) {
            partnerProductVersion = Id.valueOf(ApexPages.currentPage().getParameters().get('partnerVer'));
            List<Partner_Product_Version__c> partnerprodlist = [SELECT Product_Name_Partner__r.Id, Product_Name_Partner__r.Account__r.Id
                          FROM Partner_Product_Version__c
                          WHERE Id=:partnerProductVersion];
            partnerProduct = partnerprodlist[0].Product_Name_Partner__r.Id;
            partnerAcct = partnerprodlist[0].Product_Name_Partner__r.Account__r.Id;
        }        


    }

     /*
     *  getPivProdObj() returns a list of Pivotal Integrated Products as selectoptions. 
     *
     */
    public list<selectoption> getPivProdObj() {
        //Initialize list of select options
        list<selectoption> options = new list<selectoption>();
        
        //Get all the products in the Pivotal Integrated Product table
        list<Pivotal_Integrated_Product__c> pivProduct = [  SELECT Name, Id 
                                                            FROM Pivotal_Integrated_Product__c
                                                            ORDER BY Name ASC ];
        
        //Add the first select option --Select-- to the list. The true parameter will make this option visible but unselectable to a user.                                                        
        options.add(new selectoption('', '--Select--'));
        
        //Add each pivotal integrated product as an option to the list
        for(Pivotal_Integrated_Product__c product:pivProduct) {
            options.add(new selectoption(product.Id, product.Name));
        }
        return options;
    }


     /*
     *  getPivProdVersionObj() returns a list of select options for a specified Pivotal integrated product.
     *
     */
    public list<selectoption> getPivProdVersionObj() {
        //Initialize list of select options
        list<selectoption> options = new list<selectoption>();

        //Get all the product versions for the specified Pivotal product :pivProduct
        list<Pivotal_Integrated_Product_Version__c> pivProdVersion = [  SELECT Name, Id
                                                                        FROM Pivotal_Integrated_Product_Version__c
                                                                        WHERE Product_Name_Piv__c = :pivProduct
                                                                        ORDER BY Name DESC];
        
        //Add the first select option --Select-- to the list. The true parameter will make this option visible but unselectable to a user.                                                        
        options.add(new selectoption('', '--Select--'));

        //Add each possible version for the specified Pivotal product to the list. 
        //Note: the Value is the Id of the version record and Label is the Name of the version record because a Certification record's 
        //Pivotal product version is a lookup field from the Pivotal version table.
        for ( Pivotal_Integrated_Product_Version__c version : pivProdVersion){
            options.add(new selectoption(version.id, version.Name));
        }
        return options;
    }

     /*
     *  getPartnerAcctObj() returns a list of Partner Accounts with products as selectoptions.
     *
     */
    public list<selectoption> getPartnerAcctObj() {
        //set of account names (no duplicates)
        set<String> partnerNames = new set<String>();

        //list of select options
        list<selectoption> options = new list<selectoption>();

        //Get the name of all partner accounts with products. 
        //This will contain duplicate names for accounts with multiple products
        list<Partner_Product__c> partnerAcct = [SELECT Account__r.Name, Account__r.Id
                                                FROM Partner_Product__c
                                                ORDER BY Account__r.Name ASC];        
        
        options.add(new selectoption('', '--Select--'));
        //Iterating through list of partner accounts from query (WITH duplicates),
        //If the partner account is not in the set of partner account names, add it as a selectoption and add it 
        //to the set of partner account names. Else, a select option for it already exists, do nothing.
        for (Partner_Product__c partner : partnerAcct) {
            if (!partnerNames.contains(partner.Account__r.Name)) {
                options.add(new selectoption(partner.Account__r.Id, partner.Account__r.Name));
                partnerNames.add(partner.Account__r.Name);
            }
        }
        return options;
    }



     /*
     *  getPartnerProdObj() returns a list of Partner Products as selectoptions
     *
     */
    public list<selectoption> getPartnerProdObj() {
        //Initialize list of select options
        list<selectoption> options = new list<selectoption>();

        //Get all the products in the Pivotal Integrated Product table
        list<Partner_Product__c> partnerProduct = [ SELECT Name, Id 
                                                    FROM Partner_Product__c
                                                    WHERE Account__r.Id =: partnerAcct
                                                    ORDER BY Name ASC ];
        
        //Add the first select option --Select-- to the list. The true parameter will make this option visible but unselectable to a user.                                                        
        options.add(new selectoption('', '--Select--'));

        //Add each partner product as an option to the list
        for(Partner_Product__c product:partnerProduct) {
            options.add(new selectoption(product.Id, product.Name));
        }
        return options;
    }


     /*
     *  getPartnerProdVersionObj() returns a list of select options for a specified partner product.
     *
     */
    public list<selectoption> getPartnerProdVersionObj() {
        //Initialize list of select options
        list<selectoption> options = new list<selectoption>();
        
        //Get all the product versions for the specified partner product :partnerProduct
        list<Partner_Product_Version__c > partnerProdVersion = [  SELECT Name, Id
                                                                        FROM Partner_Product_Version__c 
                                                                        WHERE Product_Name_Partner__c = :partnerProduct
                                                                        ORDER BY Name DESC];
        
        //Add the first select option --Select-- to the list. The true parameter will make this option visible but unselectable to a user.                                                                
        options.add(new selectoption('', '--Select--'));
        
        //Add each possible version for the specified partner product to the list. 
        //Note: the Value is the Id of the version record and Label is the Name of the version record because a Certification record's 
        //partner product version is a lookup field from the partner version table.
        for ( Partner_Product_Version__c version : partnerProdVersion){
            options.add(new selectoption(version.id, version.Name));
        }
        return options;
    }

    public PageReference cancel_record() {
        String url='';
        if (pivProdVersion==NULL && partnerProductVersion==NULL) {
            url='/apex/integratedProduct?selectedTab=Certification';  
        } else if (pivProdVersion != NULL) {
            url ='/' + pivProdVersion;  
        } else {
            url= '/' + partnerProductVersion;
        }
        PageReference resultPage = new PageReference(url);
        resultPage.setRedirect(true);
        return resultPage;
    }
    
     /*
     *  save_record() returns a PageReference to the newly created certification record.
     *
     */
    public PageReference save_record() {
        //if the partner account does not match the partner product version, set the partner product version to a null ID
        validFields();       
        //initialize the new certification record from the user input    
        Certification__c newCert= new Certification__c(
        Notes__c = certification.notes__c,
        Status__c = certification.status__c,
        Effective_Date__c = certification.effective_date__c,

        Pivotal_Product_Version__c = pivProdVersion,

        Partner_Product_Version__c = partnerProductVersion);
        try {          
            //insert the new certification record into the Certification table
                insert newCert;
           
        } catch (System.DMLException e) {

            if (String.isBlank(pivProduct)) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Pivotal Product is a required field.'));}
            if (String.isBlank(partnerAcct)) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner Account is a required field.'));}
            
            if (String.isBlank(partnerProduct)) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner Product is a required field.'));}
            if (pivProdVersion == NULL) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Pivotal Product Version is a required field.'));}
            if (partnerProductVersion == NULL) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner Product Version is a required field.'));}
            return null;
        }
        //initalize PageReference to the new certification record and redirect
        PageReference resultPage = new PageReference('/' + newCert.Id);
        resultPage.setRedirect(true);
        return resultPage;
     

    }
    
    /*
    *    validFields() is a helper method that checks if the Partner Account matches the Partner Product Version. If a user selects all required
    *    partner info then changes the Partner Account, they may fail to update the partner product/version and the partner product version ID does not refresh.
    *    This method will check if this is the case and if they do not match, it resets the partnerProductVersion variable and adds an error message.
    *
    */
    private void validFields() {
        Partner_Product_Version__c[] partnerAcctcheck = [   SELECT Product_Name_Partner__r.Account__r.Id
                                                            FROM Partner_Product_Version__c
                                                            WHERE Id =: partnerProductVersion];
        if (partnerAcctcheck.isEmpty() || partnerAcctcheck[0].Product_Name_Partner__r.Account__r.Id != partnerAcct) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a valid Partner Product.'));
            partnerProductVersion = badId;                                               
        }
    }

}