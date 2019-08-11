({
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
        fetchContacts : function(component, accountId,usr){
        var newCase = component.get("v.cObj");
        var cAdmin = component.get("v.cAdmin");
        /*fetch Contact Records Start*/
       if(accountId !=null){
            if(usr.Profile.Name == cAdmin){
                console.log('I am Manager');
                var contAction = component.get("c.getRelatedContacts");//get data from controller
                console.log("getRelatedContacts called");
                contAction.setParams({
                    accountId:accountId,
                });
                contAction.setCallback(this, function(a) {
                component.set("v.contacts", a.getReturnValue());//set data in the page variable
                    var cont = component.get("v.contacts");
                    console.log("contacts :"+cont);
                    if(cont){
                         console.log(cont.length);
                        if(cont.length == 1){
                            newCase.ContactId = cont[0].Id;
                        }else{
                            newCase.ContactId = 'None';
                        }
                    }    
                    else{
                      /* if(accountId =='None'){
                          component.set("v.contacts",usr.Contact); 
                       }*/
                    }
                });
                $A.enqueueAction(contAction);
            }               
        }
		
		/*fetch Contact Records End */
    
	},
        sendSafetySetup : function(component,accountId){
            console.log('I am helping to fetch sendsafety :'+accountId);
        var ssAction =component.get("c.getSendSafetyURL");
            console.log("getSendSafetyURL method called");
            ssAction.setParams({accountId : accountId});
            ssAction.setCallback(this,function(a){
            var spl = a.getReturnValue();
                console.log('spl '+spl);
            component.set("v.accsplIds",spl);
            var apiKey = spl.split("*")[0];
            var ssURL = spl.split("*")[1];
            var accsplhan=component.get("v.accsplIds");
                console.log('calling again send safe ::'+accsplhan);
                window.setTimeout($A.getCallback(function(){  //window.setTimeout function begin
                    var placeholderElement = $('#dropzone-replacement-div');
                    //The formField variable is not required by SendSafely in this implementation because widget.disableAutoSubmit is set to true, however we are setting anyway to prevent a Lightning undefined error.
                    var formField = $('#hidden-secure-link-field');
                    
                    //Create a new instance.
                    var widget = new SendSafelyDropzone(apiKey, placeholderElement, formField);
                    //Once created, we can specify any optional configurations here.
                    widget.disableAutoSubmit = true;
                    //Finally we are ready to initialize the API.
                    //Added by Deepa as per Joe email
                     widget.url=ssURL; //"https://securefiles-sp.pivotal.io";
                    //widget.url = "https://securefiles-sp.pivotal.io/";
                    //console.log("ssURL : "+ssURL);
                    console.log("widget.url : "+widget.url);
                    widget.initialize();
                    //Assign the SendSafely JavaScript widget to the Lightning component widget attribute
                    component.set("v.widget", widget); 
                }),0)
                console.log('outside helper');
               component.set("v.disableNonSub",false);
            }); 
            $A.enqueueAction(ssAction);
    },
    accountRecords : function(component,cUser,newCase){
 		var cAdmin = component.get("v.cAdmin");
        var pUser = component.get("v.pUser");
        var rUser = component.get("v.rUser");
        var self = this;
        if(cUser.Profile.Name != rUser){
       		var action = component.get("c.getAccountList");
            action.setCallback(this, function(a) {
                if(a.getState() == 'SUCCESS'){
                    component.set("v.accounts",a.getReturnValue());
                    var countAccount = component.get("v.accounts");
                    if(countAccount && countAccount.length ==1){
                        var accountId = countAccount[0].Id;
                        if(cUser.Profile.Name == cAdmin){
                            console.log("fetchCOntacts called");
                            self.fetchContacts(component,accountId,cUser);
                        }
                        console.log("ooooo");
                        self.sendSafetySetup(component,accountId);
                        console.log("ss called");
                        newCase.AccountId = accountId;                        
                    }
                }else{
                    var errors = a.getError();
                    console.log("Error getting Account Data"+errors[0].message);
                }
            });
            $A.enqueueAction(action);
        }
    },
})