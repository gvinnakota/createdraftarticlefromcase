({
	doInit: function(component,event,helper){ 
		//component.set("v.parentId", component.get("v.parentId"));
       helper.doInit(component,event,helper);        
    },

    sortByDocName :function(component,event,helper){ 
    	helper.sortBy(component,'docName');  
    },

    sortByLastModifiedDate :function(component,event,helper){ 
    	helper.sortBy(component,'docModifiedDate');  
    },

     openRecordDetail :function(component,event,helper){
      
        var docId = event.currentTarget.dataset.docid || ''; 
       helper.openRecordDetail(component,event,helper,docId);
    },
     editMode: function(component,event,helper){
        component.set("v.isEditMode", true); 
    },
    
    cancelDocUpdate: function(component,event,helper){

        component.set("v.isEditMode", false); 
    },

    saveDocRecord :function(component,event,helper){ 
       
       helper.saveDocRecord(component,event,helper);
    },

    closeRecordDetail :function(component,event,helper){
        helper.closeRecordDetail(component,event,helper);
    },

    openModel: function(component, event, helper) {  
        
      helper.openModel(component,event,helper); 
   },

    closeModel :function(component,event,helper){
      // reset values
      component.set("v.docName","");
      component.set("v.docUrl","");         
      helper.closeModel(component,event,helper);
   },

    deleteDocRecord :function(component,event,helper){
      helper.deleteDocRecord(component,event,helper);
    },

    submitDetails: function(component, event, helper) {
    
      var createWarning = component.find("createWarning");
      var docName =  component.get("v.docName");
      var docUrl =  component.get("v.docUrl");
      var parentId =  component.get("v.parentId");
      if(docUrl == null || docName == null){
          component.set("v.WarningMsg","Required Fields Missing");
          $A.util.addClass(createWarning, 'slds-show');
          $A.util.removeClass(createWarning, 'slds-hide'); 
          return;
      }else{
           $A.util.addClass(createWarning, 'slds-hide');
           $A.util.removeClass(createWarning, 'slds-show');
      }
   	  var action = component.get("c.createGoogleDoc");
        action.setParams({
            "Name" : docName, 
            "URL" :  docUrl,
            "parentId" : parentId
         });
 		    action.setCallback(this, function(response){
          var state = response.getState();
          if (state === "SUCCESS") { 
              helper.doInit(component,event,helper); 
              //component.set("v.isModalOpen", false); 
              
             // var dismissActionPanel = $A.get("e.force:closeQuickAction");
      			//dismissActionPanel.fire();
      			var createSuccess = component.find("createSuccess");
      			$A.util.addClass(createSuccess,"slds-show");
      			$A.util.removeClass(createSuccess,"slds-hide");
      			component.set("v.WarningMsg", "Google Doc created Successfully");
      			window.setTimeout(
      				$A.getCallback(function(){
      					$A.util.addClass(createSuccess,"slds-hide");
      					$A.util.removeClass(createSuccess,"slds-show");
      				}),3000 
      			);
      			component.set("v.docName",'');
      			component.set("v.docUrl",'');
               helper.closeModel(component,event,helper);
          }else{
             var errorMsg = response.getError()[0];
	           component.set("v.WarningMsg",errorMsg.message);
             $A.util.addClass(createWarning, 'slds-show');
             $A.util.removeClass(createWarning, 'slds-hide'); 
          }
      });
      $A.enqueueAction(action);
    },

     showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        if(spinner != undefined){ 
	        $A.util.addClass(spinner, 'slds-show'); 
	        $A.util.removeClass(spinner, 'slds-hide');
        } 
    },
   // automatically call when the component is waiting for a response to a server request.
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        if(spinner != undefined){
        	$A.util.addClass(spinner,"slds-hide");
      		$A.util.removeClass(spinner,"slds-show");
        }   
    }
})