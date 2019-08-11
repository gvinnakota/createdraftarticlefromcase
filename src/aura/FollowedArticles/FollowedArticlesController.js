({
	doInit : function(component, event, helper) {
        console.log("inMyAction");
		var action = component.get("c.getFollowedAricles");
        console.log("inMyAction ;;"+ action);
         action.setCallback(this, function(response){
            //4. process the reponse that we got from Server
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                
                component.set("v.followedArticles", result);
                console.log("result: "+result);
                
            } else{
                console.log("Errorr:"+response.getError()[0].message);
            }
            // console.log("viewall : "+ component.localStorage.getItem("v.viewall"));
              
        });
        //5. put the call in queue @ server side
        $A.enqueueAction(action);
        
	},
    viewall : function(component,event, helper){
        alert('i am called');
        component.set("v.viewAll",true);
       
        //console.log("viewall : "+ component.get("v.viewAll"));
       /* var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef: "c:AllFollowedArticles",
        componentAttributes: {
            // Attributes here.
            viewAll : true
        }
    });
evt.fire();*/
    },
})