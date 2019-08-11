({
	getCurrentUser :function(component){
       console.log('i M CUser');
        var userAction = component.get("c.getCurrentUser");//get data from controller
        userAction.setCallback(this, function(a) {
            component.set("v.cUser", a.getReturnValue());//set data in the page variable
            var usr = component.get("v.cUser");
            component.set("v.isWindowOpen", true);
        });
      	$A.enqueueAction(userAction); 
        component.set("v.disablesubmit",false);
    },
    
    createCaseHandler : function(component,newCase){
        console.log('Getting Data to create Case');
        var action = component.get("c.createRecord");
        action.setParams({
                ca : newCase,
        });
        console.log('Getting Data to create Case1');
        action.setCallback(this,function(a){
            console.log('Getting Data to create Case1--');
            var error = a.getError();
            var state = a.getState();
            var rtnValue = a.getReturnValue();
            var reSetCase = component.get("v.ca");
            console.log('Getting Data to create Case2');
            if(rtnValue != null){
                console.log('Getting Data to create Case4');
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }else{
               var toastEvent = $A.get("e.force:showToast");
                if(state == 'SUCCESS'){
                console.log('Executed successful.'); 
                    toastEvent.setParams({
                            "title": "Success!",
                            "type":"Success",
                            "message": "Case created successfully."
                    });
                    toastEvent.fire();
                }else if(state == 'ERROR'){
                    console.log('Executed with an Error.' + error);
                    var toastEvent = $A.get("e.force:showToast");
                         toastEvent.setParams({
                             "title": "Error!",
                             "type":"Error",
                             "message": "Case is not created."
                     });
                }
                component.set("v.oWindow", false);
                component.set("v.modalWindow", false);
                component.set("v.proceed", false);
                component.set("v.ca", { 'sobjectType': 'case',
                    'Subject': '',
                    'Description': 0,
                     });
            }
            console.log('00001');
        });
        var widget = component.get("v.ssWidget");
        console.log("widhet : "+widget.nbrOfFilesAttached);
        if(widget.nbrOfFilesAttached > 0) {
            console.log("newCase: "+newCase);
            var cUser = component.get("v.cUser");
            widget.setUnconfirmedSender(cUser.Contact.Email);
            component.set("v.disablesubmit",false);
            widget.finalizePackage($A.getCallback(function (url) {
            component.set("v.disablesubmit",true);
            console.log("finalize called");
            newCase.Case_Comments__c = "This comment includes a file attached using a Pivotal secure file drop zone: " + url;
            $A.enqueueAction(action);
            }));
            
        }else{
            $A.enqueueAction(action);          
        }
        console.log('00002');
    },
})