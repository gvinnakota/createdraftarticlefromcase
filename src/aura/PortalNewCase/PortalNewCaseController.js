({ 
    doInit : function(com,event,helper){
        console.log("doinit");
        const values = [
            $A.get("$Label.c.Product_Support"),
            $A.get("$Label.c.Non_Product_Support")
        ];
        com.set("v.rtypes",values);
        console.log(com.get("v.rtypes"));
    },
     
    saveRecord : function(component,event,helper){
        console.log('Save Record');
        var newCase = component.get("v.ca");
        console.log('newCase===>'+newCase);
        var rtype = component.get("v.rtype");
        newCase.RecordTypeId = component.get("v.rtype");
        var validate = component.find("child");
        console.log('validate ::'+validate);
        var validatedData;
          console.log("rtype---->"+rtype);
        if(rtype==$A.get("$Label.c.Product_Support")){
            validatedData = validate.validateTechCase(newCase);
      	}
        if(rtype==$A.get("$Label.c.Non_Product_Support")){
            validatedData = validate.validateNonTechCase(newCase);
      	 }
        console.log("validateDate---->"+validatedData);
        if(validatedData != null){
            console.log("Error---");
            component.set("v.errorMessage",validatedData);
            component.set("v.showError",true);
            component.set("v.proceed",false);
            component.set("v.oWindow",true);
        }else{
           console.log("Ready to create case");
           component.set("v.showError",false);
             component.set("v.disablesubmit",true);
           //component.set("v.oWindow",false); 
           helper.createCaseHandler(component,newCase);
        }
    },
   
    modalWindow : function(component,event,helper){
		component.set("v.ca",{'sobjectType':'case',
                              'Subject':''});
        console.log('Am i called'+component.get("v.rtype"));
        helper.getCurrentUser(component);        
        component.set("v.errorMessage",'');
        component.set("v.showError",false);

    },
    openModal : function(component,event,helper){
        var usr = component.get("v.cUser");
        var rtype=component.get("v.rtype");
        component.set("v.oWindow", true);
        component.set("v.isWindowOpen",false);
        component.set("v.proceed",false);
        component.set("v.disablesubmit",false);
     },
    closeModal : function(component,event,helper){
        component.set("v.proceed",false);
        component.set("v.isWindowOpen", false);
        component.set("v.oWindow", false);  
        component.set("v.disablesubmit",false);
        window.location.reload();    
    },
    cancelRecord : function(component,event,helper){
        component.set("v.oWindow",false);
        component.set("v.isWindowOpen",false);
        component.set("v.proceed",false);
        component.set("v.disablesubmit",false);
        window.location.reload();
    },
    rTypeChange : function(component, event, helper) {
        var selected = event.getSource().get("v.label");
		component.set("v.rtype", selected);
        component.set("v.proceed",true);
		console.log(selected);
	},
      
    applyStyle : function(component,event){
        var cmpTarget = component.find("modalContainer");
    	$A.util.addClass(cmpTarget, 'changeMe');

	},
    })