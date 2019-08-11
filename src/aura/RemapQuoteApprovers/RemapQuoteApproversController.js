({
	doInit : function(component, event, helper) {
        
        
        
        var quoteId = component.get("v.recordId"); 
        var action = component.get("c.RemapApproversLightning");
        action.setParams({
            "quoteId": quoteId
        });   
        
        action.setCallback(this,function(a){
            
         	var state =a.getState(); 
            
            if(state === "SUCCESS"){
                var res = a.getReturnValue();
                if(res==false){
                    component.set("v.isError", true);   
                    component.set("v.wraningMsg","Cannot modify the record when status is Approved or InProcess");
                    window.setTimeout(
                        $A.getCallback(function() {
                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();  
                        }), 3000 
                    ); 
                }else{  
                    window.setTimeout(
                        $A.getCallback(function() {
                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();  
                        }), 2000  
                    );
                }  
            }
        });
        $A.enqueueAction(action);   
	}
})