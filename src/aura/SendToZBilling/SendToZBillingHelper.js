({
	initAction : function(c, e, h) {
        var methodName = "SendToZBilling.h.initAction";
        console.log(methodName, "start");
        var self = this;
        this.apex(c, "initAction", {quoteId: c.get("v.quoteId")}).then(function(result){
            console.log(methodName, JSON.stringify(result));
            c.set("v.chargeKeys", result.subQuotes);
            c.set("v.primaryQuote", result.primaryQuote);
            c.set("v.errors", result.errors);
            var any_to_send = false;
            var any_sent = false;
            var all_new = true;
            result.subQuotes.forEach(function(sq){
            	if(sq.quoteStatus == 'Sent to Z-Billing') any_sent = true;
            	if(sq.quoteStatus != 'Sent to Z-Billing') any_to_send = true;
            	if(sq.quoteStatus != 'New') all_new = false;
            });
            console.log(methodName, 'any_to_send='+any_to_send + '; any_sent='+ any_sent + '; all_new='+all_new);
            if(any_to_send) {
                c.set("v.state", "Ready");
                self.enableSendButton(c);
            }else{
                c.set("v.state", "All quotes have been sent");
                self.disableSendButton(c);
                self.disableSplitButton(c);
            }
            
            if(result.subQuotes.length > 0) {
                if(!any_sent) self.enableSplitButton(c);
            }else{
                if(all_new) self.splitQuote(c);
                else if(!any_sent) self.enableSplitButton(c);
            }
        }, function(error){
            console.error(methodName, JSON.stringify(error));
            if(error && error.length > 0) alert(error[0].message);
        });
        console.log(methodName, "end");
	},
	refreshAfterSplit : function(c, e, h) {
        var methodName = "SendToZBilling.h.refreshAfterSplit";
        console.log(methodName, "start");
        var self = this;
        this.apex(c, "initAction", {quoteId: c.get("v.quoteId")}).then(function(result){
            console.log(methodName, JSON.stringify(result));
            c.set("v.chargeKeys", result.subQuotes);
            var any_to_send = false;
            result.subQuotes.forEach(function(sq){
            	if(sq.quoteStatus != 'Sent to Z-Billing') any_to_send = true;
            });

            if(any_to_send) {
                c.set("v.state", "Quote split is complete, sub-quotes have been created");
                self.enableSendButton(c);
            }
        }, function(error){
            console.error(methodName, JSON.stringify(error));
            if(error && error.length > 0) alert(error[0].message);
        });
        console.log(methodName, "end");
	},
    splitQuote: function(c) {
        var methodName = "splitQuote";
        this.logStart(methodName);
        this.disableSplitButton(c);
        this.disableSendButton(c);
        //this.enableDisableButton(c, "cleanButton", true);
        c.set("v.state", "getting charge keys...");
        var self = this;
        this.apex(c, "getChargeKeys", {quoteId: c.get("v.quoteId")}).then(function(result){
            console.log(methodName, "getChargeKeys result:"+JSON.stringify(result)); 
            var nextKey = null;
            if(result && result.length > 0) nextKey = result[0].key;
            c.set("v.chargeKeys", result);
            if(nextKey) {
                console.log(methodName, "calling quoteSplitOne from splitQuote");
                self.quoteSplitOne(c, nextKey);
            }else{
		        self.enableSplitButton(c);
                self.enableSendButton(c);
		        //self.refreshAfterSplit(c);
            }
        }, function(error){
            console.error(methodName, JSON.stringify(error));
            if(error && error.length > 0) alert(error[0].message);
        });
        this.logEnd(methodName);
    },
    quoteSplitOne: function(c, key){
    	var methodName = "quoteSplitOne";   
        this.logStart(methodName);
        console.log(methodName, "key="+key);
        c.set("v.state", "Splitting " + key);
        var chargeKeys = c.get("v.chargeKeys");
        chargeKeys.forEach(function(chargeKey){
            if(chargeKey.key == key) {
                chargeKey.splitStatus = "In Progress";
            }
        });
        c.set("v.chargeKeys", chargeKeys);
        var self = this;
        this.apex(c, "splitQuote", {quoteId: c.get("v.quoteId"), chargeKey:key}).then(function(result){
	        var chargeKeys = c.get("v.chargeKeys");
	        var nextKey = null;
            console.log(methodName, "quoteSplit result:"+JSON.stringify(result));             
            chargeKeys.forEach(function(chargeKey){
                if(chargeKey.key == key) {
                    chargeKey.splitStatus = "Done";
                    chargeKey.quoteId = result;
                    chargeKey.quoteStatus = 'New';
                } else if(chargeKey.splitStatus != 'Done') {
                    nextKey = chargeKey.key;
                }
            });
            c.set("v.chargeKeys", chargeKeys);
            console.log(methodName, "nextKey="+nextKey);
            if(nextKey){
		        self.logEnd(methodName);
                self.log(methodName, "calling again...");
                self.quoteSplitOne(c, nextKey);
            }else{
                //self.enableDisableButton(c, "cleanButton", false);
		        self.enableSplitButton(c);
                self.enableSendButton(c);
		        self.refreshAfterSplit(c);
		        self.logEnd(methodName);
            }
        }, function(error){
            console.error(methodName, JSON.stringify(error));
            if(error && error.length > 0) alert(error[0].message);
        });
    },
    enableSplitButton: function(c){
        this.enableDisableButton(c,"splitButton",false);
    },
    disableSplitButton: function(c){
        this.enableDisableButton(c,"splitButton",true);
    },
    enableSendButton: function(c){
        this.enableDisableButton(c,"sendButton",false);
    },
    disableSendButton: function(c){
        this.enableDisableButton(c,"sendButton",true);
    },
    enableDisableButton: function(c, btn_id, disabled_flag){
        var btn = c.find(btn_id);
        if(btn) btn.set("v.disabled",disabled_flag);
	},
    sendToZBilling: function(c,quoteId){
        c.set("v.state", "sending " + quoteId + " to Zuora...");
        this.disableSplitButton(c);
        var chargeKeys = c.get("v.chargeKeys");
        chargeKeys.forEach(function(chargeKey){
            if(chargeKey.quoteId == quoteId){
                chargeKey.quoteStatus = "In Progress";
                chargeKey.quoteErrorMessage = null;
            }
        });
        c.set("v.chargeKeys", chargeKeys);
		var self = this;
        
        //TODO call createZuoraAccount on the first quote - after the first one all sub-quotes should have
        //Z account id and number set.
        
        this.apex(c, "createZuoraAccount", { quoteId: quoteId }).then(function(result){
            console.log("createZuoraAccount: response:"+result);
            self.apex(c,"sendToZBilling", { quoteId: quoteId }).then(function(result){
                console.log("send", JSON.stringify(result));
                console.log("send", "send is complete");
                
                if(!result) {
                    chargeKeys.forEach(function(ck){
                        if(ck.quoteId == quoteId){
                            ck.quoteStatus = "Sent to Z-Billing";
                        }
                    });
                }else{
                    chargeKeys.forEach(function(ck){
                        if(ck.quoteId == quoteId){
                            ck.quoteStatus = "Failed";
                            ck.quoteErrorMessage = result;
                        }
                    });
                }
                c.set("v.chargeKeys", chargeKeys);
                var nextQuoteId = null;
                chargeKeys.forEach(function(ck){
                    if(ck.quoteStatus == 'New') {
                        nextQuoteId = ck.quoteId;
                    }
                });
                if(nextQuoteId) {
                    self.sendToZBilling(c,nextQuoteId);
                }else {
                    c.set("v.state", "All quotes have been sent");
                    self.initAction(c);
                }
            }, function(errors) {
                //self.enableDisableButton(c, "cleanButton", false);
                var err = null;
                if(errors && errors.length > 0 && errors[0].message) {
                    err = errors[0].message;
                }else{
                    err = errors;
                }
                chargeKeys.forEach(function(ck){
                    if(ck.quoteId == quoteId){
                        ck.quoteStatus = "Failed";
                        ck.quoteErrorMessage = err;
                    }
                });
                c.set("v.chargeKeys", chargeKeys);
            });
        }, function(errors){
            var err = null;
            if(errors && errors.length > 0 && errors[0].message) {
                err = errors[0].message;
            }else{
                err = errors;
            }
            chargeKeys.forEach(function(ck){
                if(ck.quoteId == quoteId){
                    ck.quoteStatus = "Failed";
                    ck.quoteErrorMessage = err;
                }
            });
            c.set("v.chargeKeys", chargeKeys);
        });
        
    },
	apex : function( cmp, apexAction, params ) {
        console.log('apex', 'calling ' + apexAction);
        console.log('apex', 'params: ' + JSON.stringify(params));
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = cmp.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
	},
    handleRuntimeException : function(c,src, exc) {
        try {
            var methodName = "handleRuntimeException";
            //this.logStart(methodName);
            this.logError(methodName, "src="+src+",exc="+JSON.stringify(exc)+",exc.message="+exc.message);
            //this.showErrorAlert(exc.message, c);
            //this.logEnd(methodName);
            //this.logEnd(src);    
        }catch(ex){
            this.logError("handleRuntimeException", "Failed in handleRuntimeException:"+ex);
            if(ex) {
                //this.logError("handleRuntimeException", ex.message);
                //this.showErrorAlert(ex.message, c);
            }
        }
    },
    onStartAsync: function(c){
        this.logStart("onStartAsync");
        //var btn = c.find("sendButton");
        //btn.set("v.disabled",true);
        this.logEnd("onStartAsync");
    },
    onEndAsync: function(c){
        this.logStart("onEndAsync");
        //var btn = c.find("sendButton");
        //btn.set("v.disabled",false);
        this.logEnd("onEndAsync");
    },
    log: function(methodName, msg) {
        console.log(methodName, msg);
    },
    logStart: function(methodName) {
        console.log(methodName, "<"+methodName+">");
    },
    logEnd: function(methodName) {
        console.log(methodName, "</"+methodName+">");
    },
    logError: function(methodName, msg) {
        console.error(methodName, msg);
    }
})