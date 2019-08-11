public class certTestExtension {
    /**
    *    certTestExtension() is the extension for /apex/newCertTest, new record page for a certification test. 
    *    It shows the name of the certification record for which the test record is being created
    *    to prevent confusion/enhance the user experience.
    *    A user can only navigate to this page from a certification detail page so the id of the
    *    certification is passed through the URL ie '/apex/newCertTest?certId=a0xJ0000007SCBg'.
    *    If a user navigates to the url without an id param, then they will see an error message.
    *
    *
    */
    public final ApexPages.standardController controller;
    public String certName {get; set;}
    public Id certId {get; set;}
    public final Certification_Test__c certTest;
    public Boolean showForm {get; set;}    //boolean that determines if the error message (no id param in url) is displayed or not

    /**
    *    certTestExtension() is the constructor for the extension. 
    *    @param the standard controller 
    *    
    */
    public certTestExtension(ApexPages.StandardController stdcontroller) {
        this.controller = stdcontroller;
        this.certTest = (Certification_Test__c) stdcontroller.getRecord();
        //check if URL has id params and set the Certification Name
        if(ApexPages.currentPage().getParameters().get('certId') != null) {
            certId = Id.valueOf(ApexPages.currentPage().getParameters().get('certId'));
            certTest.Certification__c = certID;
            certName = concatCertName();
            showForm = true;       
        } else {    //no id params passed
            showForm = false;
        }
        
    }

    /*
    *    concatCertName() is a helper method that concantenates the Certification Name from a Certification record
    *    NOTE: Pivotal_Product_Version__r.Product_Name_Piv__r.Name is used to get the Pivotal Product name instead of
    *    directly using Pivotal_Product_f__c because of the escaped html characters from the nature of the field. Same for Partner Product name.
    */

    public String concatCertName() {
        Certification__c cert = [    SELECT Pivotal_Product_Version__r.Product_Name_Piv__r.Name, Partner_Product_Version__r.Product_Name_Partner__r.Name, Pivotal_Product_Version__r.Name, Partner_Product_Version__r.Name
                                     FROM Certification__c
                                     WHERE Id =: certId];
        return cert.Pivotal_Product_Version__r.Product_Name_Piv__r.Name + ' ' + cert.Pivotal_Product_Version__r.Name + ' - ' + cert.Partner_Product_Version__r.Product_Name_Partner__r.Name + ' ' + cert.Partner_Product_Version__r.Name;
    
    }
    /*
    *    cancel_record() returns the user to the previous page (certification record detail page).
    *
    *
    */
    public pageReference cancel_record() {
        PageReference resultPage = new PageReference('/'+ certId);
        resultPage.setRedirect(true);
        return resultPage;   
    }
}