public class matrixController {
    //variables for the user input
    public Id pivotalProductName { get; set; }
    public String partnerProductName {get; set;}
    public String partnerProductCategory { get; set; }

    //This object is needed for the autocomplete component which requires an SObject.
    public Partner_Product__c partnerProduct {get; set;}

    public String pivProduct {get; set;}
    public List<Certification__c> certifications {get; set;}

    //booleans to control re/rendering of the results and no results message.
    public Boolean hasResults {get; set;}
    public Boolean showMsg {get; set;}


    public String selectedTab {get; set;}
    public Id reportId {get; set;}
    public String reportName {get; set;}
    public String status {get; set;}

    
    public integer totalResultCount {get; set;}
    /**
    *   The matrixController() controls the product interoperability matrix VF page.
    *
    */
    public matrixController() {
        selectedTab = ApexPages.currentPage().getParameters().get('selectedTab');
        if (String.isBlank(selectedTab)) {
            this.selectedTab = 'Matrix';
        }
        reportName = 'All Certifications';
        List<Report> reports =      [SELECT Id
                                    FROM Report
                                    WHERE Name =:reportName];
        if (!reports.isEmpty()) {
            reportId = reports[0].Id;
        }    
            
        partnerProduct = new Partner_Product__c();

        hasResults = False;
        showMsg = False; //initially set to false so 'no result' message is not displayed upon first visit of the page.


    }




    /**
    *   getProductCategories() returns a selectoptions object of partner product categories.
    *
    */
    public List<selectoption> getProductCategories() {
        SObject obj = new Partner_Product__c();
        String fld = 'Product_Category__c';
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '--All--'));
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        return options;
        }

    public List<selectoption> getPivProdObj() {
        //Initialize list of select options
        list<selectoption> options = new list<selectoption>();
        
        //Get all the products in the Pivotal Integrated Product table
        list<Pivotal_Integrated_Product__c> pivProductlist = [  SELECT Name, ID 
                                                            FROM Pivotal_Integrated_Product__c
                                                            ORDER BY Name ASC ];
        
        //Add the first select option --Select-- to the list. The true parameter will make this option visible but unselectable to a user.                                                        
        options.add(new selectoption('', '--All--'));
        
        //Add each pivotal integrated product as an option to the list
        for(Pivotal_Integrated_Product__c product:pivProductlist) {
            options.add(new selectoption(product.Id, product.Name));
        }
        return options;
    }

    /**
    *   Report() returns a page reference to the report titled 'All Certifications'.
    *   
    *
    */
    public PageReference Report() {
        PageReference resultPage = new PageReference('/' + reportId);
        resultPage.setRedirect(true);
        return resultPage;
    }


    /**
    *   Results() builds a string query based on the users inputs: partnerProductName, pivotalProductName, partnerProductCategory.
    *   It then queries the database and gets the results, changing hasResults to True and showMsg to false.
    *
    */
    public PageReference Results() {
        //set String variable equal to partner product object's name. This is to make use of variables for 
        //the query more consistent 
        partnerProductName = partnerProduct.Name;
        status = 'Completed';
        //call helperfunction buildQuery() to build the final string query with appropriate where clauses
        String resultQuery = buildQuery(partnerProductName, pivotalProductName, partnerProductCategory);
        //Query the database 
        certifications = Database.query(resultQuery);


        
        //if certifications list is empty, set hasResults to false so the blank table is not displayed on Product Interop VF page
        if (certifications.isEmpty() ) {
            hasResults = False;
            totalResultCount = 0;
        } else {
            hasResults=True;
            totalResultCount = certifications.size();
        }
        //showMsg is always the opposite of hasResults in order to allow the 'no results' message to be displayed when there are no certifications.
        showMsg = !hasResults ;                        
        return null;
    }



    /**
    *   buildQuery() constructs the String SOQL query given a user's input/constraints. 
    *   
    *   
    *   @param partnerProductName the name of the partner product that a user is searching for. The name
    *   is not always complete. For example, a user may search 'SAS' or 'Alpine' instead of 'SAS Data Integrator' or 'Alpine Miner'.
    *   @param pivotalProductName the name of the pivotal product that the user is searching for.
    *   @param partnerProductCategory the category of the partner product that the user is searching for.
    *
    *
    */
    private String buildQuery (String partnerProductName, Id pivotalProductName, String partnerProductCategory) {
        //SELECT clause for the query selects the certification name, pivotal product name, partner product name, status of the certification, last modified timestamp, effective date, and partner product category
        String selectClause =   'SELECT Certification_Name__c, Pivotal_Product_f__c, Partner_Product_f__c, Status__c, SystemModstamp, Effective_Date__c, Partner_Product_Version__r.Product_Name_Partner__r.Product_Category__c, Partner_Account__c FROM Certification__c';
        //ORDER BY clause for the query with the following order: Pivotal product name, Pivotal product version, Parnter product name, Partner product version ascending and the last modified timestamp descencing
        String orderByClause =  'ORDER BY Pivotal_Product_f__c, Pivotal_Product_Version__c, Partner_Product_f__c, Partner_Product_Version__c ASC, SystemModstamp DESC';      
        //call helper function to build whereClause based on user's inputs
        String whereClause =  buildWhereClause(partnerProductName, pivotalProductName, partnerProductCategory);
        String finalQuery = '';
        //If there is no where clause, meaning the user did not specify any parameters and wants to see ALL results, then build the final query string without the WHERE clause
        if (String.isBlank(whereClause)) {
            finalQuery = selectClause + ' WHERE Status__c = :status ' + orderByClause;
        //Else concantenate the WHERE clause to the final query
        } else {
            finalQuery = selectClause + ' WHERE Status__c = :status AND ' + whereClause + ' ' + orderByClause;
        }
        return finalQuery;
    }


    /**
    *   buildWHereClause() returns the WHERE clause string. It does NOT include 'WHERE'.
    *
    *   @param partnerProductName the name of the partner product that a user is searching for. The name
    *   is not always complete. For example, a user may search 'SAS' or 'Alpine' instead of 'SAS Data Integrator' or 'Alpine Miner'.
    *   @param pivotalProductName the name of the pivotal product that the user is searching for.
    *   @param partnerProductCategory the category of the partner product that the user is searching for.
    *
    */
    private String buildWhereClause (String partnerProductName, Id pivotalProductName, String partnerProductCategory) {
        String andStr = 'AND';
        String whereClause = '';
        //if the partner product is specified, then WHERE/LIKE clause is concatenated to the whereClause 
        if (!String.isBlank(partnerProductName)) {
            whereClause += 'Partner_Product_f__c LIKE' + '\'%' + partnerProductName + '%\'';
        }
        //if the pivotal product is specified, then a WHERE clause is constructed for the partner product and concantenated to whereClause
        if (!String.isBlank(pivotalProductName)) {
            //if whereClause is empty, meaning the partner product WHERE clause was not constructed, then concatenate without 'AND'
            if (String.isBlank(whereClause)) {
                whereClause += ' ' + 'Pivotal_Product_Version__r.Product_Name_Piv__c =: pivotalProductName';
            //else concat with 'AND'
            } else {
                whereClause += ' ' + andStr + ' ' + 'Pivotal_Product_Version__r.Product_Name_Piv__c =: pivotalProductName';
            }
        }
        //if partner product category is specified, then a WHERE clause is constructed for it
        if (!String.isBlank(partnerProductCategory)) {
            //if whereClause is empty, meaning neither the partner product nor the pivotal product WHERE clause was not constructed, then concatenate without 'AND'
            if (String.isBlank(whereClause)) {
                whereClause += ' ' + 'Partner_Product_Version__r.Product_Name_Partner__r.Product_Category__c = :partnerProductCategory';
            //else concat with 'AND'
            } else {
                whereClause += ' ' + andStr + ' ' + 'Partner_Product_Version__r.Product_Name_Partner__r.Product_Category__c = :partnerProductCategory';
            }
        }
        return whereClause;
    }
                                      
                    
}