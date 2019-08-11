({
	apex : function( cmp, apexAction, params ) {
        console.log('apex', 'calling ' + apexAction);
        console.log('apex', 'params: ' + JSON.stringify(params));
        this.onBeforeApex(cmp);
        var self = this;
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = cmp.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
		        self.onAfterApex(cmp);
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
    onBeforeApex: function(c){
		console.log('onBeforeApex','start');  
		var cmpTarget = c.find('spinner');
        $A.util.addClass(cmpTarget, 'spinner');
    },
    onAfterApex: function(c){
      console.log('onAfterApex','start');  
		var cmpTarget = c.find('spinner');
        $A.util.removeClass(cmpTarget, 'spinner');
        console.log('onAfterApex','end');  
	}
})