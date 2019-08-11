({
	fetchPickListVal: function(component, fieldName, elementId) {
        console.log('test');
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": component.get("v.cObj"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
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
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
            	}
                component.find(elementId).set("v.options", opts);
             }else if(response.getError()){
                console.log('dfdsf' + response.getError()[0].message);
            }
        
        });
        $A.enqueueAction(action);
    },
    getCurrentUser :function(component){
        var usr;
        var userAction = component.get("c.getCurrentUser");//get data from controller
        userAction.setCallback(this, function(a) {
            component.set("v.cUser", a.getReturnValue());//set data in the page variable
            usr = component.get("v.cUser");
            console.log(usr);
             return usr;
        });
      	$A.enqueueAction(userAction); 
    },
    
    fetchEntitlements : function(component, accountId){
        var newCase = component.get("v.cObj");
        /*fetch Entitlement Records Start*/
        console.log('I will help to fetch all entitlements ::: '+accountId);
        if(accountId != null){
            var entAction = component.get("c.getRelatedEntitlements");//get data from controller
            var self = this;
            entAction.setParams({
                accountId:accountId,
            });
            entAction.setCallback(this, function(a) {
                console.log(a.getState());
                if(a.getState() == 'SUCCESS'){
                  component.set("v.entitles", a.getReturnValue());//set data in the page variable
                  var count = component.get("v.entitles");
                    console.log('Enit Count'+count.length);
                   if(count){
                        console.log('Enit Count'+count.length);
                       if(count.length == 1){
                            console.log('test---1');
                            self.fetchDependentValues(component,count[0].Id);
                            newCase.EntitlementId = count[0].Id;
                            var eName = component.find("entitleName");
                            eName.set("v.value",count[0].Name);
                       }else{
                           newCase.EntitlementId = 'None';
                       }
                   }else{
                        var eName = component.find("entitleName");
                         eName.set("v.value",'No Products. Select another Account.');
                        newCase.EntitlementId = null;
                   }
                       
                       
                }
           
            });
            $A.enqueueAction(entAction);
		}
       /*fetch Entitlement Records End */ 
	},
    fetchContacts : function(component, accountId,usr){
        var newCase = component.get("v.cObj");
        /*fetch Contact Records Start*/
        console.log('I will help to fetch all Contacts ::: '+accountId);
        
        var cAdmin = component.get("v.cAdmin");
		if(accountId !=null){
            if(usr.Profile.Name == cAdmin){
                console.log('I am Manager');
                var contAction = component.get("c.getRelatedContacts");//get data from controller
                contAction.setParams({
                    accountId:accountId,
                });
                contAction.setCallback(this, function(a) {
                
                    if(a.getState() =="SUCCESS"){
                        console.log('Setback');
                        component.set("v.contacts", a.getReturnValue());//set data in the page variable
                        var cont = component.get("v.contacts");
                        console.log(cont);
                        if(cont){
                            console.log('# of Contacts :: '+ cont.length);
                           if(cont.length ==1){
                            newCase.ContactId = cont[0].Id;
                        	}else{
                            newCase.ContactId = 'None';
                       		}
                        }else{
                            if(accountId =='None'){
                                component.set("v.contacts",usr.Contact); 
                            }
                        }
                        
                        
                    }else if(a.getState() == "ERROR"){
                        console.log("Error :: "+a.getError()[0].message);
                    }
               		
                });
                $A.enqueueAction(contAction);
            }else{
                console.log('test---');
                component.set("v.contacts",usr.Contact);
                newCase.ContactId = usr.ContactId;
            }                
        }
		
		/*fetch Contact Records End */
    
	},
    
    getSubComponents : function (component, compId){
        if(compId){
            console.log('Finding related Sub Comp');
            var newCase = component.get("v.cObj");
            var action = component.get("c.getSubCompValue");
            action.setParams({entitlementId:newCase.EntitlementId, cmpId : compId});
            action.setCallback(this,function(a){
                component.set("v.rSubComponents",a.getReturnValue());
            });
            $A.enqueueAction(action);
        }
    },
    
    fetchDependentValues : function(component, entitleId){
        console.log('I will help you fetch dependent values :::'+entitleId);
    	if(entitleId!=null){
            var newCase = component.get("v.cObj");
            console.log('I have Entitlement Id to Proceed'+entitleId);
            var action = component.get("c.getAllDepFieldValue");
            action.setParams({entId: entitleId});
            action.setCallback(this,function(response){
                component.set("v.depMap",response.getReturnValue());
                var map = component.get("v.depMap");
                console.log(map.length);
                if(map){
                    console.log('+++++++');
                    component.set("v.productVersions" , map['ProductVersion']);                   
                    component.set("v.rComponents" , map['Component']);
                    //component.set("v.rSubComponents" , map['SubComponent']);
                    component.set("v.Product",map['Product'][0]);
                    var prod = component.get("v.Product");
                    console.log('prod --'+prod);
                    var countV = component.get("v.productVersions");
                     var countC = component.get("v.rComponents");
                    console.log('======' +countV.length+"<---Components-->"+countC.length);
                    console.log('======count' +countV);
                     console.log('======count' +countC);
                    if(countV.length > 0){
                        newCase.Versions__c = 'NoData';
                    }else{
                         newCase.Versions__c = null;
                    }
                    if(countC.length > 0){
                        newCase.Component__c = 'NoData';
                    }else {
                        newCase.Component__c = null;
                    }
                    if(prod){
                        newCase.Products__c = prod;
                    }
                    console.log('new'+newCase.Products__c);
                }
                
                
            });
            $A.enqueueAction(action);
        }else{
            console.get("No records matched this Entitlement");
        }
        
	},
        sendSafetySetup : function(component,accountId){
        console.log('I am helping to fetch sendsafety'+accountId);
        var ssAction =component.get("c.getSendSafetyURL");
            ssAction.setParams({accountId : accountId});
            ssAction.setCallback(this,function(a){
            var spl = a.getReturnValue();
            component.set("v.accsplIds",spl);
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
        var cAdmin = component.get("v.cAdmin");
        var rUser = component.get("v.rUser");
        var self = this;
        if(cUser.Profile.Name != rUser){
            console.log('I am not Registered User'+cUser.ContactId);
            if(cUser.Profile.Name != cAdmin){
                component.set("v.contacts",cUser.Contact);
                newCase.ContactId = cUser.ContactId;
                console.log(newCase.ContactId);
            }
            var action = component.get("c.getAccountList");
            action.setCallback(this, function(a) {
                   
                if(a.getState() == "SUCCESS"){
                    component.set("v.accounts",a.getReturnValue());
                    var countAccount = component.get("v.accounts");
                    if(countAccount){
                        if(countAccount.length ==1){
                            var accountId = countAccount[0].Id;
                            if(cUser.Profile.Name == cAdmin){
                                self.fetchContacts(component,accountId,cUser);
                            }
                            self.sendSafetySetup(component,accountId);
                            self.fetchEntitlements(component,accountId);
                            newCase.AccountId = accountId;
                        }
                    }
                    
                }else{ 
                    var errors = a.getError();
                }
               
            });$A.enqueueAction(action);
            
            
        }else{
            console.log('I am a Registered User'+cUser);
            component.set("v.accounts",cUser.Account);
            component.set("v.contacts",cUser.Contact);
            newCase.AccountId = cUser.AccountId;
            newCase.ContactId = cUser.CoPortntactId;
            self.sendSafetySetup(component,cUser.AccountId);
        }
    },
    
})