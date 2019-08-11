if(!window.jQuery){
	var script = document.createElement('script');
	script.type = "text/javascript";
	script.src = "https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js";
	var sheet = document.createElement('style');
	//sheet.innerHTML = ".bRelatedList .listRelatedObject.opportunityLineItemBlock .actionColumn {display: none;}";
	document.body.appendChild(sheet);
	 if (script.readyState) { //IE
            script.onreadystatechange = function () {
                if (script.readyState == "loaded" || script.readyState == "complete") {
                    script.onreadystatechange = null;
                    jqueryLoaded();
                }
            };
    } else {
		script.onload = function() { jqueryLoaded() };
	}
	document.getElementsByTagName('head')[0].appendChild(script);
 } else {
	jqueryLoaded();
 }

 var trac_jQuery;
 var componentList;
 
 function jqueryLoaded(){
	trac_jQuery = jQuery.noConflict();
	trac_jQuery( document ).ready(function() {
		var pageType = trac_jQuery('h1.pageType').text();
		componentList= ['trac_InjectionBox'];
		trac_hideSidebarComponent(componentList);
		if(pageType.indexOf("Opportunity") > -1){
			trac_jQuery('.listRelatedObject.opportunityLineItemBlock input[name="addProd"]').attr('value', 'Add Product(s)');
			trac_jQuery('.listRelatedObject.opportunityLineItemBlock input[name="editProd"]').attr('value', 'Edit Product(s)');
			var relList = trac_jQuery('.bRelatedList');
			relList.bind("DOMSubtreeModified", function(){
				trac_jQuery('.listRelatedObject.opportunityLineItemBlock input[name="addProd"]').attr('value', 'Add Product(s)');
				trac_jQuery('.listRelatedObject.opportunityLineItemBlock input[name="editProd"]').attr('value', 'Edit Product(s)');
			});
		}
	} );
 }
 
 /*
@author Thomas Tran, Traction on Demand
@description Hide the sidebar component from showing.
*/
function trac_hideSidebarComponent(componentsName){
//Add All the name of the components that you want to hide.
var hideComponentArray = componentsName;
   trac_jQuery("h2.brandPrimaryFgr").each(function(){
      if(trac_jQuery.inArray(jQuery(this).text(), hideComponentArray) != -1){
         //Hiding the entire div.
         trac_jQuery(this).parent("div.sidebarModuleHeader").parent("div.linksModule").hide();
      }
    });
 
}