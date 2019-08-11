/*******************************************************************************************************************
* Apex Class Name  : PS_CaseBusinessHours
* Test Class Name  :  
* Version          : 1.0
* Function         : Class is used to set SLA Target Date for Case Records.
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Richa Gupta                 09/29/2017              intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/

public class PS_CaseBusinessHours {
/***
Method Name : setCaseSLATargetDate
Purpose : Used to set SLA Target Date for Case record
***/
    Public static void  setCaseSLATargetDate(list<case> newcase){
        set<Id>businessId=new set<Id>();
        list<case>caseUpdate= new list<Case>();
        for(case casebu:newcase){
            businessId.add(casebu.BusinessHoursid);
        }
        list<BusinessHours> bh = [SELECT Id FROM BusinessHours WHERE id in:businessid];
            for(case ca:newcase){

                    if(ca.Priority=='Severity 1 - Critical' ){
                        case casupdate= new case(id=ca.id,Priority=ca.Priority,SLA_Target_date__c =ca.SLA_Target_date__c,businesshoursid=ca.businesshoursid);
                        DateTime dt = ca.CreatedDate; 
                        DateTime SEV1TIME= dt.addMinutes(+30);
                        casupdate.SLA_Target_date__c = SEV1TIME;
                        caseupdate.add(casupdate);
                    }
                    else {
                        for(BusinessHours busiid:bh){
                            if (ca.BusinessHoursid==busiid.id ){
                                case casupdate= new case(id=ca.id,Priority=ca.Priority,SLA_Target_date__c =ca.SLA_Target_date__c,businesshoursid=ca.businesshoursid);
                                if(casupdate.Priority=='Severity 2 - Major'){
                                    casupdate.SLA_Target_date__c = BusinessHours.addGMT(busiid.id, ca.CreatedDate, 02*60 * 60 * 1000l);
                                }
                                else if(casupdate.Priority=='Severity 3 - Minor'){
                                    casupdate.SLA_Target_date__c = BusinessHours.addGMT(busiid.id, ca.CreatedDate, 08*60 * 60 * 1000l);
                                }
                                else if(casupdate.Priority=='Severity 4 - Cosmetic'){
                                    casupdate.SLA_Target_date__c = BusinessHours.addGMT(busiid.id, ca.CreatedDate, 12*60 * 60 * 1000l);
                                }
                                caseupdate.add(casupdate);
                            }    
                        }
                    }    
            }

            if(!caseupdate.isempty()){
             try{
                update caseupdate;
                }
             catch(Exception e){
               ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
               }
            }
    }
}