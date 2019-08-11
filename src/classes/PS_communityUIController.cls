/*******************************************************************************************************************
* Apex Class Name  : PS_communityUIController
* Test Class Name  : PS_communityUIController_TC
* Version          : 1.0
* Function         : Class is used for Community UI
* Modification Log :
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Hemavathi NM                     10/06/2017              Intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public with sharing class PS_communityUIController{
    @AuraEnabled
    //Used to update Menu List in Community
    Public static List<Community_MenuItems__mdt> getMenuList()
    {
         String profileId = String.valueOf(userInfo.getProfileId()).SubString(0,15);
         list<Community_MenuItems__mdt> menuItemL = new List<Community_MenuItems__mdt>();
         for(Community_MenuItems__mdt menu: [select DeveloperName,Id,Menu_Label__c,URL__c,Object_Name__c,VisibleTo__c,Sequence_Number__c from Community_MenuItems__mdt order by Sequence_Number__c LIMIT 1000]){
              if(menu.VisibleTo__c !=null&& menu.VisibleTo__c.contains(profileId)){menuItemL.add(menu);}     
          }
          return menuItemL;
       }
}