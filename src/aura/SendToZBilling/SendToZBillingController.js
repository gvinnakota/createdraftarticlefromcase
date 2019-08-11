({
	init : function(c, e, h) {
        console.log("init", "start");
        h.initAction(c);
        /*h.doApexCallback(c, "initAction", "initAction", {quoteId: c.get("v.quoteId")}, function(result){
            console.log("init", JSON.stringify(result));
            c.set("v.chargeKeys", result.subQuotes);
            c.set("v.primaryQuote", result.primaryQuote);
            var any_to_send = false;
            var any_sent = false;
            var all_new = true;
            result.subQuotes.forEach(function(sq){
            	if(sq.quoteStatus == 'Sent to Z-Billing') any_sent = true;
            	if(sq.quoteStatus != 'Sent to Z-Billing') any_to_send = true;
            	if(sq.quoteStatus != 'New') all_new = false;
            });
            console.log("init", 'any_to_send='+any_to_send + '; any_sent='+ any_sent + '; all_new='+all_new);
            if(any_to_send) {
                c.set("v.state", "Ready");
                h.enableSendButton(c);
            }else{
                c.set("v.state", "All quotes have been sent");
                h.disableSendButton(c);
                h.disableSplitButton(c);
            }
            
            if(result.subQuotes.length > 0) {
                if(!any_sent) h.enableSplitButton(c);
                //h.enableSendButton(c);
                //h.enableDisableButton(c, "cleanButton", false);
            }else{
                if(all_new) h.splitQuote(c);
                else if(!any_sent) h.enableSplitButton(c);
                //h.disableSendButton(c);
                //h.enableDisableButton(c, "cleanButton", false);
            }
        });*/
        console.log("init", "end");
	},
    onClickSplit : function(c, e, h) {
        console.log("onClickSplit", "start");
        var chargeKeys = c.get("v.chargeKeys");
        if(chargeKeys.length == 0){
	        h.splitQuote(c);
        }else{
            h.apex(c,"cleanSplit", {quoteId: c.get("v.quoteId")}).then(function(result){
                c.set("v.chargeKeys", []);
                h.splitQuote(c);
            });
        }
        console.log("onClickSplit", "end");
	},
    onClickSend : function(c, e, h) {
        console.log("onClickSend", "start");
        //TODO
        //h.enableDisableButton(c, "cleanButton", true);
        h.disableSendButton(c);

        var chargeKeys = c.get("v.chargeKeys");
        var quoteId = null;
        chargeKeys.forEach(function(ck){
            if(ck.quoteStatus != 'Sent to Z-Billing') {
                quoteId = ck.quoteId;
            }
        });
        if(quoteId){
            h.sendToZBilling(c,quoteId);
        }else {
            c.set("v.state", "All quotes have been sent");
        }

        console.log("onClickSend", "end");
	}
})