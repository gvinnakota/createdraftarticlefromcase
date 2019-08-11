({

	doInit: function(component,event,helper){ 
        
        var parentId = component.get("v.parentId"); 
		var action =  component.get("c.getGoogleDocs");
        action.setParams({
            'parentId' : parentId  
        });
        action.setCallback(this,function(a){
			var state =  a.getState();
            if(state === "SUCCESS"){
                var res = a.getReturnValue();
                component.set("v.currentList", res);  
                component.set("v.parent", res[0].parent);  
                //this.sortBy(component,'docModifiedDate');  
            }
        });
        $A.enqueueAction(action);
        
    },

    sortBy: function(component, field) {
        
        var sortAsc = component.get("v.sortAsc");
        var sortField = component.get("v.sortField");
        var records = component.get("v.currentList");
        sortAsc = sortField != field || !sortAsc; 
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);   
        component.set("v.currentList", records);
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

    closeRecordDetail :function(component,event,helper){
      var modalPop = document.getElementById("modal-showEditRecord");
      var modalShadow = document.getElementById("modal-dropEditRecord"); 
      $A.util.addClass(modalPop, 'slds-fade-in-close');
      $A.util.removeClass(modalPop, 'slds-fade-in-open');
      $A.util.addClass(modalShadow,'slds-backdrop--close');
      $A.util.removeClass(modalShadow,'slds-backdrop--open');
      component.set("v.isEditMode",false); 
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

    getGoogleDocRecord : function(component, event, helper, docId) {
        
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
                var createSuccess = component.find("createSuccess");
      			$A.util.addClass(createSuccess,"slds-show");
      			$A.util.removeClass(createSuccess,"slds-hide"); 
      			component.set("v.WarningMsg", "Google Doc saved Successfully");
      			window.setTimeout(
      				$A.getCallback(function(){
      					$A.util.addClass(createSuccess,"slds-hide");
      					$A.util.removeClass(createSuccess,"slds-show");
      				}),3000 
      			);  
            } 
        });
        
        $A.enqueueAction(action);

  },

  deleteDocRecord :function(component,event,helper){ 
      
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
                var createSuccess = component.find("createSuccess");
      			$A.util.addClass(createSuccess,"slds-show");
      			$A.util.removeClass(createSuccess,"slds-hide"); 
      			component.set("v.WarningMsg", "Google Doc deleted Successfully");
      			window.setTimeout(
      				$A.getCallback(function(){
      					$A.util.addClass(createSuccess,"slds-hide");
      					$A.util.removeClass(createSuccess,"slds-show");
      				}),3000 
      			); 
            }
        });

        $A.enqueueAction(action);

    }
})