/*******************************************************************************************************************
* Apex Class Name  : CheckRecursive
* Test Class Name  : ChechRecursive_Test
* Version          : 1.0
* Function         : Class is used stop recursive calls
* Modification Log :
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Ranjithkumar Udhaya        05/09/2017              Intial version (Used to stop recursive call)
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public Class CheckRecursive{
    public static boolean checkContact = true;
    public static boolean checkUser = true;
    //Used to execute on Contact Trigger
    public static boolean runContactTrigger(){
        if(checkContact){
            checkContact=false;
            return true;
        }else{
            return checkContact;
        }
    }
    
    //Used to execute on User Trigger
    public static boolean runUserTrigger(){
        if(checkUser){
            checkUser=false;
            return true;
        }else{
            return checkUser;
        }
    }
}