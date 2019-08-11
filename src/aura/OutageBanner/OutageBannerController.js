////////////
//This simply checks the users date compared to when we want to show/not show the banner
//All dates are in UTC so you will need to convert the start/end dates to be in UTC
//
//May 2019 - Created by Shane
////////////
({
    boolCheckDate: function(component) {
        
        var d = new Date();  //this is todays date
        //format of date Date(Year, Month - 0 indexed, Date, Hr, Min, Sec);
        var banner_end = new Date(Date.UTC(2019,5,31,18,59,0));  //date and time the banner will no longer be seen
        var banner_start = new Date(Date.UTC(2019,5,4,18,53,0));  //date and time the banner will start to be seen
        //working with epochs which are based on UTC
        if (d.getTime() <= banner_end.getTime() && d.getTime() >= banner_start.getTime()) { 
            component.set("v.showBanner", true);
        }else {
                component.set("v.showBanner", false);
        }
    }
})