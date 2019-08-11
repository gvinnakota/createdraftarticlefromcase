({
    doInit :  function(component,event,helper){ 
        debugger;
        var recIdLst = component.get('v.selectRecIds');
        recIdLst = recIdLst.replace('[','');
        recIdLst = recIdLst.replace(']','');
        recIdLst = recIdLst.trim();
        var forclose = component.find("showDiv");
        var forError = component.find("noRecord");
        var Forsubmit = component.find("SubmitHide");
        var ForShowError = component.find("showError");
        var submitHide2 = true;
        if(recIdLst != '' && recIdLst != undefined){
            component.set('v.countOfRecord', recIdLst.split(',').length);
            component.set('v.selectRecIds',recIdLst);
            $A.util.addClass(forclose,'slds-show');
            $A.util.removeClass(forclose,'slds-hide');
            $A.util.addClass(forError,'slds-hide');
            $A.util.removeClass(forError,'slds-show');
            $A.util.addClass(ForShowError,'slds-hide');
            $A.util.removeClass(ForShowError,'slds-show');
             component.set("v.HideSubmit", submitHide2)  
            
        }else{
            component.set('v.Message','Select at least one record and try again.');
            component.set('v.toastType','error');
            $A.util.addClass(forclose,'slds-hide');
            $A.util.removeClass(forclose,'slds-show');
            $A.util.addClass(ForShowError,'slds-show');
            $A.util.removeClass(ForShowError,'slds-hide');
            $A.util.addClass(forError,'slds-hide');
            $A.util.removeClass(forError,'slds-show');   
              
        }
    }, 
     Search : function(component, event, helper) {  
        debugger;
        var lookupList = component.find("lookupList");
        var action = component.get("c.fetchUser");
        var searchKeyWord = component.get("v.searchUser");
        if(searchKeyWord == ''){
            $A.util.addClass(lookupList, 'slds-hide');
            $A.util.removeClass(lookupList, 'slds-show');
            return;
        }
        action.setParams({
            "searchKeyWord" : component.get("v.searchUser"), 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.listOfSearchRecords", storeResponse);
                
                if(storeResponse != '' || storeResponse != undefined){
                    $A.util.addClass(lookupList, 'slds-show');
                    $A.util.removeClass(lookupList, 'slds-hide');
                }else{
                    $A.util.addClass(lookupList, 'slds-hide');
                    $A.util.removeClass(lookupList, 'slds-show');
                }
            }
        });
        $A.enqueueAction(action); 
    },

    submitDetails: function(component,event,handler){
        debugger;
        var ownerId  =component.get("v.ownerId") ;
        var selectRecIds  = component.get("v.selectRecIds");
        var sObjName  = component.get("v.sobjectName");
        var action = component.get("c.changeOwner");
        action.setParams({
            "ownerId": ownerId, 
            "recIds":selectRecIds[0],
            "objName" :sObjName
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var forerror = component.find("noRecord");
                component.set('v.Message','Record Owner has been updated Successfully');
                component.set('v.toastType','success');
                $A.util.addClass(forerror,'slds-show');
                $A.util.removeClass(forerror,'slds-hide');
                var listViewId = component.get("v.listViewId");
               var listViewName = component.get("v.listViewName");
                window.setTimeout(function(){ 
                    sforce.one.navigateToList(listViewId,listViewName,sObjName);
                 }, 2000);
                
                
            }
        });
    
        $A.enqueueAction(action);
    },
    
    handleComponentEvent: function(component,event, helper){
        var selectedRecordGetFromEvent = event.getParam("userByEvent");
	    component.set("v.searchUser" , selectedRecordGetFromEvent.Name); 
        component.set("v.ownerId" , selectedRecordGetFromEvent.Id);

        var forclose = component.find("lookupList");
        $A.util.addClass(forclose, 'slds-hide');
        $A.util.removeClass(forclose, 'slds-show');
    },

    cancelCase:function(component,event,helper){
        var sObjName  = component.get("v.sobjectName");
        var listViewId = component.get("v.listViewId");
        var listViewName = component.get("v.listViewName");
        sforce.one.navigateToList(listViewId,listViewName,sObjName);
     
    },
    closeModel:function(component,event,helper){
       debugger;
       var sObjName  = component.get("v.sobjectName");
       var listViewId = component.get("v.listViewId");
       var listViewName = component.get("v.listViewName");
       sforce.one.navigateToList(listViewId,listViewName,sObjName);
    },

    hideSpinner : function (component, event, helper) {
       var spinner = component.find('spinner');
       var evt = spinner.get("e.toggle");
       evt.setParams({ isVisible : false });
       evt.fire();    
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
       var spinner = component.find('spinner');
       var evt = spinner.get("e.toggle");
       evt.setParams({ isVisible : true });
       evt.fire();    
    }
})