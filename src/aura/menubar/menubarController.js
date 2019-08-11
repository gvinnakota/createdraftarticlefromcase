({
    doInit : function(component, event, helper) {
        helper.getMenuList(component);
    },
    tabclick : function(component, event) {
        var elems = document.getElementsByClassName('active');          
        for (var i=elems.length-1;i>=0;i=i-1) {
            var elem=elems[i];
            elem.className="menuitem";
        }
        var eleID = event.currentTarget.id; 
        var divToClose =document.getElementById(eleID);
        divToClose.classList.toggle('active'); 
    },
   
})