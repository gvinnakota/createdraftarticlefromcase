({
	doInit : function(component, event, helper) {
        helper.doInit(component,event,helper);
	},
    addGoogleDoc : function(component,event,helper){
        component.set('v.isModalOpen', true);
    },
    
  submitDetails: function(component, event, helper) {
    
      var createWarning = component.find("createWarning");
      var docName =  component.get("v.docName");
      var docUrl =  component.get("v.docUrl");
      var recordId =  component.get("v.recordId");
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
            "parentId" : recordId
         });
 		    action.setCallback(this, function(response){
          var state = response.getState();
          if (state === "SUCCESS") { 
              helper.doInit(component,event,helper); 
              //component.set("v.isModalOpen", false); 
              
            //var dismissActionPanel = $A.get("e.force:closeQuickAction");
      			//dismissActionPanel.fire(); 
              var resultsToast = $A.get("e.force:showToast");
              resultsToast.setParams({ 
                  "title": "Save Success!",
                  "type" : "success",
                  "message": "Google Doc created successfully!"
                  
              });
              
              // reset values
              component.set("v.docName","");
              component.set("v.docUrl","");
              
              resultsToast.fire(); 
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
    
    navigateToUrl: function(component,event,helper){
        
        var docId= event.currentTarget.dataset.docid ||'';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/Google_Doc_Details" 
        });
        //urlEvent.fire();
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({  
        "recordId": docId,
        "slideDevName": "detail"
        
         });
          navEvt.fire(); 
    },

   openModel: function(component, event, helper) {  
      helper.openModel(component,event,helper);   
      helper.closeMenu(component,event,helper);
   },
  
   closeModel :function(component,event,helper){
      // reset values
      component.set("v.docName","");
      component.set("v.docUrl","");   
      helper.closeModel(component,event,helper);
     
   },
    
    openMenu : function(component,event,helper){
       helper.openMenu(component,event,helper); 
    },
    
    closeMenu :function(component,event,helper){
        helper.closeMenu(component,event,helper); 
    },

    openRecordDetail :function(component,event,helper){
      
        var docId = event.currentTarget.dataset.docid || ''; 
       helper.openRecordDetail(component,event,helper,docId);
    },
    
    editMode: function(component,event,helper){
        component.set("v.isEditMode", true); 
    },

    closeRecordDetail :function(component,event,helper){
        helper.closeRecordDetail(component,event,helper);
    },

    saveDocRecord :function(component,event,helper){ 
        
       helper.saveDocRecord(component,event,helper);
    }, 

    cancelDocUpdate: function(component,event,helper){

        component.set("v.isEditMode", false); 
    },

    deleteDocRecord :function(component,event,helper){
     
        helper.deleteDocRecord(component,event,helper); 
    },

    openDocDetail :function(component,event,helper){
     
       var parentId = component.get("v.recordId"); 
       var urlEvent = $A.get("e.force:navigateToURL");
       urlEvent.setParams({
          "url": "/apex/Google_Doc_List?parentId="+parentId
       });

       urlEvent.fire();
    }


})