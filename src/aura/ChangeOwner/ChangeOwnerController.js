({
    doInit :  function(component,event,helper){ 
        
       var  oppIdLst = component.get('v.oppRecIds');
        oppIdLst = oppIdLst.replace('[','');
        oppIdLst = oppIdLst.replace(']','');
        oppIdLst = oppIdLst.trim();
        var forclose = component.find("showDiv");
        var forError = component.find("noRecord");
        var Forsubmit = component.find("SubmitHide");
        var ForShowError = component.find("showError");
         var submitHide2 = true;
      

  if(oppIdLst != '' && oppIdLst != undefined){
            component.set('v.countOfRecord', oppIdLst.split(',').length);
            component.set('v.oppRecIds',oppIdLst);
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
        var forclose = component.find("lookupList");
        var action = component.get("c.fetchUser");
        var searchKeyWord = component.get("v.searchUser");
        if(searchKeyWord == ''){
            $A.util.addClass(forclose, 'slds-hide');
            $A.util.removeClass(forclose, 'slds-show');
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
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');
                }else{
                    $A.util.addClass(forclose, 'slds-hide');
                    $A.util.removeClass(forclose, 'slds-show');
                }
            }
        });
               $A.enqueueAction(action); 
    },

    submitDetails: function(component,event,handler){
       var ownerId  =component.get("v.ownerId") ;
        var oppRecIds  = component.get("v.oppRecIds");
              var action = component.get("c.changeOwner");
        action.setParams({
            "ownerId": ownerId, 
            "oppRecIds":oppRecIds[0]
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
                    sforce.one.navigateToList(listViewId,listViewName,'Opportunity');
                 }, 2000);
                
                
            }
        });
    
        $A.enqueueAction(action);
    },
    
  

     handleComponentEvent: function(component,event, helper){
    var selectedAccountGetFromEvent = event.getParam("accountByEvent");

        console.log('selectedAccountGetFromEvent.Name:' + selectedAccountGetFromEvent.Name);
        console.log('selectedAccountGetFromEvent.Id:' + selectedAccountGetFromEvent.Id);
        component.set("v.searchUser" , selectedAccountGetFromEvent.Name); 
        component.set("v.ownerId" , selectedAccountGetFromEvent.Id);

        var forclose = component.find("lookupList");
        $A.util.addClass(forclose, 'slds-hide');
        $A.util.removeClass(forclose, 'slds-show');
    },

    cancelCase:function(component,event,helper){
        var listViewId = component.get("v.listViewId");
        var listViewName = component.get("v.listViewName");
              sforce.one.navigateToList(listViewId,listViewName,'Opportunity');
     
    },
    closeModel:function(component,event,helper){
                var listViewId = component.get("v.listViewId");
        var listViewName = component.get("v.listViewName");
              sforce.one.navigateToList(listViewId,listViewName,'Opportunity');
        
    },
    

})