({
	init : function(c, e, h) {
        var map = c.get("v.map");
        var key = c.get("v.key");
        var value = h.readFromObject(map, key);
	    c.set("v.value", value);
	}
})