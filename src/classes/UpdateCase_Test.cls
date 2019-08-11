@isTest(SeeAlldata=True)
Public class UpdateCase_Test{
Static testMethod void Testmethod1()
{
ApexPages.StandardSetController setCon;
Case cs =new Case();
cs.Requestupdate__c= true;
insert cs;
ApexPages.StandardController sc = new ApexPages.StandardController(cs);
UpdateCase ec= new UpdateCase(sc);

        
        ec.getResponse();
        ec.getRequestEscalateResponse();
        UpdateCase.getEscalateResponse(cs.id);

}
}