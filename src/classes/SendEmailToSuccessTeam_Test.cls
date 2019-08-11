@isTest(seeAllData=false)
public class SendEmailToSuccessTeam_Test{

    
    static void SetupCustomSettingData(){
        TestDataUtil.dataValueMapCSData();
    }    
    
    
   static testmethod void test(){
        SetupCustomSettingData();
       
        profile p =[select id , name from profile where name='system administrator'];
        user u = createTestUser(p.id,'Dwayne','Johnson');
        
        account acc = new account();
        acc.name = 'test Account';

        insert acc; 
 
        contact con = new contact();
        con.FirstName = 'John';
        con.LastName = 'Wood';
        con.AccountId = acc.id;

        insert con;        
        
        
        list<Success_team__C> successTeamLst =  new list<Success_Team__c>();
        
        for(integer i=0; i<2; i++){
            Success_Team__c successTeam =  new Success_Team__c();
            successTeam.Role__c = 'New Case Notification';
            successTeam.user__c = u.id ;
            successTeam.account__c = acc.id;
            successTeamLst.add(successTeam);
        }
        insert successTeamLst;
        
        list<case>caseLst =  new list<case>();
        for(integer i = 0; i<2; i++){
            case c= new case();
            c.accountId = acc.id;
            c.contactid = con.id;
            c.Status ='New';
            c.Origin = 'Phone';
            caseLst.add(c);
        }
        insert caseLst;
       
       
        Case cse = [select id from case limit 1];
       
        SendEmailToSuccessTeam.InvocableVariables invocableclass = new SendEmailToSuccessTeam.InvocableVariables();
        invocableclass.caseId = cse.id;
        invocableclass.templateName='';
        list<SendEmailToSuccessTeam.InvocableVariables> invocableclassList = new list<SendEmailToSuccessTeam.InvocableVariables>();
        invocableclassList.add(invocableclass);
        SendEmailToSuccessTeam sendemailST = new SendEmailToSuccessTeam();
        SendEmailToSuccessTeam.SendSuccessTeamEmailAlert(invocableclassList);
            
    }
    
    
    
    public static user createTestUser(string pId, string fName, string lName){
        
        string orgId = userinfo.getOrganizationId();
        string dateString = string.valueOf(datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        integer randomValue = integer.valueOf(math.rint(math.random()*1000000));
        string uniqueName = orgId+datestring+RandomValue;
        
        user u = new user(firstName = fName,
                          lastName = lName,
                          Email = uniqueName + '@test' + orgId + '.org',
                          userName = uniqueName + '@test' + orgId + '.org',
                          EmailEncodingKey = 'ISO-8859-1',
                          alias = uniqueName.substring(18,23),
                          TimeZoneSidKey = 'America/Los_Angeles',
                          LocaleSidKey = 'en_US',
                          LanguageLocaleKey = 'en_US',
                          profileId = pId
                        );
        insert u;
         
        return u;
    }



}