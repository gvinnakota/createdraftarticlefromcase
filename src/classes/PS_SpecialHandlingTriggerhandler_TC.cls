@isTest
public class PS_SpecialHandlingTriggerhandler_TC{
static testMethod void  specialHandlingTriggerhandler()
    {
         TestDataUtil.dataValueMapCSData();
         account accobj= new Account();
         accobj.name ='Test123';
         accobj.Special_Handling__c = 'Standard';
         insert accobj;
         system.debug('Account Created' +  accobj);
         Map<Id,account> accountMap = new Map<Id,account>();
         accountMap.put(accobj.id,accobj);
         system.debug('accountMap' +  accountMap);
         system.debug('accobj.id' +  accobj.id);
         accobj.Special_Handling__c = 'EH - Executive Handling';
         system.debug('accountMap' +  accountMap);
         system.debug('accobj.id' +  accobj.id);
        
         list<case>caseupdate= new list<Case>();       
        
        case cobj =new case();
         cobj.Special_Handling_Instructions__c ='test';
         cobj.Products__c='Datometry Hyper-Q for Pivotal Data Suite';
         cobj.AccountId=accobj.id;
         cobj.subject='TS-34';
         cobj.description='TS-34 : Test SS';
         insert cobj;
         system.debug('Case Created' +  cobj);
         system.debug('cobj.AccountId ' +  cobj.AccountId);
         
         Special_Handling_Instructions__c  sp =new Special_Handling_Instructions__c();
         sp.Handling_Instructions__c='test12';
         sp.Products__c='Datometry Hyper-Q for Pivotal Data Suite';
         sp.Account__c=accobj.id;
         insert sp;
         
         
        
         if(accountMap.containskey(cobj.AccountId)){
         system.debug('inside if ' +  cobj.AccountId);
         cobj.Special_Handling_Type__c  = accountMap.get(cobj.AccountId).Special_Handling__c;
         system.debug('cobj.Special_Handling_Type__c ' + cobj.Special_Handling_Type__c);
         system.debug('accountMap.get(cobj.accountId).Special_Handling__c ' + accountMap.get(cobj.accountId).Special_Handling__c);
    
        system.debug('Inserted');
         if(sp.account__c==cobj.AccountId && cobj.Products__c==sp.Products__c)
                {
                  
                    cobj.Special_Handling_Instructions__c=sp.Handling_Instructions__c;
                    system.debug('cobj.Special_Handling_Instructions__c' + cobj.Special_Handling_Instructions__c);
                    system.debug('sp.Handling_Instructions__c' + sp.Handling_Instructions__c);
                    update cobj;
                    }
                    /*  if(cobj.Products__c==spl.Products__c)
                    {
                    cobj.Special_Handling_Instructions__c=spl.Handling_Instructions__c;
                    system.debug('cobj.Special_Handling_Instructions__c' + cobj.Special_Handling_Instructions__c);
                    system.debug('sp.Handling_Instructions__c' + sp.Handling_Instructions__c);
                    update cobj;
                    }
                    }*/
                }  
        system.debug('After If');

         update accobj;
         update sp;
         //update spl;
         update cobj;
        
    }
}