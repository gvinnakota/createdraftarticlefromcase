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
    sortBy: function(component, field) {
        console.log('inside helpwr');
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.Entitlements");
       // sortAsc = field == sortField? !sortAsc: true;
        sortAsc = sortField != field || !sortAsc;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
               // t2 = a[field] > b[field];
               t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            //return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.Entitlements", records);
        console.log(component.get('v.sortAsc'));
        this.renderPage(component);
    },
     createCaseHandler : function(component,newCase){
        console.log('Getting Data to create Case');
        
        var action = component.get("c.createRecord");
        action.setParams({
                ca : newCase,
        });
        action.setCallback(this,function(a){
            var error = a.getError();
            var state = a.getState();
            var rtnValue = a.getReturnValue();
            var reSetCase = component.get("v.ca");
            if(rtnValue != null){
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                if(state == 'SUCCESS'){
                    var message = 'Case created successfully.' ;
                    console.log('Executed successful.');
                    toastEvent.setParams({
                            "title": "Success!",
                            "type":"Success",
                            "message":"Case is created notified ."
                    });
                    toastEvent.fire();
             	}
               else if(state == "ERROR"){
                    console.log('Executed with an Error.' + error);
                    //var toastEvent = $A.get("e.force:showToast");
                         toastEvent.setParams({
                             "title": "Error!",
                             "type":"Error",
                             "message": "Case is not created notified ."
                     });
                }
                component.set("v.oWindow", false);
                component.set("v.isWindowOpen", false);
                component.set("v.proceed", false);
                component.set("v.ca", { 'sobjectType': 'case',
                    'Subject': '',
                    'Description': 0,
                     });
            }
       });
       // $A.enqueueAction(action);
       var widget = component.get("v.ssWidget");
        console.log("widhet : "+widget.nbrOfFilesAttached);
        if(widget.nbrOfFilesAttached > 0) {
            //newCase = component.get("v.cObj");
            console.log("newCase: "+newCase);
            var cUser = component.get("v.cUser");
            console.log("newCase: "+cUser.Contact.Email);
            widget.setUnconfirmedSender(cUser.Contact.Email);
            //console.log("email : "+newCase.ContactEmail);
            widget.finalizePackage($A.getCallback(function (url) {
            console.log("finalize called");
            newCase.Case_Comments__c = "This comment includes a file attached using a Pivotal secure file drop zone: " + url;
            console.log("urllll: "+url);
            $A.enqueueAction(action);
            }));
        }else{
            $A.enqueueAction(action);            
        }
    },

    buttonSubmit:function(Component){
    $("#container").css("opacity",0.5);
   $("#loading-img").css({"display": "block"});
},
	renderPage: function(component) {
		var records = component.get("v.Entitlements"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
        component.set("v.currentList", pageRecords);
	}
})