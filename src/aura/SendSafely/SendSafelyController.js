({
    sendSafelySetup : function(component, event, helper) {
        var params = event.getParam('arguments');
        if(params){
            var accountId = params.accountId;
            var ssAction =component.get("c.getSendSafetyURL");
            console.log("getSendSafetyURL method called");
            ssAction.setParams({accountId : accountId});
            ssAction.setCallback(this,function(a){
                var spl = a.getReturnValue();
                console.log('spl '+spl);
                if(spl){
                    var apiKey = spl.split("*")[0];
                    var ssURL = spl.split("*")[1];
                }
                
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
                    console.log("widget.url : "+widget.url);
                    widget.initialize();
                    //Assign the SendSafely JavaScript widget to the Lightning component widget attribute
                    component.set("v.widget", widget); 
                }),0)
                console.log('outside helper');
            }); 
            $A.enqueueAction(ssAction);
        }
    },
    
    doInit : function(component,event,helper){
        debugger;
        console.log("I am sendsafely");
        console.log("widget"+component.get("v.recordId"));
        var caseId = component.get("v.recordId");
        
        var userAction = component.get("c.getCurrentUser");
        userAction.setCallback(this,function(res){
            component.set("v.cUser",res.getReturnValue());
        });
        $A.enqueueAction(userAction);
        var accountId = component.get("v.accountId");
        console.log("accountId---"+accountId);
        /* if(accountId || caseId){below line added by dilip */
        if((accountId != null && accountId != '' && accountId != 'undefined') || (caseId != null && caseId != '' && caseId != 'undefined')){
            
            var ssAction =component.get("c.getSendSafetyURL");
            console.log("getSendSafetyURL method called");
            ssAction.setParams({accountId : accountId,
                                caseId : caseId
                               });
            ssAction.setCallback(this,function(a){
                debugger;
                var spl = a.getReturnValue();
                console.log('spl '+spl);
                if(spl != null && spl != '' && spl != 'undefined')
                {
                    var apiKey = spl.split("*")[0];
                    var ssURL = spl.split("*")[1];
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
                        console.log("widget.url : "+widget.url);
                        widget.initialize();
                        //Assign the SendSafely JavaScript widget to the Lightning component widget attribute
                        component.set("v.widget", widget); 
                    }),0)
                    console.log('outside helper');
                }
            }); 
            $A.enqueueAction(ssAction);
        }
    },
    
    attachFile :function(component,event,helper){        
        var widget = component.get("v.widget");
        var cUser = component.get("v.cUser");
        var caseId =component.get("v.recordId");
        console.log("attach file");
        if(widget.nbrOfFilesAttached == 0) {
            alert('Please attach a file.');   
        }        
        if(widget.nbrOfFilesAttached > 0) {            
            var attachAction = component.get("c.attachFileOnCase");
            console.log("attach file1");           
            console.log("newCase: "+cUser.Contact.Email);
            widget.setUnconfirmedSender(cUser.Contact.Email);
            widget.finalizePackage($A.getCallback(function (url) {
                console.log("finalize called");
                var body = " This comment includes a file attached using a Pivotal secure file drop zone: " + url; 
                console.log("urllll: "+url);
                attachAction.setParams({body : body,
                                        caseId : caseId
                                       });
                console.log("attach file2");
                
                attachAction.setCallback(this,function(a){
                    var state =a.getState();
                    console.log(state);   
                    if(state === "SUCCESS"){
                        //  alert('File Submitted Successfully.');
                        window.location.reload();
                    }             
                });
                component.set("v.disablesubmit",false);
                $A.enqueueAction(attachAction);
            }));        
        }
    },
})