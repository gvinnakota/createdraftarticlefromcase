({
    
    doInit: function(component, event, helper)
    {  
         // get url values.
         var entitlmentId;
         var accId;
         if (helper.getJsonFromUrl().eId){
             entitlmentId = helper.getJsonFromUrl().eId;//will get abc as id
             component.set('v.origin','entTab'); 
             component.set('v.isCaseTab',false); 
         }
         if (helper.getJsonFromUrl().accId){
             accId = helper.getJsonFromUrl().accId;//will get abc as id
             component.set('v.origin','entTab'); 
             component.set('v.isCaseTab',false); 
         }
 
         var origin=component.get("v.origin"); 
         var isEntTabOrigin = (origin=='entTab');
         
         if(isEntTabOrigin==true){
            component.set("v.selectedAccountEntOrgin", accId);
            component.set("v.selectedEntitlementEntOrgin", entitlmentId);
         }   

         console.log('eId is. ' + entitlmentId);
         console.log('accId is. ' + accId);
 
         helper.fetchPickListVal(component, 'Environment__c', 'environ');
         helper.fetchPickListVal(component, 'What_action_were_you_performing__c', 'perform');
         helper.fetchPickListVal(component, 'priority', 'priority'); 
 
         var newCase = component.get("v.cObj");
 
         var accountId;          
         var action=  component.get('c.getCurrentUser');     
         action.setCallback(this,function(response)  {
             var state=response.getState();           
             if(state==='SUCCESS')
             {
                 var res =  response.getReturnValue();
 
                 if(res != null){
                     component.set('v.cUser',res); 
                     component.set("v.contacts",res.Contact);
 
                     newCase.ContactId = res.ContactId;
                     newCase.AccountId = 'None';
                     component.set("v.cObj",newCase);
                     
                     if (accId){
                         newCase.AccountId = accId;
                         component.set("v.selectedAccount", accId);
                         
                     }
 
                     helper.accountRecords(component,res,newCase);
 
                     if (entitlmentId){
                         newCase.EntitlementId = entitlmentId;
                         component.set("v.selectedEntitlement", entitlmentId);
                     }
                     else{
                         newCase.EntitlementId = 'None';
                     }
 
                     if (accId){
                         helper.fetchEntitlements(component,accId);
                     }else{
                         helper.fetchEntitlements(component,res.AccountId);
                     }
                            
                 }
             }
         });
         $A.enqueueAction(action);

   },
    
    
    onClick: function(component,event,handler){
         var action = component.get("c.fetchsupportcase")
         var recordId =  component.get("v.recordId");
         
         action.setParams({
             "AccountName": component.get("v.Account"), 
             "ContactName": component.get("v.Contact"),
             "Subject":component.get("v.Subject"),
             "Description": component.get("v.Descr"),
             "Product": component.get("v.Product")
               
         });
         action.setCallback(this, function(response){
             var state = response.getState();
             if (state === "SUCCESS") {
                 //var res = response.getReturnvalue();
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                 dismissActionPanel.fire(); 
                 var resultsToast = $A.get("e.force:showToast");
                 resultsToast.setParams({ 
                     "title": "Save Success!",
                     "type" : "success",
                     "message": "A Support Case File  save successfully!"
                 });
                 resultsToast.fire();
                 $A.get("e.force:closeQuickAction").fire();
             }else{
                 var errorMsg = response.getError()[0];

                 component.set("v.errorMessage",errorMsg.message);
                 component.set("v.showError",true);
                 
             }
         });
    },
    
    

    onValueChange :function(component,event,helper){
        
        var selectedRec = event.getSource().getLocalId();
        var newCase = component.get("v.cObj");
        console.log('selected--'+selectedRec);
        var cmpValue = component.find(selectedRec).get("v.value");
        //var cmpLabel = component.find(selectedRec).get("v.text"); 
        console.log('My Value is--'+cmpValue);

        if(selectedRec == 'ProductVersion'){
            var showComponents =  component.find("showComponents");
            newCase.Versions__c = cmpValue;
            if(cmpValue != "None"){
                if(component.get("v.rComponents")!= ''){
                    $A.util.addClass(showComponents,"slds-show");
                    $A.util.removeClass(showComponents,"slds-hide");
                }else{
                    $A.util.addClass(showComponents,"slds-hide");
                    $A.util.removeClass(showComponents,"slds-show");
                }
                    $A.util.addClass(showSubComponent,"slds-hide");
                    $A.util.removeClass(showSubComponent,"slds-show");
                
            }else{
                //component.set("v.productVersions", null);
                //component.set("v.rComponents", null);
                component.find("Components").set("v.value","None")
                component.set("v.rSubComponents", null);
                var showSubComponent =  component.find("showSubComponent");
                $A.util.addClass(showComponents,"slds-hide");
                $A.util.removeClass(showComponents,"slds-show");
                $A.util.addClass(showSubComponent,"slds-hide");
                $A.util.removeClass(showSubComponent,"slds-show");
            }

        }else if(selectedRec == 'Components'){
            newCase.Component__c = cmpValue;
            if(cmpValue != "None"){
                helper.getSubComponents(component,cmpValue);
            }else{
                component.set("v.rSubComponents", null);
                newCase.Sub_Component__c = null;
                var showSubComponent =  component.find("showSubComponent");
                $A.util.addClass(showSubComponent,"slds-hide");
                $A.util.removeClass(showSubComponent,"slds-show");
            }
        }else if(selectedRec == 'subComponents'){
            newCase.Sub_Component__c = cmpValue;

        }
        if(selectedRec == 'environ'){
            newCase.Environment__c = cmpValue;
        }
        if(selectedRec == 'perform'){
            newCase.What_action_were_you_performing__c = cmpValue;
        }
        if(selectedRec == 'priority'){
            newCase.Priority = cmpValue; 
        }
        if(selectedRec == 'contactIds'){
            newCase.ContactId = cmpValue;
        }
    },
    createCase : function(component,event,helper){
		component.set("v.disableCaseBttn",true);
        
        console.log('create case button clicked');
        var newCase = component.get("v.cObj");
        console.log('create case button 1');
        var priority =  component.find("priority").get("v.value");
        console.log('create case button 2');
        console.log('create case button 4');

        var validatedData = helper.validateNewCase(component);
      	console.log("validateDate---->"+validatedData);
        if(validatedData != null){
            console.log("Error---");
            component.set("v.errorMessage",validatedData);
            component.set("v.showError",true);
            component.set("v.disableCaseBttn",false);

        }else{
           console.log("Ready to create case");
           component.set("v.showError",false);
           component.set("v.disableCaseBttn",true);

        var action = component.get("c.createRecord");

            if (newCase.Versions__c == 'NoData' || newCase.Versions__c == 'None'){
                newCase.Versions__c=null;
            }        

            if (newCase.Component__c == 'NoData' || newCase.Component__c == 'None'){
                newCase.Component__c=null;
            }        
            if (newCase.Sub_Component__c == 'NoData' || newCase.Sub_Component__c == 'None'){
                newCase.Sub_Component__c=null;
            }        


        action.setParams({
            'ca' : newCase
        });
        action.setCallback(this,function(a){
            var state = a.getState();
            if(state === "SUCCESS"){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/s/cases" 
                });
                urlEvent.fire();

                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({ 
                     "title": "Save Success!",
                     "type" : "success",
                     "message": "Case Created successfully!"
                 });
                 resultsToast.fire();
                 /*window.setTimeout(
                    $A.getCallback(function(){
                        //window.open('/s','_self');
                    }),2000

                 );*/
			}else if(state === "ERROR"){ 
                component.set("v.disableCaseBttn",false);
                component.set("v.errorMessage",action.getError()[0].message);
                component.set("v.showError",true);

            }

        });
        $A.enqueueAction(action);
      }
 
    },

    onChangeOfEntitlement: function (component, event, helper) {
        
        var selectedRec = component.find("entitleIds").get("v.value");
        var newCase = component.get("v.cObj");
        newCase.EntitlementId = selectedRec;
        var showVersion = component.find("showVersion");

        console.log('selected Entitlement :' + selectedRec);
        if (selectedRec != 'None') {
            var showComponents =  component.find("showComponents");
            $A.util.addClass(showComponents,"slds-hide");
            $A.util.removeClass(showComponents,"slds-show");
            var showSubComponent =  component.find("showSubComponent");
            $A.util.addClass(showSubComponent,"slds-hide");
            $A.util.removeClass(showSubComponent,"slds-show");

            component.set("v.productVersions", null);
            component.set("v.rComponents", null);
            component.set("v.rSubComponents", null);
            helper.fetchDependentValues(component, selectedRec);
        } else {

            $A.util.addClass(showVersion,"slds-hide");
            $A.util.removeClass(showVersion,"slds-show");
            var showComponents =  component.find("showComponents");
            $A.util.addClass(showComponents,"slds-hide");
            $A.util.removeClass(showComponents,"slds-show");
            var showSubComponent =  component.find("showSubComponent");
            $A.util.addClass(showSubComponent,"slds-hide");
            $A.util.removeClass(showSubComponent,"slds-show");
            component.set("v.productVersions", null);
            component.set("v.rComponents", null);
            component.set("v.rSubComponents", null);
            component.set("v.Product", null);
        }
    },

    cancelCase:function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/s/cases" 
            });
        urlEvent.fire();
    },

    onChangeOfAccount : function(component,event, helper){
        
        console.log('AccountChange');
        var selectedAcc = component.find("accountIds").get("v.value");
        var selectedAccount = component.get("v.selectedAccount");

        

        var usr = component.get("v.cUser");
        var newCase = component.get("v.cObj");
        var cAdmin = component.get("v.cAdmin");
        
        newCase.AccountId = selectedAcc
        newCase.EntitlementId = 'None';
        
        console.log('Selected AccountId :: '+selectedAcc);
        console.log('Selected selectedAccount :: '+selectedAccount);
        
        helper.sendSafetySetup(component,selectedAcc); 
        if(usr.Profile.Name == cAdmin){
           helper.fetchContacts(component,selectedAcc,usr);
        }else{
           component.set("v.contacts",usr.Contact);
           newCase.ContactId = usr.ContactId;
        }
        var origin = component.get("v.origin");
        if(origin =='caseTab'){
            console.log('Am i called');
            helper.fetchEntitlements(component,selectedAcc);
        }
        
    }
    ,
    caseCreateFieldChange : function(component, event, helper){
        var expression = event.getParam("expression");
        var val = event.getParam("value");
        
        if(expression != 'v.cObj' && val.length>3){
            var appEvent = $A.get("e.selfService:caseCreateFieldChange");
        
            console.log(expression.replace('v.cObj.', ''));   
            console.log(val);

            appEvent.setParams({
            "modifiedField": expression.replace('v.cObj.', ''),
            "modifiedFieldValue": val
        	});

        	appEvent.fire();
        }
        
    } 
})