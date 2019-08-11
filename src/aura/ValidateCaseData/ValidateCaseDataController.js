({
	validateNonTechCase : function(component, event) {
		var params = event.getParam('arguments');
        if(params){
            var caseRec = params.caseObj;
            if(!caseRec.AccountId || caseRec.AccountId == 'None'){
               return 'Please populate Account.';
            }else if(!caseRec.ContactId || caseRec.ContactId == 'None'){
               return 'Please populate Contact.';
            }else if(!caseRec.Subject){
               return 'Please populate Subject.';
            }else if(!caseRec.Description){
               return 'Please populate Description.';
            }else{
                console.log('iro');
                return null;
           }            
        }
	},
   validateTechCase : function(component, event) {
		var params = event.getParam('arguments');
        if(params){
            var caseRec = params.caseObj;
            console.log('+++=' + caseRec.Component__c);
			if(!caseRec.AccountId || caseRec.AccountId== 'None'){
                return 'Please populate Account.';
            }else if(!caseRec.ContactId || caseRec.ContactId=='None'){
                return 'Please populate Contact.';
            }else if(!caseRec.Priority){
               return 'Please populate Severity.';
            } else if(caseRec.Versions__c == 'NoData'){
               return 'Please populate Product Version.';
            }else if(caseRec.Component__c  == 'NoData'){
                return 'Please populate Component.';
            }else if(!caseRec.Environment__c){
               return 'Please populate Environment';
            }else if(!caseRec.What_action_were_you_performing__c){
               return 'Please populate What action were you performing?';
            }else if(caseRec.EntitlementId == 'None'){
                return 'Please populate Product Subscriptions.';
            }if(!caseRec.Subject){
               return 'Please populate Subject.';
            }else if(!caseRec.Description){
               return 'Please populate Description.';
            }else{
                console.log('iro');
                return null;
            }            
        }
	}
})