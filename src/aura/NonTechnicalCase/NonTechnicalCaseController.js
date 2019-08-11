({
	 setInitialData : function(component,event,helper){
        var usr = component.get("v.cUser");
        var newCase = component.get("v.cObj");
        var cAdmin = component.get("v.cAdmin");
        var pUser = component.get("v.pUser");
        var rUser = component.get("v.rUser");
	    newCase.Priority = 'Severity 3 - Minor';
         if(usr.Profile.Name != rUser){
             helper.accountRecords(component,usr,newCase);
             var initialAccount = component.find("accountIds");
                    if(initialAccount){
                        newCase.AccountId = inititalAccount.get("v.value");
                    }
             if(usr.Profile.Name != cAdmin){
                  component.set("v.contacts",usr.Contact);
                  newCase.ContactId = usr.ContactId;
             }
         }else{
             component.set("v.accounts",usr.Account);
             newCase.AccountId = usr.AccountId; 
             if(usr.Profile.Name == rUser){
                 helper.sendSafetySetup(component,usr.AccountId);
                 newCase.AccountId = usr.AccountId;
                 component.set("v.contacts",usr.Contact);
                 newCase.ContactId = usr.ContactId;
        	 }
         }
        
    },
       
    onChangeOfAccount : function(component,event, helper){
        console.log('AccountChange');
        var selectedAcc = component.find("accountIds").get("v.value");
        var usr = component.get("v.cUser");
        var newCase = component.get("v.cObj");
        var cAdmin = component.get("v.cAdmin");
        newCase.AccountId = selectedAcc;
        helper.sendSafetySetup(component,selectedAcc);
        if(usr.Profile.Name == cAdmin){
        	helper.fetchContacts(component,selectedAcc,usr);
        }
        
    },
    onValueChange :function(component,event){
        var newCase = component.get("v.cObj");
        var selectedRec = event.getSource().getLocalId();
        var cmpValue = component.find(selectedRec).get("v.value"); 
        if(selectedRec == 'contactIds'){
            newCase.ContactId = cmpValue;
        }
    },
    
    emptyCheck : function(Component,event){
        if(component.get("v.cObj.Subject").length>0){
            component.set("v.disablesubmit",false);
        }
        
    }
	
})