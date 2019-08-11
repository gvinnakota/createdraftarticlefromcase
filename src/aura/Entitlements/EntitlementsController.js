({
    getEntitlements : function(component, event, helper) {
        var action = component.get("c.getEntitlementList");//get data from controller
        action.setCallback(this, function(a) {
            component.set("v.Entitlements", a.getReturnValue());//set data in the page variable
            var records = component.get("v.Entitlements");
            if(records){
                component.set("v.maxPage", Math.floor((records.length+9)/10));
            }
            helper.renderPage(component);
            
        });
        $A.enqueueAction(action);
        var usr = helper.getCurrentUser(component);
        
    },
   
    openModel: function(component, event, helper) {
        var idx = event.target.Id;
        var target = event.target.getAttribute('data-id');
        var rowIndex = event.target.getAttribute("data-selected-Index");
        var selectedEntitle = component.get("v.currentList")[rowIndex];
        component.set("v.entRecorToPass",selectedEntitle);
        component.set("v.ca",{'sobjectType':'case','AccountId':selectedEntitle.AccountId});
   		var newCase = component.get("v.ca");
        newCase.AccountId = selectedEntitle.AccountId;
 		component.set("v.oWindow", true);  
        component.set("v.disablesubmit",false);
    },    
    saveRecord : function(component,event,helper){
        console.log('Save Record');
        var newCase = component.get("v.ca");
        var ent = component.get("v.entRecorToPass");
        
        var validate = component.find("child");
        console.log('validate ::'+validate);
        var validatedData = validate.validateTechCase(newCase);
      	console.log("validateDate---->"+validatedData);
        if(validatedData != null){
            console.log("Error---");
            component.set("v.errorMessage",validatedData);
            component.set("v.showError",true);
            component.set("v.oWindow",true);
        }else{
           console.log("Ready to create case");
           component.set("v.showError",false);
           component.set("v.disablesubmit",true);
           // component.set("v.oWindow",false);
           helper.createCaseHandler(component,newCase);
        }
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.oWindow", false);
        component.set("v.isWindowOpen", false);
        component.set("v.proceed", false);
        component.set("v.errorMessage",'');
        component.set("v.ca",{'sobjectType':'case','Subject':''});
        window.location.reload();
    },
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Name");
    },
    
    sortByAccount: function(component, event, helper) {
        helper.sortBy(component, "Accountname__c");
        
    },
    sortByStartDate: function(component, event, helper) {
        
        helper.sortBy(component, "StartDate");
    },
    sortByEndDate: function(component, event, helper) {
        helper.sortBy(component, "EndDate");
        
    },
    sortByStatus: function(component, event, helper) {
       
        helper.sortBy(component, "Status");
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    createNewCase: function(component, event, helper) {
        var idx = event.target.Id;
        var target = event.target.getAttribute('data-id');
        var rowIndex = event.target.getAttribute("data-selected-Index");
        var selectedEntitle = component.get("v.currentList")[rowIndex];
        console.log('AccountId:'+ selectedEntitle.AccountId);
        console.log('Entitlement Id:'+ selectedEntitle.Id)

    	var urlEvent = $A.get("e.force:navigateToURL");
    	urlEvent.setParams({
        	"url": "/s/create-case?accId=" + selectedEntitle.AccountId +"&eId=" + selectedEntitle.Id
    	});
    	urlEvent.fire();
        
                
    }       
})