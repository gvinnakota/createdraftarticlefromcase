({
	getMenuList : function(component) {
        var MenuListAction = component.get("c.getMenuList");
        MenuListAction.setCallback(this, function(response)
		{
        	var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
                var resData = response.getReturnValue();  
                component.set("v.RecordsList", resData);
                 var recordList = component.get("v.RecordsList");
                 var count = recordList.length;
                for(var i=0 ; i<count;i++){
                    if(recordList[i].DeveloperName =='Support_Home'){
                        component.set("v.url",recordList[i].URL__c);
                    }
                }
            } 
        });
        $A.enqueueAction(MenuListAction);   
	},
})