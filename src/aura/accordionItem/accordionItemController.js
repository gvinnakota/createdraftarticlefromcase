({
	init : function(c, e, h) {
        var methodName = "accordionItem.h.init";
		console.log(methodName, "start");
		console.log(methodName, "end");
	},
	expand : function(c, e, h) {
		c.set("v.expanded",true);
	},
	collapse : function(c, e, h) {
		c.set("v.expanded",false);
	}
})