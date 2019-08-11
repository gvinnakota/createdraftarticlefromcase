({
   openModel: function(component, event, helper) {
      component.set("v.isModalOpen", true);
       component.set("v.closeAddButton", false);
       
   },
  
   closeModel: function(component, event, helper) {
       	  $A.get("e.force:closeQuickAction").fire();
         },
   submitDetails: function(component, event, helper) {

       debugger;
       var fieldId = component.find("fieldId");
       var docName =  component.get("v.docName");
  	   var docUrl =  component.get("v.docUrl");
 	   var recordId =  component.get("v.recordId");
      if(docUrl == null || docName == null){
          component.set("v.WarningMsg","Required Fields Missing");
          $A.util.addClass(fieldId, 'slds-show');
          $A.util.removeClass(fieldId, 'slds-hide'); 
          return;
      }else{
           $A.util.addClass(fieldId, 'slds-hide');
          $A.util.removeClass(fieldId, 'slds-show');
      }
   var action = component.get("c.AddGoogleDoc");
        action.setParams({
            "Name" : docName, 
            "URL" :  docUrl,
            "parentId" : recordId
         });
            action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
        			dismissActionPanel.fire(); 
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({ 
                    "title": "Save Success!",
                    "type" : "success",
                    "message": "A Google Doc File  save successfully!"
                });
                resultsToast.fire();
                 $A.get("e.force:closeQuickAction").fire();
            }else{
               var errorMsg = response.getError()[0];
				component.set("v.WarningMsg",errorMsg.message);
                  $A.util.addClass(fieldId, 'slds-show');
                  $A.util.removeClass(fieldId, 'slds-hide'); 
            }
                });
                $A.enqueueAction(action);
            }
})