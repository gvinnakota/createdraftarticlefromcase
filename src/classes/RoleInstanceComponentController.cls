public class RoleInstanceComponentController{
    public final zqu__QuoteRatePlanCharge__c quoteRatePlanCharge {get; set;}
    public Boolean editMode {get; set;}
    public Id instanceIdEdit {get; set;}

    public List<Role_Instance__c> instances{get; private set;}

    public RoleInstanceComponentController(ApexPages.StandardController controller){
        quoteRatePlanCharge = (zqu__QuoteRatePlanCharge__c)controller.getRecord();
        editMode = true;
        instances = [
                SELECT Name, Role_Quantity__c, Hourly_rate__c, Hours_Per_Role__c, Total_Hours__c
                FROM Role_Instance__c
                WHERE Quote_Rate_Plan_Charge__c = :quoteRatePlanCharge.Id
        ];
    }

    public PageReference saveAndCalculate(){
        System.debug('RoleInstanceComponentController::saveAndCalculate instances: ' + instances);
//        editMode = false;
        update instances;
        return null;
    }

    public PageReference editRow() {
        System.debug('RoleInstanceComponentController::editRow instanceIdEdit: ' +instanceIdEdit);
        editMode = true;
        return null;
    }

    public Id getQRPCId() {
        return quoteRatePlanCharge.Id;
    }

    public Boolean getIsCustomCharge() {
        return RoleHelper.isAddingRoleAvailable(quoteRatePlanCharge);
    }

    public boolean displayPopup {get; set;}

    public void closePopup() {
        displayPopup = false;
    }
    public void showPopup() {
        displayPopup = true;
    }

    public Boolean getRenderPage() {
        return !instances.isEmpty() || getIsCustomCharge();
    }
}