public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    public OpportunityTriggerHandler() {}

    /* Context Overrides */
    protected override void beforeInsert() {
        updateFiscalYear();
        updateFirstProductDateOnAccount();
        updateNextStepLastUpdate();
    }

    protected override void beforeUpdate() {
        updateFiscalYear();
        updateFirstProductDateOnAccount();
        updateNextStepLastUpdate();
    }

    protected override void afterUpdate(){
        calculateMasterOpportunityFields();
    }

    private void updateNextStepLastUpdate() {

            for (Opportunity opp : (List<Opportunity>) Trigger.new) {
                if (Trigger.isBefore &&  Trigger.isInsert && opp.Next_Action_involving_CSO_org_PA_CNS__c != null){
                    opp.Next_Steps_Last_Update__c = System.Today();
                }
                else if(Trigger.isBefore &&  Trigger.isUpdate ){
                    Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
                    if (opp.Next_Action_involving_CSO_org_PA_CNS__c != oldOpp.Next_Action_involving_CSO_org_PA_CNS__c) {
                        opp.Next_Steps_Last_Update__c = System.Today();
                    }
                }        
            }
    }


    private void calculateMasterOpportunityFields(){
        Set<Id> toCalculateIds = new Set<Id>(); //master opportunities that needs recalculate fields
        for (Opportunity opportunity : (List<Opportunity>) Trigger.new) {
            Opportunity oldOpportunity = (Opportunity) Trigger.oldMap.get(opportunity.Id);
            //we really only need to update if related fields have changes
            Boolean isChange = opportunity.Amount != oldOpportunity.Amount ||
                            opportunity.Total_App_Tx__c != oldOpportunity.Total_App_Tx__c ||
                            opportunity.Total_Pivotal_Labs__c != oldOpportunity.Total_Pivotal_Labs__c ||
                            opportunity.Total_PaaS_Services__c != oldOpportunity.Total_PaaS_Services__c ||
                            opportunity.Scoping_Scheduled__c != oldOpportunity.Scoping_Scheduled__c ||
                            opportunity.AppTx_Scoping_Scheduled__c != oldOpportunity.AppTx_Scoping_Scheduled__c ||
                            opportunity.AppTx_Scoping_Delivered_to_Customer__c != oldOpportunity.AppTx_Scoping_Delivered_to_Customer__c ||
                            opportunity.PCFS_Scoping_Scheduled_Date__c != oldOpportunity.PCFS_Scoping_Scheduled_Date__c ||
                            opportunity.PCFS_Scoping_Delivered_to_Customer__c != oldOpportunity.PCFS_Scoping_Delivered_to_Customer__c ||
                            opportunity.Total_All_Services__c != oldOpportunity.Total_All_Services__c ||
                            opportunity.Data_Scoping_Complete__c != oldOpportunity.Data_Scoping_Complete__c ||
                            opportunity.Labs_Scoping_Complete__c != oldOpportunity.Labs_Scoping_Complete__c ||
                            opportunity.Master_Opportunity_Subscription__c != oldOpportunity.Master_Opportunity_Subscription__c;

            if (opportunity.Master_Opportunity_Subscription__c != null && isChange) {
                toCalculateIds.add(opportunity.Master_Opportunity_Subscription__c);
            }
        }
        if(toCalculateIds.size() == 0) return ;

        List<Opportunity> masterOpportunities = [
                SELECT Id, (
                        SELECT Id, Master_Opportunity_Subscription__c, RecordType.Name,
                                Amount,
                                Total_App_Tx__c,//Total: App Tx
                                Total_Pivotal_Labs__c,//Total: Labs
                                Total_PaaS_Services__c,//Total: PCF Services
                                Scoping_Scheduled__c,//Labs Scoping Scheduled
                                AppTx_Scoping_Scheduled__c, //AppTx Scoping Scheduled
                                AppTx_Scoping_Delivered_to_Customer__c, //AppTx SOW Delivered to Customer
                                PCFS_Scoping_Scheduled_Date__c, //PCFS Scoping Scheduled Date
                                PCFS_Scoping_Delivered_to_Customer__c, //PCFS SOW Delivered to Customer
                                Total_All_Services__c,
                                Data_Scoping_Complete__c,
                                Labs_Scoping_Complete__c
                        FROM Services_Opportunities__r
                )
                FROM Opportunity
                WHERE Id
                IN :toCalculateIds
        ];

        //clear master opp. Prepare for new calculations
        for (Opportunity opportunity: masterOpportunities) {
            opportunity.Linked_Service_Opportunity_Total__c = 0;
            opportunity.Linked_Subscription_Opportunity_Total__c = 0;
            opportunity.Linked_AppTX_Services_Opportunity_Total__c = 0;
            opportunity.Linked_Labs_Services_Opportunity_Total__c = 0;
            opportunity.Linked_PCF_Services_Opportunity_Total__c = 0;
            opportunity.Linked_All_Services_Opportunity_Total__c = 0;
            opportunity.Linked_Labs_Scoping_Scheduled__c = false;
            opportunity.Linked_AppTX_Scoping_Scheduled__c = false;
            opportunity.Linked_AppTx_SOW_Delivered_to_Customer__c = false;
            opportunity.Linked_PCFS_Scoping_Scheduled_Date__c = false;
            opportunity.Linked_PCFS_SOW_Delivered_to_Customer__c = false;
            opportunity.Linked_Labs_Scoping_Complete__c = false;
            opportunity.Linked_Data_Scoping_Complete__c = false;
        }

        //calculate new values
        for (Opportunity master :  masterOpportunities) {
            for (Opportunity opportunity : master.Services_Opportunities__r) {
                if (opportunity.RecordType.Name == 'Services') {
                    master.Linked_Service_Opportunity_Total__c += opportunity.Amount;
                    //
                    master.Linked_Labs_Scoping_Scheduled__c |= opportunity.Scoping_Scheduled__c != null;
                    master.Linked_AppTX_Scoping_Scheduled__c |= opportunity.AppTx_Scoping_Scheduled__c != null;
                    master.Linked_AppTx_SOW_Delivered_to_Customer__c |= opportunity.AppTx_Scoping_Delivered_to_Customer__c;
                    master.Linked_PCFS_Scoping_Scheduled_Date__c |= opportunity.PCFS_Scoping_Scheduled_Date__c != null;
                    master.Linked_PCFS_SOW_Delivered_to_Customer__c |= opportunity.PCFS_Scoping_Delivered_to_Customer__c;
                    //
                } else if (opportunity.RecordType.Name == 'Subscription') {
                    master.Linked_Subscription_Opportunity_Total__c += opportunity.Amount;
                }
                master.Linked_PCF_Services_Opportunity_Total__c += opportunity.Total_PaaS_Services__c;
                master.Linked_Labs_Services_Opportunity_Total__c += opportunity.Total_Pivotal_Labs__c;
                master.Linked_AppTX_Services_Opportunity_Total__c += opportunity.Total_App_Tx__c;
                master.Linked_All_Services_Opportunity_Total__c += opportunity.Total_All_Services__c;
                master.Linked_Data_Scoping_Complete__c |= opportunity.Data_Scoping_Complete__c;
                master.Linked_Labs_Scoping_Complete__c |= opportunity.Labs_Scoping_Complete__c;
            }
            if(master.Linked_Service_Opportunity_Total__c + master.Linked_Subscription_Opportunity_Total__c != 0){
                master.Services_Percentage_Of_Total_Deal__c = master.Linked_Service_Opportunity_Total__c/(master.Linked_Service_Opportunity_Total__c + master.Linked_Subscription_Opportunity_Total__c) * 100.0;
            }
        }

        update masterOpportunities;
    }

    /* Private Methods */
    private void updateFiscalYear() {

        List<Opportunity> oppList = new List<Opportunity>();
         list<date> closeDateList = new list<date>();

        for (Opportunity opp : (List<Opportunity>) Trigger.new) {
            if (Trigger.isBefore &&  Trigger.isInsert && opp.CloseDate != null){
                oppList.add(opp);
                closeDateList.add(opp.CloseDate);
            }
            else if(Trigger.isBefore &&  Trigger.isUpdate ){
                Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
                if (opp.CloseDate != null && opp.CloseDate != oldOpp.CloseDate) {
                    oppList.add(opp);
                    closeDateList.add(opp.CloseDate);
                }
            }        
        }
        
        // get all the periods  
        if (oppList.size()>0) {
                //list<period> periodYearList = [SELECT FiscalYearSettings.Name, StartDate, EndDate, type FROM Period WHERE Type = 'Year' order by StartDate desc limit 300];
                list<string> periodTypeList = new list<string>{'Year','Week','Quarter'};
                List<period> periodYearList =  getPeriodList(closeDateList, periodTypeList);

                //Get Records from period.
                map<Date, Period> yearPeriodMap = getPeriodMap( closeDateList, periodYearList, 'Year');
                map<Date, Period> quarterPeriodMap = getPeriodMap( closeDateList, periodYearList, 'Quarter');
                map<Date, Period> weekPeriodMap = getPeriodMap( closeDateList, periodYearList, 'Week');

                for (Opportunity opp : oppList) {
                    
                    // find period record for the close date.
                    if (Trigger.isBefore &&  Trigger.isInsert && opp.CloseDate != null){
                        opp = setPeriod( opp, yearPeriodMap, quarterPeriodMap,weekPeriodMap );
                    }
                    else if(Trigger.isBefore &&  Trigger.isUpdate ){
                        Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
                        if (opp.CloseDate != null && opp.CloseDate != oldOpp.CloseDate) {
                            opp = setPeriod( opp, yearPeriodMap, quarterPeriodMap,weekPeriodMap );

                        }
                    }
                    
                }
             
         }     
    }

    // Get period list
    private list<period> getPeriodList(list<date> dateList, list<string> periodTypeList){
                dateList.sort();
                date startDate =dateList[0];
                date endDate =dateList[dateList.size()-1];
                list<period> periodList = [SELECT FiscalYearSettings.Name, StartDate, EndDate, type, Number FROM Period WHERE StartDate <=:endDate AND EndDate>=:startdate AND Type IN:periodTypeList order by StartDate desc limit 600];
        return    periodList;             
    }

    // Get period map by period type in the date range.
    public static  map<Date, Period> getPeriodMap(list<date> dateList, list<period> period, string typeName){
        map<Date, period> dateIdMap = new  map<Date, period>();
        for(date dt : dateList){
            for(period p : period){
                    if ( dt >= p.StartDate  &&  dt <= p.EndDate && p.Type == typeName ){
                        dateIdMap.put(dt, p);
                        break;
                    }
            }
        }
        return dateIdMap;
    }

    // Set fiscal data fields using periold object.
    private Opportunity setPeriod(Opportunity opp, map<Date, Period> yearPeriodMap, map<Date, Period> quarterPeriodMap, map<Date, Period> weekPeriodMap ) 
    {   

        if (yearPeriodMap.containskey(opp.CloseDate)){
            Period yearPeriod = yearPeriodMap.get(opp.CloseDate);
            opp.Fiscal_Year__c = yearperiod.FiscalYearSettings.Name;
            opp.Fiscal_Year_Start_Date__c  = yearperiod.StartDate;
        }

        if (quarterPeriodMap.containskey(opp.CloseDate))   { 
            opp.Week_of_the_Quarter_Value__c = quarterPeriodMap.get(opp.CloseDate).Number;
            opp.Fiscal_Quarter_Start_Date__c = quarterPeriodMap.get(opp.CloseDate).StartDate;
        }

        if (weekPeriodMap.containskey(opp.CloseDate)){
            opp.Week_Year_value__c = weekPeriodMap.get(opp.CloseDate).Number;
        }    

        return opp;        
    }

    // used  setPeriod instead of this.
    /*
    private Opportunity setFiscalPeriod(Opportunity opp, Period yearperiod)
    {   
        
        if (yearperiod != null){
            opp.Fiscal_Year__c = yearperiod.FiscalYearSettings.Name;
            opp.Fiscal_Year_Start_Date__c  = yearperiod.StartDate;
        }    
                
                /*
                if (opp.CloseDate.year() <= 2016) {
                    opp.Fiscal_Year__c = String.valueof(opp.CloseDate.year());
                }
                else if (opp.CloseDate >= date.newInstance(opp.CloseDate.year(), 2, 1).adddays(7) - math.mod(date.newInstance(1900, 1, 6).daysBetween(date.newInstance(opp.CloseDate.year(), 2, 1)), 7)) {
                    opp.Fiscal_Year__c = String.valueof(Integer.valueof(opp.CloseDate.year() + 1));
                }
                else {
                    opp.Fiscal_Year__c = String.valueof(opp.CloseDate.year());
                }
                    opp.Fiscal_Year_Start_Date__c = date.newInstance(Integer.valueof(opp.Fiscal_Year__c) - 1, 2, 1).adddays(7) - math.mod(date.newInstance(1900, 1, 6).daysBetween(date.newInstance(Integer.valueof(opp.Fiscal_Year__c) - 1, 2, 1)), 7);
                */
    /*    
        return opp;        
    }
    */
    
    /*
    private Period findYearPeriodRecordByDate(List<Period> PeriodList, Date datevalue)
    {
        period yearPeriod = new period();
        
        for (period p :PeriodList){
            if ( datevalue >= p.StartDate  &&  datevalue <= p.EndDate){
                yearPeriod = p;   
                break;
            }
            
        }
        
        return yearPeriod;
    }
    */
    
    private void updateFirstProductDateOnAccount() {
        List<Id> accIds = new List<Id>();
        List<Opportunity> bookedOppList = new List<Opportunity>();

        for (Opportunity opp : (List<Opportunity>) Trigger.new) {
            if (opp.StageName == 'Booked') {
                accIds.add(opp.AccountId);
                bookedOppList.add(opp);
            }
        }

        if (bookedOppList.size() > 0) {
            Map<Id, Account> originalAccountValues = setupAccountMap(accIds);
            Map<Id, Account> updatedAccountValues = originalAccountValues.deepClone();

            for (Opportunity opp : bookedOppList) {
                updateAccountPCFDate(opp, updatedAccountValues);
                updateAccountDataProductDate(opp, updatedAccountValues);
                updateAccountLabsDate(opp, updatedAccountValues);
            }

            Map<Id, Account> accountsToUpdate = generateMapOfAccountsToUpdate(originalAccountValues, updatedAccountValues);

            if (accountsToUpdate.size() > 0) {
                for (Account childAcc : accountsToUpdate.values()) {
                    if(childAcc.ParentId != null) {
                        Account parentAcc = new Account(Id = childAcc.ParentId,
                                                            First_purchase_Date_PCF__c = childAcc.Parent.First_purchase_Date_PCF__c,
                                                            First_Purchase_Date_Data_Products__c = childAcc.Parent.First_Purchase_Date_Data_Products__c,
                                                            First_Purchase_Date_Labs__c = childAcc.Parent.First_Purchase_Date_Labs__c);

                        updateParentAccountPCFDate(childAcc, parentAcc, accountsToUpdate);
                        updateParentAccountDataProductDate(childAcc, parentAcc, accountsToUpdate);
                        updateParentAccountLabsDate(childAcc, parentAcc, accountsToUpdate);
                    }
                }

                update accountsToUpdate.values();
            }
        }
    }

    private Map<Id, Account> setupAccountMap(List<Id> accIds) {
        return new Map<Id, Account>([
                SELECT Id,
                        First_Purchase_Date_Data_Products__c,
                        First_Purchase_Date_Labs__c,
                        First_purchase_Date_PCF__c,
                        ParentId,
                        Parent.First_Purchase_Date_Data_Products__c,
                        Parent.First_Purchase_Date_Labs__c,
                        Parent.First_Purchase_Date_PCF__c
                FROM Account
                WHERE Id IN :accIds
        ]);
    }

    private void updateAccountPCFDate(Opportunity opp, Map<Id, Account> updatedAccountValues) {
        /* Update the Account Cloud Foundry Date if:
        *  The Opportunity has a Cloud Foundry Product
        *  AND
        *  The Opportunity Close Date is lower than the current Cloud Foundry Date
        */
        if (opp.Total_Pivotal_CF_Product__c > 0 && (updatedAccountValues.get(opp.AccountId).First_Purchase_Date_PCF__c == null || updatedAccountValues.get(opp.AccountId).First_Purchase_Date_PCF__c > opp.CloseDate)) {
            updatedAccountValues.get(opp.AccountId).First_Purchase_Date_PCF__c = opp.CloseDate;
        }
    }

    private void updateParentAccountPCFDate(Account childAcc, Account parentAcc, Map<Id, Account> accountsToUpdate) {
        /* Update the Parent Account Cloud Foundry Date if:
        *  The Parent doesn't have a Date yet or it's greater than the Child Date
        *  Also check dates with existing accounts on the accountsToUpdate list
        */
        if ((parentAcc.First_purchase_Date_PCF__c == null && childAcc.First_purchase_Date_PCF__c != null) || parentAcc.First_purchase_Date_PCF__c > childAcc.First_purchase_Date_PCF__c) {
            parentAcc.First_purchase_Date_PCF__c = childAcc.First_purchase_Date_PCF__c;

            if(accountsToUpdate.get(parentAcc.Id) == null) {
                accountsToUpdate.put(parentAcc.Id, parentAcc);
            } else if(accountsToUpdate.get(parentAcc.Id).First_purchase_Date_PCF__c == null || accountsToUpdate.get(parentAcc.Id).First_purchase_Date_PCF__c > parentAcc.First_purchase_Date_PCF__c) {
                accountsToUpdate.get(parentAcc.Id).First_purchase_Date_PCF__c = parentAcc.First_purchase_Date_PCF__c;
            }
        }
    }

    private void updateAccountDataProductDate(Opportunity opp, Map<Id, Account> updatedAccountValues) {
        /* Update the Account Data Product Date if:
        *  The Opportunity has a Data Product
        *  AND
        *  The Opportunity Close Date is lower than the current Data Product Date
        */
        if (opp.Total_Data_Product__c > 0 && (updatedAccountValues.get(opp.AccountId).First_Purchase_Date_Data_Products__c == null || updatedAccountValues.get(opp.AccountId).First_Purchase_Date_Data_Products__c > opp.CloseDate)) {
            updatedAccountValues.get(opp.AccountId).First_Purchase_Date_Data_Products__c = opp.CloseDate;
        }
    }

    private void updateParentAccountDataProductDate(Account childAcc, Account parentAcc, Map<Id, Account> accountsToUpdate) {
        /* Update the Parent Account Data Product Date if:
        *  The Parent doesn't have a Date yet or it's greater than the Child Date
        *  Also check dates with existing accounts on the accountsToUpdate list
        */
        if (parentAcc.First_Purchase_Date_Data_Products__c == null || parentAcc.First_Purchase_Date_Data_Products__c > childAcc.First_Purchase_Date_Data_Products__c) {
            parentAcc.First_Purchase_Date_Data_Products__c = childAcc.First_Purchase_Date_Data_Products__c;

            if(accountsToUpdate.get(parentAcc.Id) == null) {
                accountsToUpdate.put(parentAcc.Id, parentAcc);
            } else if(accountsToUpdate.get(parentAcc.Id).First_Purchase_Date_Data_Products__c == null || accountsToUpdate.get(parentAcc.Id).First_Purchase_Date_Data_Products__c > parentAcc.First_Purchase_Date_Data_Products__c) {
                accountsToUpdate.get(parentAcc.Id).First_Purchase_Date_Data_Products__c = parentAcc.First_Purchase_Date_Data_Products__c;
            }
        }
    }

    private void updateAccountLabsDate(Opportunity opp, Map<Id, Account> updatedAccountValues) {
        /* Update the Account Labs Date if:
        *  The Opportunity has a Labs Product
        *  AND
        *  The Opportunity Close Date is lower than the current Labs Date
        */
        if (opp.Total_Pivotal_Labs__c > 0 && (updatedAccountValues.get(opp.AccountId).First_Purchase_Date_Labs__c == null || updatedAccountValues.get(opp.AccountId).First_Purchase_Date_Labs__c > opp.CloseDate)) {
            updatedAccountValues.get(opp.AccountId).First_Purchase_Date_Labs__c = opp.CloseDate;
        }
    }

    private void updateParentAccountLabsDate(Account childAcc, Account parentAcc, Map<Id, Account> accountsToUpdate) {
        /* Update the Parent Account Labs Date if:
        *  The Parent doesn't have a Date yet or it's greater than the Child Date
        *  Also check dates with existing accounts on the accountsToUpdate list
        */
        if (parentAcc.First_Purchase_Date_Labs__c == null || parentAcc.First_Purchase_Date_Labs__c > childAcc.First_Purchase_Date_Labs__c) {
            parentAcc.First_Purchase_Date_Labs__c = childAcc.First_Purchase_Date_Labs__c;

            if(accountsToUpdate.get(parentAcc.Id) == null) {
                accountsToUpdate.put(parentAcc.Id, parentAcc);
            } else if(accountsToUpdate.get(parentAcc.Id).First_Purchase_Date_Labs__c == null || accountsToUpdate.get(parentAcc.Id).First_Purchase_Date_Labs__c > parentAcc.First_Purchase_Date_Labs__c) {
                accountsToUpdate.get(parentAcc.Id).First_Purchase_Date_Labs__c = parentAcc.First_Purchase_Date_Labs__c;
            }
        }
    }

    private Map<Id, Account> generateMapOfAccountsToUpdate(Map<Id, Account> originalAccountValues, Map<Id, Account> updatedAccountValues) {
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (Account acc : updatedAccountValues.values()) {
            if(originalAccountValues.get(acc.Id).First_Purchase_Date_PCF__c != acc.First_purchase_Date_PCF__c ||
                    originalAccountValues.get(acc.Id).First_Purchase_Date_Data_Products__c != acc.First_Purchase_Date_Data_Products__c ||
                    originalAccountValues.get(acc.Id).First_Purchase_Date_Labs__c != acc.First_Purchase_Date_Labs__c
                    ) {

                accountsToUpdate.put(acc.Id, acc);
            }
        }
        return accountsToUpdate;
    }
}