({
    doInit : function(cmp){},
    
    selectRecord : function(component, event, helper){     
        debugger;
        var getSelectRecord = component.get("v.oRecord");
        var compEvent = component.getEvent("oSelectedUserEvent");
        compEvent.setParams({"userByEvent" : getSelectRecord });  
        compEvent.fire();
    }
})