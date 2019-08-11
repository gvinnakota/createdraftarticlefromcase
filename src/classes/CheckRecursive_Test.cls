@isTest
public class CheckRecursive_Test {
    public static boolean checkContact = true;
    public static boolean checkUser = true;
    public static testMethod void RecursionMethod(){
        checkRecursive.runContactTrigger();
        checkRecursive.runUserTrigger();        
        checkContact = false;
        checkUser = false;
        checkRecursive.runContactTrigger();
        checkRecursive.runUserTrigger();
        
    }
}