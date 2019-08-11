/*
  Date : Oct 23 2018
  Description : Sends email alert upon creation of a case for the new notification roles.
  By : Sun

*/

public class SendEmailToSuccessTeam{

    public class InvocableVariables{
        @InvocableVariable
        public id caseId;
        @InvocableVariable
        public string templateName;
    }
    
    @InvocableMethod
    public static void SendSuccessTeamEmailAlert(list<InvocableVariables> Variables){
    
     //try{
       
        set<string> templateLst = new set<string>();
        list<case> caseLst =  new list<case>();
        for(InvocableVariables iv : variables){
            caseLst.add(new case(id= iv.caseId));
            templateLst.add(iv.templateName);
        }
        
        map<id, list<string>> UserByCaseIdMap = new map<id, list<string>>();
        map<id, list<Case>> accountRoleUserByCaseIdMap = new map<id, list<Case>>();
        
        string fromEmailAddress = Label.From_Email_Address;
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress];
        
        
       
        list<EmailTemplate> mailTemplateList = [select id, name, HtmlValue, body, subject from EmailTemplate WHERE DeveloperName IN:templateLst];
        
        list<id> acctId = new list<id>();
        map<id,list<case>> mapOfCase = new map<id,list<case>>();
        list<case> cseLst = [select id, CaseNumber, Subject, accountId, Account.Name, Contact.Name,Priority,Products__c,Owner.Name,Description from case where id IN:caseLst];
        
        for(case cs : cseLst){
            acctId.add(cs.accountId);
        }
        
        list<Success_Team__c> acntRole =  new list<Success_Team__c>();
        acntRole = [select id, name, user__c, user__r.email, account__c from Success_Team__c where account__c in: acctId and Role__c = 'New Case Notification'];
        
        list<id> userIdList = new list<id>();
        
        for(Success_Team__c rle : acntRole){
            userIdList.add(rle.user__c);
        }
        
        list<user> usrLst = [select id, name, email from user where id IN:userIdList];
        
        system.debug('usrLst:' + usrLst);

        set<string> mailLst = new set<string>();
        
        for(case cs : cseLst){
            list<case> clst = new list<case>();
            clst.add(cs);
            accountRoleUserByCaseIdMap.put(cs.id, clst);
            for(user u : usrLst){
                mailLst.add(u.email);
                list<string> userMailLst = new list<string>();
                
                if (u.email!= null)
                   userMailLst.add(u.email);
                
                
                if(UserByCaseIdMap.size()==0){
                    UserByCaseIdMap.put(cs.id,userMailLst);
                }else{
                    if(UserByCaseIdMap.containskey(cs.id)){
                        UserByCaseIdMap.get(cs.id).addAll(userMailLst);
                    }else{
                        UserByCaseIdMap.put(cs.id, userMailLst);
                    }
                }
            }
        }
        
        map<id,string> mapstrng = new map<id,string>();
        
        list<messaging.singleEmailMessage> mails = new list<messaging.singleEmailMessage>();
       
        string Name= userinfo.getName();
        string UserEmail =  userinfo.getUserEmail();
        
        for(case c: cseLst ){
           list<case> cs = new list<case>();
           list<string> mailIdList = new list<string>();
           messaging.singleEmailMessage mail =  new messaging.singleEmailMessage();
           
           if(UserByCaseIdMap.containskey(c.id)){ 
               mailIdList = UserByCaseIdMap.get(c.id);
 
           system.debug('UserByCaseIdMap:' + UserByCaseIdMap);
           system.debug('mailIdList:' + mailIdList);
           
           if (mailIdList.size() <= 0)
               Continue;
           
           mail.setToAddresses(mailIdList);

           if (Label.From_Email_Address != null){ 
               if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
               }                
           }
           else{
               mail.setReplyTo(UserEmail);
           }
           
           string subject = '';
           string htmlBody =  '';
           string plainBody =  '';
            
            if (mailTemplateList.size() > 0){
              subject = mailTemplateList[0].subject;
              htmlBody = '<center>' + mailTemplateList[0].HtmlValue + '</center>';
              plainBody = mailTemplateList[0].Body;
            }
            
           if(subject == '')
              subject = (c.Subject== null) ? '' : c.Subject;

           subject = subject.replace('{!Case.CaseNumber}', (c.caseNumber== null) ? '' : c.caseNumber);
           subject = subject.replace('{!Case.Subject}', (c.Subject== null) ? '' : c.Subject);
           subject = subject.replace('{!Case.Account}', (c.Account.Name == null) ? '' : c.Account.Name);
           subject = subject.replace(']]>', '');
              
           mail.setSubject(subject);
           
           
           htmlBody = htmlBody.replace('{!Case.Link}', Label.Domain_URL+c.id);
           plainBody = plainBody.replace('{!Case.Link}', Label.Domain_URL+c.id);

           htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.caseNumber);
           plainBody = plainBody.replace('{!Case.CaseNumber}', c.caseNumber);


           htmlBody = htmlBody.replace('{!Case.Subject}', (c.Subject == null)? '' : c.Subject);
           plainBody = plainBody.replace('{!Case.Subject}', (c.Subject == null)? '' : c.Subject);

           htmlBody = htmlBody.replace('{!Case.Account}', (c.Account.Name == null) ? '' : c.Account.Name);
           plainBody = plainBody.replace('{!Case.Account}', (c.Account.Name == null) ? '' : c.Account.Name);

           htmlBody = htmlBody.replace('{!Case.Contact}', (c.Contact.Name == null) ? '' : c.Contact.Name);
           plainBody = plainBody.replace('{!Case.Contact}', (c.Contact.Name == null) ? '' : c.Contact.Name);

           htmlBody = htmlBody.replace('{!Case.Priority}', (c.Priority == null) ? '' : c.Priority);
           plainBody = plainBody.replace('{!Case.Priority}', (c.Priority == null) ? '' : c.Priority);

           htmlBody = htmlBody.replace('{!Case.Products__c}', (c.Products__c == null) ? '' : c.Products__c);
           plainBody = plainBody.replace('{!Case.Products__c}', (c.Products__c == null) ? '' : c.Products__c);
           
           htmlBody = htmlBody.replace('{!Case.OwnerFullName}', (c.Owner.Name == null) ? '' : c.Owner.Name);
           plainBody = plainBody.replace('{!Case.OwnerFullName}', (c.Owner.Name == null) ? '' : c.Owner.Name);

           htmlBody = htmlBody.replace('{!Case.Description}', (c.Description == null) ? '' : c.Description );
           plainBody = plainBody.replace('{!Case.Description}', (c.Description == null) ? '' : c.Description);

           htmlBody = htmlBody.replace('{!Case.Thread_Id}', '');
           plainBody = plainBody.replace('{!Case.Thread_Id}', '');
   
           htmlBody = htmlBody.replace(']]>', '');
           plainBody = plainBody.replace(']]>', '');

               
           mail.setHtmlBody(htmlbody);
           mail.setPlainTextBody(plainBody);
           
           mails.add(mail);
          }
       }
       
           if (mails.size()>0)
               messaging.sendEmail(mails);
      
     //}catch(exception ex){
       // system.debug('line++'+ex.getLineNumber());
        //system.debug('getMsg++'+ex.getMessage());
    //}
    }
}