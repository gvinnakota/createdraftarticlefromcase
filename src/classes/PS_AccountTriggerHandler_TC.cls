@isTest
private class PS_AccountTriggerHandler_TC {
        static testMethod  void  accountTest(){
            TestDataUtil.dataValueMapCSData(); 
            case cObj = TestDataUtil.createNonTechnicalCase();
            case cObjTec = TestDataUtil.createTechnicalCase();
            cObjTec.AccountId = cObj.AccountId;
            Entitlement ent = TestDataUtil.createEntitlement(cObj.AccountId);
            cObjTec.EntitlementId = ent.id;
            update cObjTec;
            System.assert(cObj.ID != null,'Case not created');
            System.assert(cObj.AccountId != null,'Case not associated to Account');
            Test.startTest();
            Special_Handling_Instructions__c spl = TestDataUtil.createSpecialHandling(cObj.AccountId);
            System.assert(spl != null);
            System.assertEquals(cObj.AccountId,spl.Account__c, 'Account are not same for Case and Spl');
            Account acc =[SELECT Id , Special_Handling__c FROM Account WHERE Id=:cObj.AccountId];
            acc.Special_Handling__c = 'EU - Safe Harbour';
            update acc;
            System.assert(acc.Special_Handling__c != 'EU - Safe Harbou','Special Handling not updated');
            System.assertEquals('EU - Safe Harbour', acc.Special_Handling__c, 'Special Handling not updated');
            list<Case> caseRecList =[SELECT Id , Products__c,Special_Handling__c FROM Case WHERE AccountId=:acc.Id];
            for(case caseRec : caseRecList){
                System.assertEquals(acc.Special_Handling__c,caseRec.Special_Handling__c);
                System.assert(caseRec.Products__c==spl.Products__c);
            
            }
            
            spl.Handling_Instructions__c ='Change Handling Instruction';
            update spl;
            System.assert(spl.Handling_Instructions__c =='Change Handling Instruction');
            Test.stopTest();
        }
}