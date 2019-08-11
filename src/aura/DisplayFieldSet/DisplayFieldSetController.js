({
	init : function(c, e, h) {
        var methodName = "DisplayFieldSet.c.init";
        console.log(methodName, "start");
        var params = {
            sobj:c.get("v.sobject"), 
            sobjectType:c.get("v.sobjectType"), 
            fieldSetName: c.get("v.fieldSetName")
        };
        h.apex(c,"getFields", params).then(function(result){
            console.log(methodName, JSON.stringify(result));
            c.set("v.fields", result);
        }, function(errors){
            console.log(methodName, "ERRORS:"+JSON.stringify(errors));
        });
        console.log(methodName, "end");
	}
})