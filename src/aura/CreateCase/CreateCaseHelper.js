({
	getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },

	fetchEntitlements: function (component, accountId) {
	
        var origin=component.get("v.origin"); 
        var isEntTabOrigin = (origin=='entTab');
		var newCase = component.get("v.cObj");
		var selectedEntitlementEntOrgin = component.get("v.selectedEntitlementEntOrgin");

		/*fetch Entitlement Records Start*/
		console.log('I will help to fetch all entitlements ::: ' + accountId);
		if (accountId != null) {
			var entAction = component.get("c.getRelatedEntitlements"); //get data from controller
			var self = this;
			entAction.setParams({
				accountId: accountId,
			});
			entAction.setCallback(this, function (a) {
				console.log(a.getState());
				var state = a.getState();
				if (state == "SUCCESS") {
					var res = a.getReturnValue();
					component.set("v.entitles", res); //set data in the page variable
					if (isEntTabOrigin==false){
						newCase.EntitlementId = 'None';
					}
					var entRecord = component.get("v.entitles");
					
					if (entRecord ) {
						console.log('Enit entRecord' + entRecord.length);
						
						if (entRecord.length == 1 || isEntTabOrigin==true) {

							if (isEntTabOrigin==false){
								newCase.EntitlementId = entRecord[0].Id;
								var eName = component.find("entitleName");
								eName.set("v.value", entRecord[0].Name);
							}
							else
							{
								newCase.EntitlementId = selectedEntitlementEntOrgin;
					
							}

							var showVersion = component.find("showVersion");
							$A.util.addClass(showVersion,"slds-show");
							$A.util.removeClass(showVersion,"slds-hide");
							console.log('test---1');
							self.fetchDependentValues(component, newCase.EntitlementId);

						} else {
							
							if (isEntTabOrigin==false){
								newCase.EntitlementId = 'None';
							}
							else{
								newCase.EntitlementId = selectedEntitlementEntOrgin;
							}
							var showVersion = component.find("showVersion");
							$A.util.addClass(showVersion,"slds-hide");
							$A.util.removeClass(showVersion,"slds-show");
						}
					} else {
						var eName = component.find("entitleName");
						eName.set("v.value", 'No Product Subscriptions to display. Please email support@pivotal.io for help.');
						newCase.EntitlementId = 'None';
					}


				}

			});
			$A.enqueueAction(entAction);
		}
	},
	validateNewCase :function(component) {

		console.log('at validateNewCase');
		var caseRec = component.get("v.cObj");
		console.log(caseRec);
		console.log(caseRec.AccountId);
		console.log(caseRec.ContactId);
		console.log(caseRec.EntitlementId);

        var productVersionLength = 0;
		var productVersions = component.get("v.productVersions");
        if (productVersions){
            productVersionLength = productVersions.length;
        }


		if(!caseRec.AccountId || caseRec.AccountId== 'None'){
			return 'Please populate Account';
		}else if(!caseRec.ContactId || caseRec.ContactId=='None'){
			return 'Please populate Contact';
		}else if(!caseRec.Priority){
		   return 'Please populate Severity';
		}else if(!caseRec.EntitlementId || caseRec.EntitlementId == 'None'){
			return 'Please populate Product Subscription';
		} else if ( ( productVersionLength > 0 )&& (!caseRec.Versions__c || caseRec.Versions__c == 'NoData' || caseRec.Versions__c == 'None')){
			return 'Please populate Product Version';
		}else if(!caseRec.Environment__c || caseRec.Environment__c == 'NoData'){
			return 'Please populate Environment';
		 //}else if(caseRec.Component__c  == 'NoData'){
		//    return 'Please populate Component.';
		}else if(!caseRec.What_action_were_you_performing__c){
		   return 'Please populate What action were you performing?';
		}if(!caseRec.Subject){
		   return 'Please populate Subject';
		}else if(!caseRec.Description){
		   return 'Please populate Description';
		}else{
			console.log('iro');
			return null;
		}            

	},  	
	fetchDependentValues: function (component, entitleId) {
		//debugger;
		console.log('I will help you fetch dependent values :::' + entitleId);
		if (entitleId != null) {
			var newCase = component.get("v.cObj");
			console.log('I have Entitlement Id to Proceed' + entitleId);
			var action = component.get("c.getAllDepFieldValue");
			action.setParams({
				entId: entitleId
			});
			action.setCallback(this, function (a) {
				var state = a.getState();
				if (state === "SUCCESS") {
					var res = a.getReturnValue();
					component.set("v.depMap", res);
					var map = component.get("v.depMap");
					console.log(map.length);
					if (map) {
						console.log('+++++++');
						var showVersion = component.find("showVersion");
						if(map['ProductVersion'] == ''){
							$A.util.addClass(showVersion,"slds-hide");
            				$A.util.removeClass(showVersion,"slds-show");
						}else{
							$A.util.addClass(showVersion,"slds-show");
            				$A.util.removeClass(showVersion,"slds-hide");
						}
						component.set("v.productVersions", map['ProductVersion']);
						var showComponents = component.find("showComponents");
						if(map['Component'] == ''){
							$A.util.addClass(showComponents,"slds-hide");
            				$A.util.removeClass(showComponents,"slds-show");
						}
						else
						{
							$A.util.addClass(showComponents,"slds-show");
            				$A.util.removeClass(showComponents,"slds-hide");

						}
						component.set("v.rComponents", map['Component']);
						//component.set("v.rSubComponents" , map['SubComponent']);
						component.set("v.Product", map['Product'][0]);
						var prod = component.get("v.Product");
						console.log('prod --' + prod);
						var countV = component.get("v.productVersions");
						var countC = component.get("v.rComponents");
						console.log('======' + countV.length + "<---Components-->" + countC.length);
						console.log('======count' + countV);
						console.log('======count' + countC);
						if (countV.length > 0) {
							newCase.Versions__c = 'NoData';
						} else {
							newCase.Versions__c = null;
						}
						if (countC.length > 0) {
							newCase.Component__c = null;
                            newCase.Sub_Component__c  = null;
						} else {
							newCase.Component__c = null;
                            newCase.Sub_Component__c  = null;
						}
						if (prod) {
							newCase.Products__c = prod;
						}
						console.log('new' + newCase.Products__c);
					}
				}


			});
			$A.enqueueAction(action);
		} else {
			console.get("No records matched this Entitlement");
		}

	},

	fetchPickListVal: function (component, fieldName, elementId) {
		
		console.log('test');
		var action = component.get("c.getselectOptions");
		action.setParams({
			"objObject": component.get("v.cObj"),
			"fld": fieldName
		});
		var opts = [];
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state == "SUCCESS") {
				var res = response.getReturnValue();
				var allValues = response.getReturnValue();
				if (allValues && allValues.length > 0) {
					console.log('I am in');
					opts.push({
						class: "optionClass",
						label: "Please Select",
						value: ""
					});


					for (var i = 0; i < allValues.length; i++) {
						opts.push({
							class: "optionClass",
							label: allValues[i].label,
							value: allValues[i].value
						});
					}
				}
				
				component.find(elementId).set("v.options", opts);
			} else if (response.getError()) {
				console.log('dfdsf' + response.getError()[0].message);
			}

		});
		$A.enqueueAction(action);
	},

	getSubComponents: function (component, compId) {
		
		if (compId != "None") {
			console.log('Finding related Sub Comp');
			var newCase = component.get("v.cObj");
			var action = component.get("c.getSubCompValue");
			action.setParams({
				entitlementId: newCase.EntitlementId,
				cmpId: compId
			});
			action.setCallback(this, function (a) {
				var res = a.getReturnValue();
				if(res && res.length>0){
					var showSubComponent =  component.find("showSubComponent");
		            $A.util.addClass(showSubComponent,"slds-show");
		            $A.util.removeClass(showSubComponent,"slds-hide");
					component.set("v.rSubComponents", res);
                    newCase.Sub_Component__c = null;


				}
			});
			$A.enqueueAction(action);
		}
	},
	
	fetchContacts: function (component, accountId, usr) {
		
		var newCase = component.get("v.cObj");
		/*fetch Contact Records Start*/
		console.log('I will help to fetch all Contacts ::: ' + accountId);

		var cAdmin = component.get("v.cAdmin");
		if (accountId != null) {
			if (usr.Profile.Name == cAdmin) {
				console.log('I am Manager');
				var contAction = component.get("c.getRelatedContacts"); //get data from controller
				contAction.setParams({
					accountId: accountId,
				});
				contAction.setCallback(this, function (a) {

					if (a.getState() == "SUCCESS") {
						console.log('Setback');
						component.set("v.contacts", a.getReturnValue()); //set data in the page variable
						var cont = component.get("v.contacts");
						console.log(cont);
						if (cont) {
							console.log('# of Contacts :: ' + cont.length);
							if (cont.length == 1) {
								newCase.ContactId = cont[0].Id;
							} else {
								newCase.ContactId = 'None';
							}
						} else {
							if (accountId == 'None') {
								component.set("v.contacts", usr.Contact);
							}
						}


					} else if (a.getState() == "ERROR") {
						console.log("Error :: " + a.getError()[0].message);
					}

				});
				$A.enqueueAction(contAction);
			} else {
				console.log('test---');
				component.set("v.contacts", usr.Contact);
				newCase.ContactId = usr.ContactId;
			}
		}

		/*fetch Contact Records End */

	},


	
		sendSafetySetup : function(component,accountId){

		if(!accountId)
		{
			accountId = component.get("v.selectedAccount");
		}
		console.log('I am helping to fetch sendsafety'+accountId);
		var ssAction =component.get("c.getSendSafetyURL");
			ssAction.setParams({accountId : accountId});
			ssAction.setCallback(this,function(a){
			var spl = a.getReturnValue();
			component.set("v.accsplIds",spl);

			console.log('spl:' + spl);
			if(!spl)	
			{
				return;
			}
			//Added by Deepa
			var apiKey = spl.split("*")[0];
			var ssURL = spl.split("*")[1];
			var accsplhan=component.get("v.accsplIds");
				console.log('calling again send safe ::'+accsplhan);
				window.setTimeout($A.getCallback(function(){  //window.setTimeout function begin
					console.log('timeout called');
					var placeholderElement = $('#dropzone-replacement-div');
					//The formField variable is not required by SendSafely in this implementation because widget.disableAutoSubmit is set to true, however we are setting anyway to prevent a Lightning undefined error.
					var formField = $('#hidden-secure-link-field');
					
					//Create a new instance.
					var widget = new SendSafelyDropzone(apiKey, placeholderElement, formField);
					//Once created, we can specify any optional configurations here.
					widget.disableAutoSubmit = true;
					//Finally we are ready to initialize the API.
					//Added by Deepa as per Joe email
					widget.url = ssURL;
					console.log("widget.url : "+widget.url);
					widget.initialize();
					//Assign the SendSafely JavaScript widget to the Lightning component widget attribute
					component.set("v.widget", widget); 
				}),0)
			}); 
			$A.enqueueAction(ssAction);
	},
	accountRecords : function(component,cUser,newCase){
		////debugger;
        var origin=component.get("v.origin"); 
		var isEntTabOrigin = (origin=='entTab');
        var cAdmin = component.get("v.cAdmin");
        var rUser = component.get("v.rUser");
        var self = this;
       
            var action = component.get("c.getAccountList");
            action.setCallback(this, function(a) {
                   
                if(a.getState() == "SUCCESS"){
                    component.set("v.accounts",a.getReturnValue());
                    var countAccount = component.get("v.accounts");
            		if(countAccount){
                        if(countAccount.length ==1){
							var accountId = countAccount[0].Id;
							
							component.set("v.selectedAccountName", countAccount[0].Name);
							console.log('selectedAccountName 20:' + component.get("v.selectedAccountName"));

                            if(cUser.Profile.Name == cAdmin){
                                helper.fetchContacts(component,accountId,cUser);
							}
							
							////debugger;
                            self.sendSafetySetup(component,accountId);
                            self.fetchEntitlements(component,accountId);
							// if account id set by the url.
							if (isEntTabOrigin==false){
								newCase.AccountId = accountId;
							}
						}
						else{
							if (isEntTabOrigin==true){
								var selectedAccountId = component.get("v.selectedAccount");
								for (var i = 0; i < countAccount.length; i++) {
									console.log(countAccount[i].Id);
									console.log(selectedAccountId);
									if (countAccount[i].Id == selectedAccountId ){
										component.set("v.selectedAccountName", countAccount[i].Name);
										console.log('selectedAccountName 21:' + component.get("v.selectedAccountName"));
									}
								}
							}
						}
					}

                    
                }else{ 
                    var errors = a.getError();
                }
               
            });$A.enqueueAction(action);
            
         
    }

})