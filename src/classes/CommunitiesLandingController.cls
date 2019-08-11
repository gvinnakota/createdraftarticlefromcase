/**
* An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    /* public PageReference forwardToStartPage() {
    	return Network.communitiesLanding();
    }
    
    */
    
    // Adding code for testing purpose
    
    public PageReference forwardToStartPage(){
        String communityUrl = Label.CommunityUrl;
        String customHomePage = Label.customHomePageForCommunity;
        System.debug('Community URL: ' + communityUrl + customHomePage);
        return new PageReference(communityUrl + '?startURL=' + EncodingUtil.urlEncode(customHomePage, 'UTF-8'));        
    }   
    public CommunitiesLandingController() {}
}