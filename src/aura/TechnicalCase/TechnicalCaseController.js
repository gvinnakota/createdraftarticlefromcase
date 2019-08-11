({
	 setInitialData : function(component,event,helper){
        console.log('Technical Case');
        var origin = component.get("v.origin");
        var usr = component.get("v.cUser");
        var newCase = component.get("v.cObj");
        var cAdmin = component.get("v.cAdmin");
        var pUser = component.get("v.pUser");
       
        var accountId;
		if(origin=='entTab'){
            var entRecord = component.get("v.entitles");
            component.set("v.entitles",entRecord);
            component.set("v.accounts",entRecord.Account);
            var eName = component.find("entitleName");
            eName.set("v.value",entRecord.Name);
            
            accountId = entRecord.AccountId;
            newCase.EntitlementId = entRecord.Id;
            newCase.AccountId = accountId;
            helper.fetchDependentValues(component,entRecord.Id);
            if(usr.Profile.Name == cAdmin){
               helper.fetchContacts(component,accountId,usr);
               component.set("v.contacts",usr.Contact);
               newCase.ContactId = usr.ContactId;
            }else{
               console.log(' I am not manager');
               component.set("v.contacts",usr.Contact);
               newCase.ContactId = usr.ContactId;
            }
            helper.sendSafetySetup(component,accountId);
        }
        if(origin=='caseTab'){
            /*fetch Account Records*/
            helper.accountRecords(component,usr,newCase);
        }
        helper.fetchPickListVal(component, 'Environment__c', 'environ');
         helper.fetchPickListVal(component, 'What_action_were_you_performing__c', 'perform');
        component.set("v.cObj",newCase);
        console.log("newCase--"+newCase.AccountId); 
    },
    onPicklistChange: function(component, event, helper) {
        var enviornments=event.getSource("v.environ").get("v.value");
        component.set("v.environ",enviornments);
    },
    onPicklistChange: function(component, event, helper) {
        var performs=event.getSource("v.perform").get("v.value");
        component.set("v.perform",performs);
    },
    Radiovalueset: function(component, event, helper) {
        var Val = event.target.value;
        component.set("v.priority",Val);
        console.log('Priority'+Val);
        var cases = component.get("v.cObj");
        cases.Priority = Val;
        component.set("v.cObj",cases);
    },
    
    onChangeOfAccount : function(component,event, helper){
        console.log('AccountChange');
        var selectedAcc = component.find("accountIds").get("v.value");
        var usr = component.get("v.cUser");
        var newCase = component.get("v.cObj");
        var cAdmin = component.get("v.cAdmin");
        newCase.AccountId = selectedAcc;
        console.log('Selected AccountId :: '+selectedAcc);
        
        helper.sendSafetySetup(component,selectedAcc);
        if(usr.Profile.Name == cAdmin){
           helper.fetchContacts(component,selectedAcc,usr);
        }else{
           component.set("v.contacts",usr.Contact);
           newCase.ContactId = usr.ContactId;
        }
        var origin = component.get("v.origin");
        if(origin =='caseTab'){
            console.log('Am i called');
            helper.fetchEntitlements(component,selectedAcc);
        }
        
    },
	
	onChangeOfEntitlement : function(component,event, helper){
        var selectedRec = component.find("entitleIds").get("v.value");
        var newCase = component.get("v.cObj");
        newCase.EntitlementId = selectedRec;
       
        console.log('selected Entitlement :: '+selectedRec);
        if(selectedRec != 'None'){
             component.set("v.productVersions" , null);
                component.set("v.rComponents" , null);
                component.set("v.rSubComponents" , null);
             helper.fetchDependentValues(component,selectedRec);
        }else{
            component.set("v.productVersions" , null);
            component.set("v.rComponents" , null);
            component.set("v.rSubComponents" , null);
            component.set("v.Product",null);
        }
	},
    
    onValueChange :function(component,event,helper){
		var selectedRec = event.getSource().getLocalId();
        var newCase = component.get("v.cObj");
        console.log('selected--'+selectedRec);
        var cmpValue = component.find(selectedRec).get("v.value"); 
        console.log('My Value is--'+cmpValue);
        if(selectedRec == 'ProductVersion'){
            newCase.Versions__c = cmpValue;
        }else if(selectedRec == 'Components'){
            newCase.Component__c = cmpValue;
            helper.getSubComponents(component,cmpValue);
        }else if(selectedRec == 'subComponents'){
            newCase.Sub_Component__c = cmpValue;
        }
        if(selectedRec == 'environ'){
            newCase.Environment__c = cmpValue;
        }
        if(selectedRec == 'perform'){
            newCase.What_action_were_you_performing__c = cmpValue;
        }
        if(selectedRec == 'contactIds'){
            newCase.ContactId = cmpValue;
        }
    },
    
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    
  
})