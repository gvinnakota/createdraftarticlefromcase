({
     doInit: function(component,event,helper){ 
        
        var parentId = component.get("v.recordId");
		var action =  component.get("c.getGoogleDocs");
        action.setParams({
            'parentId' : parentId  
        });
        action.setCallback(this,function(a){
			var state =  a.getState();
            if(state === "SUCCESS"){
                var res = a.getReturnValue();
                component.set("v.allGoogleLst", res);
                component.set("v.numberOfDocs", res.length);
                if(res.length>3){ 
                    var docLst= res; 
                    docLst.length = 3;
                    component.set("v.googleLst", docLst);
                    component.set("v.viewAll", true); 
                }else{
                   component.set("v.googleLst", res);
                   if(res.length!=0)
                   	component.set("v.viewAll", true);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
	 openModel: function(component, event, helper) {  
        
      component.set("v.isModalOpen", true);
       component.set("v.closeAddButton", false);
        var modalPop = document.getElementById("modal-pop");
        var modalShadow = document.getElementById("modal-Shadow");
        $A.util.addClass(modalPop, 'slds-fade-in-open');
        $A.util.removeClass(modalPop, 'slds-fade-in-close');
        $A.util.addClass(modalShadow,'slds-backdrop--open');
        $A.util.removeClass(modalShadow,'slds-backdrop--close');  
   },
  
   closeModel :function(component,event,helper){

      var modalPop = document.getElementById("modal-pop");
      var modalShadow = document.getElementById("modal-Shadow"); 
      $A.util.addClass(modalPop, 'slds-fade-in-close');
      $A.util.removeClass(modalPop, 'slds-fade-in-open');
      $A.util.addClass(modalShadow,'slds-backdrop--close');
      $A.util.removeClass(modalShadow,'slds-backdrop--open');
    },

    closeRecordDetail :function(component,event,helper){
      var modalPop = document.getElementById("modal-showEditRecord");
      var modalShadow = document.getElementById("modal-dropEditRecord"); 
      $A.util.addClass(modalPop, 'slds-fade-in-close');
      $A.util.removeClass(modalPop, 'slds-fade-in-open');
      $A.util.addClass(modalShadow,'slds-backdrop--close');
      $A.util.removeClass(modalShadow,'slds-backdrop--open');
      component.set("v.isEditMode",false); 
    },
    
    closeMenu :function(component,event,helper){  
        
		    var dropdown = component.find('dropdown');  
        $A.util.addClass(dropdown,'slds-hide'); 
        $A.util.removeClass(dropdown,'slds-show');  
    },
    
    openMenu : function(component,event,helper){
        
        var dropdown = component.find('dropdown'); 
        $A.util.addClass(dropdown,'slds-show'); 
        $A.util.removeClass(dropdown,'slds-hide');
    },

    openRecordDetail:function(component,event,helper,docId){
        debugger;
        var modalPop = document.getElementById("modal-showEditRecord");
        var modalShadow = document.getElementById("modal-dropEditRecord");
        $A.util.addClass(modalPop, 'slds-fade-in-open');
        $A.util.removeClass(modalPop, 'slds-fade-in-close');
        $A.util.addClass(modalShadow,'slds-backdrop--open');
        $A.util.removeClass(modalShadow,'slds-backdrop--close'); 
        helper.getGoogleDocRecord(component,event,helper,docId);

    },

    getGoogleDocRecord : function(component, event, helper, docId) {
        debugger;
        //var docId =  component.get("v.docId");
        var action = component.get("c.googleDocDetails");
        action.setParams({
            'docId': docId 
        });
        
        action.setCallback(this,function(a){
           var state = a.getState();
            if(state === "SUCCESS"){
                var res =  a.getReturnValue();   
                component.set("v.googleDocRec", res);
                //component.set("v.gDocId",res.Id);
                //component.set("v.parentId",res.ParentId);
            }
        });
        
        $A.enqueueAction(action);
  },

  saveDocRecord :function(component,event,helper){
    
      var gDoc = component.get("v.googleDocRec");

      var editWarning = component.find("editWarning");
      var recordId =  component.get("v.recordId");

      if(gDoc[0].docURL == null || gDoc[0].docName == null){
          component.set("v.WarningMsg","Required Fields Missing");
          $A.util.addClass(editWarning, 'slds-show');
          $A.util.removeClass(editWarning, 'slds-hide'); 
          return;
      }else{
           $A.util.addClass(editWarning, 'slds-hide');
           $A.util.removeClass(editWarning, 'slds-show');
      }
       
      var action = component.get("c.updateDocRecord");
      action.setParams({
          'docLst': gDoc  
      });
      
      action.setCallback(this,function(a){
         var state = a.getState();
          if(state === "SUCCESS"){
              component.set("v.isEditMode", false);
              helper.doInit(component,event,helper);
              helper.closeRecordDetail(component,event,helper);
              var resultsToast = $A.get("e.force:showToast");
              resultsToast.setParams({ 
                  "title": "Save Success!",
                  "type" : "success",
                  "message": "Google Doc saved successfully!"
                  
              });
              resultsToast.fire(); 

          }else{
             var errorMsg = response.getError()[0];
             component.set("v.WarningMsg",errorMsg.message);
             $A.util.addClass(editWarning, 'slds-show');
             $A.util.removeClass(editWarning, 'slds-hide'); 
          }
      });
      
      $A.enqueueAction(action);

  },

  deleteDocRecord :function(component,event,helper){
      debugger;
        var gDocId =  component.get("v.gDocId");
        var parentId = component.get("v.parentId");
        var gDoc = component.get("v.googleDocRec");

        var action = component.get("c.deleteDoc");
        action.setParams({ 
            'docLst' : gDoc
        });

        action.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                //'/lightning/r/'+parentId+'/related/CombinedAttachments/view'
                helper.doInit(component,event,helper);
                helper.closeRecordDetail(component,event,helper);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({ 
                    "title": "Save Success!",
                    "type" : "success",
                    "message": "Google Doc deleted successfully!"
                    
                });
              resultsToast.fire();  
            }
        });

        $A.enqueueAction(action);

    }

})